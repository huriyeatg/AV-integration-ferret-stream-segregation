function LFPTraceExtraction_awake(blockIndex, path)
% %LFPTraceExtraction_awake(blockIndex, path) %%

%% %%% Parameters
fs      = 24414;
sLength = 4;
length_sweep = floor(sLength*fs);
pre_sweep    = floor(0.5*fs);
% for 50Hz noise filter
wo = 50/(fs/2);
bw = wo/35;
[b,a] = iirnotch(wo,bw);

blockIndex = blockIndex(isnan(blockIndex.LFPAvailable) & blockIndex.BlocksAvailable==1, :);

nBlock = size(blockIndex,1);
nShank = 2;

%%  %% Save BB & LFP sweeps 
for k =1:nBlock
    blockName = [num2str(blockIndex.Animal(k)),'_',blockIndex.BlockName{k}];
    allChannels = dir(fullfile(path.blocks,[blockName,'*']));
    for ch =1:numel(allChannels)
        fprintf('%d\\%d Trace Extracting channel %d...\n',k, nBlock,ch);
        %% get signal and time stamps
        dd = load(fullfile(path.blocks,allChannels(ch).name));
        sTimes = dd.stimTimes*fs;
        sOrderSite   = dd.stimLib.order;
        for sh =1:nShank
            if sh==1; trace = dd.BB_2{1,1};
            else;     trace = dd.BB_3{1,1};
            end
            % save broadband signal for spike sorting
            LFPsignal = trace;
            save(fullfile(path.broadband,['LFPsignal_',allChannels(ch).name(1:end-4),'_sh_',num2str(sh,'%02d'),'.mat']),'LFPsignal', '-v7.3');
            
            %% Get sweeps for each stimuli presentation 
            LFPsweeps = cell(size(sTimes,1),1);
            for ii=1:size(sTimes,1)
                sweepStart = sTimes(ii)- pre_sweep;
                sweepEnd   = sTimes(ii)+ length_sweep;
                if sweepStart > 0 &&  sweepEnd <numel(trace)
                    sweepTime = floor(sTimes(ii)-pre_sweep):floor(sTimes(ii)-pre_sweep)+length_sweep-1;
                    temp = LFPprocessBAND(trace(sweepTime),fs,150,1); % LFP filter
                    temp = filtfilt(b,a,temp);
                    temp = resample(temp',1e3,fs);
                    LFPsweeps{ii,1}= temp; % 0.5 to 3.5 sec
                end
            end
            % save lfp sweeps
            save(fullfile(path.lfp,['LFPsweeps_',allChannels(ch).name(1:end-4),'_sh_',num2str(sh,'%02d'),'.mat']),'LFPsweeps', 'sOrderSite', '-v7.3');  
        end          
    end
end

end % function


%% CheckTrace in frequency band
%
% signal = sweeps{1,1};
% L = length(signal);
% NFFT = 2^nextpow2(L);
% f = 1e3/2*linspace(0,1,NFFT/2+1);
%
% for ii=1:10
% signal = sweeps{ii};
% Y = fft(signal,NFFT)/L;
% F2(ii,:) = 2*abs(Y(1:NFFT/2+1));
% end
% figure
% plot(f,mean(F2))
% xlim([0 200])
