classdef PCA < eegtoolkit.featselection.FeatureSelectionBase
    properties (Access = public)
        componentNum;
        avgTime;
    end
    methods
        function PCA = PCA(instanceSet,componentNum)
            if nargin == 0
                PCA.componentNum = 50;
            else
                PCA.componentNum = componentNum;
                PCA.originalInstanceSet = instanceSet;
            end
        end
        
        function PCA = compute(PCA)
            ins = PCA.originalInstanceSet.getInstances;
            [numInst,~] = size(ins);
            tic
            [~,score,~,~,~] = pca(ins,'NumComponents',PCA.componentNum);
            PCA.avgTime = toc/numInst;
            PCA.filteredInstanceSet = eegtoolkit.util.InstanceSet(score,PCA.originalInstanceSet.getLabels);
        end
        function configInfo = getConfigInfo(PCA)
            configInfo = sprintf('PCA\tcomponents:%d', PCA.componentNum);
        end
        
        function time = getTime(PCA)
            time = PCA.avgTime;
        end
    end
end