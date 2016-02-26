% RESULTSET class
% Stores the results of an experiment
classdef ResultSet < ssveptoolkit.util.InstanceSet
    
    properties
        outputLabels; % The output labels 
        outputProbabilities; % Probabilities
        outputRanking; % Confidence scores
        confusionMatrix; % The Confusion Matrix
    end
    
    methods
        function RS = ResultSet(instanceSet, labels, probabilities, ranking)
            %Constructor method
            %Input:
            %(InstanceSet object): the original instanceSet
            %Labels: a vector containing the output labels of the
            %experiment
            %Proababilities: a vector containing the probabilities of each
            %label
            %Ranking (optional): a matrix containing a score for each label
            
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
            RS.confusionMatrix = RS.confusionMatrix';
            %if classifier supports ranking/probabilities
            if nargin > 2
                RS.outputProbabilities = probabilities;
                RS.outputRanking = ranking;
            end
        end
        
        function RSSubset = subset(RS,indices)
            sOutputLabels = RS.outputLabels(indices);
            sOutputProbabilities = RS.outputProbabilities(indices);
            sInstanceSet = RS.getDatasetWithIndices(indices);
            if isempty(RS.outputProbabilities)
                RSSubset = ssveptoolkit.util.ResultSet(sInstanceSet,sOutputLabels,sOutputProbabilities);
            else
                sOutputRanking = RS.outputRanking(indices);
                RSSubset = ssveptoolkit.util.ResultSet(sInstanceSet,sOutputLabels,sOutputProbabilities,sOutputRanking);
            end
        end
            
    end
    
end

