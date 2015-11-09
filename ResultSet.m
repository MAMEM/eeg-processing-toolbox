classdef ResultSet < InstanceSet
    
    properties
        outputLabels;
        outputProbabilities;
        outputRanking;
    end
    
    methods
        function RS = ResultSet(instanceSet, labels, probabilities, ranking)
            RS = RS@InstanceSet(instanceSet);
            RS.outputLabels = labels;
            RS.outputProbabilities = probabilities;
            RS.outputRanking = ranking;
        end
    end
    
end

