function [class,d,score,bootClass,bootScore,criticalValue] = classifySweeps(raster,stim, p, iterations)
% % [class,d,score,bootClass,bootScore,criticalValue] = classifySweeps
%                        (raster,stim, confidence_p, boothstrap_iterations)

% function to test for temporal structure in a PSTH and classify sweeps
% using the mean response as a template
% input a raster (e.g. in 20 ms precision), desired p-value and number of
% iterations to be performed, with stim, a vector of stimulus classes
% sorted in the same way that the raster is with one entry per raster sweep
% returns score (1 or 0 for whether the observed raster contains a
% temporal structure which is different from chance and optional rDist
% which gives the proportion of trials classified as closer to the real
% data than the bootstrapped data on each iteration
% AUTHORS: H Atilgan & JK Bizley, 06062020

%%
if ~exist('p','var')
    p = 0.001; % default to 5% confidence
end
if ~exist('iterations','var')
    iterations = 100;% default to 100
end

%% create the templates from the real data 
%For each classese, calculate mean with all sweeps except the one to be tested
classType = unique(stim);% how many stimulus classes are there
template  = nan(numel(classType),size(raster,2));
sInd      = cell(1,numel(classType));
for k = 1:numel(classType) % for each
    f = find(stim==classType(k)); % extract the reps from this stimulus
    sInd{k} = f;
    template(k,:) = mean(raster(f,:));
end

%% Caclulate euclidean distance between template and test data

for ii=1:size(raster,1) % for each sweep
    % recalculate its cloud omitting the test sweep  
    ind = setdiff(sInd{stim(ii)},ii);
    mWithin = mean(raster(ind,:));
    test = raster(ii,:);
    
    for k = 1:length(classType)
        if classType(k) == stim(ii)
            d(ii,classType(k)) = sqrt(sum((test - mWithin).^2));
        else
            d(ii,classType(k)) = sqrt(sum((test - template(k,:)).^2));
        end
    end
end
% d should now be a nSweeps x nStim matrix of differences;
[~,class] = min(d,[],2);
score = sum(class==stim)/length(stim);


%% bootstrap to calculate confidence interval 
bootScore = nan(iterations,1);
bootClass = nan(iterations,size(raster,1));
for jj=1:iterations
    r = randperm(size(raster,1)); % sample without replacement
    % OR:
    %r = RANDI(size(raster,1),1,size(raster,1)); % sample with replacement
    raster = raster(r,:);
    for uu = 1:length(classType) % for each
        f = find(stim==classType(uu)); % extract the reps from this stimulus
        sInd{uu} = f;
        template(uu,:) = mean(raster(f,:));
    end
 
    for ii=1:size(raster,1) % for each sweep
        
        % recalculate its cloud omitting the test sweep
        ind = setdiff(sInd{stim(ii)},ii);
        mWithin = mean(raster(ind,:));
        test = raster(ii,:);
        
        for uu = 1:length(classType)
            if classType(uu) == stim(ii)
                d(ii,classType(uu)) = sqrt(sum((test - mWithin).^2));
            else
                d(ii,classType(uu)) = sqrt(sum((test - template(uu,:)).^2));
            end
        end
    end
    % d should now be a nSweeps x nStim matrix of differences;
    [~,bootClass(jj,:)] = min(d,[],2);
    bootScore(jj) = sum(bootClass(jj,:)'==stim)/length(stim);
end

criticalValue = prctile(bootScore,100-p*100);