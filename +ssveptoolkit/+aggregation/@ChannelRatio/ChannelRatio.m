classdef ChannelRatio < ssveptoolkit.aggregation.AggregatorBase;
    %CHANNELRATIO Summary of this class goes here
    %   This is probably 
    
    properties
    end
    
    methods
        
        function CR = ChannelRatio(CR)
        end
        
        function CR = aggregate(CR)
            numTransf = length(CR.transformers);
            if numTransf ~=2
                error ('ChannelRatio: Number of transformers should be 2');
            end
            in1 = CR.transformers{1}.getInstances;
            in2 = CR.transformers{2}.getInstances;
            ratio = in1./in2;
            CR.instanceSet = ssveptoolkit.util.InstanceSet(ratio,CR.transformers{1}.getLabels);
        end
        
        function configInfo = getConfigInfo(CR)
            configInfo = 'ChannelRatio';
        end
    end
    
end

