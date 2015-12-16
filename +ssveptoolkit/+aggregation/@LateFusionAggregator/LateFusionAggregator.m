classdef LateFusionAggregator < ssveptoolkit.aggregation.AggregatorBase;
    %CHANNELCONCAT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
        function LFA = LateFusionAggregator(LFA)
        end
        
        function LFA = aggregate(LFA)
            numTransf = length(LFA.transformers);
            LFA.instanceSet = ssveptoolkit.util.FusionInstanceSet(LFA.transformers{1}.instanceSet);
            
            for i=1:numTransf
                LFA.instanceSet = LFA.instanceSet.addInstanceSet(LFA.transformers{i}.instanceSet);
            end
        end
        
        function configInfo = getConfigInfo(LFA)
            configInfo = 'LateFusionAggregator';
        end
    end
    
end

