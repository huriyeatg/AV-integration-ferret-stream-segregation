function table = runClassifySweepsAwake(params)
% % table = runClassifySweepsAwake(params) %%
% INPUT: params is a structure with path, animal, block,shank,channel
% OUTPUT : table: results of classifications
%           -VowelClass: classification based on vowel id (Bootstrap 
%               criteria, classification score), if score is larger than 
%               bootstrap criteria, it is significantly classified based 
%               on vowel id.
%           -VisCondClass: classification based on visual condition
%              (Bootstrap criteria,classification score) 
%           -doubleStream_relativeClassification: classification of dual
%              stream to coherent single stream. (to what extent it is  
%              classified as A1V1 stream, and A2V2 stream)

% H Atilgan, Jun20

%% load data
resolution = 20;

load(fullfile(params.path.spikes,['rasters_',params.animal,...
    '_', params.block,...
    '_ch_',params.channel,...
    '_sh_',params.shank,'.mat']));

idx = numel(STM); % final one is multi unit
trials = getMask (STM(idx).raster,sOrderSite,'streamSegregation');
trials_PSTHs = getPSTHs (trials, resolution);

preStim = 500; % 500ms in raster is before stim onset - exclude this part.
sLength = 3000;
tSweep = preStim/resolution:(sLength+preStim)/resolution;

data1 = [trials_PSTHs.A1V1noblip(:,tSweep);trials_PSTHs.A1V2noblip(:,tSweep)];
stim1 = [[ones(size(trials_PSTHs.A1V1noblip(:,tSweep),1),1),ones(size(trials_PSTHs.A1V1noblip(:,tSweep),1),1)]; ...
    [ones(size(trials_PSTHs.A1V2noblip(:,tSweep),1),1),ones(size(trials_PSTHs.A1V2noblip(:,tSweep),1),1)*2]]; 

data2 = [trials_PSTHs.A2V1noblip(:,tSweep);trials_PSTHs.A2V2noblip(:,tSweep)];
stim2 = [[ones(size(trials_PSTHs.A2V1noblip(:,tSweep),1),1)*2,ones(size(trials_PSTHs.A2V1noblip(:,tSweep),1),1)]; ...
    [ones(size(trials_PSTHs.A2V2noblip(:,tSweep),1),1)*2,ones(size(trials_PSTHs.A2V2noblip(:,tSweep),1),1)*2]];

data_test = [trials_PSTHs.A12V1noblip(:,tSweep);trials_PSTHs.A12V2noblip(:,tSweep)];
stim_test = [[ones(size(trials_PSTHs.A12V1noblip(:,tSweep),1),1)*3,ones(size(trials_PSTHs.A12V1noblip(:,tSweep),1),1)]; ...
    [ones(size(trials_PSTHs.A12V2noblip(:,tSweep),1),1)*3,ones(size(trials_PSTHs.A12V2noblip(:,tSweep),1),1)*2]];


%% Calculate classification values for single stream
singleStream_data = [data1;data2];
singleStream_stim = [stim1;stim2]; % vowel id, visual condition id

[~,~,score1,~,~,crit1] = classifySweeps(singleStream_data,singleStream_stim(:,1)); % for vowel
[~,~,score2,~,~,crit2] = classifySweeps(singleStream_data,singleStream_stim(:,2)); %for visual condition
table. VowelClass         = [crit1 score1];
table. VisCondClass       = [crit2 score2];

%% calculate relative classification estimation of double stream to single streams
doubleStream_data = [data1;data2;data_test];
doubleStream_stim = [stim1;stim2;stim_test];


[score,critV]     = classifySweeps_relativeClassification(doubleStream_data,doubleStream_stim);
table.doubleStream_relativeClassification  =  [score];



