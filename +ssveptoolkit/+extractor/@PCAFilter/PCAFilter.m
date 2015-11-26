classdef PCAFilter < ssveptoolkit.extractor.FeatureExtractorBase
properties (Access = public)
        componentNum;
end
methods
        function FF = PCAFilter(instanceSet,componentNum)
            if nargin == 0
                FF.componentNum = 50;
            else
                FF.componentNum = componentNum;
                FF.originalInstanceSet = instanceSet;
            end
        end
        
        function FF = filter(FF)
            B = (FF.originalInstanceSet.getInstances-repmat(mean(FF.originalInstanceSet.getInstances),[size(FF.originalInstanceSet.getInstances,1) 1]))./repmat(std(FF.originalInstanceSet.getInstances),[size(FF.originalInstanceSet.getInstances,1) 1]);
            [V, D] = eig(cov(B));
            PC = B*V(:,end-FF.componentNum:end);
            FF.filteredInstanceSet = ssveptoolkit.util.InstanceSet(PC, FF.originalInstanceSet.getLabels);
        end
        function configInfo = getConfigInfo(FF)
                configInfo = sprintf('PCAFilter\tcomponents:%d', FF.componentNum);
        end
end
end