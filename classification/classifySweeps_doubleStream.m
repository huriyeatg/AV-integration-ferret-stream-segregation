function [class,d,score,bootClass,bootScore,criticalValue] = classifySweeps_doubleStream(raster,stim)

if ~exist('p','var')
    p = 0.001; % default to 5% confidence
end
if ~exist('iterations','var')
    iterations = 100;% default to 100
end

% create the templates from the real data using the visual coherent
% conditions
us = [1,2];
for uu = 1:2 % for each
    f = find(stim(:,1)==us(uu) & stim(:,2)==us(uu)); % extract the reps from this stimulus
    template(uu,:) = mean(raster(f,:));
end

% now test each sweep by calculating the euclidean distance between it and the
% template sweeps
f = find(stim(:,1)==3);
raster = raster(f,:);
tStim = stim(f,2);
for ii=1:size(raster,1) % for each sweep
    % recalculate its cloud omitting the test sweep
    test = raster(ii,:);
    for uu = 1:length(us)
        d(ii,us(uu)) = sqrt(sum((test - template(uu,:)).^2));
    end
end
% d should now be a nSweeps x nStim matrix of differences;
[m,class] = min(d,[],2);
score = sum(class==tStim)/length(tStim);


%% now bootstrap:
bootScore = nan(iterations,1);
bootClass = nan(iterations,size(raster,1));
for jj=1:iterations
    r = randperm(size(raster,1)); % sample without replacement
    raster = raster(r,:);
    for ii=1:size(raster,1)      % for each sweep
        % recalculate its cloud omitting the test sweep
        test = raster(ii,:);
        for uu = 1:length(us)
            d(ii,us(uu)) = sqrt(sum((test - template(uu,:)).^2));
        end
    end
    % d should now be a nSweeps x nStim matrix of differences;
    [m,bootClass(jj,:)] = min(d,[],2);
    bootScore(jj) = sum(bootClass(jj,:)'==tStim)/length(tStim);
end
criticalValue = prctile(bootScore,100-p*100);
