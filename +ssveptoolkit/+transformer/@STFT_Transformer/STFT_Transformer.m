classdef STFT_Transformer < ssveptoolkit.transformer.FeatureTransformerBase
    
    properties (Access = public)
        channel;
        seconds;
        Frange;
    end
    
    methods (Access = public)
        function mSTFT = STFT_Transformer(trials, seconds, channel,rangeFreq)
            if nargin == 0
                mSTFT.seconds = 0;
                mSTFT.channel = 126;
                mSTFT.Frange(1) = 0;
%                 mSTFT.Frange(2) = mSTFT.trials{1}.samplingRate;
            elseif nargin == 1
                mSTFT.trials = trials;
                mSTFT.seconds = 0;
                mSTFT.channel = 126;
                mSTFT.Frange(1) = 0;
                mSTFT.Frange(2) = mSTFT.trials{1}.samplingRate;
            elseif nargin == 2
                mSTFT.trials = trials;
                mSTFT.channel = 126;
                mSTFT.seconds = seconds;
                mSTFT.Frange(1) = 0;
                mSTFT.Frange(2) = mSTFT.trials{1}.samplingRate;
            elseif nargin == 3
                mSTFT.trials = trials;
                mSTFT.channel = channel;
                mSTFT.seconds = seconds;
                mSTFT.Frange(1) = 0;
                mSTFT.Frange(2) = mSTFT.trials{1}.samplingRate;
            elseif nargin==4
                
                mSTFT.trials = trials;
                
                if prod(size(rangeFreq)) ~=2
                    error('vector for frequency range must has two elements')
                end
                if rangeFreq(1)>=rangeFreq(2)
                    error('first element must be smaller.');
                end
                if (rangeFreq(1)<0 || rangeFreq(2)>mSTFT.trials{1}.samplingRate)
                    error('invalid values for frequency range');
                end
                
                mSTFT.channel = channel;
                mSTFT.seconds = seconds;
                mSTFT.Frange(1) = rangeFreq(1);
                mSTFT.Frange(2) = rangeFreq(2);
            else
                error('invalid number of arguments');
            end
        end
        
        function transform(mSTFT)
            mSTFT.Frange(2) = mSTFT.trials{1}.samplingRate;
            numsamples = mSTFT.trials{1}.samplingRate * mSTFT.seconds;
            if (numsamples == 0)                    
                numsamples = size(mSTFT.trials{1}.signal(mSTFT.channel,:),2);                             
            end
            
            numTrials = length(mSTFT.trials);
            y = mSTFT.trials{1}.signal(mSTFT.channel, 1:numsamples);
            [S,F,T,P]=spectrogram(y,[],[],[mSTFT.Frange(1):0.5:mSTFT.Frange(2)],mSTFT.trials{1}.samplingRate);
            instances = zeros(numTrials, length(P(:)));
            labels = zeros(numTrials,1);
            for i=1:numTrials
                numsamples = mSTFT.trials{i}.samplingRate * mSTFT.seconds;
                if(numsamples == 0)
                    y = mSTFT.trials{i}.signal(mSTFT.channel,:);
                else
                    y = mSTFT.trials{i}.signal(mSTFT.channel, 1:numsamples);
                end                
                
                [S,F,T,P]=spectrogram(y,[],[],[mSTFT.Frange(1):0.5:mSTFT.Frange(2)],mSTFT.trials{i}.samplingRate);
                instances(i,:) = P(:);
                labels(i,1) = floor(mSTFT.trials{i}.label);
            end
            mSTFT.instanceSet = ssveptoolkit.util.InstanceSet(instances,labels);
        end
        
        function configInfo = getConfigInfo(mSTFT)
            if length(mSTFT.Frange) == 2
                configInfo = sprintf('STFT_Transformer\tchannel:%d\tseconds:%d\tfrange1:%d\tfrange2:%d',mSTFT.channel,mSTFT.seconds,mSTFT.Frange(1),mSTFT.Frange(2));
            else
                configInfo = sprintf('STFT_Transformer\tchannel:%d\tseconds:%d\tfrange1:%d\tfrange2:unset',mSTFT.channel,mSTFT.seconds,mSTFT.Frange(1));
            end
        end
    end
   
end

