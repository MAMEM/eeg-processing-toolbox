classdef Trial < handle
    %A class that defines a Trial
    
    properties (Access = public)
        signal; % the signal of the trial
        label; % a label for the trial (typically assigned with the frequency that is calculated using DIN data)
        duration; % the duration of the trial in seconds
        samplingRate; % the samling rate used to capture the signal
        subjectid; %the subject from
        sessionid; %the session id
    end
    
    methods (Access = public)
        function T = Trial(signal, label, samplingRate, subjectID, sessionID)
            T.signal = signal;
            T.label = label;
            T.samplingRate = samplingRate;
            T.duration = length(signal)/samplingRate;
            T.subjectid = subjectID;
            T.sessionid = sessionID;
        end
    end
    
    methods (Static)
        function trialsMat = trialsCellToMat(trials)
            numTrials = length(trials);
            for i=1:numTrials
                labels(i) = trials{i}.label;
            end
            numLabels = length(unique(labels));
            [numChannels, numSamples] = size(trials{1}.signal);
            trialsMat = zeros(numChannels,numSamples,numTrials,numLabels);
            for i=1:numTrials
                trialsMat(:,:,i,trials{i}.label) = trials{i}.signal;
            end
        end
    end
    
end

