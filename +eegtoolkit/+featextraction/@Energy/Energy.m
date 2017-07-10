classdef Energy < eegtoolkit.featextraction.FeatureExtractionBase
    
    properties (Access = public)
        channel;
    end
    
    methods (Access = public)
        function E= Energy()
            E.channel = 1;
        end
        
        function extract(E)
            numTrials = length(E.trials);
            instances = zeros(numTrials,1);
            labels = zeros(numTrials,1);
            for i=1:numTrials
                instances(i) = sum(E.trials{i}.signal(E.channel,:).^2);
                labels(i) = E.trials{i}.label;
                labels(i) = E.trials{i}.label;
            end
            E.instanceSet = eegtoolkit.util.InstanceSet(instances,labels);
        end
        
        function configInfo = getConfigInfo(E)
            configInfo = 'Simple Energy features';
        end
        
                        
        function time = getTime(E)
            time = 0;
        end
    end
    
end

