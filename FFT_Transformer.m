classdef FFT_Transformer < FeatureTransformerBase
    
    properties (Access = public)
        channel;
        seconds;
        nfft;
    end
    
    methods (Access = public)
        function mFFT = FFT_Transformer(trials, seconds, channel,nfft)
            if ~iscell(trials)
                error('trials must be cell array of Trial object');
            end
            if nargin == 0
                error('not enough arguments');
            elseif nargin == 1
                mFFT.trials = trials;
                mFFT.seconds = 0;
                mFFT.channel = 126;
                mFFT.nfft = 512;
            elseif nargin == 2
                mFFT.trials = trials;
                mFFT.channel = 126;
                mFFT.seconds = seconds;
                mFFT.nfft = 512;
            elseif nargin == 3
                mFFT.trials = trials;
                mFFT.channel = channel;
                mFFT.seconds = seconds;
                mFFT.nfft = 512;
            elseif nargin == 4
                mFFT.trials = trials;
                mFFT.channel = channel;
                mFFT.seconds = seconds;
                mFFT.nfft = nfft;
                error('invalid number of arguments');
            end
        end
        
        function transform(mFFT)
            NUM_FEATURES = mFFT.nfft/2+1;
            numTrials = length(mFFT.trials);
            instances = zeros(numTrials, NUM_FEATURES);
            labels = zeros(numTrials,1);
            for i=1:numTrials
                numsamples = mFFT.trials{i}.samplingRate * mFFT.seconds;
                if(numsamples == 0)
                    y = mFFT.trials{i}.signal(mFFT.channel,:);
                else
                    y = mFFT.trials{i}.signal(mFFT.channel, 1:numsamples);
                end                
                %Y = fft(y,(NUM_FEATURES-1)*2)/((NUM_FEATURES-1)*2);
                %f = Fs/2*linspace(0,1,NFFT/2+1);
                %pyy = abs(Y(1:(NUM_FEATURES-1)*2/2+1)).^2;
                [pyy,f] = periodogram(y,[],mFFT.nfft,mFFT.trials{i}.samplingRate);
                instances(i,:) = pyy;
                labels(i,1) = floor(mFFT.trials{i}.label);
            end
            mFFT.instanceSet = InstanceSet(instances,labels);
        end
    end
   
end

