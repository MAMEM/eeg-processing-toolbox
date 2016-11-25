% Abstract class for classification. Implement the functions for any
% classifier (e.g. LibSVM, LDA, MLR, Decision trees, Adaboost, etc.)
% 
% Properties:
% instanceSet: the training/test set in an InstanceSet structure
% 
% Functions:
%Implement this function to train the classification models. Each
%implementation should define the type of models that are to be trained by
%the build function.
%   obj = obj.build();
%Implement this function to apply the classification models to the provided
%instance, where instance is a matrix #instances x #features including the
%instances. The function should return the following three outputs; 1)
%output, the classified labels of the instances (#instances x 1), 2)
%probabilities, the probabilities for the output label (instances x 1) and
%3) ranking, a matrix #instances x #classes with the probabilities of each
%instance for each class (used for multiclass classification).
%   [output, probabilities, ranking] = obj.classifyInstance(instance);
%Implement this function to reset the classifier (e.g. delete the stored
%classification models
%   obj.reset();
%Info & run time so that the experiments are easily documented. configInfo
%is a string with the configuration information and time is of type double.
%   configInfo = obj.getConfigInfo();
%   time = obj.getTime();

classdef (Abstract) ClassifierBase < handle
    
    properties
        instanceSet;
    end
    
    methods (Abstract = true)
        [output, probabilities, ranking] = classifyInstance(obj,instance);
        obj = build(obj);
        obj = reset(obj);
        configInfo = getConfigInfo(obj);
        time = getTime(obj);
    end
    
end
