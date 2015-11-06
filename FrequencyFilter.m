classdef FrequencyFilter < FeatureExtractorBase
    properties (Constant)
        STIM_FREQUENCIES = [6.66 7.5 8.57 10 12];
    end
    properties (Access = public)
        numberOfHarmonics;
        pff;
    end
    
    methods
        function FF = FrequencyFilter(instanceSet, pff, numberOfHarmonics)
            if nargin == 2
                FF.pff = pff.*2;
                FF.originalDataset = instanceSet;
                FF.numberOfHarmonics = 1;
            elseif nargin == 3
                FF.pff = pff.*2;
                FF.originalDataset = instanceSet;
                FF.numberOfHarmonics = numberOfHarmonics;
            else
                error('invalid number of arguments');
            end
        end
        
        function FF = filter(FF)
            bins = FF.STIM_FREQUENCIES;
            [numInstances,~] = size(FF.originalDataset.instances);
            for i=2:FF.numberOfHarmonics
                bins = horzcat(bins, FF.STIM_FREQUENCIES.*i);
            end
            instances = zeros(numInstances, length(bins));
            for i=1:length(bins)
                [~,indx] = min(abs(FF.pff-bins(i)));
                instances(:,i) = FF.originalDataset.instances(:,indx);
            end
            FF.filteredDataset = InstanceSet(instances, FF.originalDataset.labels);
        end
            
    end
    
end

