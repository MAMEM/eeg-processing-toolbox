classdef (Abstract) AggregatorBase < handle
    %AGGREGATORBASE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        transformers;
        instanceSet;
    end
    
    methods (Abstract = true)
        obj = aggregate(obj);
        configInfo = getConfigInfo(obj);
        time = getTime(obj);
    end
    
end

