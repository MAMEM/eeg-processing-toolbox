classdef RawSignalSet < eegtoolkit.util.InstanceSet
    %RAWSIGNALSET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %numTrials X numChannels X numSamples
        signalMatrix;
    end
    
    methods
        function RSS = RawSignalSet(trials)
            %             RSS = RSS@eegtoolkit.util.InstanceSet(zeros(1,1000),ones(1,1000));
            if(nargin~=1)
                error('trials parameter not set');
            end
            %             if(nargin>0)
            numTrials = length(trials);
            labels = zeros(numTrials,1);
            for i=1:numTrials
                labels(i) = trials{i}.label;
            end
            [numChannels, numSamples] = size(trials{i}.signal);
            sMatrix = zeros(numTrials,numChannels,numSamples);
            for i=1:numTrials
                sMatrix(i,:,:) = trials{i}.signal;
            end
            RSS = RSS@eegtoolkit.util.InstanceSet(squeeze(sMatrix(:,1,:)),labels);
            RSS.signalMatrix = sMatrix;
            %             end
        end
        
        function sMatrix = get(indices)
            sMatrix = squeeze(RSS.signalMatrix(indices,:,:));
        end
        
        function sMatrix = getInstancesWithIndices(RSS,indices)
            sMatrix = RSS.signalMatrix(indices,:,:);
        end
        
        function instanceStruct = removeInstancesWithIndices(RSS,indices)
%             newRSS = eegtoolkit.util.RawSignalSet;
%             newRSS.labels = RSS.labels;
%             newRSS.labels(indices) = [];
%             newRSS.signalMatrix = RSS.signalMatrix;
%             newRSS.signalMatrix(indices,:,:) = [];
            sMatrix = RSS.signalMatrix;
            sMatrix(indices,:,:) = [];
            
            labels = RSS.labels;
            labels(indices) = [];
            instanceStruct = struct('sMatrix',sMatrix, 'labels', labels);
        end
        
        function numInstances = getNumInstances(RSS)
            [numInstances,~,~] = size(RSS.signalMatrix);
        end
            
    end
    
    
end
    
