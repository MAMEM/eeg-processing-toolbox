classdef Trial < handle
    %A class that defines a Trial
    
    properties (Access = public)
        signal; % the signal of the trial
        label; % a label for the trial (typically assigned with the frequency that is calculated using DIN data)
        duration; % the duration of the trial in seconds
        samplingRate; % the samling rate used to capture the signal
    end
    
    methods (Access = public)
        function T = Trial(signal, label, samplingRate)
            T.signal = signal;
            T.label = label;
            T.samplingRate = samplingRate;
            T.duration = length(signal)/samplingRate;
        end
    end
    
end

