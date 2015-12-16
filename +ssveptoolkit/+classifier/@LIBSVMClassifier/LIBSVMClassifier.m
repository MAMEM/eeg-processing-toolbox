% LIBSVMCLASSIFIER class
% Wrapper class of the libsvm library (libsvm) .mex files must be added to
% your matlab path before using this class
classdef LIBSVMClassifier < ssveptoolkit.classifier.ClassifierBase
    
    properties (Constant)
        KERNEL_LINEAR = 0; 
%         KERNEL_POLYNOMIAL = 1; not supported yet
        KERNEL_RBF = 2;
%         KERNEL_SIGMOID = 3; not supported yet
    end
    properties
        kernel; % The svm kernel
        cost; % The cost parameter
        gamma; % The gamma parameter (used only with rbf kernel)
        models; % The trained models
    end
    
    methods (Access = public)
        function LSVM = LIBSVMClassifier(instanceSet)
            if nargin > 0
                LSVM.kernel = LSVM.KERNEL_LINEAR;
                LSVM.cost = 1.0;
                LSVM.instanceSet = instanceSet;
                LSVM.gamma = 1/instanceSet.getNumFeatures;
            else
                LSVM.kernel = LSVM.KERNEL_LINEAR;
                LSVM.cost = 1.0;
                LSVM.gamma = 1;
            end
        end
        
        function LSVM = build(LSVM)
            % Builds the classification models
            LSVM.reset;
            numLabels = LSVM.instanceSet.getNumLabels;
            uniqueLabels = unique(LSVM.instanceSet.getLabels);
            for i=1:numLabels
                currentLabel = uniqueLabels(i);
                labels = zeros(LSVM.instanceSet.getNumInstances,1)-1;
                labels(LSVM.instanceSet.getInstanceIndicesForLabel(currentLabel)) = 1;
                instances = sparse(LSVM.instanceSet.getInstances);
                if LSVM.kernel == LSVM.KERNEL_LINEAR;
                    %store the models in an instance variable
                    LSVM.models{i} = svmtrain(labels, instances, sprintf('-t %d -c %f -b 1 -q', LSVM.kernel, LSVM.cost));
                elseif LSVM.kernel == LSVM.KERNEL_RBF;
                    LSVM.models{i} = svmtrain(labels, instances, sprintf('-t %d -c %f -g %f -b 1 -q', LSVM.kernel, LSVM.cost, LSVM.gamma));
                else
                    error('invalid kernel parameter');
                end
            end
        end
        
        function [output, probabilities, ranking] = classifyInstance(LSVM,instance)
            %input = instance matrix rows = instances, cols = attributes
            %output = predicted class
            %probabilities = probability for predicted class
            %ranking = propabilities for all classes (e.g. to use with mAP)
            
            %TODO:should print an error if 'build' has not been called
            numModels = length(LSVM.models);
            [numinstance, ~] = size(instance);
            scores = zeros(numModels,numinstance);
            for i=1:numModels
                %predict using the stored models
                [~, ~, t] = svmpredict(eye(numinstance,1),instance, LSVM.models{i},'-b 1 -q');
                %store probability for each class
                scores(i,:) = t(:,1);
            end
            output = zeros(numinstance,1);
            probabilities = zeros(numinstance,1);
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
            % 'Resets' the classifier.
            LSVM.models = {};
        end
        
        function configInfo = getConfigInfo(LSVM)
            % Prints the parameters of the classifier
            switch LSVM.kernel
                case LSVM.KERNEL_LINEAR
                    configInfo = sprintf('LIBSVMClassifier\tkernel:linear\tcost:%d', LSVM.cost);
                case LSVM.KERNEL_RBF
                    configInfo = sprintf('LIBSVMClassifier\tkernel:rbf\tcost:%d\tgamma:%d', LSVM.cost, LSVM.gamma);
                otherwise 
                    configInfo = 'Error in configuration (only linear and rbf kernels supported for now)';
            end
        end
                
    end
end

