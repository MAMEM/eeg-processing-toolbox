classdef WaveDec < ssveptoolkit.featextraction.FeatureExtractionBase
    
    properties (Access = public)
        channel;
        seconds;
        levelWT;
        WavFamily;
        avgTime;
    end
    
    methods (Access = public)
        function WD = WaveDec(trials, seconds, channel,levWT,WavFam)
            if nargin == 0
                WD.seconds = 0;
                WD.channel = 1;
                WD.levelWT = 5;
                WD.WavFamily = 'db1';
            elseif nargin == 1
                WD.trials = trials;
                WD.seconds = 0;
                WD.channel = 1;
                WD.levelWT = 5;
                WD.WavFamily = 'db1';
            elseif nargin == 2
                WD.trials = trials;
                WD.channel = 1;
                WD.seconds = seconds;
                WD.levelWT = 5;
                WD.WavFamily = 'db1';
            elseif nargin == 3
                WD.trials = trials;
                WD.channel = channel;
                WD.seconds = seconds;
                WD.levelWT = 5;
                WD.WavFamily = 'db1';
            elseif nargin == 4
                WD.trials = trials;
                WD.channel = channel;
                WD.seconds = seconds;
                WD.levelWT = levWT;
                WD.WavFamily = 'db1';
            elseif nargin ==5
                WD.trials = trials;
                WD.channel = channel;
                WD.seconds = seconds;
                WD.levelWT = levWT;
                WD.WavFamily = WavFam;
            else
                error('invalid number of arguments');
            end
            WD.avgTime = 0;
        end
        
        function extract(WD)
            if length(WD.seconds)==1
                numsamples = WD.trials{1}.samplingRate * WD.seconds;
                if (numsamples == 0)
                    numsamples = size(WD.trials{1}.signal(WD.channel,:),2);
                end
                numTrials = length(WD.trials);
                
                [C L] = wavedec(WD.trials{1}.signal(WD.channel, 1:numsamples),WD.levelWT,WD.WavFamily);
                instances = zeros(numTrials, length(C));
                labels = zeros(numTrials,1);
            elseif length(WD.seconds) == 2
                sampleA = WD.trials{1}.samplingRate * WD.seconds(1) + 1;
                sampleB = WD.trials{1}.samplingRate * WD.seconds(2);
                numTrials = length(WD.trials);
                [C L] = wavedec(WD.trials{1}.signal(WD.channel, sampleA:sampleB),WD.levelWT,WD.WavFamily);
                instances = zeros(numTrials, length(C));
                labels = zeros(numTrials,1);
            else
                error('invalid seconds parameter');
            end
            tic
            for i=1:numTrials
                if length(WD.seconds) == 1
                    numsamples = WD.trials{i}.samplingRate * WD.seconds;
                    if(numsamples == 0)
                        y = WD.trials{i}.signal(WD.channel,:);
                    else
                        y = WD.trials{i}.signal(WD.channel, 1:numsamples);
                    end
                    % zero padding to nearest power of 2
                    if isa(WD.filter,'dfilt.df2sos')
                        y = filter(WD.filter,y);
                    elseif isa(WD.filter,'dfilt.dffir')
                        y = filtfilt(WD.filter.Numerator,1,y);
                    end
                    [C L] = wavedec(y,WD.levelWT,WD.WavFamily);%pwelch(y,[],[],512,mDWT.trials{i}.samplingRate,'onesided');
                elseif length(WD.seconds) == 2
                    sampleA = WD.trials{i}.samplingRate * WD.seconds(1) + 1;
                    sampleB = WD.trials{i}.samplingRate * WD.seconds(2);
                    y = WD.trials{i}.signal(WD.channel,sampleA:sampleB);
                    if isa(WD.filter,'dfilt.df2sos') || isa(WD.filter,'dfilt.df2')
                        y = filter(WD.filter,y);
                    elseif isa(WD.filter,'dfilt.dffir')
                        y = filtfilt(WD.filter.Numerator,1,y);
                    end
                    [C L] = wavedec(y,WD.levelWT,WD.WavFamily);%pwelch(y,[],[],512,mDWT.trials{i}.samplingRate,'onesided');
                else
                    error('invalid seconds parameter');
                end
                instances(i,:) = C;
                labels(i,1) = floor(WD.trials{i}.label);
            end
            WD.avgTime = toc/numTrials;
            WD.instanceSet = ssveptoolkit.util.InstanceSet(instances,labels);
        end
        
        function configInfo = getConfigInfo(WD)
            configInfo = sprintf('WD\tchannel:%d\tseconds:%d\tlevelWT:%d\tWavFamily:%s',WD.channel,WD.seconds,WD.levelWT,WD.WavFamily);
        end
        
                        
        function time = getTime(WD)
            time = WD.avgTime;
        end
    end
    
end