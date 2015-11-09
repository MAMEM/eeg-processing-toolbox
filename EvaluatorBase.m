classdef  EvaluatorBase < handle

    properties
        classifier;
        instanceSet;
        resultSet;
    end
    
    methods 
        function EB = EvaluatorBase(classifier)
            if nargin > 0
                EB.classifier = classifier;
                EB.instanceSet = InstanceSet(classifier.instanceSet.getDataset);
            end
        end
        
        function EB = leaveOneOutCV(EB)
            numInstances = EB.instanceSet.getNumInstances;
            outputLabels = zeros(numInstances,1);
            outputScores = zeros(numInstances,1);
            outputRanking = zeros(numInstances, EB.instanceSet.getNumLabels);
            for i=1:numInstances
%                 EB.classifier.reset;
                EB.classifier.instanceSet = EB.instanceSet.removeInstance(i);
                EB.classifier.build();
                [outputLabels(i,1), outputScores(i,1), outputRanking] = EB.classifier.classifyInstance(EB.instanceSet.getInstance(i));
            end
            EB.resultSet = ResultSet(EB.instanceSet.getDataset, outputLabels, outputScores, outputRanking);
        end
        
        function acc = getAccuracy(EB)
            outputLabels = EB.resultSet.outputLabels;
            trueLabels = EB.resultSet.getLabels;
            numInstances = EB.resultSet.getNumInstances;
            numCorrect = 0;
            for i=1:numInstances
                if outputLabels(i,1) == trueLabels(i,1)
                    numCorrect = numCorrect +1;
                end
            end
            acc = (numCorrect/numInstances) *100.0;
        end
        
%         function AP = getAP(EB)
%             outputScores = EB.resultSet.outputProbabilities;
%             outputLabels = EB.resultSet.outputLabels;
%             outputRanking = EB.resultSet.outputRanking;
%             [~, IDs] = sort(outputScores,'descend');
%             Ranked = outputLabels(IDs(:));
%             
%             AP = 0;
%             for i=1:length(Ranked)
%                 if Ranked(i) ==1
%                     temp = Ranked(1:i);
%                     TP = sum(temp == 1);
%                     Pr = TP/length(temp);
%                     AP = AP + Pr;
%                 end
%             end
%             
%             Total = sum(Ranked == 1);
%             AP = AP/Total;
%         end
    end
end

