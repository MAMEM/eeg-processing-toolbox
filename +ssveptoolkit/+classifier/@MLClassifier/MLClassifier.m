classdef MLClassifier < ssveptoolkit.classifier.ClassifierBase
    
    properties (Constant)
        
    end
    
    properties
        Learners; %'discriminant': Discriminant analysis. | 'knn': k-nearest neighbors. | 'naivebayes': Naive Bayes.
        % 'svm': SVM. | 'tree': Classification trees. | any Matlab template classifier
        Coding; % Coding design 'onevsall' (default) | 'allpairs' | 'binarycomplete' | 'denserandom' | 'onevsone' | 'ordinal' | 'sparserandom' | 'ternarycomplete' | numeric matrix
        FitPosterior; % Flag indicating whether to transform scores to posterior probabilities false or 0 (default) | true or 1
        Prior % 'empirical' (default) or 'uniform'.  Prior probabilities for each class.
        models;
    end
    
    methods (Access = public)
        function MLC = MLClassifier(instanceSet, learners, coding, fitPosterior, prior)
            %set default parameters
            MLC.Learners = 'svm';
            MLC.Coding='onevsall';
            MLC.FitPosterior='off';
            MLC.Prior='empirical';
            
            if nargin > 0
                MLC.instanceSet = instanceSet;
            end
            if nargin > 1
                MLC.Learners = learners;
            end
            if nargin > 2
                MLC.Coding=coding;
            end
            if nargin > 3
                MLC.FitPosterior=fitPosterior;
            end
            if nargin > 4
                MLC.Prior=prior;
            end
        end
        
        function MLC = build(MLC)
            %clear all from previous calls to "build"
            MLC.reset;
            numLabels = MLC.instanceSet.getNumLabels;
            uniqueLabels = unique(MLC.instanceSet.getLabels);
            
            % ---- Multi-Class ----- %
            instances=MLC.instanceSet.instances;
            labels=MLC.instanceSet.labels;
            
            %t=templateSVM('KernelFunction','linear');
            MLC.models{1}=fitcecoc(instances,labels,'Coding', MLC.Coding,'FitPosterior', MLC.FitPosterior,'Prior',MLC.Prior,'Learners',MLC.Learners);
        end
        
        function [output, probabilities, ranking] = classifyInstance(MLC,instance)

            %TODO:should print an error if 'build' has not been called
            numModels = length(MLC.models);
            [numinstance, ~] = size(instance);
            %scores = zeros(numModels,numinstance);
            
            % ---- Multi-class ----- %
            [label,scores,loss] = predict(MLC.models{1},instance);
            
            output = zeros(numinstance,1);
            probabilities = zeros(numinstance,1);
            %we need these for ranking metrics (e.g. mAP)
            ranking = scores;
            for i=1:numinstance
                %select the class with the highest probability
                [prob, idx] = max(scores(i,:));
                uniqueLabels = unique(MLC.instanceSet.getLabels);
                %output the label with highest probability
                output(i,1) = uniqueLabels(idx);
                %return the probability for the output label
                probabilities(i,1) = prob;
            end
        end
        
        function MLC = reset(MLC)
            %delete all stored models
            MLC.models = {};
        end
        
        function configInfo = getConfigInfo(MLC)
            configInfo=sprintf('MLClassifier\tCoding:%s\tFitPosterior:%s\tPrior:%s\n\tLearners:', MLC.Coding, MLC.FitPosterior,MLC.Prior);
            disp(MLC.Learners)
            %configInfo = 'MLSVMClassifier (Config info not supported yet)';
        end
        
                        
        function time = getTime(MLC)
            time = 0;
        end
        
    end
end

