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
        
        function trialsMat = trialsCellToMatForLabel(trials,label)
            labels = ssveptoolkit.util.Trial.getLabelsVectorForTrials(trials);
            numTrialsForLabel = sum(labels==label);
            [numChannels, numSamples] = size(trials{1}.signal);
            trialsMat = zeros(numChannels,numSamples,numTrialsForLabel);
            count = 0;
            for i=find(labels==label)
                count = count + 1;
                trialsMat(:,:,count) = trials{i}.signal;
            end
        end
        function labels = getLabelsVectorForTrials(trials)
            numTrials = length(trials);
            for i=1:numTrials
                labels(i) = trials{i}.label;
            end
        end
    end
    
end

