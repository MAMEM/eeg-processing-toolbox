classdef FrequencyFilter < ssveptoolkit.extractor.FeatureExtractorBase
    properties (Constant)
        STIM_FREQUENCIES = [6.66 7.5 8.57 10 12];
    end
    properties (Access = public)
        numberOfHarmonics;
        pff;
    end
    
    methods
        function FF = FrequencyFilter(instanceSet, pff, numberOfHarmonics)
            if nargin == 0
                FF.numberOfHarmonics = 1;
            elseif nargin == 2
                FF.pff = pff.*2;
                FF.originalInstanceSet = instanceSet;
                FF.numberOfHarmonics = 1;
            elseif nargin == 3
                FF.pff = pff.*2;
                FF.originalInstanceSet = instanceSet;
                FF.numberOfHarmonics = numberOfHarmonics;
            else
                error('invalid number of arguments');
            end
        end
        
        function FF = filter(FF)
            bins = FF.STIM_FREQUENCIES;
            [numInstances,~] = size(FF.originalInstanceSet.instances);
            for i=2:FF.numberOfHarmonics
                bins = horzcat(bins, FF.STIM_FREQUENCIES.*i);
            end
            instances = zeros(numInstances, length(bins));
            for i=1:length(bins)
                [~,indx] = min(abs(FF.pff-bins(i)));
                instances(:,i) = FF.originalInstanceSet.instances(:,indx);
            end
            FF.filteredInstanceSet = ssveptoolkit.util.InstanceSet(instances, FF.originalInstanceSet.labels);
        end
        
        function configInfo = getConfigInfo(FF)
            configInfo = sprintf('FrequencyFilter\tnumberofharmonics:%d',FF.numberOfHarmonics);
        end
            
    end
    
end

