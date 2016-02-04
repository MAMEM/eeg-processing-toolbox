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

