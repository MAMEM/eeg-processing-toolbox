classdef (Abstract) FeatureExtractorBase < handle
    %Base class for a FeatureExtractor
    %Subclasses must implement the filter method
    properties
        originalInstanceSet; % Input: The original dataset
        filteredInstanceSet; % Output: The filtered dataset
    end
    
    methods (Abstract = true)
        obj = filter(obj);
        configInfo = getConfigInfo(obj);
    end
    
end

