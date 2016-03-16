% RESULTEVALUATOR class
% Parses the results of an experiment and calculates various metrics
classdef  ResultEvaluator < handle
    properties
        resultSet; % A 'ResultSet' object containing the results of an experiment
        subjectid; % The subject ids corresponding
        sessionid;
    end
    
    methods 
        function RE = ResultEvaluator(resultSet)
            if nargin > 0
                RE.resultSet = resultSet;
            end
        end
        
        function acc = getAccuracy(RE)
            conf = RE.resultSet.confusionMatrix;
            acc = sum(diag(conf))/sum(sum(conf))*100;
        end
        
        function confusionMatrix = getConfusionMatrix(RE)
            %Returns the confusion matrix with labels as the last row
            %if you want the confusion matrix without labels then
            %access the confusionMatrix property of the resultSet directly
            labels = unique(RE.resultSet.getLabels);
            confusionMatrix = horzcat(RE.resultSet.confusionMatrix, labels);
        end
        
        function acc = getAccuracyForSession(RE,session)
            conf = RE.resultSet.subset(RE.sessionid==session).confusionMatrix;
            acc = sum(diag(conf))/sum(sum(conf))*100;
        end
        
        function accuracies = getAccuracyBySession(RE)
            unsessions = unique(RE.sessionid);
            for i=1:length(unsessions)
                accuracies(i) = RE.getAccuracyForSession(unsessions(i));
            end
        end
        
        function accuracies = getAccuracyByLabel(RE)
            [rows,~] = size(RE.resultSet.confusionMatrix);
            for i=1:rows
                accuracies(i) = RE.resultSet.confusionMatrix(i,i)/sum(RE.resultSet.confusionMatrix(i,:))*100;
            end
        end
        
%         function TP = getNumTruePositives(RE)
%             conf = RE.resultSet.confusionMatrix;
%             TP = diag(conf)';
%         end
%         
%         function TN = getNumTrueNegatives(RE)
%             numInstances = RE.resultSet.getNumInstances;
%             FN = RE.getNumFalseNegatives;
%             TP = RE.getNumTruePositives;
%             FP = RE.getNumFalsePositives;
%             TN = numInstances - FN - TP - FP;
%         end
%         
%         function FP = getNumFalsePositives(RE)
%             conf = RE.resultSet.confusionMatrix;
%             FP = sum(conf') - diag(conf)';
%         end
%         
%         function FN = getNumFalseNegatives(RE)
%             conf = RE.resultSet.confusionMatrix;
%             FN = sum(conf) - diag(conf)';
%         end
        
    end
end

