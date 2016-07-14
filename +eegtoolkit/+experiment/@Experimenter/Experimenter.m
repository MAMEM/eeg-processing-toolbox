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
            E.subjectids = E.session.subjectids;
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
        
        function resultSet = leaveOneSubjectOut(E, subjectid, instanceSet)
            testingset = find(E.subjectids == subjectid);
            E.classification.instanceSet = instanceSet.removeInstancesWithIndices(testingset);
            E.classification.build();
            [outputLabels, outputScores, outputRanking] = E.classification.classifyInstance(instanceSet.getInstancesWithIndices(testingset));
            resultSet = eegtoolkit.util.ResultSet(instanceSet.getDatasetWithIndices(testingset), outputLabels, outputScores, outputRanking);
            E.results{length(E.results)+1} = eegtoolkit.experiment.ResultEvaluator(resultSet);
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
    end
    
end

