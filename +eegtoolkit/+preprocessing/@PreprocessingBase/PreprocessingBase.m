classdef PreprocessingBase < handle
    
    properties
        originalTrials;
        processedTrials;
    end
    
    methods (Abstract = true)
        out = process(obj,in);
        configInfo = getConfigInfo(obj);
        time = getTime(obj);
    end
    
end

