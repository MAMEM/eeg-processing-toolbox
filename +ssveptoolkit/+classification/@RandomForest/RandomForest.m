classdef RandomForest < ssveptoolkit.classification.ClassifierBase
    
    properties (Constant)

    end
    
    properties
       models;
       numTrees
    end
    
    methods (Access = public)
        function RF = RandomForest(instanceSet, numTrees)
            %set default parameters
            RF.numTrees = 100;
            if nargin > 0
                RF.instanceSet = instanceSet;
            end
            if nargin > 1
                RF.numTrees = numTrees;
            end
        end
        
        function RF = build(RF)
            %clear all from previous calls to "build"
            RF.reset;
            
            instances=RF.instanceSet.instances;
            labels=RF.instanceSet.labels;
            RF.models{1} = TreeBagger(RF.numTrees,instances, labels, 'Method', 'classification');
        end
        
        function [output, probabilities, ranking] = classifyInstance(RF,instance)
            %input = instance matrix rows = instances, cols = attributes
            %output = predicted class
            %probabilities = probability for predicted class
            %ranking = propabilities for all classes (e.g. to use with mAP)
            
            
            %TODO:should print an error if 'build' has not been called
            probabilities = [];
            [output, ranking] = RF.models{1}.predict(instance);
            output = str2double(output);
        end
        
        function RF = reset(RF)
            %delete all stored models
            RF.models = {};
        end
        
        function configInfo = getConfigInfo(RF)
            configInfo = sprintf('RandomForest:\tnumTrees:%d',RF.numTrees);
        end
        
                        
        function time = getTime(RF)
            time = 0;
        end
                
    end
end

