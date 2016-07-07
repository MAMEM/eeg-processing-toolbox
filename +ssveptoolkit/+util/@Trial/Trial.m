classdef Trial < handle
    %A class that defines a Trial
    
    properties (Constant)
        %Type of trial
        SSVEP = 1;
        ERRP = 2;
        MI = 3;
    end
    
    properties (Access = public)
        signal; % the signal of the trial
        label; % a label for the trial (typically assigned with the frequency that is calculated using DIN data)
        duration; % the duration of the trial in seconds
        samplingRate; % the samling rate used to capture the signal
        subjectid; %the subject from
        sessionid; %the session id
        type;
    end
    
    methods (Access = public)
        function T = Trial(signal, label, samplingRate, subjectID, sessionID,type)
            T.signal = signal;
            T.label = label;
            T.samplingRate = samplingRate;
            T.duration = length(signal)/samplingRate;
            T.subjectid = subjectID;
            T.sessionid = sessionID;
            if nargin>5
                T.type = type;
            end
        end
        
    end
    
end

