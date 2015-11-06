classdef FEASTFilter < FeatureExtractorBase
    properties (Constant)
        ALGORITHM_MIM = 'mim';
        ALGORITHM_MRMR = 'mrmr';
        ALGORITHM_CMIM = 'cmim';
        ALGORITHM_JMI = 'jmi';
        ALGORITHM_DISR = 'disr';
        ALGORITHM_CIFE = 'cife';
        ALGORITHM_ICAP = 'icap';
        ALGORITHM_CONDRED = 'condred';
        ALGORITHM_CMI = 'cmi';
        ALGORITHM_RELIEF = 'relief';
        ALGORITHM_MIFS = 'mifs' %beta parameter required
        ALGORITHM_BETAGAMMA = 'betagamma'; %beta and gamma parameters required
        ALGORITHM_FCBF = 'fcbf'; %threshold parameter required
    end
    properties (Access = public)
        algorithm;
        numToSelect;
        parameter1;
        parameter2;
    end
    
    methods
        function FF = FEASTFilter(instanceSet,algorithm, numtoSelect, param1, param2)
            if nargin > 1
                FF.originalDataset = instanceSet;
                FF.algorithm = algorithm;
            end
            if nargin > 2 
                FF.numToSelect = numtoSelect;
            end
            if nargin > 3
                FF.parameter1 = param1;
            end
            if nargin > 4
                FF.parameter2 = param2;
            end
        end
        
        function FF = filter(FF)
            if (strcmp(FF.algorithm,FEASTFilter.ALGORITHM_MIFS) == 1) || (strcmp(FF.algorithm, FEASTFilter.ALGORITHM_FCBF) == 1)
                indices = feast(FF.algorithm, FF.numToSelect, FF.originalDataset.getInstances, FF.originalDataset.getLabels, FF.parameter1);
            elseif strcmp(FF.algorithm, FEASTFilter.ALGORITHM_BETAGAMMA) == 1
                indices = feast(FF.algorithm, FF.numToSelect, FF.originalDataset.getInstances, FF.originalDataset.getLabels, FF.parameter1, FF.parameter2);
            else 
                indices = feast(FF.algorithm, FF.numToSelect, FF.originalDataset.getInstances, FF.originalDataset.getLabels);
            end
            dataset = FF.originalDataset.getInstances;
            FF.filteredDataset = InstanceSet([dataset(:,indices) FF.originalDataset.getLabels]);
        end
            
    end
    
end

