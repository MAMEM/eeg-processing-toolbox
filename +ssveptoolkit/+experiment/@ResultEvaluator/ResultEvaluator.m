classdef  ResultEvaluator < handle
    %evaluate a classifier

    properties
        %the input instances
%         instanceSet;
        %a struct with the input instances and the outputlabels
        resultSet;
        subjectid;
    end
    
    methods 
        function RE = ResultEvaluator(resultSet)
            if nargin > 0
                RE.resultSet = resultSet;
%                 RE.instanceSet = ssveptoolkit.util.InstanceSet(resultSet.instanceSet.getDataset);
            end
        end
        
        function acc = getAccuracy(RE)
            conf = RE.resultSet.confusionMatrix;
            acc = sum(diag(conf))/sum(sum(conf))*100;
        end
        
        function confusionMatrix = getConfusionMatrix(RE)
            %returns confusion with labels as the last row
            %if you want the conf mat without labels then
            %"EB.resultSet.confusionMatrix"
            labels = unique(RE.resultSet.getLabels);
            confusionMatrix = horzcat(RE.resultSet.confusionMatrix, labels);
        end
        
        %@Elli: are these correct?
        %delete them if you want
        function TP = getNumTruePositives(RE)
            conf = RE.resultSet.confusionMatrix;
            TP = diag(conf)';
        end
        
        function TN = getNumTrueNegatives(RE)
            %mpakale tropos
            numInstances = RE.resultSet.getNumInstances;
            FN = RE.getNumFalseNegatives;
            TP = RE.getNumTruePositives;
            FP = RE.getNumFalsePositives;
            TN = numInstances - FN - TP - FP;
        end
        
        function FP = getNumFalsePositives(RE)
            conf = RE.resultSet.confusionMatrix;
            FP = sum(conf') - diag(conf)';
        end
        
        function FN = getNumFalseNegatives(RE)
            conf = RE.resultSet.confusionMatrix;
            FN = sum(conf) - diag(conf)';
        end
        
%         
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

