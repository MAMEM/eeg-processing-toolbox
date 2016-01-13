classdef PreprocessingBase < handle
    %PREPROCESSINGBASE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        originalTrials;
        processedTrials;
    end
    
    methods (Abstract = true)
        obj = process(obj);
        configInfo = getConfigInfo(obj);
    end
    
end

