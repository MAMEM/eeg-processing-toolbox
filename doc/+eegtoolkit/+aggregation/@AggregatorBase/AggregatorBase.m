% Abstract class for aggregation. Implement the functions for any
% fusion methodology (e.g. late fusion, VLAD, channel concatenation, etc.)
% 
% Properties:
% featextractors: cell array with the the feature extractors to be used on
% the trials. Each cell contains a featextraction object, and the trials
% are given to each of the objects within the Experimenter class
% instanceSet: output - the aggregated features. Can be a simple
% InstanceSet or the extended FusionInstanceSet
% 
% Functions:
%Implement this function to process the trials of each featextraction
%object in the cell array featextractors. It should store in the
%instanceSet property the features.
%   obj.aggregate();
%Info & run time so that the experiments are easily documented. configInfo
%is a string with the configuration information and time is of type double.
%   configInfo = obj.getConfigInfo();
%   time = obj.getTime();

classdef (Abstract) AggregatorBase < handle
    
    properties
        featextractors;
        instanceSet;
    end
    
    methods (Abstract = true)
        obj = aggregate(obj);
        configInfo = getConfigInfo(obj);
        time = getTime(obj);
    end
    
end

