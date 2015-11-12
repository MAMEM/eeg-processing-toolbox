classdef MLDAClassifier < ssveptoolkit.classifier.ClassifierBase
    
    properties (Constant)

    end
    
    properties
       DiscrimType; % 'linear' (default) | 'quadratic' | 'diagLinear' | 'diagQuadratic' | 'pseudoLinear' | 'pseudoQuadratic'
       Delta % 0 (default) | nonnegative scalar value that acts as a linear coefficient threshold. Delta must be 0 for quadratic discriminant models. 
       Gamma % scalar value in the range [0,1]. Parameter for regularizing the correlation matrix of predictors.
       FillCoeffs % on (default) Coeffs property flag, specified as the comma-separated pair consisting of 'FillCoeffs' and 'on' or 'off
       ScoreTransform % 'none' (default). Score transform function. Check http://www.mathworks.com/help/stats/fitcdiscr.html
       Prior % 'empirical' (default) or 'uniform'.  Prior probabilities for each class. 
       models; 
    end
    
    methods (Access = public)
        function MLDA = MLDAClassifier(instanceSet, discrimType, delta, gamma, fillCoeffs, scoreTransform,prior)
            %set default parameters
            if nargin > 0
                MLDA.instanceSet = instanceSet;
            end
            if nargin > 1
                MLDA.DiscrimType = discrimType;
            end
            if nargin > 2 
                MLDA.Delta=delta;
            end
            if nargin > 3
                MLDA.Gamma = gamma;
            end
            if nargin > 4
                MLDA.FillCoeffs = fillCoeffs;
            end
            if nargin > 5
                MLDA.ScoreTransform = scoreTransform;
            end
            if nargin > 6
                MLDA.Prior = prior;
            end
        end
        
        function MLDA = build(MLDA)
            %clear all from previous calls to "build"
            MLDA.reset;
            numLabels = MLDA.instanceSet.getNumLabels;
            uniqueLabels = unique(MLDA.instanceSet.getLabels);
           
            % ---- Multi-Class ----- %
            instances=MLDA.instanceSet.instances;
            labels=MLDA.instanceSet.labels;
            
            %LDA.models{1}=fitcecoc(instances,labels,'Coding','ternarycomplete');
            MLDA.models{1} = fitcdiscr(instances,labels,'DiscrimType',MLDA.DiscrimType,'Delta',MLDA.Delta,'Gamma',MLDA.Gamma,'FillCoeffs',MLDA.FillCoeffs,'ScoreTransform',MLDA.ScoreTransform, 'Prior',MLDA.Prior);
            
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
        
        function [output, probabilities, ranking] = classifyInstance(MLDA,instance)
            %input = instance matrix rows = instances, cols = attributes
            %output = predicted class
            %probabilities = probability for predicted class
            %ranking = propabilities for all classes (e.g. to use with mAP)
            
            
            %TODO:should print an error if 'build' has not been called
            numModels = length(MLDA.models);
            [numinstance, ~] = size(instance);
            scores = zeros(numModels,numinstance);
             
            % ---- Multi-class ----- %
            [label,scores,cost] = predict(MLDA.models{1},instance); 
            
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
                 uniqueLabels = unique(MLDA.instanceSet.getLabels);
                 %output the label with highest probability
                 output(i,1) = uniqueLabels(idx);
                 %return the probability for the output label
                 probabilities(i,1) = prob;
             end
        end
        
        function MLDA = reset(MLDA)
            %delete all stored models
            MLDA.models = {};
        end
                
    end
end

