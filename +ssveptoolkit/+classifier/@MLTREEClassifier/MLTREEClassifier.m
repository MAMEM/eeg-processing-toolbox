
classdef MLTREEClassifier < ssveptoolkit.classifier.ClassifierBase
    
    properties (Constant)

    end
    
    properties
       AlgorithmForCategorical; % Algorithm for best categorical predictor split 'Exact' | 'PullLeft' | 'PCA' | 'OVAbyClass' 
       MaxNumSplits; % Maximal number of decision splits. size(X,1) - 1 (default) | positive integer
       MinLeafSize; % Minimum number of leaf node observations 1 (default) | positive integer value
       MinParentSize; % Minimum number of branch node observations 10 (default) | positive integer value
       NumVariablesToSample; % Number of predictors to select at random for each split 'all' | positive integer value
       ScoreTransform % 'none' (default). Score transform function. Check http://www.mathworks.com/help/stats/fitcdiscr.html
       Prior; % Prior probabilities 'empirical' (default) | 'uniform' | vector of scalar values | structure
       models; 
    end
    
    methods (Access = public)
        function MLTREE = MLTREEClassifier(instanceSet, algorithmForCategorical, maxNumSplits, minLeafSize, minParentSize, numVariablesToSample, scoreTransform, prior)
            %set default parameters
            if nargin > 0
                MLTREE.instanceSet = instanceSet;
            end
            if nargin > 1
                MLTREE.AlgorithmForCategorical = algorithmForCategorical;
            end
            if nargin > 2 
                MLTREE.MaxNumSplits=maxNumSplits;
            end
            if nargin > 3
                MLTREE.MinLeafSize = minLeafSize;
            end
            if nargin > 4
                MLTREE.MinParentSize = minParentSize;
            end
            if nargin > 5
                MLTREE.NumVariablesToSample = numVariablesToSample;
            end
            if nargin > 6
                MLTREE.ScoreTransform = scoreTransform;
            end
            if nargin > 7
                MLTREE.Prior = prior;
            end
        end
        
        function MLTREE = build(MLTREE)
            %clear all from previous calls to "build"
            MLTREE.reset;
            numLabels = MLTREE.instanceSet.getNumLabels;
            uniqueLabels = unique(MLTREE.instanceSet.getLabels);
           
            % ---- Multi-Class ----- %
            instances=MLTREE.instanceSet.instances;
            labels=MLTREE.instanceSet.labels;
            
            %LDA.models{1}=fitcecoc(instances,labels,'Coding','ternarycomplete');
            MLTREE.models{1} = fitctree(instances,labels,'AlgorithmForCategorical',MLTREE.AlgorithmForCategorical,'MaxNumSplits',MLTREE.MaxNumSplits,'MinLeafSize',MLTREE.MinLeafSize,'MinParentSize',MLTREE.MinParentSize,'NumVariablesToSample', MLTREE.NumVariablesToSample,'ScoreTransform',MLTREE.ScoreTransform, 'Prior',MLTREE.Prior);
     
            
            % ---- One (vs) All ----- %
%             for i=1:numLabels
%                 currentLabel = uniqueLabels(i);
%                 labels = zeros(LDA.instanceSet.getNumInstances,1)-1;
%                 labels(LDA.instanceSet.getInstanceIndicesForLabel(currentLabel)) = 1;
%                 instances = sparse(LDA.instanceSet.getInstances);
%                 LDA.models{i} = libsvmtrain(labels,instances, '-t 0 -c 1 -b 1');
%                 if LDA.kernel == LDA.KERNEL_LINEAR;
%                    %store the models in an instance variable
%                    LDA.models{i} = libsvmtrain(labels, instances, sprintf('-t %d -c %f -b 1 -q', LDA.kernel, LDA.cost));
%                 elseif LDA.kernel == LDA.KERNEL_RBF;
%                    LDA.models{i} = libsvmtrain(labels, instances, sprintf('-t %d -c %f -g %f -b 1 -q', LDA.kernel, LDA.cost, LDA.gamma));
%                 else
%                    error('invalid kernel parameter');
%                 end
%             end
        end
        
        function [output, probabilities, ranking] = classifyInstance(MLTREE,instance)
            %input = instance matrix rows = instances, cols = attributes
            %output = predicted class
            %probabilities = probability for predicted class
            %ranking = propabilities for all classes (e.g. to use with mAP)
            
            
            %TODO:should print an error if 'build' has not been called
            numModels = length(MLTREE.models);
            [numinstance, ~] = size(instance);
            scores = zeros(numModels,numinstance);
             
            % ---- Multi-class ----- %
            [label,scores,cost] = predict(MLTREE.models{1},instance); 
            
            % ---- One (vs) All -----%
%              for i=1:numModels
%                  %predict using the stored models
%                  [label,score,cost] = predict(LDA.models{i},instance);
%                  %libsvmpredict(eye(numinstance,1),instance, LSVM.models{i},'-b 1 -q');
%                 %store probability for each class
%                 scores(i,:) = score(:,1);
%             end

             output = zeros(numinstance,1);
             probabilities = zeros(numinstance,1);
             %we need these for ranking metrics (e.g. mAP)
             ranking = scores;
             for i=1:numinstance
                 %select the class with the highest probability
                 [prob, idx] = max(scores(i,:));
                 uniqueLabels = unique(MLTREE.instanceSet.getLabels);
                 %output the label with highest probability
                 output(i,1) = uniqueLabels(idx);
                 %return the probability for the output label
                 probabilities(i,1) = prob;
             end
        end
        
        function MLTREE = reset(MLTREE)
            %delete all stored models
            MLTREE.models = {};
        end
                
    end
end

