classdef (Abstract) EvaluatorBase
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        instanceSet;
        output;
    end
    
    methods (Abstract = true)
        obj = classifyInstance(obj);
        obj = build(obj);
    end
    
end

