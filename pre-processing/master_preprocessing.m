% preprocessing data: 
%    1) Transfer TDT signal to matlab (saved in blocks folder)
%    2) Save broadband signal (saved in lfp signal folder) & Clean 50Hz
%    noise and saves LFP signal for sweeps(1-150Hz, saved in LFP folder)
%    3) Spike sorted for each units. Wave Cluster automatic spike sorting
%    algorithm is used (saved in spikes folder). Each channel have single
%    units and multi unit( last one in the raster structure)
% %%%% ----> lfpsignal/lfpsweeps/spikes data is currently avaliable (copy 
% of blocks and raw exist in SAMSUNG harddrive, but spike sorting 
% algorthm's code is missing)

%%
% Get blockIndex info
blockIndex = makeBlockIndex_awake(path);

%% 1- Get data from TDT tank to matlab - this includes many version of
% signals
TDT2Matlab_awake(blockIndex); % data saved in 'blocks folder' 

%% 2- Get broadband signal for spike sorting algorithms and LFP sweeps 
LFPTraceExtraction_awake(blockIndex, path) % data saved in lfpsignal folder and lfpsweeps folder

%% 3- automatic spike sorting, Wave cluster is used. 
WaveClustDataExtraction_awake(blockIndex); % data saved in 'spikes folder' 

