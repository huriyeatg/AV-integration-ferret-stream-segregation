function plot_ITPC (params)
% %plot_ITPC (params)%%
% sample code to calculate ITPC
% set morlet waveform
fs_wavelet         = 1e3;
frequencies  = 1:0.5:45;
ds_wavelet   = 1;
num_wavelets = length(frequencies);
DownsampledWavelet = cell(1,num_wavelets);
for i_freq=1:num_wavelets
    Wavelet = CreateWavelet(frequencies(i_freq) , fs_wavelet );
    Re = Wavelet{1}( 1 : ds_wavelet : end );
    Im = Wavelet{2}( 1 : ds_wavelet : end );
    DownsampledWavelet{i_freq} = { Re, Im };
end

% load data
load(fullfile(params.path.lfpsweeps,['lfpSweeps_',params.animal,...
    '_', params.block,...
    '_ch_',params.channel,...
    '_sh_',params.shank,'.mat']));
LFPsweeps = cell2mat(LFPsweeps');
lfp = getMask (LFPsweeps',sOrderSite,'streamSegregation');

%% calculate spectrum
stimType =  [{'A1V1blip'};{'A1V2blip'}];
for k=1:numel(stimType)
    temp = lfp.(stimType{k});
    
    num_trials = size(temp,1);
    time_steps = size(temp,2);
    
    data_spectrum_amp = zeros(num_trials,num_wavelets,time_steps);
    data_spectrum_phase = zeros(num_trials,num_wavelets,time_steps);
    
    for i_trial=1:num_trials
        for i=1:num_wavelets
            Re = conv( squeeze(temp(i_trial,1:ds_wavelet:end)), DownsampledWavelet{i}{1}, 'same' );
            Im = conv( squeeze(temp(i_trial,1:ds_wavelet:end)), DownsampledWavelet{i}{2}, 'same' );
            data_spectrum_amp(i_trial,i,:) = sqrt( Re.*Re + Im.*Im ) ;
            data_spectrum_phase(i_trial,i,:) =  atan2( Im,Re ) ;
        end
    end
    
    temp = nan(size(data_spectrum_phase,2),time_steps);
    for freq = 1:size(data_spectrum_phase,2) % each freq
        phT = squeeze(data_spectrum_phase(:,freq,:));
        temp(freq,:) =abs(mean(exp(1i*phT),1));
    end
    data.(stimType{k}) =temp;
end

%% plot spectrum
figure;
for k=1:numel(stimType)
    subplot(numel(stimType),1,k)
    imagesc(1:1:4001,frequencies,data.(stimType{k}));
    set(gca,'YDir','normal') 
    set(gca,'XTick',0:500:4000);
    ylim([2.5 45]);
    set(gca,'XTickLabel',0:0.5:4);
    ylabel('Frequency (Hz)')
    xlabel('Time (seconds)')
    title (stimType{k})
end

%%% In the paper, we used randomly selected permutation for baseline to
%%% calculate the phase discrimination index for each condition. 

