classdef DWT < ssveptoolkit.featextraction.FeatureExtractionBase
    
    properties (Access = public)
        numLevels;%not used yet
        wavFamily;
        channel;
        avgTime;
    end
    
    methods (Access = public)
        function DWT = DWT()
            DWT.wavFamily = 'sym2';
            DWT.numLevels = 3; %not used yet
            DWT.channel = 1;
            DWT.avgTime = 0;
        end
        
        function extract(DWT)
            numTrials = length(DWT.trials);
            instances = zeros(numTrials,4);
            labels = zeros(numTrials,1);
            for i=1:numTrials
                [a1 d1] = dwt(DWT.trials{i}.signal(DWT.channel,:),DWT.wavFamily);
                [a2 d2] = dwt(a1,DWT.wavFamily);
                [a3 d3] = dwt(a2,DWT.wavFamily);
                instances(i,1) = mean(abs(d2));
                instances(i,2) = std(d2);
                instances(i,3) = mean(abs(d3));
                instances(i,4) = std(d3);
                labels(i) = DWT.trials{i}.label;
            end
            DWT.instanceSet = ssveptoolkit.util.InstanceSet(instances,labels);
        end
        
        function configInfo = getConfigInfo(WD)
            configInfo = sprintf('WD\tchannel:%d\tseconds:%d\tlevelWT:%d\tWavFamily:%s',WD.channel,WD.seconds,WD.levelWT,WD.WavFamily);
        end
        
                        
        function time = getTime(WD)
            time = WD.avgTime;
        end
    end
    
end