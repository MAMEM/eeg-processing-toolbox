classdef SVD < eegtoolkit.featselection.FeatureSelectionBase;
    properties (Access = public)
        modes;
        avgTime;
    end
    methods
        function SVD = SVD(modes)
            if nargin > 0
                SVD.modes = modes;
            end
        end
        
        function SVD = compute(SVD)
            tic
            [U, S, V] = svd(SVD.originalInstanceSet.getInstances);
            data_svd = U*S(:,1:SVD.modes)*V(1:SVD.modes,1:SVD.modes)';
            [numInst, ~] = size(data_svd);
            SVD.avgTime = toc/numInst;
            SVD.filteredInstanceSet = eegtoolkit.util.InstanceSet(data_svd, SVD.originalInstanceSet.getLabels);
        end
        function configInfo = getConfigInfo(SVD)
            configInfo = sprintf('SVD\tmodes:%d', SVD.modes);
        end
        
        function time = getTime(SVD)
            time = SVD.avgTime;
        end
    end
end