function trials_PSTHs = getPSTHs(trials, resolution)
% %trials_PSTHs = getPSTHs(trials, resolution)%%

fnames = fields(trials);
for k = 1:numel(fnames)
    temp = trials.(fnames{k});
    PSTH = nan(size(temp,1),size(temp,2)/resolution);
    for kk = 1: size(temp,1) % for each sweeps/trials
        data = temp(kk,:);
        PSTH(kk,:) = hist(find(data),1:resolution:size(data,2));
    end
    trials_PSTHs.(fnames{k}) = PSTH;
end