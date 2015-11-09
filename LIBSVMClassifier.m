classdef LIBSVMClassifier < ClassifierBase
    
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
    end
    
    methods (Access = public)
        function LSVM = LIBSVMClassifier(instanceSet)
            if nargin > 0
                LSVM.kernel = LSVM.KERNEL_LINEAR;
                LSVM.cost = 1.0;
                LSVM.instanceSet = instanceSet;
                LSVM.gamma = 1/instanceSet.getNumFeatures;
            end
        end
        
        function LSVM = build(LSVM)
            LSVM.reset;
            numLabels = LSVM.instanceSet.getNumLabels;
            uniqueLabels = unique(LSVM.instanceSet.getLabels);
            for i=1:numLabels
                currentLabel = uniqueLabels(i);
                labels = zeros(LSVM.instanceSet.getNumInstances,1)-1;
                labels(LSVM.instanceSet.getInstanceIndicesForLabel(currentLabel)) = 1;
                instances = sparse(LSVM.instanceSet.getInstances);
                LSVM.models{i} = libsvmtrain(labels,instances, '-t 0 -c 1 -b 1');
                if LSVM.kernel == LSVM.KERNEL_LINEAR;
                    LSVM.models{i} = libsvmtrain(labels, instances, sprintf('-t %d -c %f -b 1 -q', LSVM.kernel, LSVM.cost));
                elseif LSVM.kernel == LSVM.KERNEL_RBF;
                    LSVM.models{i} = libsvmtrain(labels, instances, sprintf('-t %d -c %f -g %f -b 1 -q', LSVM.kernel, LSVM.cost, LSVM.gamma));
                else
                    error('invalid kernel parameter');
                end
            end
        end
        
        function [output, probabilities, ranking] = classifyInstance(LSVM,instance)
            numModels = length(LSVM.models);
            
            [numinstance, ~] = size(instance);
            scores = zeros(numModels,numinstance);
            for i=1:numModels
                [~, ~, t] = libsvmpredict(eye(numinstance,1),instance, LSVM.models{i},'-b 1 -q');
                scores(i,:) = t(:,1);
            end
            output = zeros(numinstance,1);
            probabilities = zeros(numinstance,1);
            ranking = scores;
            for i=1:numinstance
                [prob, idx] = max(scores(:,i));
                uniqueLabels = unique(LSVM.instanceSet.getLabels);
                output(i,1) = uniqueLabels(idx);
                probabilities(i,1) = prob;
            end
        end
        
        function LSVM = reset(LSVM)
            LSVM.models = {};
        end
                
    end
end

