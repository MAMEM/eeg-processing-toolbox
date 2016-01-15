classdef SVDFilter < ssveptoolkit.extractor.FeatureExtractorBase
    properties (Access = public)
        modes;
    end
    methods
        function FF = SVDFilter(instanceSet,modes)
            if nargin == 0
                FF.modes = 80;
            else
                FF.modes = modes;
                FF.originalInstanceSet = instanceSet;
            end
        end
        
        function FF = filter(FF)
            [U, S, V] = svd(FF.originalInstanceSet.getInstances);
            data_svd = U*S(:,1:FF.modes)*V(1:FF.modes,1:FF.modes)';
            FF.filteredInstanceSet = ssveptoolkit.util.InstanceSet(data_svd, FF.originalInstanceSet.getLabels);
        end
        function configInfo = getConfigInfo(FF)
            configInfo = sprintf('SVDFilter\tmodes:%d', FF.modes);
        end
        
        function time = getTime(FF)
            time = 0;
        end
    end
end