function TDT2Matlab_awake(blockIndex)
% %TDT2Matlab_awake(blockIndex) %%

% Imports TDT signal to matlab can from blockIndex
% params.redo=1 % Reloads block that have already been extracted
% params.EvIDs contains IDs to import
% params.chans contains channels to import
% params.resampleFs=24414.06250



% EvID, sampleRate, resampleRate
params.EvIDs = {...
    {'SU_2', 24414.0625, 24414.0625}, ...
    {'SU_3', 24414.0625, 24414.0625}, ...
    {'SU_4', 24414.0625, 24414.0625}, ...
    {'BB_2', 24414.0625, 24414.0625}, ...
    {'BB_3', 24414.0625, 24414.0625}, ...
    {'BB_4', 24414.0625, 24414.0625}, ...
    {'dBug', 6103.515625, 6103.515625}, ...
    {'Lspk', 762.939254, 762.939254}, ... 
    {'rSpk', 762.939254, 762.939254}, ...
    {'aLED', 762.939254, 762.939254}, ...
    };

params.RecIDs = {...
    {'SU_2', 24414.0625, 24414.0625}, ...
    {'SU_3', 24414.0625, 24414.0625}, ...
    {'SU_4', 24414.0625, 24414.0625}, ...
    {'BB_2', 24414.0625, 24414.0625}, ...
    {'BB_3', 24414.0625, 24414.0625}, ...
    {'BB_4', 24414.0625, 24414.0625}, ...
    };

params.redo=0;
params.chans=1:32;

for i=1:height(blockIndex)
    disp(['Importing block ' num2str(i), '/', num2str(height(blockIndex))]);
    clear data bd
    tic
    % Only procede with block if .mat doesn't exist, or set to redo
    if (blockIndex.Available(i)==1 & blockIndex.BlocksAvailable(i) == 0 || ...
            params.redo==1) ...
            && blockIndex.Complete(i)==1;
        
        b=blockIndex.BlockNumber(i);      
        bNum = blockIndex.BlockName(b);

        
        %% Load matlab file
        path = blockIndex.MatDataPath{b};
        try
             bdata = importdata(path);
            loadOK=1;
        catch
            disp(['Failed to load mat file for block ', num2str(b)])
            loadOK=0;
        end
        
        stimTimes = bdata.data(:,3);
        stimLib.order   = bdata.data(:,12);
        %% Load tank data
        bTank = blockIndex.BlockPath{b};
        paramsImp.blocks=bNum; % Name not num
        for ch=1:16
            for eV = 1:length(params.EvIDs)
                
                % Get ID
                paramsImp.EvID = params.EvIDs{eV};
                
                % Create blank variable to fill
                eval([paramsImp.EvID{1}, '=[];']);
                % saveList{eV,1} = paramsImp.EvID{1};
                
                % Set defaults
                paramsImp.chans=params.chans;
                paramsImp.resampleFs=params.EvIDs{eV}{3};
                paramsImp.fRec=params.EvIDs{eV}{2};
                paramsImp.tank=bTank;
                
                disp(params.EvIDs{eV})
                
                bd = importTankInternal(paramsImp,ch); %#ok<NASGU>
                eval(['data.', paramsImp.EvID{1}, '=bd.Block', ';']);
                
                clear bd
            end
            
            % Save matlab and data file
            ff=blockIndex.BlocksPath{i};
            
            if ch<10
                filename = [ ff(:,1:end-10), '_ch_0', num2str(ch),'.mat'];
            else
                filename = [ ff(:,1:end-10), '_ch_', num2str(ch),'.mat'];
            end

            data.path=path;
            % data.blockIndex=blockIndex;
            if loadOK==1
%                 data.fStim=fStim;
%                 data.fRec=fRec;
%                 data.ev_times=ev_times;
                data.stimLib=stimLib;
                data.stimTimes=stimTimes;
            end
            disp('Saving...');
            save(filename, '-struct', 'data', '-v7.3');
            % save(filename, '-struct', 'data');
            clear data
        end
        
        disp(toc)
    else
        disp(['Skipping block ' num2str(i), '/', num2str(height(blockIndex))]);
    end
    
end

function blockData = importTankInternal(paramsImp, ch) %#ok<STOUT> % In eval

EvID=paramsImp.EvID{1};
bb=paramsImp.blocks; % This is name not just num
chans=paramsImp.chans;
tank=paramsImp.tank;
fRec=paramsImp.fRec;
resampleFs=paramsImp.resampleFs;



% Establish tank connection
ok = 0;
while ok==0
    TTfig = figure('visible','off');
    TT    = actxcontrol('TTank.X');
    TT.ConnectServer('Local','Me');
    
    % Open tank
    ok = TT.OpenTank(tank, 'R');
end


% Open Requested blocks
blockname= bb{1};
% disp([blockname,' (', num2str(p), '/', num2str(length(blocks)), ')...'])
ok = TT.SelectBlock(blockname);
if ok==0
    disp('BLOCK NOT SELECTED!!')
    return
end

% Read events
nMax    = 500000;
srtCode = 0;            % 0 disregrads sort codes
Tstart  = 0;            % 0 = start of block
Tend    = 0;            % 0 = end of block
options = 'ALL';        % Get all data


for xi = 1 %: length(chans)
    %pp=pp+1;
    ii= ch;
    disp([blockname, ': Channel ', num2str(ii), ' (', num2str(ii), '/', num2str(length(chans)), ')'])
    %disp([blockname, ': Channel ', num2str(chanID)])
    
    ev = TT.ReadEventsV(nMax, EvID, ii, srtCode, Tstart, Tend, options);
    
    % Parse events
    x = TT.ParseEvV(0, ev);     % Matrix: N columns = N events; Q points = Q rows
    clear ev
    % De-concatenate Parse Event matrix
    n_x=numel(x);
    output=reshape(x,1,n_x);
    clear x n_x
    if fRec==resampleFs % Don't resample
        output=double(output);
    else % Do resample
        output=resample(double(output),resampleFs,round(fRec));
    end
    dataOut{xi}=output; % Save
    %dataOutmat(:,ii)=output';
end
eval(['blockData.Block','=dataOut;']);
clear dataOut
%blockData_mat(:,:,p)=dataOutmat;


% Close connection and release server
TT.CloseTank
TT.ReleaseServer
close(TTfig)
clear TT TTfig
close all
pause(1)