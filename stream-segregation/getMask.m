function trials = getMask(data, sOrder, stimuliSet)
% %trials = getMask(data)%%

%% get stimuli type code
switch stimuliSet
    case 'streamSegregation'
        sType = [{'A1V1blip'};{'A1V1noblip'};... % order is important
                 {'A2V1blip'};{'A2V1noblip'};...
                 {'A12V1blip'};{'A12V1noblip'};...
                 {'A1V2blip'};{'A1V2noblip'};...
                 {'A2V2blip'};{'A2V2noblip'};...
                 {'A12V2blip'};{'A12V2noblip'}];
    case 'uniSensory' 
          sType = [{'A1'};{'V1'};... % order is important
                 {'A1static'};{'A2'};...
                 {'V2'};{'A2static'};...
                 {'A12'};{'Vstat'};...
                 {'A1staticV1static'};{'A1V1static'};...
                 {'A1staticV1'};{'A12Vstatic'};...
                 {'A1V1'};{'A2V2'}];
    otherwise
        error ('This function only works for two stimuli set: ''streamSegregation'' & ''uniSensory''')
        
end

%% get trials
trials = struct;

for k=1:numel(sType)
    mask = sOrder==k;
    trials.(sType{k}) = full(data(mask,:));
end
