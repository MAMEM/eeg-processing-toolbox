% RESULTSET class
% Stores the results of an experiment
classdef L1MCCAInstanceSet < eegtoolkit.util.InstanceSet
    
    properties
        matrix4D;
        labelss;
    end
    
    methods
        function L1 = L1MCCAInstanceSet(trials)
            %Constructor method
            %Input:
            %(InstanceSet object): the original instanceSet
            %Labels: a vector containing the output labels of the
            %experiment
            %Proababilities: a vector containing the probabilities of each
            %label
            %Ranking (optional): a matrix containing a score for each label
            L1 = L1@eegtoolkit.util.InstanceSet(zeros(1,1000),ones(1,1000));
            if(nargin>0)
                numTrials = length(trials);
                lbls = zeros(numTrials,1);
                for i=1:numTrials
                    lbls(i) = trials{i}.label;
                end

                L1.labelss = lbls;
                [numChannels, numSamples] = size(trials{1}.signal);
                
                L1.matrix4D = zeros(numChannels,numSamples,numTrials,1);
                
                for i=1:numTrials
                    L1.matrix4D(:,:,i) = trials{i}.signal;
                end
            end

        end
        
        function newL1 = removeInstancesWithIndices(L1,indices)
            newL1 = eegtoolkit.util.L1MCCAInstanceSet;
            newL1.labelss = L1.labelss;
            newL1.labelss(indices) = [];
            newL1.matrix4D = L1.matrix4D;
            newL1.matrix4D(:,:,indices) = [];
        end
        
        function instances = getInstancesWithIndices(L1,indices)
            instances = L1.matrix4D(:,:,indices);
        end
        
        function dataset = getDatasetWithIndices(L1,indices)
            instances = zeros(length(indices),1000);
            labels = L1.labelss(indices);
            dataset = horzcat(instances,labels);
        end
        
        function numInstances = getNumInstances(L1)
            [~,~,numInstances] = size(L1.matrix4D);
        end
        
        function dataset = getDataset(L1)
            instances = zeros(L1.getNumInstances,1000);
            labels = L1.labelss;
            dataset = horzcat(instances,labels);
        end
            
        function numLabels = getNumLabels(L1)
            numLabels = length(unique(L1.labelss));
        end
    end
    
end

