classdef CSPFilterBankWrapperMedian < eegtoolkit.classification.ClassifierBase;
    properties (Constant)
        
    end
    properties
        baseClassifier;
        channel;
        cspFilters;
        filterBanks;
        samplingRate;
    end
    
    methods (Access = public)
        function CSPFB = CSPFilterBankWrapperMedian(filterBanks, samplingRate)
            CSPFB.cspFilters = {};
            CSPFB.filterBanks = filterBanks;
            CSPFB.samplingRate = samplingRate;
            %filter_banks=[8 12; 12 16; 16 20;20 24;24 28];
            %             if(isa(instanceSet,'eegtoolkit.util.RawSignalSet')
            %                 CSP.instanceSet = instanceSet;
            %             else
            %                 error('RawSignal extractor should be used with CSPWrapper');
            %             end
        end
        
        
        function CSPFB = build(CSPFB)
            % Builds the classification models
            CSPFB.learnCSPMatrix(CSPFB.instanceSet.sMatrix,CSPFB.instanceSet.labels);
            instanceLocal = CSPFB.extract(CSPFB.instanceSet.sMatrix);
            CSPFB.baseClassifier.instanceSet = eegtoolkit.util.InstanceSet(instanceLocal,CSPFB.instanceSet.labels);
            CSPFB.baseClassifier.build;
            CSPFB.reset;
        end
        
        function [output, probabilities, ranking] = classifyInstance(CSPFB,instance)
            
            %             instance = CSP.extract
            %input = instance matrix rows = instances, cols = attributes
            %output = predicted class
            %probabilities = probability for predicted class
            %ranking = propabilities for all classes (e.g. to use with mAP)
            
            %TODO:should print an error if 'build' has not been called
            testInstances = CSPFB.extract(instance);
            [output, probabilities, ranking] = CSPFB.baseClassifier.classifyInstance(testInstances);
            %             numModels = length(LSVM.models);
            %             [numinstance, ~] = size(testInstances);
            %             scores = zeros(numModels,numinstance);
            %             for i=1:numModels
            %                 %predict using the stored models
            %                 [~, ~, t] = svmpredict(eye(numinstance,1),testInstances, LSVM.models{i},'-b 1 -q');
            %                 %store probability for each class
            %                 scores(i,:) = t(:,1);
            %             end
            %             output = zeros(numinstance,1);
            %             probabilities = zeros(numinstance,1);
            %             ranking = scores;
            %             for i=1:numinstance
            %                 %select the class with the highest probability
            %                 [prob, idx] = max(scores(:,i));
            %                 uniqueLabels = unique(LSVM.instanceSet.getLabels);
            %                 %output the label with highest probability
            %                 output(i,1) = uniqueLabels(idx);
            %                 %return the probability for the output label
            %                 probabilities(i,1) = prob;
            %             end
        end
        
        function CSPFB = reset(CSPFB)
            % 'Resets' the classifier.
            %             CSP.models = {};
        end
        
        function configInfo = getConfigInfo(CSPFB)
            configInfo = '\n';
        end
        
        
        function time = getTime(CSPFB)
            time = 0;
        end
    end
    methods (Access = private)
        function [] = learnCSPMatrix(CSPFB, sMatrix, labels)
            %[trialsMat,labels] = ssveptoolkit.util.Trial.trialsCellToMat(in);
            [numTrials,numChannels,numSamples] = size(sMatrix);
            %             numTrials = length(CSPFB.trials);
            %             [numChannels,numSamples] = size(CSPFB.trials{1}.signal);
            %             samplingRate = CSPFB.trials{1}.samplingRate;
            filter_banks= CSPFB.filterBanks;
            [nfb, mfb] = size(filter_banks);
            
            for iter_fb=1:nfb
                
                [b,a]=butter(3,filter_banks(iter_fb)/(CSPFB.samplingRate/2));
                %numTrials X numChannels X numSamples
                trialsMat = permute(sMatrix,[2,3,1]);
                trialsMat = zeros(numChannels,numSamples,numTrials);
                for i = 1 : size(sMatrix,1)
                    for i_ch = 1:numChannels
                        trialsMat(i_ch,:,i) = filtfilt(b,a,squeeze(sMatrix(i,i_ch,:)));
                        %                         trialsMat(i_ch,:,i) = filtfilt(Hd.sosMatrix,Hd.ScaleValues,squeeze(sMatrix(i,i_ch,:)));
                    end
                    %                     labels(i) = trials{i}.label;
                end
                
                trialsMat = permute(trialsMat,[2 1 3]);
                [N1, Nch1, Ntr1] = size(trialsMat);
                for i = 1:Nch1
                    for j = 1:Ntr1
                        trialsMat(:,i,j) = (trialsMat(:,i,j) - mean(trialsMat(:,i,j)));
                    end
                end
                x_train = trialsMat;%(:,:,CSP_Feat.trainIdx);
                y_train = labels;%(CSP_Feat.trainIdx);
                [N, Nch, Ntr] = size(x_train);
                trialCov=zeros(Nch,Nch,Ntr);
                for t=1:length(y_train)
                    E = x_train(:,:,t)';
                    EE = E * E';
                    trialCov(:,:,t) = EE ./ trace(EE);
                end
                for c=1:2
                    covMat{c} = mean(trialCov(:,:,y_train == c),3);
                end
                [U, D] = eig(covMat{1},covMat{2},'qz');
                eigenvalues = diag(D);
                [~, ind] = sort(eigenvalues, 'descend');
                if(numChannels<6)
                    %2 Channels
                    U = U(:,ind);
                else
                    %Many channels
                    for k=1:size(x_train,3)
                        % trialsMat2(:,:,j) = (CSPFB.cspFilters{iter_fb}*trialsMat(:,:,j)')';
                        trialsMatAB(:,:,k) = U*squeeze(x_train(:,:,k))';
                        % %                         variances = var(projectedTrial,0,1);
                    end
%                     variances = [];
                    for i=1:numTrials
                        
                        projectedTrial = trialsMatAB(:,:,i);%Filter * CSP_Feat.trials{i}.signal(:,i);% EEGSignals.x(:,:,t)';
                        %generating the features as the log variance of the projected signals
                        variances(i,:) = var(projectedTrial',0,1);
                    end
                    unlabels = unique(labels);
                    for i=1:Nch
                        x1 = median(variances(labels==unlabels(1),i));
                        x2 = median(variances(labels==unlabels(2),i));
                        score(i) = x1/(x2+x1);
                    end
                    [sortedScores, ind] = sort(score);
                    
                    U = U(:,ind([1,2,end-3:end]));
                end
                CSPFB.cspFilters{iter_fb} = U';
                %                 CSP_Filter = U';
            end
            %trialsMat2=zeros(N,3,Ntr);
            
        end
        
        function instances = extract(CSPFB,sMatrix)
            trialsMat = permute(sMatrix,[2,3,1]);
            trialsMat = permute(trialsMat,[2,1,3]);
            [a,b,c] = size(trialsMat);
%             if(b>=6)
%                 b = 6;
%             end
%             b =4;
            b = size(CSPFB.cspFilters{1},1);
            trialsMat2 = zeros(a,b,c);
            [numTrials,numChannels,~] = size(sMatrix);
            final_instances = zeros(numTrials, b*length(CSPFB.filterBanks));
            for iter_fb=1:length(CSPFB.cspFilters)
                for j = 1:size(trialsMat,3)
                    trialsMat2(:,:,j) = (CSPFB.cspFilters{iter_fb}*trialsMat(:,:,j)')';
                end
                
                instances = zeros(numTrials, b);
                %labels = zeros(numTrials,1);
                
                for i=1:numTrials
                    
                    projectedTrial = trialsMat2(:,:,i);%Filter * CSP_Feat.trials{i}.signal(:,i);% EEGSignals.x(:,:,t)';
                    %generating the features as the log variance of the projected signals
                    variances = var(projectedTrial,0,1);
                    instances(i,:) = log(variances)';
                    %labels(i,1) = floor(CSP_Feat.trials{i}.label);
                end
                final_instances(:,b*(iter_fb-1)+1:b*iter_fb) = instances;
                %            CSP_Feat.avgTime = toc/numTrials;
                %                 CSP_Feat.instanceSet = ssveptoolkit.util.InstanceSet(final_instances,labels);
            end
            instances = final_instances;
        end
        
        
        
    end
    %             [numTrials,numChannels,~] = size(sMatrix);
    %             sMatrix = permute(sMatrix,[3,2,1]);
    %             for i=1:size(sMatrix,3);
    %                 sMatrix(:,:,i) = (CSPFB.cspFilter*sMatrix(:,:,i)')';
    %             end
    %             instances = zeros(numTrials,numChannels);
    %             for i=1:numTrials
    %                 projectedTrial = sMatrix(:,:,i);
    %                 variances = var(projectedTrial,0,1);
    %                 instances(i,:) = log(variances)';
    %             end
    % %             instanceSet = eegtoolkit.util.InstanceSet(instances,labels);
    %         end
    %end
end

