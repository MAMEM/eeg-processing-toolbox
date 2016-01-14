classdef ChannelAveraging < ssveptoolkit.aggregation.AggregatorBase;
    %CHANNELAVERAGING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
        function CA = ChannelAveraging(CA)
        end
        
        function CA = aggregate(CA)
            numTransf = length(CA.transformers);
            numInstances = CA.transformers{1}.getInstanceSet.getNumInstances;
            numFeatures = CA.transformers{1}.getInstanceSet.getNumFeatures;
            fused = zeros(numInstances,numFeatures,numTransf);
            for i=1:numTransf
                fused(:,:,i) = CA.transformers{i}.getInstances;
            end
            fusedMean = mean(fused,3);
            CA.instanceSet = ssveptoolkit.util.InstanceSet(fusedMean,CA.transformers{1}.getLabels);
        end
        
        function configInfo = getConfigInfo(CA)
            configInfo = 'ChannelAveraging';
        end
        
        function time = getTime(CA)
            time = 0;
        end
    end
    
end

