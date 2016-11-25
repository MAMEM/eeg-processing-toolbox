% Abstract class for feature extraction. Implement the functions for any
% preprocessing step (e.g. filtering, artifact removal, sub-sampling,
% rereferencing, etc.
% 
% Properties:
% instanceSet: Output - the features in an InstanceSet structure
% trials: Input - the signals in a cell of Trial structures
% 
% Functions:
%Implement this function to extract the features from the input Trials 
%and return the features in an instanceSet
%   out = obj.extract(in);
%Info & run time so that the experiments are easily documented. configInfo
%is a string with the configuration information and time is of type double.
%   configInfo = obj.getConfigInfo();
%   time = obj.getTime();


classdef (Abstract) FeatureExtractionBase < handle
    %Base class for a feature transformer
    %For writing your own FeatureTransformer extend this class and
    %implement the 'transform' function
    properties (Access = public)
        instanceSet; % Output: The dataset
        trials;% Input: The trial signals
        filter;
    end
    
    methods (Abstract = true)
        obj = extract(obj);
        configInfo = getConfigInfo(obj);
        time = getTime(obj);
    end
    
    methods (Access = public)
        function instances = getInstances(obj)
            %Get the instances (no class labels)
            instances = obj.instanceSet.getInstances;
        end
        function labels = getLabels(obj)
            %Get the labels
            labels = obj.instanceSet.getLabels;
        end
        
        function dataset = getDataset(obj)
            % same with getInstances but includes the labels as the last
            % row
            dataset = obj.instanceSet.getDataset;
        end
        
        function instanceSet = getInstanceSet(obj)
            % Get the dataset as an 'InstanceSet' class object
            instanceSet = obj.instanceSet;
        end
        function writeCSV(obj, csvname)
            % write the dataset to a csv file
            % Example:
            %   obj.writeCSV('data.csv');
            obj.instanceSet.writeCSV(csvname);
        end
        function writeArff(obj, fname)
            % write the dataset to a weka-readable file (arff)
            % Caution: filename without extension
            % Example:
            %   obj.writeArff('data')            
            obj.instanceSet.writeArff(fname);
        end
    end
end