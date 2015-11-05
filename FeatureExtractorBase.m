classdef (Abstract) FeatureExtractorBase < handle
    %Base class for a FeatureExtractor
    %Subclasses must implement the filter method
    properties
        originalDataset; % Input: The original dataset
        filteredDataset; % Output: The filtered dataset
    end
    
    methods (Abstract = true)
        obj = filter(obj);
    end
    
end

