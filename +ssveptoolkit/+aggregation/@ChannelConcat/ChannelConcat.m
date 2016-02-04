classdef ChannelConcat < ssveptoolkit.aggregation.AggregatorBase;
    
    properties
    end
    
    methods
        
        function CC = ChannelConcat(CC)
        end
        
        function CC = aggregate(CC)
            numExtract = length(CC.featextractors);
            fused = [];
            for i=1:numExtract
                fused = horzcat(fused,CC.featextractors{i}.getInstances);
            end
%             [~,y] = size(fused);
%             ind = randperm(y);
%             fused = fused(:,ind);
            CC.instanceSet = ssveptoolkit.util.InstanceSet(fused,CC.featextractors{1}.getLabels);
        end
        
        function configInfo = getConfigInfo(CC)
            configInfo = 'ChannelConcat';
        end
        
                
        function time = getTime(CC)
            time = 0;
        end
    end
    
end

