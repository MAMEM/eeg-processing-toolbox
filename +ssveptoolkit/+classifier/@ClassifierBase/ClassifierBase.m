classdef (Abstract) ClassifierBase < handle
    
    properties
        instanceSet;
    end
    
    methods (Abstract = true)
        obj = classifyInstance(obj);
        obj = build(obj);
        obj = reset(obj);
    end
    
end
