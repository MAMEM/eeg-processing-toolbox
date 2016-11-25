% Abstract class for preprocessing. Implement the functions for any
% preprocessing step (e.g. filtering, artifact removal, sub-sampling,
% rereferencing, etc.
% 
% Properties:
% originalTrials: cell array with the trials to be processed
% processedTrials: the processed trials to be returned
% 
% Functions:
%Implement this function to process the in trials and return the processed
%trials (out)
%   out = obj.process(in);
%Info & run time so that the experiments are easily documented. configInfo
%is a string with the configuration information and time is of type double.
%   configInfo = obj.getConfigInfo();
%   time = obj.getTime();

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

