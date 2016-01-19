classdef Adaboost < ssveptoolkit.classification.ClassifierBase
    
    properties (Constant)

    end
    
    properties
        Method % AdaboostM2 (default), TotalBoost, LPBoost, Subspace, etc
        NLearn % Number of learners (default 100)
        Learners % Tree (default), KNN (only for Subspace), Discriminant(recommended for subspace), Custom
        models; 
    end
    
    methods (Access = public)
        function BOOST = Adaboost(instanceSet, Method, NLearn, Learners)
            %set default parameters
            BOOST.Method = 'AdaBoostM2';
            BOOST.NLearn=100;
            BOOST.Learners = 'Tree';
            if nargin > 0
                BOOST.instanceSet = instanceSet;
            end
            if nargin > 1
                BOOST.Method = Method;
            end
            if nargin > 2 
                BOOST.NLearn=NLearn;
            end
            if nargin > 3
                BOOST.Learners = Learners;
            end
        end
        
        function BOOST = build(BOOST)
            %clear all from previous calls to "build"
            BOOST.reset;
            numLabels = BOOST.instanceSet.getNumLabels;
            uniqueLabels = unique(BOOST.instanceSet.getLabels);
            
            % ---- Multi-Class ----- %
            instances=BOOST.instanceSet.instances;
            labels=BOOST.instanceSet.labels;
            
            BOOST.models{1} = fitensemble(instances,labels,BOOST.Method, BOOST.NLearn, BOOST.Learners,...
                'Type','Classification');

%             for i=1:numLabels
%                 currentLabel = uniqueLabels(i);
%                 labels = zeros(BOOST.instanceSet.getNumInstances,1)-1;
%                 labels(BOOST.instanceSet.getInstanceIndicesForLabel(currentLabel)) = 1;
%                 instances = sparse(BOOST.instanceSet.getInstances);
%                 N = length(labels); % X training labels
%                 W = 1/N * ones(N,1); %Weights initialization
%                 M = 10; % Number of boosting iterations
%                 for m=1:M
%                     C = 1; %The cost parameters of the linear SVM, you can...
%                     % perform a grid search for the optimal value as well
%                     
%                     %Calculate the error and alpha in adaBoost with cross validation
%                     cmd = ['-c ', num2str(C), ' -b 1'];
%                     model = svmtrain(W,labels, instances, cmd);
%                     [Xout, acc, ~] = svmpredict(labels, instances,model);
%                     
%                     err = sum(.5 * W .* acc * N)/sum(W);
%                     alpha = log( (1-err)/err );
%                     
%                     % update the weight
%                     W = W.*exp( - alpha.*Xout.*X );
%                     W = W/norm(W);
%                 end
%                 BOOST.models{i} = model;
%                 
%             end
            
        end
        
        function [output, probabilities, ranking] = classifyInstance(BOOST,instance)
            %input = instance matrix rows = instances, cols = attributes
            %output = predicted class
            %probabilities = probability for predicted class
            %ranking = propabilities for all classes (e.g. to use with mAP)
            
            
            %TODO:should print an error if 'build' has not been called
            numModels = length(BOOST.models);
            [numinstance, ~] = size(instance);
            scores = zeros(numModels,numinstance);
             
            % ---- Multi-class ----- %
            [label,scores] = predict(BOOST.models{1},instance); 
            

             output = zeros(numinstance,1);
             probabilities = zeros(numinstance,1);
             %we need these for ranking metrics (e.g. mAP)
             ranking = scores;
             for i=1:numinstance
                 %select the class with the highest probability
                 [prob, idx] = max(scores(i,:));
                 uniqueLabels = unique(BOOST.instanceSet.getLabels);
                 %output the label with highest probability
                 output(i,1) = uniqueLabels(idx);
                 %return the probability for the output label
                 probabilities(i,1) = prob;
             end
        end
        
        function BOOST = reset(BOOST)
            %delete all stored models
            BOOST.models = {};
        end
        
        function configInfo = getConfigInfo(BOOST)
            configInfo = sprintf('Adaboost: Method: %s NLearn: %d Learners: %s',...
                BOOST.Method, BOOST.NLearn, BOOST.Learners);
        end
        
                        
        function time = getTime(BOOST)
            time = 0;
        end
                
    end
end

