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
% experiment = eegtoolkit.experiment.Experimenter;
% experiment.session = eegtoolkit.util.Session;
% experiment.session.loadSubject(1);
% experiment.transformer = eegtoolkit.transformer.PWelchTransformer;
% experiment.extractor = eegtoolkit.extractor.FEASTFilter;
% experiment.classifier = eegtoolkit.classifier.LIBSVMClassifier;
% experiment.evalMethod = experiment.evalMethod.EVAL_METHOD_LOSO;
% experiment.run;
% results = experiment.results;
% confmatrix = results{1}.getConfusionMatrix;
classdef Experimenter < handle
    properties (Constant)
        EVAL_METHOD_LOOCV = 0; % Leave One Out Cross-Validation
        EVAL_METHOD_LOSO = 1; % Leave One Subject Out
        EVAL_METHOD_LOBO = 2;
        EVAL_METHOD_SPLIT = 3;
        EVAL_METHOD_XFOLD_CV = 4;
        EVAL_METHOD_LOSO_LOBO = 5;
    end
    
    properties (Access = public)
        session; % The Session object. Trials must be loaded before run() is executed
        preprocessing;
        featextraction; % A transformer object
        aggregator;
        featselection; % An extractor object
        evalMethod; % The evaluation method
        classification; % A classifier object
        results; % A cell array containing objects of the 'ResultEvaluator' class.
        trainresults;
        subjectids;
        sessionids;
    end
    
    methods
        function E = Experimenter(evalMethod)
            if nargin > 0
                E.evalMethod = evalMethod;
            else E.evalMethod = 0;
            end
            E.results = {};
        end
        function E = run(E,varargin)
            if(length(varargin)==1)
                numFolds = varargin{1};
            elseif(length(varargin)==2)
                trainIDx = varargin{1};
                testIDx = varargin{2};
            end
            % Runs an experiment
            E.checkCompatibility;
            E.subjectids = E.session.subjectids;
            E.sessionids = E.session.sessionids;
            trials = {};
            for i=1:length(E.session.trials)
                trials{i} = eegtoolkit.util.Trial(E.session.trials{i}.signal,...
                            E.session.trials{i}.label,E.session.trials{i}.samplingRate,E.session.trials{i}.subjectid,E.session.trials{i}.sessionid,E.session.trials{i}.type);
            end
            if ~isempty(E.preprocessing)
                for i=1:length(E.preprocessing)
%                     E.preprocessing{i}.originalTrials = trials;
                    trials = E.preprocessing{i}.process(trials);
