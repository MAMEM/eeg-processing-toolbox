classdef ResultSet < ssveptoolkit.util.InstanceSet
    
    properties
        outputLabels;
        outputProbabilities;
        outputRanking;
        confusionMatrix;
    end
    
    methods
        function RS = ResultSet(instanceSet, labels, probabilities, ranking)
            RS = RS@ssveptoolkit.util.InstanceSet(instanceSet);
            RS.outputLabels = labels;

            %compute the confusion matrix
            labels = unique(RS.getLabels);
            numLabels = length(labels);
            RS.confusionMatrix = zeros(numLabels);
            trueLabels = RS.getLabels;
            numInstances = RS.getNumInstances;
            for k=1:numInstances
                idx1 = find(labels==RS.outputLabels(k,1));
                idx2 = find(labels==trueLabels(k,1));
                RS.confusionMatrix(idx1,idx2) = RS.confusionMatrix(idx1,idx2)+ 1;
            end
            %if classifier supports ranking/probabilities
            if nargin > 2
                RS.outputProbabilities = probabilities;
                RS.outputRanking = ranking;
            end
        end
    end
    
end

