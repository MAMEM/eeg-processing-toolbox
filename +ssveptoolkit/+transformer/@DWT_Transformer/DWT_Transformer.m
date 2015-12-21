classdef DWT_Transformer < ssveptoolkit.transformer.FeatureTransformerBase
    
    properties (Access = public)
        channel;
        seconds;
        levelWT;
        WavFamily;
    end
    
    methods (Access = public)
        function mDWT = DWT_Transformer(trials, seconds, channel,levWT,WavFam)
            if nargin == 0
                mDWT.seconds = 0;
                mDWT.channel = 126;
                mDWT.levelWT = 5;
                mDWT.WavFamily = 'db1';
            elseif nargin == 1
                mDWT.trials = trials;
                mDWT.seconds = 0;
                mDWT.channel = 126;
                mDWT.levelWT = 5;
                mDWT.WavFamily = 'db1';
            elseif nargin == 2
                mDWT.trials = trials;
                mDWT.channel = 126;
                mDWT.seconds = seconds;
                mDWT.levelWT = 5;
                mDWT.WavFamily = 'db1';
            elseif nargin == 3
                mDWT.trials = trials;
                mDWT.channel = channel;
                mDWT.seconds = seconds;
                mDWT.levelWT = 5;
                mDWT.WavFamily = 'db1';
            elseif nargin == 4
                mDWT.trials = trials;
                mDWT.channel = channel;
                mDWT.seconds = seconds;
                mDWT.levelWT = levWT;
                mDWT.WavFamily = 'db1';
            elseif nargin ==5
                mDWT.trials = trials;
                mDWT.channel = channel;
                mDWT.seconds = seconds;
                mDWT.levelWT = levWT;
                mDWT.WavFamily = WavFam;                
            else
                error('invalid number of arguments');
            end
        end
        
        function transform(mDWT)
            if length(mDWT.seconds) == 1
                numsamples = mDWT.trials{1}.samplingRate * mDWT.seconds;
                if (numsamples == 0)
                    numsamples = size(mDWT.trials{1}.signal(mDWT.channel,:),2);
                end
                numTrials = length(mDWT.trials);
                
                [C L] = wavedec(mDWT.trials{1}.signal(mDWT.channel, 1:numsamples),mDWT.levelWT,mDWT.WavFamily);
            elseif length(mDWT.seconds == 2)
                sampleA = mDWT.trials{i}.samplingRate*mDWT.seconds(1) + 1;
                sampleB = mDWT.trials{i}.samplingRate*mDWT.seconds(2);
                [C L] = wavedec(mDWT.trials{i}.signal(mDWT.channel, sampleA:sampleB), mDWT.levelWT, mDWT.WavFamily);
            else
                error('invalid seconds parameter');
            end
            instances = zeros(numTrials, length(C));
            labels = zeros(numTrials,1);
                                    
            for i=1:numTrials
                numsamples = mDWT.trials{i}.samplingRate * mDWT.seconds;
                if(numsamples == 0)
                    y = mDWT.trials{i}.signal(mDWT.channel,:);
                else
                    y = mDWT.trials{i}.signal(mDWT.channel, 1:numsamples);
                end
                % zero padding to nearest power of 2
                y = mDWT.trials{i}.signal(mDWT.channel, 1:numsamples);
                [C L] = wavedec(y,mDWT.levelWT,mDWT.WavFamily);%pwelch(y,[],[],512,mDWT.trials{i}.samplingRate,'onesided');
                instances(i,:) = C;
                labels(i,1) = floor(mDWT.trials{i}.label);
            end
            mDWT.instanceSet = ssveptoolkit.util.InstanceSet(instances,labels);
        end
        
        function configInfo = getConfigInfo(mDWT)
            configInfo = sprintf('DWT_Transformer\tchannel:%d\tseconds:%d\tlevelWT:%d\tWavFamily:%s',mDWT.channel,mDWT.seconds,mDWT.levelWT,mDWT.WavFamily);
        end
    end
   
end

