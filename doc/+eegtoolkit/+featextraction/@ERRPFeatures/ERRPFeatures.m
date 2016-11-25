classdef ERRPFeatures < eegtoolkit.featextraction.PSDExtractionBase%FeatureExtractionBase
    properties (Access = public)
        channel;
        avgTime;
%         downSampleFactor;
    end
    methods (Access = public)
        function ERRP = ERRPFeatures()
%             ERRP.downSampleFactor = 8;
            ERRP.channel = 1;
        end
        
        function extract(ERRP)
            
            numTrials = length(ERRP.trials);
            [~,numSamples]  =  size(ERRP.trials{1}.signal(ERRP.channel,:));
%             numFeatures = floor(numSamples/ERRP.downSampleFactor);
            instances = zeros(numTrials,numSamples);
            labels = zeros(numTrials,1);
            for i=1:numTrials
                instances(i,:) = ERRP.trials{i}.signal(ERRP.channel,:);
                labels(i) = ERRP.trials{i}.label;
            end
            ERRP.instanceSet = eegtoolkit.util.InstanceSet(instances, labels);
        end
        
        function configInfo = getConfigInfo(ERRP)
            configInfo = sprintf('ERRP features');
        end
        
        function time = getTime(ERRP)
            time = ERRP.avgTime;
        end
    end
    
end
