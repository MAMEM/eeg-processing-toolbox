classdef ChannelRatio < eegtoolkit.aggregation.AggregatorBase;
    
    properties
    end
    
    methods
        
        function CR = ChannelRatio(CR)
        end
        
        function CR = aggregate(CR)
            numExtract = length(CR.featextractors);
            if numExtract ~=2
                error ('ChannelRatio: Number of transformers should be 2');
            end
            in1 = CR.featextractors{1}.getInstances;
            in2 = CR.featextractors{2}.getInstances;
            ratio = in1./in2;
            CR.instanceSet = eegtoolkit.util.InstanceSet(ratio,CR.featextractors{1}.getLabels);
        end
        
        function configInfo = getConfigInfo(CR)
            configInfo = 'ChannelRatio';
        end
        
                
        function time = getTime(CR)
            time = 0;
        end
    end
    
end

