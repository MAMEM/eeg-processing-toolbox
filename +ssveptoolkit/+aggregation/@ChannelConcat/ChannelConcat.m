classdef ChannelConcat < ssveptoolkit.aggregation.AggregatorBase;
    %CHANNELCONCAT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
        function CC = ChannelConcat(CC)
        end
        
        function CC = aggregate(CC)
            numTransf = length(CC.transformers);
            fused = [];
            for i=1:numTransf
                fused = horzcat(fused,CC.transformers{i}.getInstances);
            end
%             [~,y] = size(fused);
%             ind = randperm(y);
%             fused = fused(:,ind);
            CC.instanceSet = ssveptoolkit.util.InstanceSet(fused,CC.transformers{1}.getLabels);
        end
        
        function configInfo = getConfigInfo(CC)
            configInfo = 'ChannelConcat';
        end
        
                
        function time = getTime(CC)
            time = 0;
        end
    end
    
end

