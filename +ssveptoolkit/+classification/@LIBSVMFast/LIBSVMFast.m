classdef LIBSVMFast < ssveptoolkit.classification.ClassifierBase
    
    properties (Constant)

    end
    properties
        kernel;
        cost;
        gamma;
        models;
        Ktrain;
        Ktest;
        maxlag;
        scaleopt;
        predictTotalTime;
        predictCount;
    end
    
    methods (Access = public)
        function LSVM = LIBSVMFast (instanceSet,kernel,cost,gamma,maxlag,scaleopt)
            %set default parameters
            LSVM.predictTotalTime = 0;
            LSVM.predictCount = 0;
            LSVM.kernel = 'linear';
            LSVM.cost = 1.0;
            LSVM.gamma = 0.01;
            LSVM.maxlag = 150;
            LSVM.scaleopt = 'coeff';
            if nargin > 0
                LSVM.instanceSet = instanceSet;
                LSVM.gamma = 1/instanceSet.getNumFeatures;
            end
            if nargin > 1
                LSVM.kernel = kernel;
            end
            if nargin > 2
                LSVM.cost = cost;
            end
            if nargin > 3
                LSVM.gamma = gamma;
            end
            if nargin > 4
                LSVM.maxlag = maxlag;
            end
            if nargin > 5
                LSVM.scaleopt = scaleopt;
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
                LSVM.models{i} = svmtrain(labels, [(1:size(LSVM.Ktrain,1))', ...
                    LSVM.Ktrain+eye(size(LSVM.Ktrain,1))*realmin], ...
                    sprintf(' -t 4 -c %f -b 1 -q', LSVM.cost));
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
                tic
                [~, ~, t] = svmpredict(eye(numinstance,1),...
                    [(1:numinstance)', LSVM.Ktest], LSVM.models{i},'-b 1 -q');
                LSVM.predictTotalTime = LSVM.predictTotalTime + toc;
                LSVM.predictCount = LSVM.predictCount + 1;
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
                case {'linear','spearman','correlation','cosine'}
                    configInfo = sprintf('LIBSVMFast\tkernel:%s\tcost:%d', LSVM.kernel, LSVM.cost);
                case 'xcorr'
                    configInfo = sprintf('LIBSVMFast\tkernel:%s\tcost:%d\tgamma:%d\tmaxlag:%d\tscaleopt:%s', LSVM.kernel, LSVM.cost, LSVM.maxlag,LSVM.scaleopt);
                otherwise
                    configInfo = sprintf('LIBSVMFast\tkernel:%s\tcost:%d\tgamma:%d', LSVM.kernel, LSVM.cost, LSVM.gamma);
%                 otherwise 
%                     configInfo = 'Error in configuration (only linear and rbf kernels supported for now)';
            end
        end
        
        function time = getTime(LSVM)
            time = LSVM.predictTotalTime/LSVM.predictCount;
        end
    end
end

