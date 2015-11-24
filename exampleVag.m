
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% example code for using classes: DWT_Transformer,
%    FFT_Transformer, STFT_Transformer, PYAR_Transformer
%    and PWelchTransformer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%load data
%testing
%create a session
session = ssveptoolkit.util.Session();
%subject: 1
session.loadSubject(1);

%process signals (load signals into the transformer)

%pwelch class, session:1, second: 1st, channel: 126
cPwt = ssveptoolkit.transformer.PWelchTransformer(session.trials,1,126);
%Perform the transformation
cPwt.transform();
%get PSDs (features)
f_welch = cPwt.getInstances();

%FFT class, session:1, second: 4st, channel: 126
ft = ssveptoolkit.transformer.FFT_Transformer(session.trials, 4, 126);
%Perform the transformation
ft.transform();
%get PSDs (features)
f_ft = ft.getInstances();

%pyulear class, session:1, second: 5, channel 126, 
%       AR model order:20
cPar= ssveptoolkit.transformer.PYAR_Transformer(session.trials,5,126,20);
%Perform the transformation
cPar.transform();
%get PSDs (features)
f_PAR = cPar.getInstances();

%DWT class, session:1, second: 5, channel 126, level of
%decomposition: 3, wavelet family: db1
cDwt = ssveptoolkit.transformer.DWT_Transformer(session.trials,1,126,5,'db1');  
%Perform the transformation
cDwt.transform();
%get the wavelet coefficients (features)
f_dwt = cDwt.getInstances();

% Short Time Fourier Transform, session:1, second: 5, channel 126,
% frequency range : 4 - 12 Hz 
stft = ssveptoolkit.transformer.STFT_Transformer(session.trials, 1, 126,[4 12]);
%Perform the transformation
stft.transform();
%get the wavelet coefficients (features)
f_stft = stft.getInstances();

% Short Time Fourier Transform, session:1, second: 5, channel 126,
% frequency range : 0 to Sampling Frequency 
stft1 = ssveptoolkit.transformer.STFT_Transformer(session.trials, 1, 126);
%Perform the transformation
stft1.transform();
%get the wavelet coefficients (features)
f_stft1 = stft1.getInstances();