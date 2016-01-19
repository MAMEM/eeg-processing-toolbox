classdef (Abstract) FeatureSelectionBase < handle
    %Base class for a FeatureExtractor
    %Subclasses must implement the filter method
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

