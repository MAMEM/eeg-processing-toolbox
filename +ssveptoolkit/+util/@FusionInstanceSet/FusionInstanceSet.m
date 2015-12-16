classdef FusionInstanceSet < ssveptoolkit.util.InstanceSet
    %FUSIONINSTANCESET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        numFusion;
        instanceSets;
    end
    
    methods 
        function FIS = FusionInstanceSet(baseInstanceSet)
            FIS = FIS@ssveptoolkit.util.InstanceSet(baseInstanceSet.getDataset);
            FIS.numFusion = 0;
            FIS.instanceSets = {};
        end
        
        function FIS = addInstanceSet(FIS, instanceSet)
            FIS.numFusion = FIS.numFusion + 1;
            FIS.instanceSets{FIS.numFusion} = instanceSet;
        end
        
        function FIS = removeInstancesWithIndices(FIS, indices)
            for i=1:length(FIS.instanceSets)
                FIS.instanceSets{i} = FIS.instanceSets{i}.removeInstancesWithIndices(indices);
            end
        end
        
        function instances = getInstancesWithIndices(FIS, indices)
            instances = zeros(length(indices),FIS.getNumFeatures,FIS.numFusion);
            for i=1:length(FIS.instanceSets)
                instances(:,:,i) = FIS.instanceSets{i}.getInstancesWithIndices(indices);
            end
        end
    end
    
end
