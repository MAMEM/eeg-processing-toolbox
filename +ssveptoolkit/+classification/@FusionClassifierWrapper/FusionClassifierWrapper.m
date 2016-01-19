classdef FusionClassifierWrapper < ssveptoolkit.classification.ClassifierBase & ssveptoolkit.experiment.Experimenter;
    %FUSIONCLASSIFIERWRAPPER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        baseClassifier;
        classifiers;
    end
    
    methods
        function FCW = FusionClassifierWrapper(baseClassifier, fusionInstanceSet)
            if nargin>0
                FCW.baseClassifier = baseClassifier;
            end
            if nargin>1
                FCW.instanceSet = fusionInstanceSet;
            end
        end
        
        function FCW = build(FCW)
            numFusion = FCW.instanceSet.numFusion;
            FCW.reset;
            if ~isa(FCW.baseClassifier,'ssveptoolkit.classifier.LIBSVMClassifier')
                error ('Only LIBSVMClassifier supported as base classifier');
            else
                for i=1:numFusion
                    FCW.classifiers{i} = FCW.baseClassifier.copy;
                    FCW.classifiers{i} = ssveptoolkit.classifier.LIBSVMClassifier;
                    FCW.classifiers{i}.instanceSet = FCW.instanceSet.instanceSets{i};
                    FCW.classifiers{i}.build;
                end
            end
        end
        
        function [output, probabilities, ranking]  = classifyInstance(FCW,instance)
            [numInstances,~] = size(instance);
            numClass = length(FCW.classifiers);
            out = zeros(numInstances,numClass);
            output = zeros(numInstances,1);
            for i=1:length(FCW.classifiers)
                [out(:,i), probabilities, ranking] = FCW.classifiers{i}.classifyInstance(instance(:,:,i));
            end
            for i=1:numInstances
                x = out(i,:);
                [a,b] = hist(x,unique(x));
                [~,idx] = max(a);
                output(i,:) = b(idx);
            end
            probabilities = [];
            ranking = [];
            %TODO:*****
            
        end
        
        function configInfo = getConfigInfo(FCW)
            configInfo = 'FusionClassifierWrapper';
        end
        
                        
        function time = getTime(FCW)
            time = 0;
        end
        
        function FCW = reset(FCW)
            FCW.classifiers = {};
        end
        
        
        
    end
    
end

