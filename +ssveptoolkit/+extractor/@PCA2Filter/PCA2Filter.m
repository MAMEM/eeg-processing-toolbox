classdef PCA2Filter < ssveptoolkit.extractor.FeatureExtractorBase
properties (Access = public)
        componentNum;
end
methods
        function PCA2 = PCA2Filter(instanceSet,componentNum)
            if nargin == 0
                PCA2.componentNum = 50;
            else
                PCA2.componentNum = componentNum;
                PCA2.originalInstanceSet = instanceSet;
            end
        end
        
        function PCA2 = filter(PCA2)
            ins = PCA2.originalInstanceSet.getInstances;
            [~,score,~,~,~] = pca(ins,'NumComponents',PCA2.componentNum);
            PCA2.filteredInstanceSet = ssveptoolkit.util.InstanceSet(score,PCA2.originalInstanceSet.getLabels);
        end
        function configInfo = getConfigInfo(PCA2)
                configInfo = sprintf('PCA2Filter\tcomponents:%d', PCA2.componentNum);
        end
end
end