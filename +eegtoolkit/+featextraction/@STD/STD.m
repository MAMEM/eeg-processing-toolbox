classdef STD < eegtoolkit.featextraction.FeatureExtractionBase
    
    properties (Access = public);
        channel;
    end
    
    methods (Access = public)
        function STD = STD()
        end
        
        function extract(STD)
            numTrials = length(STD.trials);
            instances = zeros(numTrials,1);
            labels = zeros(numTrials,1);
            for i=1:numTrials
                instances(i,1) = std(STD.trials{i}.signal(STD.channel,:))*100;
                labels(i) = STD.trials{i}.label;
            end
            STD.instanceSet = eegtoolkit.util.InstanceSet(instances,labels);
        end
        
        function configInfo = getConfigInfo(STD)
            configInfo = 'Standard Deviation';
        end
        
        function time = getTime(STD)
            time = 0;
        end
        
    end
end

