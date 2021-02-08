function WaveletArray = CreateWavelet(waveletF, Fs )
% author: Flavio Frolich Feb 2013

waveletT = 1/waveletF; % Wavelet period

waveletS = 2/waveletF;

numOscPerSide = 7;

timePerSide = numOscPerSide * waveletT;

waveletTime = -timePerSide: 1/Fs : timePerSide;

waveletCosine = cos( 2*pi*waveletF*waveletTime );
waveletSine = sin( 2*pi*waveletF*waveletTime );
waveletGaussian = (waveletS^(-0.5)*pi^(-0.25))* exp(-waveletTime.^2/(2*waveletS^2) );

waveletReal = waveletCosine.*waveletGaussian;
waveletImag = waveletSine.*waveletGaussian;
WaveletArray = { waveletReal, waveletImag };
