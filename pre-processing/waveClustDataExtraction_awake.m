function waveClustDataExtraction_awake(blockIndex)
% % waveClustDataExtraction_awake(blockIndex) %%

fs=24414;
sweepLength=floor(4*fs);
preSweep=floor(0.5*fs);

WrngStim = [5]; % BrokenDataFile - No data recorded
ind = blockIndex.BlocksAvailable==1 & blockIndex.RasterAvailable==0  & ~ismember(blockIndex.StimSet,WrngStim);
aBlocks = blockIndex(ind, :);

pathFigures = 'E:\Data\Analysis_Awake\WC_Spikes\';
t=1;
% [ 9,14, 33,37,38]
for k = 1:height(aBlocks)% Site shows an animal
    animal   = aBlocks.Animal{k};
    blocks =  aBlocks.BlockName{k};
    for sh =t:2 % no need 3- no 3rd shrank
        Fname = [aBlocks.RasterPath{k}(1:end-5),num2str(sh),'.mat'];
        if exist(Fname,'file')
            disp (['Has been generated: ',Fname])
        else
            sOrderSite=[];
            tic;
            iiT=1; % sweeps=cell(size(dd.stimTimes,1),16);
            BlockName = aBlocks.BlocksPath{k};
            dd = load([BlockName(1:end-6), sprintf('%02d',1)]);
            % Cut the traces into sweeps
            sTimes = dd.stimTimes*fs;
            sLib   = dd.stimLib.order;
            
            signal = dd.BB_2{1,1};
            clear dd
            if  size(signal,2)/(fs*3)<size(sTimes,1)
                fprintf('\n Animal %d - %s does not have enough stimuli.\n',...
                    animal,aBlocks.BlockName{k});
            else
                trace =[];
                fprintf('\n %d\\%d Trace Extracting... Channels completed:\n',k,height(aBlocks)) ;
                for ch = ((sh-1)*16)+1:((sh-1)*16)+16
                    fprintf('%3d',ch) ;
                    BlockName = aBlocks.BBPath{k};
                    BB = load([BlockName(1:end-6), sprintf('%02d',ch)]);
                    trace = [trace, {BB.BB}];
                end
                clear BB
                fprintf('\nTrace Extracting...Sweeps completed:\n') ;
                % check we have same number of sTimes and sLib
                mStimes = size(sTimes,1);  mLib = size(sLib,1); mtrace = floor(size(trace{1,2},1)/(fs*3.5));
                mLimit = min( [mStimes,mLib,mtrace-1]);
                sTimes = sTimes (1:mLimit,:);  sLib   = sLib(1:mLimit,:);
                
                for ii=1:size(sTimes,1)
                    fprintf('%3d',ii)
                    for jj=1:size(trace,2)
                        if ~isnan(trace{1,jj})
                            if size(trace{1,jj},1) > floor(sTimes(ii)-preSweep)+sweepLength-1
                                sweepTime=  floor(sTimes(ii)-preSweep):floor(sTimes(ii)-preSweep)+sweepLength-1;
                                sweeps{iiT,jj}=trace{1,jj}(sweepTime);
                            end
                        end
                    end
                    
                    iiT= iiT+1;
                end
                clear trace
                fprintf('\n')
                sOrderSite = sLib;
            end
            clear signal
            
            nrchannels=size(sweeps,2);
            sc_channels=1:nrchannels;
            nrsweeps=size(sweeps,1);
            
            sweepsize=size(sweeps{1},1);
            sweepcutoff=sweepsize/fs; % in seconds
            comb=0;
            assignin('base','comb',comb)
            assignin('base','nrchannels',nrchannels);
            assignin('base','preSweep',preSweep);
            assignin('base','sc_channels',sc_channels);
            assignin('base','nrsweeps',nrsweeps);
            assignin('base','sweepsize',sweepsize);
            assignin('base','sweepcutoff',sweepcutoff);
            assignin('base','nReps',1);
            assignin('base','sweeps',sweeps);
            assignin('base','stimTimes',sTimes);
            assignin('base','sOrderSite',sOrderSite);
            assignin('base','pathFigures',pathFigures);
            
            KCWanalyseSweepsAwake (animal, sh, aBlocks.BlockName{k})
            clear sweeps trace data
            clear STM spike_results indexarray spikearray...
                cluster_results clusters spikes sTimes sLib...
                stimTImes signal
            
            disp ( ['F', num2str(animal),'_',aBlocks.BlockName{k},' Shrank ', num2str(sh),' completed!'])
            toc
        end
        
    end
    t=1;
end

