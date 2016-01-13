classdef PreprocessingWrapper < ssveptoolkit.preprocessing.PreprocessingBase
    %PREPROCESSINGWRAPPER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
        steps;
    end
    
    methods
        function PW = PreprocessingWrapper(~)
        end
        function PW = process(PW)
            numSteps = length(PW.steps);
            currTrials = PW.originalTrials;
            for i=1:numSteps
                PW.steps{i}.originalTrials = currTrials;
                PW.steps{i}.process;
                currTrials = PW.steps{i}.processedTrials;
            end
            PW.processedTrials = currTrials;
        end
    end
    
end

