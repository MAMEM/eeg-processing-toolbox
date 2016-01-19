classdef SVD < ssveptoolkit.featselection.FeatureSelectionBase;
    properties (Access = public)
        modes;
    end
    methods
        function SVD = SVD(instanceSet,modes)
            if nargin == 0
                SVD.modes = 80;
            else
                SVD.modes = modes;
                SVD.originalInstanceSet = instanceSet;
            end
        end
        
        function SVD = compute(SVD)
            [U, S, V] = svd(SVD.originalInstanceSet.getInstances);
            data_svd = U*S(:,1:SVD.modes)*V(1:SVD.modes,1:SVD.modes)';
            SVD.filteredInstanceSet = ssveptoolkit.util.InstanceSet(data_svd, SVD.originalInstanceSet.getLabels);
        end
        function configInfo = getConfigInfo(SVD)
            configInfo = sprintf('SVD\tmodes:%d', SVD.modes);
        end
        
        function time = getTime(SVD)
            time = 0;
        end
    end
end