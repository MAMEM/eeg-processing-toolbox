classdef LIBSVMClassifierFast < ssveptoolkit.classifier.ClassifierBase
    
    properties (Constant)
        KERNEL_LINEAR = 0;
%         KERNEL_POLYNOMIAL = 1;
        KERNEL_RBF = 2;
%         KERNEL_SIGMOID = 3;
    end
    properties
        kernel;
        cost;
        gamma;
        models;
        Ktrain;
        Ktest;
    end
    
    methods (Access = public)
        function LSVM = LIBSVMClassifierFast(instanceSet)
            %set default parameters
            if nargin > 0
                LSVM.kernel = LSVM.KERNEL_LINEAR;
                LSVM.cost = 1.0;
                LSVM.instanceSet = instanceSet;
                LSVM.gamma = 1/instanceSet.getNumFeatures;
            else
                LSVM.kernel = LSVM.KERNEL_LINEAR;
                LSVM.cost = 1.0;
            end
        end
        
        function LSVM = build(LSVM)
            %clear all from previous calls to "build"
            LSVM.reset;
            numLabels = LSVM.instanceSet.getNumLabels;
            uniqueLabels = unique(LSVM.instanceSet.getLabels);
            for i=1:numLabels
                currentLabel = uniqueLabels(i);
                labels = zeros(LSVM.instanceSet.getNumInstances,1)-1;
                labels(LSVM.instanceSet.getInstanceIndicesForLabel(currentLabel)) = 1;
                if LSVM.kernel == LSVM.KERNEL_LINEAR;
                    %store the models in an instance variable
                    LSVM.models{i} = svmtrain(labels, [(1:size(LSVM.Ktrain,1))', ...
                        LSVM.Ktrain+eye(size(LSVM.Ktrain,1))*realmin], ...
                        sprintf(' -t 4 -c %f -b 1 -q', LSVM.cost));
                else
                    error('The fast version is only supported for Linear Kernel');
                end
            end
        end
        
        function [output, probabilities, ranking] = classifyInstance(LSVM)
            %input = instance matrix rows = instances, cols = attributes
            %output = predicted class
            %probabilities = probability for predicted class
            %ranking = propabilities for all classes (e.g. to use with mAP)
            
            %TODO:should print an error if 'build' has not been called
            numModels = length(LSVM.models);
            [numinstance, ~] = size(LSVM.Ktest);
            scores = zeros(numModels,numinstance);
            for i=1:numModels
                %predict using the stored models
                [~, ~, t] = svmpredict(eye(numinstance,1),...
                    [(1:numinstance)', LSVM.Ktest], LSVM.models{i},'-b 1 -q');
                %svmpredict(labels(~idx), [(1:sum(~idx))', K(~idx,idx)], model);
                %store probability for each class
                scores(i,:) = t(:,1);
            end
            output = zeros(numinstance,1);
            probabilities = zeros(numinstance,1);
            %we need these for ranking metrics (e.g. mAP)
            ranking = scores;
            for i=1:numinstance
                %select the class with the highest probability
                [prob, idx] = max(scores(:,i));
                uniqueLabels = unique(LSVM.instanceSet.getLabels);
                %output the label with highest probability
                output(i,1) = uniqueLabels(idx);
                %return the probability for the output label
                probabilities(i,1) = prob;
            end
        end
        
        function LSVM = reset(LSVM)
            %delete all stored models
            LSVM.models = {};
        end
        
        function configInfo = getConfigInfo(LSVM)
            switch LSVM.kernel
                case LSVM.KERNEL_LINEAR
                    configInfo = sprintf('LIBSVMClassifierFast\tkernel:linear\tcost:%d', LSVM.cost);
                case LSVM.KERNEL_RBF
                    configInfo = sprintf('LIBSVMClassifierFast\tkernel:rbf\tcost:%d\tgamma:%d', LSVM.cost, LSVM.gamma);
                otherwise 
                    configInfo = 'Error in configuration (only linear and rbf kernels supported for now)';
            end
        end
                
    end
end

