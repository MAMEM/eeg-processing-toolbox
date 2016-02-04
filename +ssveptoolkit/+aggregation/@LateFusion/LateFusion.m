classdef LateFusion < ssveptoolkit.aggregation.AggregatorBase;
    
    properties
    end
    
    methods
        
        function LFA = LateFusion(LFA)
        end
        
        function LFA = aggregate(LFA)
            numTransf = length(LFA.featextractors);
            LFA.instanceSet = ssveptoolkit.util.FusionInstanceSet(LFA.featextractors{1}.instanceSet);
            
            for i=1:numTransf
                LFA.instanceSet = LFA.instanceSet.addInstanceSet(LFA.featextractors{i}.instanceSet);
            end
        end
        
        function configInfo = getConfigInfo(LFA)
            configInfo = 'LateFusion';
        end
        
                
        function time = getTime(LFA)
            time = 0;
        end
    end
    
end

