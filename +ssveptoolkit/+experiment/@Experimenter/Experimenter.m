% EXPERIMENTER class
% Wraps all the necessary objects for performing an experiment. 
%Before running an experiment all the required properties must be set.
% Required:
% - session
% - transformer
% - evalMethod
% - classifier
% Optional:
% - extractor
%
% to run the experiment execute the "run()" method.
% Example:
% experiment = ssveptoolkit.experiment.Experimenter;
% experiment.session = ssveptoolkit.util.Session;
% experiment.session.loadSubject(1);
% experiment.transformer = ssveptoolkit.transformer.PWelchTransformer;
% experiment.extractor = ssveptoolkit.extractor.FEASTFilter;
% experiment.classifier = ssveptoolkit.classifier.LIBSVMClassifier;
% experiment.evalMethod = experiment.evalMethod.EVAL_METHOD_LOSO;
% experiment.run;
% results = experiment.results;
% confmatrix = results{1}.getConfusionMatrix;
classdef Experimenter < handle
    properties (Constant)
        EVAL_METHOD_LOOCV = 0; % Leave One Out Cross-Validation
        EVAL_METHOD_LOSO = 1; % Leave One Subject Out 
    end
    
    properties (Access = public)
        session; % The Session object. Trials must be loaded before run() is executed
        transformer; % A transformer object
        aggregator;
        extractor; % An extractor object
        evalMethod; % The evaluation method
        classifier; % A classifier object
        results; % A cell array containing objects of the 'ResultEvaluator' class.
        subjectids;
    end
    
    methods
        function E = Experimenter(evalMethod)
            if nargin > 0
                E.evalMethod = evalMethod;
            else E.evalMethod = 0;
            end
            E.results = {};
        end
        
        function E = run(E)
            % Runs an experiment
            E.checkCompatibility;
            if ~isempty(E.session)
                E.subjectids = E.session.subjectids;
            end
            disp('transform ...');
            if iscell(E.transformer)
                numTransf = length(E.transformer);
                for i=1:numTransf
                    if ~isempty(E.session)
                        E.transformer{i}.trials = E.session.trials;
                    end
                    E.transformer{i}.transform;
                    
                end
                E.aggregator.transformers = E.transformer;
                E.aggregator.aggregate;
                instanceSet = E.aggregator.instanceSet;
            else 
                if ~isempty(E.session)
                    E.transformer.trials = E.session.trials;
                    E.transformer.transform;
                end
                instanceSet = E.transformer.getInstanceSet;
            end
            if ~isempty(E.extractor)
                E.extractor.originalInstanceSet = instanceSet;
                if isa(E.extractor, 'ssveptoolkit.extractor.FrequencyFilter')
                    E.extractor.pff = E.transformer.pff;
                end
                disp('extract ...');
                E.extractor.filter;
                E.classifier.instanceSet = E.extractor.filteredInstanceSet;
            else
                E.classifier.instanceSet = instanceSet;
            end
            disp('evaluating..');
            switch E.evalMethod
                case E.EVAL_METHOD_LOOCV
                    E.leaveOneOutCV();
                case E.EVAL_METHOD_LOSO
                    subjects = unique(E.subjectids);
                    instanceSet = E.classifier.instanceSet;
                    if isa(E.classifier,'ssveptoolkit.classifier.LIBSVMClassifierFast')
                        instanceSet.K = instanceSet.computeKernel(E.classifier.kernel,E.classifier.gamma,E.classifier.maxlag,E.classifier.scaleopt);
                    end
                    for i=1:length(subjects)
                        fprintf('leaving subject #%d out\n', i);
                        if isa(E.classifier,'ssveptoolkit.classifier.LIBSVMClassifierFast')
                            E.leaveOneSubjectOutFast(subjects(i), instanceSet);
                        else
                            E.leaveOneSubjectOut(subjects(i), instanceSet);
                        end
                        
                    end
                otherwise
                    error ('eval method not set or invalid');
            end
        end
        
        function info = getExperimentInfo(E)
            % Prints the configuration info of the experiment
            info = 'Experiment Configuration:\n';
            if ~isempty(E.transformer)
                if ~iscell(E.transformer)
                    info = strcat(info, E.transformer.getConfigInfo);
                    info = strcat(info,'\n');
                else
                    for i=1:length(E.transformer)
                        info = strcat(info, E.transformer{i}.getConfigInfo);
                        info = strcat(info,'\n');
                    end
                end
            end
            if ~isempty(E.aggregator)
                info = strcat(info, E.aggregator.getConfigInfo);
                info = strcat(info, '\n');
            end
            if ~isempty(E.extractor)
                info = strcat(info, E.extractor.getConfigInfo);
                info = strcat(info, '\n');
            end
            if ~isempty(E.classifier)
                info = strcat(info, E.classifier.getConfigInfo);
                info = strcat(info, '\n');
            end
            info = sprintf(info);
        end
        
    end
    
    methods (Access = private)
        
        function E = checkCompatibility(E)
            if iscell(E.transformer)
                if isempty(E.aggregator)
                    error ('Provided many transformers but not an Aggregator');
                end
            end
            if isa(E.classifier,'ssveptoolkit.classifier.LIBSVMClassifierFast') && E.evalMethod == 0
                error('LIBSVMClassifierFast not supported for LOOCV eval method');
            end
            if isa(E.extractor, 'ssveptoolkit.extractor.FrequencyFilter') && ...
                    ~isa(E.transformer,'ssveptoolkit.transformer.PSDTransformerBase')
                error('FrequencyFilter only supported with PSD based transformers');
            end
        end
            
        function E = leaveOneOutCV(E)
            %leave one out cross validation
            instanceSet = E.classifier.instanceSet;
            numInstances = instanceSet.getNumInstances;
            outputLabels = zeros(numInstances,1);
            outputScores = zeros(numInstances,1);
            outputRanking = zeros(numInstances, instanceSet.getNumLabels);
            h = waitbar(0,'Cross-validating..');
            for i=1:numInstances
                waitbar(i/numInstances,h,sprintf('Cross-validating fold: %d/%d', i, numInstances));
                %train the classifier without 1 instance
                E.classifier.instanceSet = instanceSet.removeInstancesWithIndices(i);
                E.classifier.build();
                %predict the label of the omitted instance
                [outputLabels(i,1), outputScores(i,1), outputRanking(i,:)] = E.classifier.classifyInstance(instanceSet.getInstancesWithIndices(i));
            end
            resultSet = ssveptoolkit.util.ResultSet(instanceSet.getDataset, outputLabels, outputScores, outputRanking);
            E.results{length(E.results)+1} = ssveptoolkit.experiment.ResultEvaluator(resultSet);
            close(h);
        end
        
        function resultSet = leaveOneSubjectOut(E, subjectid, instanceSet)
            testingset = find(E.subjectids == subjectid);
            E.classifier.instanceSet = instanceSet.removeInstancesWithIndices(testingset);
            E.classifier.build();
            [outputLabels, outputScores, outputRanking] = E.classifier.classifyInstance(instanceSet.getInstancesWithIndices(testingset));
            resultSet = ssveptoolkit.util.ResultSet(instanceSet.getDatasetWithIndices(testingset), outputLabels, outputScores, outputRanking);
            E.results{length(E.results)+1} = ssveptoolkit.experiment.ResultEvaluator(resultSet);
        end
        
        function resultSet = leaveOneSubjectOutFast(E, subjectid, instanceSet)
            testingset = E.subjectids == subjectid;
            E.classifier.Ktrain = instanceSet.getTrainKernel(~testingset);
            E.classifier.Ktest = instanceSet.getTestKernel(~testingset,testingset);
            testingset = find(E.subjectids == subjectid);
            E.classifier.instanceSet = instanceSet.removeInstancesWithIndices(testingset);
            E.classifier.build();
            [outputLabels, outputScores, outputRanking] = E.classifier.classifyInstance();
            resultSet = ssveptoolkit.util.ResultSet(instanceSet.getDatasetWithIndices(testingset), outputLabels, outputScores, outputRanking);
            E.results{length(E.results)+1} = ssveptoolkit.experiment.ResultEvaluator(resultSet);
        end
    end
    
end

