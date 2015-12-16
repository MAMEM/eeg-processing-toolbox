classdef Experimenter < handle
    
    properties (Constant)
        EVAL_METHOD_LOOCV = 0;
        EVAL_METHOD_LOSO = 1;
    end
    
    properties (Access = public)
        session; 
        transformer;
        extractor;
        evalMethod;
        classifier;
        results;
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
%             E.instanceSet = ssveptoolkit.util.InstanceSet(E.classifier.instanceSet.getDataset);
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
            %TODO: parfor this?
            for i=1:numInstances
                waitbar(i/numInstances,h,sprintf('Cross-validating fold: %d/%d', i, numInstances));
                %train the classifier without 1 instance
                %TODO: this line will change
                E.classifier.instanceSet = instanceSet.removeInstancesWithIndices(i);
                E.classifier.build();
                %predict the label of the omitted instance
                [outputLabels(i,1), outputScores(i,1), outputRanking(i,:)] = E.classifier.classifyInstance(instanceSet.getInstancesWithIndices(i));
            end
            resultSet = ssveptoolkit.util.ResultSet(instanceSet.getDataset, outputLabels, outputScores, outputRanking);
            E.results{length(E.results)+1} = ssveptoolkit.experiment.ResultEvaluator(resultSet);
            %store the (final) results in a resultSet instances
%             EB.resultSet = ssveptoolkit.util.ResultSet(E.instanceSet.getDataset, outputLabels, outputScores, outputRanking);
            close(h);
        end
        
        function resultSet = leaveOneSubjectOut(E, subjectid, instanceSet)
            testingset = find(E.session.subjectids == subjectid);
            E.classifier.instanceSet = instanceSet.removeInstancesWithIndices(testingset);
            E.classifier.build();
            [outputLabels, outputScores, outputRanking] = E.classifier.classifyInstance(instanceSet.getInstancesWithIndices(testingset));
            resultSet = ssveptoolkit.util.ResultSet(instanceSet.getDatasetWithIndices(testingset), outputLabels, outputScores, outputRanking);
            E.results{length(E.results)+1} = ssveptoolkit.experiment.ResultEvaluator(resultSet);
            %             h = waitbar(0, 'Evaluating..');
            
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
            %             h = waitbar(0, 'Evaluating..');
        end
    end
    
end

