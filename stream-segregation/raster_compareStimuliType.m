function raster_compareStimuliType(params,stimuliSet)
% %raster_compareStimuliType(params,stimuliSet) %%


%% load data
load(fullfile(params.path.spikes,['rasters_',params.animal,...
    '_', params.block,...
    '_ch_',params.channel,...
    '_sh_',params.shank,'.mat']));
switch stimuliSet
    case 'streamSegregation-noblip'
        idx = numel(STM); % final one is multi unit
        trials = getMask (STM(idx).raster,sOrderSite,'streamSegregation');
        compareSet = [ {'A1V1noblip'};{'A2V2noblip'};{'A12V1noblip'};{'A12V2noblip'}];
        colorMap = [ [1 0 0]; [0 0 1] ;[0.5 0 0 ]; [0 0 0.5]];
    case 'streamSegregation-blip'
        idx = numel(STM); % final one is multi unit
        trials = getMask (STM(idx).raster,sOrderSite,'streamSegregation');
        compareSet = [ {'A1V1blip'};{'A2V2blip'};{'A12V1blip'};{'A12V2blip'}];
        colorMap = [ [1 0 0]; [0 0 1] ;[0.5 0 0 ]; [0 0 0.5]];
    case 'uniSensory'
        idx = numel(STM); % final one is multi unit
        trials = getMask (STM(idx).raster,sOrderSite,'uniSensory');
        compareSet = [ {'A1'};{'V1'};{'A1V1'}];
        colorMap = [ [1 0 0]; [0 0 1] ;[0 1 0]];
    case 'amplitude_single'
        idx = numel(STM); % final one is multi unit
        trials = getMask (STM(idx).raster,sOrderSite,'uniSensory');
        compareSet = [ {'A1'};{'A1static'};{'V1'};{'V1static'};];
        colorMap = [ [1 0 0]; [0 0 1] ;[0 1 0];[0 0 0]];
    case 'amplitude_multi'
        idx = numel(STM); % final one is multi unit
        trials = getMask (STM(idx).raster,sOrderSite,'uniSensory');
        compareSet = [ {'A1staticV1static'}; {'A1staticV1'};...
                       {'A1V1static'};{'A1V1'}];
        colorMap = [ [1 0 0]; [0 0 1] ;[0 1 0];[0 0 0]];
    otherwise
        error ('This function only works for specified stimuli sets, check code for details.')
end

%% Plot condition 1 (A1V1 for doubleStream)

figure; hold on
for k =1: numel(compareSet)
    temp = trials.(compareSet{k});
    subplot(numel(compareSet),1,k)
    h = plot_raster(temp,colorMap(k,:));
    title(compareSet{k}(1:end-6))
    ylabel ( 'trials')
end
 h.XAxis.Visible = 'on';
 set(gca,'XTick',0:500:4000);
 set(gca,'XTickLabel',-0.5:0.5:4, 'visible','on');
 xlabel ( 'Time (seconds)') 
axis off

