function dataIndex = makeBlockIndex_awake(path)
% % makeBlockIndex_awake(path) %
%PURPOSE:  Make a table of the awake recording log files
%AUTHORS:   H Atilgan 06022020
%
%INPUT ARGUMENTS
%   path:  a structure with path information, requires
%        - path.logfile - text file for recording
%        - path.blocks  - outcome of all recording: blocks
%        - path.spikes  - spike sweeps for each stimuli
%        - path.broadband - raw LFP signal: LFPsignal (BB)
%        - path.lfp     - lfp sweeps for each stimuli
%
%OUTPUT ARGUMENTS
%   newDataIndex:  a table of the data files, now including information about
%                  lesions
%

%% Create block index
columnNames ={ ...
    'BlockNumber', ...
    'BlockName',...
    'Animal', ...
    'Complete', ...
    'StimSet', ...
    'StimSetPath', ...
    'AnalysisPath', ...
    'BlocksPath'...
    'BlocksAvailable'...
    'BBPath'...
    'BBAvailable'...
    'RasterPath'...
    'RasterAvailable'...
    'LFPPath',...
    'LFPAvailable'...
    'Notes'};

% get all logFiles
AllLogfiles = dir (fullfile(path.logfile,'\F*'));

nB = size(AllLogfiles,1);

allData=table(((1:nB)'), cell(nB,1),NaN(nB,1),...
     NaN(nB,1), NaN(nB,1), cell(nB,1),cell(nB,1),...
    cell(nB,1), NaN(nB,1), cell(nB,1), NaN(nB,1),...
    cell(nB,1), NaN(nB,1), cell(nB,1), NaN(nB,1),...
    cell(nB,1));

allData.Properties.VariableNames = columnNames;


%% get data path

for b = 1:nB
    disp([num2str(b), '\' num2str(nB)])
    [ind, ~] =regexp(AllLogfiles(b).name, ' ');
    block_idx = AllLogfiles(b).name(ind(end)+1:end-4);
    animal = AllLogfiles(b).name(2:5);
    allData.Animal(b)    = str2double(animal);
    allData.BlockName(b) = {block_idx};
    
    % Check to see if Block is generated : "not avaliable for shared code"
    % This includes full session-recording-signals, includes;
    %    -   BB_2/BB_3 : signals for LFPs for two shanks (BB: BroadBand)
    % generally it is two shanks in awake recordings, each shank has 16
    % recording site, Left:2 and Right:3)
    %    - SU_2/SU_3 : signals for single units
    %    - stimLib   : stimuli presentation code order -
    %    - stimTimes : stimuli presentation start times
    allData.BlocksPath{b} = fullfile(path.blocks, ...
        [ animal,'_', block_idx ,'_ch_01.mat']);
    
    if exist(allData.BlocksPath{b}, 'file')
        allData.BlocksAvailable(b)=1;
    end
    
    % Check to see if Rasters is generated
    % spike sorted data, "rasters" is a struct with all detected single 
    % units AND last one as the multi unit spikes. Rasters for trial
    % sweeps,4 sec in total;  -0.5 to 3.5 sec 
    %(each stimuli presentation lasts 3 sec)
    allData.RasterPath{b} = fullfile(path.spikes,...
        ['rasters_', animal,'_', block_idx, '_ch_01_sh_01.mat']);
    
    if exist(allData.RasterPath{b}, 'file')
        allData.RasterAvailable(b)=1;
    end
    
    % Check to see if BB is generated - Broadband signal from Blocks
    % All broadband/Local field potential signal - one signal for whole
    % session
    allData.BBPath{b} = fullfile(path.lfpsignal,...
        ['LFPsignal_', animal,'_', block_idx, '_ch_01_sh_01.mat']);
    
    if exist(allData.BBPath{b}, 'file')
        allData.BBAvailable(b)=1;
    end
    
    % Check to see if LFP is generated
    % LFP ( 50Hz cleaned, 1-150 Hz filtered ) signals for each trials, 4
    % seconds for each stimuli presentation  -   -0.5 to 3.5 sec 
    allData.LFPPath{b} = fullfile(path.lfpsweeps,...
        ['LFPsweeps_', animal,'_', block_idx, '_ch_01_sh_01.mat']);
    
    if exist(allData.LFPPath{b},'file')
        allData.LFPAvailable(b)=1;
    end

    % Define stimSet from filename - is useful to create trials
    % Code = 5 for not working folders, do not use.
    allData.StimSetPath{b} = fullfile(path.logfile,AllLogfiles(b).name);
    
    if strfind(AllLogfiles(b).name, 'level81_test_06_14')>0
        allData.StimSet(b) = 1;
    elseif strfind(AllLogfiles(b).name, 'level81_test ')>0
        allData.StimSet(b) = 2;
    elseif strfind(AllLogfiles(b).name, 'level81_UniSensory ')>0
        allData.StimSet(b) = 3;
    elseif strfind(AllLogfiles(b).name, 'level81_UniSensory2')>0
        allData.StimSet(b) = 4; 
    elseif strfind(AllLogfiles(b).name, 'level81_DiffCutOff ')>0
        allData.StimSet(b) = 6; % 5 for broken file
    elseif strfind(AllLogfiles(b).name, 'level81_DiffCutOffAll')>0
        allData.StimSet(b) = 7; % 5 for broken file
    elseif strfind(AllLogfiles(b).name, 'level81_DualControl')>0
        allData.StimSet(b) =8; % 5 for broken file
    else
        allData.StimSet(b) = NaN;
    end
    
end

% Mark incomplete files manually
allData.Complete=ones(nB,1);
dataIndex = allData;
