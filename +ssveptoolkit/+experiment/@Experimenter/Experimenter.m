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
        extractor; % An extractor object
        evalMethod; % The evaluation method
        classifier; % A classifier object
        results; % A cell array containing objects of the 'ResultEvaluator' class.
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
            E.transformer.trials = E.session.trials;
            disp('transform ...');
            E.transformer.transform;
            if ~isempty(E.extractor)
                E.extractor.originalInstanceSet = E.transformer.getInstanceSet;
                disp('extract ...');
                E.extractor.filter;
                E.classifier.instanceSet = E.extractor.filteredInstanceSet;
            else
                E.classifier.instanceSet = E.transformer.getInstanceSet;
            end
            disp('evaluating..');
            switch E.evalMethod
                case E.EVAL_METHOD_LOOCV
                    if isa(E.classifier,'ssvep.toolkit.classifier.LIBSVMClassifierFast')
                        error('LIBSVMClassifierFast not supported for LOOCV eval method');
                    end
                    E.leaveOneOutCV();
                case E.EVAL_METHOD_LOSO
                    subjects = unique(E.session.subjectids);
                    instanceSet = E.classifier.instanceSet;
                    if isa(E.classifier,'ssveptoolkit.classifier.LIBSVMClassifierFast')
                        instanceSet.K = instanceSet.computeLinKernel;
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
                info = strcat(info, E.transformer.getConfigInfo);
                info = strcat(info,'\n');
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
            testingset = find(E.session.subjectids == subjectid);
            E.classifier.instanceSet = instanceSet.removeInstancesWithIndices(testingset);
            E.classifier.build();
            [outputLabels, outputScores, outputRanking] = E.classifier.classifyInstance(instanceSet.getInstancesWithIndices(testingset));
            resultSet = ssveptoolkit.util.ResultSet(instanceSet.getDatasetWithIndices(testingset), outputLabels, outputScores, outputRanking);
            E.results{length(E.results)+1} = ssveptoolkit.experiment.ResultEvaluator(resultSet);
        end
        
        function resultSet = leaveOneSubjectOutFast(E, subjectid, instanceSet)
            testingset = E.session.subjectids == subjectid;
            E.classifier.Ktrain = instanceSet.getTrainKernel(~testingset);
            E.classifier.Ktest = instanceSet.getTestKernel(~testingset,testingset);
            testingset = find(E.session.subjectids == subjectid);
            E.classifier.instanceSet = instanceSet.removeInstancesWithIndices(testingset);
            E.classifier.build();
            [outputLabels, outputScores, outputRanking] = E.classifier.classifyInstance();
            resultSet = ssveptoolkit.util.ResultSet(instanceSet.getDatasetWithIndices(testingset), outputLabels, outputScores, outputRanking);
            E.results{length(E.results)+1} = ssveptoolkit.experiment.ResultEvaluator(resultSet);
        end
    end
    
end

