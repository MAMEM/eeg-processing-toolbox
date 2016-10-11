classdef CSPWrapper < eegtoolkit.classification.ClassifierBase;
    properties (Constant)
        
    end
    properties
        baseClassifier;
        channel;
        cspFilter;
    end
    
    methods (Access = public)
        function CSP = CSPWrapper(instanceSet)
%             if(isa(instanceSet,'eegtoolkit.util.RawSignalSet')
%                 CSP.instanceSet = instanceSet;
%             else
%                 error('RawSignal extractor should be used with CSPWrapper');
%             end
        end
        
        
        function CSP = build(CSP)
            % Builds the classification models
            CSP.learnCSPMatrix(CSP.instanceSet.sMatrix,CSP.instanceSet.labels);
            instanceLocal = CSP.extract(CSP.instanceSet.sMatrix);
            CSP.baseClassifier.instanceSet = eegtoolkit.util.InstanceSet(instanceLocal,CSP.instanceSet.labels);
            CSP.baseClassifier.build;
            CSP.reset;
        end
        
        function [output, probabilities, ranking] = classifyInstance(CSP,instance)
%             instance = CSP.extract
            %input = instance matrix rows = instances, cols = attributes
            %output = predicted class
            %probabilities = probability for predicted class
            %ranking = propabilities for all classes (e.g. to use with mAP)
            
            %TODO:should print an error if 'build' has not been called
            testInstances = CSP.extract(instance);
            [output, probabilities, ranking] = CSP.baseClassifier.classifyInstance(testInstances);
%             numModels = length(LSVM.models);
%             [numinstance, ~] = size(testInstances);
%             scores = zeros(numModels,numinstance);
%             for i=1:numModels
%                 %predict using the stored models
%                 [~, ~, t] = svmpredict(eye(numinstance,1),testInstances, LSVM.models{i},'-b 1 -q');
%                 %store probability for each class
%                 scores(i,:) = t(:,1);
%             end
%             output = zeros(numinstance,1);
%             probabilities = zeros(numinstance,1);
%             ranking = scores;
%             for i=1:numinstance
%                 %select the class with the highest probability
%                 [prob, idx] = max(scores(:,i));
%                 uniqueLabels = unique(LSVM.instanceSet.getLabels);
%                 %output the label with highest probability
%                 output(i,1) = uniqueLabels(idx);
%                 %return the probability for the output label
%                 probabilities(i,1) = prob;
%             end
        end
        
        function CSP = reset(CSP)
            % 'Resets' the classifier.
%             CSP.models = {};
        end
        
        function configInfo = getConfigInfo(CSP)
            configInfo = '\n';
        end
        
                        
        function time = getTime(CSP)
            time = 0;
        end
    end
    methods (Access = private)
        function [] = learnCSPMatrix(CSP, sMatrix, labels)
            [numTrials,numChannels,~] = size(sMatrix);
%             labels = CSP.instanceSet.getLabels;
%             sMatrix = permute(sMatrix,[2,3,1]);
%             sMatrix = permute(sMatrix,[2 1 3]);
            sMatrix = permute(sMatrix,[3,2,1]);
            for i=1:numChannels
                for j=1:numTrials
                    sMatrix(:,i,j) = (sMatrix(:,i,j) - mean(sMatrix(:,i,j)));
                end
            end
            trialCov = zeros(numChannels,numChannels,numTrials);
            for t=1:length(labels)
                E = sMatrix(:,:,t)';
                EE = E * E';
                trialCov(:,:,t) = EE ./trace(EE);
            end
            %TODO: works only for 2 labels, [1,2]
            for c=1:2
                covMat{c} = mean(trialCov(:,:,labels == c),3);
            end
            [U, D] = eig(covMat{1},covMat{2},'qz');
            eigenvalues = diag(D);
            [~,ind] = sort(eigenvalues,'descend');
            U = U(:,ind);
            CSP.cspFilter = U';
%             for i=1:size(sMatrix,3);
%                 sMatrix(:,:,i) = (cspFilter*sMatrix(:,:,i)')';
%             end
%             instances = zeros(numTrials,numChannels);
%             for i=1:numTrials
%                 projectedTrial = sMatrix(:,:,i);
%                 variances = var(projectedTrial,0,1);
%                 instances(i,:) = log(variances)';
%             end
%             instanceSet = eegtoolkit.util.InstanceSet(instances,labels);
        end
        
        function instances = extract(CSP,sMatrix)
            
            [numTrials,numChannels,~] = size(sMatrix);
            sMatrix = permute(sMatrix,[3,2,1]);
            for i=1:size(sMatrix,3);
                sMatrix(:,:,i) = (CSP.cspFilter*sMatrix(:,:,i)')';
            end
            instances = zeros(numTrials,numChannels);
            for i=1:numTrials
                projectedTrial = sMatrix(:,:,i);
                variances = var(projectedTrial,0,1);
                instances(i,:) = log(variances)';
            end
%             instanceSet = eegtoolkit.util.InstanceSet(instances,labels);
        end
    end
end

