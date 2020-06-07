% % master_AVintegration_streamSegregation %%
% Master analysis code for AV stream segregation data(two simultaneously
% presented vowel stream and one visual stream)
% Awake data: electrophysiological ferret auditory cortex, SSY data for 
%             AV passive 3 seconds long.
%
% Published work: "Atilgan et al., Neuron 2018 "Integration of visual 
%             information in auditory cortex promotes auditory scene 
%             analysis through multisensory binding"
%
% H, Atilgan Jun 2020, Bizley Lab - UCL, London

clc
clearvars;
close all;
setup_figprop;

%% set paths

root_path        = 'E:\MATLAB\AV-integration-ferret-stream-segregation';
path.logfile     = fullfile(root_path,'data','logFiles');
path.blocks      = fullfile(root_path,'data','awake-blocks');
path.lfpsweeps   = fullfile(root_path,'data','awake-lfpsweeps');
path.lfpsignal   = fullfile(root_path,'data','awake-lfpsignal');
path.spikes      = fullfile(root_path,'data','awake-spikes');
path.analysis    = fullfile(root_path,'analysis');
path.figure      = fullfile(root_path,'figs');

%% create a table-index for block recording
blockIndex = makeBlockIndex_awake(path);

%% preprocessing - outcomes (spikes and LFP) saved in associated folders.
master_preprocessing

%% Example raster for visual classified unit
params.animal  = '1203';
params.block   = 'Block6-9';
params.shank   = '01';
params.channel = '13'; %15 is also a good example
params.path    = path;

table = runClassifySweepsAwake (params)
raster_compareStimuliType(params,'streamSegregation-noblip');
% Notes: A12 with V1 visual stimuli is 81% more similar to A1V1 and 
% A12V2 is 81% more similar to A2V2 - failed to classified as
% based on vowel id. - This is quite common. Next example is more
% interesting.

%% Example raster for auditory classified unit
params.animal  = '1201';
params.block   = 'Block6-42';
params.shank   = '01';
params.channel = '15';
params.path    = path;

table = runClassifySweepsAwake (params)
raster_compareStimuliType(params,'streamSegregation-noblip')

% Notes: A12 with V1 visual stimuli is 52% more similar to A1V1 and 
% A12V2 is 85% more similar to A2V2 - classified based on vowel identity, 
% and failed to classified as based on visual stimuli, but visual stimuli
% has an clear effect on dual stream.


%% Phase coherence analysis (lfp)
params.animal  = '1201';
params.block   = 'Block6-42';
params.shank   = '01';
params.channel = '15';
params.path    = path;

plot_ITPC (params) 
