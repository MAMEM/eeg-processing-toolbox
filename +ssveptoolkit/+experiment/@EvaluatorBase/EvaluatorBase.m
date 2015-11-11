classdef  EvaluatorBase < handle
    %evaluate a classifier

    properties
        %classifier ("instanceSet" must be pre-set in the classifier instance)
        classifier;
        %the input instances
        instanceSet;
        %a struct with the input instances and the outputlabels
        resultSet;
    end
    
    methods 
        function EB = EvaluatorBase(classifier)
            if nargin > 0
                EB.classifier = classifier;
                EB.instanceSet = ssveptoolkit.util.InstanceSet(classifier.instanceSet.getDataset);
            end
        end
        
        function EB = leaveOneOutCV(EB)
            %leave one out cross validation
            numInstances = EB.instanceSet.getNumInstances;
            outputLabels = zeros(numInstances,1);
            outputScores = zeros(numInstances,1);
            outputRanking = zeros(numInstances, EB.instanceSet.getNumLabels);
            h = waitbar(0,'Cross-validating..');
            %TODO: parfor this?
            for i=1:numInstances
                waitbar(i/numInstances,h,sprintf('Cross-validating fold: %d/%d', i, numInstances));
                %train the classifier without 1 instance
                %TODO: this line will change
                EB.classifier.instanceSet = EB.instanceSet.removeInstance(i);
                EB.classifier.build();
                %predict the label of the omitted instance
                [outputLabels(i,1), outputScores(i,1), outputRanking(i,:)] = EB.classifier.classifyInstance(EB.instanceSet.getInstance(i));
            end
            %store the (final) results in a resultSet instances
            EB.resultSet = ssveptoolkit.util.ResultSet(EB.instanceSet.getDataset, outputLabels, outputScores, outputRanking);
            close(h);
        end
        
        function acc = getAccuracy(EB)
            conf = EB.resultSet.confusionMatrix;
            acc = sum(diag(conf))/sum(sum(conf))*100;
        end
        
        function confusionMatrix = getConfusionMatrix(EB)
            %returns confusion with labels as the last row
            %if you want the conf mat without labels then
            %"EB.resultSet.confusionMatrix"
            labels = unique(EB.resultSet.getLabels);
            confusionMatrix = horzcat(EB.resultSet.confusionMatrix, labels);
        end
        
        %@Elli: are these correct?
        %delete them if you want
        function TP = getNumTruePositives(EB)
            conf = EB.resultSet.confusionMatrix;
            TP = diag(conf)';
        end
        
        function TN = getNumTrueNegatives(EB)
            %mpakale tropos
            numInstances = EB.resultSet.getNumInstances;
            FN = EB.getNumFalseNegatives;
            TP = EB.getNumTruePositives;
            FP = EB.getNumFalsePositives;
            TN = numInstances - FN - TP - FP;
        end
        
        function FP = getNumFalsePositives(EB)
            conf = EB.resultSet.confusionMatrix;
            FP = sum(conf') - diag(conf)';
        end
        
        function FN = getNumFalseNegatives(EB)
            conf = EB.resultSet.confusionMatrix;
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

