classdef ChannelAveraging < ssveptoolkit.aggregation.AggregatorBase;
    
    properties
    end
    
    methods
        
        function CA = ChannelAveraging(CA)
        end
        
        function CA = aggregate(CA)
            numExtr = length(CA.featextractors);
            numInstances = CA.featextractors{1}.getInstanceSet.getNumInstances;
            numFeatures = CA.featextractors{1}.getInstanceSet.getNumFeatures;
            fused = zeros(numInstances,numFeatures,numExtr);
            for i=1:numExtr
                fused(:,:,i) = CA.featextractors{i}.getInstances;
            end
            fusedMean = mean(fused,3);
            CA.instanceSet = ssveptoolkit.util.InstanceSet(fusedMean,CA.featextractors{1}.getLabels);
        end
        
        function configInfo = getConfigInfo(CA)
            configInfo = 'ChannelAveraging';
        end
        
        function time = getTime(CA)
            time = 0;
        end
    end
    
end

