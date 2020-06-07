function [ss,criticalValue] = classifySweeps_relativeClassification(allRaster,stim,p,iterations)
% %[ss,criticalValue] =
% classifySweeps_relativeClassification(allRaster,stim,p,iterations)%%


if ~exist('p','var')
    p = 0.001; % default to 5% confidence
end
if ~exist('iterations','var')
    iterations = 100;% default to 100
end

%% create the templates from the real data using the visual coherent conditions
classType = unique(stim(:,2)); % # number of visual conditions 
template  = nan(numel(classType),size(allRaster,2));
for uu = 1:2 
    f = find(stim(:,1)==uu & stim(:,2)==uu); 
    template(uu,:) = mean(allRaster(f,:));
end

%% now test each sweep by calculating the euclidean distance between it and the
% template sweeps
fU = find(stim(:,1)==3 & stim(:,2)==1); % only double stream, vis U
fA = find(stim(:,1)==3 & stim(:,2)==2); % only double stream, vis A

raster =[ allRaster(fU,:); allRaster(fA,:)]; 
d = nan(size(raster,1), numel(classType));
for ii=1:size(raster,1)
    % recalculate its cloud omitting the test sweep
    test = raster(ii,:);
    for uu = 1:length(classType)
        d(ii,uu) = sqrt(sum((test - template(uu,:)).^2));
    end
end

% d should now be a nSweeps x nStim matrix of differences;
[~,class]  = min(d(1:numel(fU),:),[],2);
scoreA12_V1 = sum(class==1)/numel(fU);
[~,class]  = min(d(end-numel(fA)+1:end,:),[],2);
scoreA12_V2 = sum(class==2)/numel(fA);
ss = [scoreA12_V1 scoreA12_V2];

%% bootstrap to calculate confidence interval 
bootScore = nan(iterations,1);
bootClass = nan(iterations,size(raster,1));

tStim = stim([fU;fA],2);
for jj=1:iterations
    r = randperm(size(raster,1)); % sample without replacement
    raster = raster(r,:);
    for ii=1:size(raster,1) % for each sweep
        % recalculate its cloud omitting the test sweep
        test = raster(ii,:);
        for uu = 1:2
            dd(ii,uu) = sqrt(sum((test - template(uu,:)).^2));
        end
    end
    % d should now be a nSweeps x nStim matrix of differences;
    [~,bootClass(jj,:)] = min(dd,[],2);
    bootScore(jj) = sum(bootClass(jj,:)'==tStim)/length(tStim);
end
criticalValue = prctile(bootScore,100-p*100);