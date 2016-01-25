classdef PYAR < ssveptoolkit.featextraction.FeatureExtractionBase
    
    properties (Access = public)
        channel;
        seconds;
        order;
        nfft;
        avgTime;
    end
    
    methods (Access = public)
        function mAR = PYAR(trials, seconds, channel,m_ord, nfft)
            if nargin == 0
                mAR.seconds = 0;
                mAR.channel = 1;
                mAR.order = 2;
                mAR.nfft = 512;
            elseif nargin == 1
                mAR.trials = trials;
                mAR.seconds = 0;
                mAR.channel = 1;
                mAR.order = 2;
                mAR.nfft = 512;
            elseif nargin == 2
                mAR.trials = trials;
                mAR.channel = 1;
                mAR.seconds = seconds;
                mAR.order = 2;
                mAR.nfft = 512;
            elseif nargin == 3
                mAR.trials = trials;
                mAR.channel = channel;
                mAR.seconds = seconds;
                mAR.order=2;
                mAR.nfft = 512;
            elseif nargin == 4
                mAR.trials = trials;
                mAR.channel = channel;
                mAR.seconds = seconds;
                mAR.order = m_ord;
                mAR.nfft = 512;
            elseif nargin == 5
                mAR.trials = trials;
                mAR.channel = channel;
                mAR.seconds = seconds;
                mAR.order = m_ord;
                mAR.nfft = nfft;
            else
                error('invalid number of arguments');
            end
        end
        
        function extract(mAR)
            NUM_FEATURES = mAR.nfft/2+1;
            numTrials = length(mAR.trials);
            instances = zeros(numTrials, NUM_FEATURES);
            labels = zeros(numTrials,1);
            tic
            for i=1:numTrials
                if length(mAR.seconds) ==1
                numsamples = mAR.trials{i}.samplingRate * mAR.seconds;
                if(numsamples == 0)
                    y = mAR.trials{i}.signal(mAR.channel,:);
                else
                    y = mAR.trials{i}.signal(mAR.channel, 1:numsamples);
                end
                elseif length(mAR.seconds) ==2
                    sampleA = mAR.trials{i}.samplingRate*mAR.seconds(1) + 1;
                    sampleB = mAR.trials{i}.samplingRate*mAR.seconds(2);
                else
                    error('invalid seconds parameter');
                end
                if isa(mAR.filter,'dfilt.df2sos') || isa(mAR.filter,'dfilt.df2')
                    y = filter(mAR.filter,y);
                elseif isa(mAR.filter,'dfilt.dffir')
                    y = filtfilt(mAR.filter.Numerator,1,y);
                end
                [pyy pff] = pyulear(y,mAR.order,mAR.nfft,mAR.trials{i}.samplingRate);
                instances(i,:) = pyy;
                labels(i,1) = floor(mAR.trials{i}.label);
            end
            mAR.avgTime = toc/numTrials;
            mAR.instanceSet = ssveptoolkit.util.InstanceSet(instances,labels);
        end
        
        function configInfo = getConfigInfo(mAR)
            configInfo = sprintf('PYAR\tchannel:%d\tseconds:%d\tnfft:%d\torder:%d',mAR.channel,mAR.seconds,mAR.nfft,mAR.order);
        end
        
                        
        function time = getTime(mAR)
            time = mAR.avgTime;
        end
    end
   
end