%                     trials = E.preprocessing{i}.processedTrials;
                end
            end
            disp('feature extraction ...');
            if iscell(E.featextraction)
                numExtract = length(E.featextraction);
                for i=1:numExtract
                    E.featextraction{i}.trials = trials;
                    E.featextraction{i}.extract;    
                end
                E.aggregator.featextractors = E.featextraction;
                E.aggregator.aggregate;
                instanceSet = E.aggregator.instanceSet;
            else
                E.featextraction.trials = trials;
                E.featextraction.extract;
                instanceSet = E.featextraction.getInstanceSet;
            end
            if ~isempty(E.featselection)
                E.featselection.originalInstanceSet = instanceSet;
                disp('feature selection ...');
                E.featselection.compute;
                E.classification.instanceSet = E.featselection.filteredInstanceSet;
            else
                E.classification.instanceSet = instanceSet;
            end
            disp('evaluating..');
            switch E.evalMethod
                case E.EVAL_METHOD_LOOCV
                    E.leaveOneOutCV();
                case E.EVAL_METHOD_LOSO
                    subjects = unique(E.subjectids);
                    instanceSet = E.classification.instanceSet;
                    if isa(E.classification,'eegtoolkit.classification.LIBSVMFast')
                        instanceSet.K = instanceSet.computeKernel(E.classification.kernel,E.classification.gamma,E.classification.maxlag,E.classification.scaleopt);
                    end
                    for i=1:length(subjects)
                        fprintf('leaving subject #%d out\n', i);
                        if isa(E.classification,'eegtoolkit.classification.LIBSVMFast')
                            E.leaveOneSubjectOutFast(subjects(i), instanceSet);
                        else
                            
                            E.leaveOneSubjectOut(subjects(i), instanceSet);
                        end
                        
                    end
                case E.EVAL_METHOD_LOBO
                    sessions = unique(E.sessionids);
                    instanceSet = E.classification.instanceSet;
                    for i=1:length(sessions)
                        fprintf('leaving session #%d out\n', i);
                        E.leaveOneSessionOut(sessions(i), instanceSet);
                    end
                case E.EVAL_METHOD_SPLIT
                    instanceSet = E.classification.instanceSet;
                    E.splitTest(trainIDx,testIDx,instanceSet);
                case E.EVAL_METHOD_XFOLD_CV
                    instanceSet = E.classification.instanceSet;
                    E.kfoldCrossValidation(instanceSet,numFolds);
                case E.EVAL_METHOD_LOSO_LOBO
                    instanceSet = E.classification.instanceSet;
                    E.leaveOneSubjectOutLeaveOneBlockOut(instanceSet);
                otherwise
                    error ('eval method not set or invalid');
            end
        end
        
        function itrs = getITR(E)
            for i=1:length(E.preprocessing)
                if isa(E.preprocessing{i},'eegtoolkit.preprocessing.SampleSelection')
                    %T = time in seconds;
                    T = (E.preprocessing{i}.sampleRange(2)-E.preprocessing{i}.sampleRange(1)+1)/E.preprocessing{i}.samplingRate;
                end
            end
            if isempty(T)
                error('to calculate ITR the SampleSelection preprocessing step must be added to the experiment');
            end
            for i=1:length(E.results)
                itrs(i) = E.results{i}.getITR(T);
            end
        end
        function time = getTime(E)
            info = 'Average time elapsed for trial:\n';
            total = 0;
            if ~isempty(E.preprocessing)
                info = strcat(info, 'Preprocessing:\n');
                for i=1:length(E.preprocessing)
                    info = strcat(info, num2str(E.preprocessing{i}.getTime));
                    total = total + E.preprocessing{i}.getTime;
                    info = strcat(info, '\n');
                end
            end
            if ~isempty(E.featextraction)
                info = strcat(info, 'Feature Extraction:\n');
                if ~iscell(E.featextraction)
                    info = strcat(info, num2str(E.featextraction.getTime));
                    total = total + E.featextraction.getTime;
                    info = strcat(info, '\n');
                else
                    for i=1:length(E.featextraction)
                        info = strcat(info, num2str(E.featextraction{i}.getTime));
                        total = total + E.featextraction{i}.getTime;
                        info = strcat(info,'\n');
                    end
                end
            end
            if ~isempty(E.aggregator)
                info = strcat(info, 'Aggregation:\n');
                info = strcat(info, num2str(E.aggregator.getTime));
                total = total + E.aggregator.getTime;
                info = strcat(info, '\n');
            end
            if ~isempty(E.featselection)
                info = strcat(info, 'FeatureSelection:\n');
                info = strcat(info, num2str(E.featselection.getTime));
                total = total + E.featselection.getTime;
                info = strcat(info, '\n');
            end
            if ~isempty(E.classification)
                info = strcat(info, 'Classification (Prediction):\n');
                info = strcat(info, num2str(E.classification.getTime));
                total = total + E.classification.getTime;
                info = strcat(info, '\n');
            end
            info = strcat(info, 'Total:\n');
            info = strcat(info, num2str(total));
            time = sprintf(info);
        end
        
        function info = getExperimentInfo(E)
            % Prints the configuration info of the experiment
            info = 'Experiment Configuration:\n';
            if ~isempty(E.preprocessing)
                for i=1:length(E.preprocessing)
                    info = strcat(info, E.preprocessing{i}.getConfigInfo);
                    info = strcat(info,'\n');
                end
            end
            if ~isempty(E.featextraction)
                if ~iscell(E.featextraction)
                    info = strcat(info, E.featextraction.getConfigInfo);
                    info = strcat(info,'\n');
                else
                    for i=1:length(E.featextraction)
                        info = strcat(info, E.featextraction{i}.getConfigInfo);
                        info = strcat(info,'\n');
                    end
                end
            end
            if ~isempty(E.aggregator)
                info = strcat(info, E.aggregator.getConfigInfo);
                info = strcat(info, '\n');
            end
            if ~isempty(E.featselection)
                info = strcat(info, E.featselection.getConfigInfo);
                info = strcat(info, '\n');
            end
            if ~isempty(E.classification)
                info = strcat(info, E.classification.getConfigInfo);
                info = strcat(info, '\n');
            end
            info = sprintf(info);
        end
        
    end
    
    methods (Access = private)
        
        function E = checkCompatibility(E)
            if iscell(E.featextraction)
                if isempty(E.aggregator)
                    error ('Provided many feature extractors but not an Aggregator');
                end
            end
            if isa(E.classification,'eegtoolkit.classification.LIBSVMFast') && E.evalMethod == 0
                error('LIBSVMFast not supported for LOOCV eval method');
            end
        end
            
        function E = leaveOneOutCV(E)
            %leave one out cross validation
            instanceSet = E.classification.instanceSet;
            numInstances = instanceSet.getNumInstances;
            outputLabels = zeros(numInstances,1);
            outputScores = zeros(numInstances,1);
            outputRanking = zeros(numInstances, instanceSet.getNumLabels);
            h = waitbar(0,'Cross-validating..');
            for i=1:numInstances
                waitbar(i/numInstances,h,sprintf('Cross-validating fold: %d/%d', i, numInstances));
                %train the classifier without 1 instance
                E.classification.instanceSet = instanceSet.removeInstancesWithIndices(i);
                E.classification.build();
                %predict the label of the omitted instance
                [outputLabels(i,1), outputScores(i,1), outputRanking(i,:)] = E.classification.classifyInstance(instanceSet.getInstancesWithIndices(i));
            end
            resultSet = eegtoolkit.util.ResultSet(instanceSet.getDataset, outputLabels, outputScores, outputRanking);
            E.results{length(E.results)+1} = eegtoolkit.experiment.ResultEvaluator(resultSet);
            close(h);
        end
        
        function E = kfoldCrossValidation(E,instanceSet,numFolds)
            numInstances = instanceSet.getNumInstances;
            indices = crossvalind('Kfold', numInstances, numFolds);
            outputLabels = zeros(numInstances,1);
            outputScores = zeros(numInstances,1);
            outputRanking = zeros(numInstances,instanceSet.getNumLabels);
            h = waitbar(0,'Cross-validating..');
            for i=1:numFolds
                waitbar(i/numFolds,h,sprintf('Cross-validating fold: %d/%d',i,numFolds));
                testSet = find(indices==i);
                E.classification.instanceSet = instanceSet.removeInstancesWithIndices(testSet);
                E.classification.build();
                
                [outputLabels(testSet,1), outputScores(testSet,1), outputRanking(testSet,:)] = E.classification.classifyInstance(instanceSet.getInstancesWithIndices(testSet));
            end
            resultSet = eegtoolkit.util.ResultSet(instanceSet.getDataset, outputLabels, outputScores, outputRanking);
            E.results{length(E.results)+1} = eegtoolkit.experiment.ResultEvaluator(resultSet);
            close(h);
        end
        
        function resultSet = leaveOneSubjectOut(E, subjectid, instanceSet)
            testingset = find(E.subjectids == subjectid);
            E.classification.instanceSet = instanceSet.removeInstancesWithIndices(testingset);
            E.classification.build();
            [outputLabels, outputScores, outputRanking] = E.classification.classifyInstance(instanceSet.getInstancesWithIndices(testingset));
            resultSet = eegtoolkit.util.ResultSet(instanceSet.getDatasetWithIndices(testingset), outputLabels, outputScores, outputRanking);
            E.results{length(E.results)+1} = eegtoolkit.experiment.ResultEvaluator(resultSet);
        end
        
                
        function resultSet = leaveOneSubjectOutLeaveOneBlockOut(E, instanceSet)
            subjects = unique(E.subjectids);
            sessions = unique(E.sessionids);
            for i=1:length(subjects)
                numInstancesForSubject = sum(E.subjectids==subjects(i));
                outputLabels = zeros(numInstancesForSubject,1);
                outputScores = zeros(numInstancesForSubject,1);
                outputRanking = zeros(numInstancesForSubject,instanceSet.getNumLabels());
                for j=1:length(sessions)
