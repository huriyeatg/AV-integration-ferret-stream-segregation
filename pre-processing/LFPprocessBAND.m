function outSig=LFPprocessBAND(inSig,fs,lowPass,highpass)
% insig should be a trials x times matrix sampled at Fs Hz.
%filters at frequency lowpass and baseline corrects data
%resample with jenny_resample
%JKB 08/09

% low pass freq
Wp = lowPass;
[z,p,k] = butter(5,[highpass/(fs/2) Wp/(fs/2)]);
[sos,g] = zp2sos(z,p,k);
Hd = dfilt.df2tsos(sos,g);

%% and filter with it
for ii=1:size(inSig,1)
    outSig(ii,:)=round(filtfilthd(Hd,inSig(ii,:)));
    outSig(ii,:)=outSig(ii,:)-mean(outSig(ii,:));
end

