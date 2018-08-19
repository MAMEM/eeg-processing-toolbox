% Abstract class for feature selection. Implement the functions for any
% feature selection method (e.g. PCA, SVD, FEAST, etc.)
% 
% Properties:
% originalInstanceSet: Input - the original instanceSet with the features
% filteredInstanceSet: Output - the filtered instanceSet
% 
% Functions:
%Implement this function to process the originalInstanceSet trials and 
%return the filteredInstanceSet
%   obj.compute();
%Info & run time so that the experiments are easily documented. configInfo
%is a string with the configuration information and time is of type double.
%   configInfo = obj.getConfigInfo();
%   time = obj.getTime();

classdef (Abstract) FeatureSelectionBase < handle
    
    properties
        originalInstanceSet; % Input: The original dataset
        filteredInstanceSet; % Output: The filtered dataset
    end
    
    methods (Abstract = true)
        obj = compute(obj);
        configInfo = getConfigInfo(obj);
        time = getTime(obj);
    end
    
end