%                     tempResults{j} = E.leaveOneSessionOut(sessions(j),tempInstanceSet);
                    sessionidsSubset = E.sessionids(E.subjectids==subjects(i));
                    testIndices = sessionidsSubset==sessions(j);
                    numInstancesForSession = sum(E.sessionids==sessions(j)&E.subjectids==subjects(i));
                    testingset = find(E.sessionids==sessions(j)&E.subjectids==subjects(i));
                    nottrainset = find(E.sessionids==sessions(j)|E.subjectids~=subjects(i));
                    E.classification.instanceSet = instanceSet.removeInstancesWithIndices(nottrainset);
                    E.classification.build();
                    [outputLabels(testIndices,:), outputScores(testIndices,:), outputRanking(testIndices,:)] = ...
                        E.classification.classifyInstance(instanceSet.getInstancesWithIndices(testingset));
                    
                end
                sIndices = find(E.subjectids==subjects(i));
                resultSet = eegtoolkit.util.ResultSet(instanceSet.getDatasetWithIndices(sIndices),outputLabels,outputScores,outputRanking);
                E.results{length(E.results)+1} = eegtoolkit.experiment.ResultEvaluator(resultSet);
                %merge the results
            end
        end
        
        
        function resultSet = leaveOneSessionOut(E, sessionId, instanceSet)
            testingset = find(E.sessionids == sessionId);
            trainset = find(E.sessionids ~= sessionId);
            E.classification.instanceSet = instanceSet.removeInstancesWithIndices(testingset);
            E.classification.build();
            [outputLabels, outputScores, outputRanking] = E.classification.classifyInstance(instanceSet.getInstancesWithIndices(testingset));
            [trainoutputLabels, trainoutputScores, trainoutputRanking] = E.classification.classifyInstance(instanceSet.getInstancesWithIndices(trainset));
            resultSet = eegtoolkit.util.ResultSet(instanceSet.getDatasetWithIndices(testingset), outputLabels, outputScores, outputRanking);
            trainresultSet = eegtoolkit.util.ResultSet(instanceSet.getDatasetWithIndices(trainset), trainoutputLabels, trainoutputScores, trainoutputRanking);
            E.results{length(E.results)+1} = eegtoolkit.experiment.ResultEvaluator(resultSet);
            E.trainresults{length(E.trainresults)+1} = eegtoolkit.experiment.ResultEvaluator(trainresultSet);
        end
        
        function resultSet = leaveOneSubjectOutFast(E, subjectid, instanceSet)
            testingset = E.subjectids == subjectid;
            E.classification.Ktrain = instanceSet.getTrainKernel(~testingset);
            E.classification.Ktest = instanceSet.getTestKernel(~testingset,testingset);
            testingset = find(E.subjectids == subjectid);
            E.classification.instanceSet = instanceSet.removeInstancesWithIndices(testingset);
            E.classification.build();
            [outputLabels, outputScores, outputRanking] = E.classification.classifyInstance();
            resultSet = eegtoolkit.util.ResultSet(instanceSet.getDatasetWithIndices(testingset), outputLabels, outputScores, outputRanking);
            resultEvaluator = eegtoolkit.experiment.ResultEvaluator(resultSet);
            resultEvaluator.subjectid = E.subjectids(E.subjectids==subjectid);
            resultEvaluator.sessionid = E.session.sessionids(E.subjectids==subjectid);
            E.results{length(E.results)+1} = resultEvaluator;
        end

        function resultSet = splitTest(E,trainIDx,testIDx, instanceSet)
            E.classification.instanceSet = instanceSet.removeInstancesWithIndices(testIDx);
            E.classification.build();
            [outputLabels, outputScores, outputRanking] = E.classification.classifyInstance(instanceSet.getInstancesWithIndices(testIDx));
            resultSet = eegtoolkit.util.ResultSet(instanceSet.getDatasetWithIndices(testIDx), outputLabels, outputScores, outputRanking);
            resultEvaluator = eegtoolkit.experiment.ResultEvaluator(resultSet);
            E.results{length(E.results) + 1} = resultEvaluator;
        end
        

                
            
    end
    
end

