classdef ITCCA < eegtoolkit.classification.ClassifierBase;
    %                 instanceStruct = struct('sMatrix',sMatrix, 'labels', labels);
    %     it=cell(12,1);
    %                         for iN = 1:nClasses
    %                             it{iN} = mean(SSVEPdata(chan_used,1:TW_p(tw_length),idx_traindata,iN),3);
    %                         end
    %                         % recognize SSVEP
    %                         for j=1:nClasses
    %                             tempvec=zeros(nClasses,1);
    %                             for jj=1:nClasses
    %                                 [wx1,wy1,r1]=cca(SSVEPdata(chan_used,1:TW_p(tw_length),run,j),it{jj}(:,1:TW_p(tw_length)));
    %                                 tempvec(jj) = max(r1);
    %                             end
    %
    %                             [v,idx]=max(tempvec);
    %                             sub_lab(mth,(run-1)*nClasses+j,tw_length)=idx;
    %                             if idx==j
    %                                 n_correct(tw_length,mth)=n_correct(tw_length,mth)+1;
    %                             end
    %                         end
    properties (Constant)
        
    end
    properties
        baseClassifier;
        individualTemplates;
    end
    
    methods (Access = public)
        function IT = ITCCA(instanceSet)
            %             if(isa(instanceSet,'eegtoolkit.util.RawSignalSet')
            %                 CSP.instanceSet = instanceSet;
            %             else
            %                 error('RawSignal extractor should be used with CSPWrapper');
            %             end
        end
        
        
        function IT = build(IT)
            % Builds the classification models
            %             IT.learnCSPMatrix(IT.instanceSet.sMatrix,IT.instanceSet.labels);
            numLabels = length(unique(IT.instanceSet.labels));
            IT.individualTemplates = cell(numLabels,1);
            unLabels = unique(IT.instanceSet.labels);
            for i = 1:numLabels
                trialsIndices = IT.instanceSet.labels==unLabels(i);
                IT.individualTemplates{i} = squeeze(mean(IT.instanceSet.sMatrix(trialsIndices,:,:),1));
            end
            %             instances = IT.extract(IT.instanceSet.sMatrix);
            %             instanceSet = eegtoolkit.util.InstanceSet(instances,IT.instanceSet.labels);
            %             IT.baseClassifier.instanceSet = instanceSet;
            %             IT.baseClassifier.build();
        end
        
        function [output, probabilities, ranking] = classifyInstance(CSP,instance)
            %                         for j=1:nClasses
            %                             tempvec=zeros(nClasses,1);
            %                             for jj=1:nClasses
            %                                 [wx1,wy1,r1]=cca(SSVEPdata(chan_used,1:TW_p(tw_length),run,j),it{jj}(:,1:TW_p(tw_length)));
            %                                 tempvec(jj) = max(r1);
            %                             end
            %
            %                             [v,idx]=max(tempvec);
            %                             sub_lab(mth,(run-1)*nClasses+j,tw_length)=idx;
            %                             if idx==j
            %                                 n_correct(tw_length,mth)=n_correct(tw_length,mth)+1;
            %                             end
            %                         end
            %             instance = CSP.extract
            %input = instance matrix rows = instances, cols = attributes
            %output = predicted class
            %probabilities = probability for predicted class
            %ranking = propabilities for all classes (e.g. to use with mAP)
            
            %TODO:should print an error if 'build' has not been called
            testInstances = CSP.extract(instance);
            [output, probabilities, ranking] = CSP.baseClassifier.classifyInstance(testInstances);
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
        
        function CSP = reset(CSP)
            % 'Resets' the classifier.
            %             CSP.models = {};
        end
        
        function configInfo = getConfigInfo(CSP)
            configInfo = '\n';
        end
        
        
        function time = getTime(CSP)
            time = 0;
        end
    end
    
    
    methods (Access = private)
        function [Wx, Wy, r] = cca(CCA,X,Y)
            %
            % CCA calculate canonical correlations
            %
            % [Wx Wy r] = cca(X,Y) where Wx and Wy contains the canonical correlation
            
            % vectors as columns and r is a vector with corresponding canonical
            % correlations. The correlations are sorted in descending order. X and Y
            % are matrices where each column is a sample. Hence, X and Y must have
            % the same number of columns.
            %
            % Example: If X is M*K and Y is N*K there are L=MIN(M,N) solutions. Wx is
            % then M*L, Wy is N*L and r is L*1.
            %
            %
            % ?? 2000 Magnus Borga, Link?pings universitet
            
            % --- Calculate covariance matrices ---??????????????
            
            z = [X;Y];
            C = cov(z.');
            sx = size(X,1);   %X??????(??),
            sy = size(Y,1);
            Cxx = C(1:sx, 1:sx) + 10^(-8)*eye(sx);
            Cxy = C(1:sx, sx+1:sx+sy);
            Cyx = Cxy';
            Cyy = C(sx+1:sx+sy, sx+1:sx+sy) + 10^(-8)*eye(sy);%eye()????????
            invCyy = inv(Cyy);
            
            % --- Calcualte Wx and r ---
            
            [Wx,r] = eig(inv(Cxx)*Cxy*invCyy*Cyx); % Basis in X eig????????????
            r = sqrt(real(r));      % Canonical correlations
            
            % --- Sort correlations ---
            
            V = fliplr(Wx);		% reverse order of eigenvectors??????????????????????i??????????i??????
            r = flipud(diag(r));	% extract eigenvalues and reverse their order
            [r,I]= sort((real(r)));	% sort reversed eigenvalues in ascending order
            r = flipud(r);		% restore sorted eigenvalues into descending order??????????????
            for j = 1:length(I)
                Wx(:,j) = V(:,I(j));  % sort reversed eigenvectors in ascending order
            end
            Wx = fliplr(Wx);	% restore sorted eigenvectors into descending order
            
            % --- Calcualte Wy  ---
            
            Wy = invCyy*Cyx*Wx;     % Basis in Y
            % Wy = Wy./repmat(sqrt(sum(abs(Wy).^2)),sy,1); % Normalize Wy
            
        end
        
        
        function instancesOutput = extract(IT,sMatrix)
            
            numClasses = length(IT.individualTemplates);
            numInstances = size(sMatrix,1);
            tempvec=zeros(numClasses,1);
            instancesOutput = zeros(numInstances,numClasses);
            for i=1:numInstances
                for j=1:numClasses
                    [~,~,r1] = IT.cca(squeeze(sMatrix(i,:,:)),IT.individualTemplates{j});
                    %                     [wx1,wy1,r1]=cca(SSVEPdata(chan_used,1:TW_p(tw_length),run,j),IT.individualTemplates{j});
                    instancesOutput(i,j) = max(r1);
                end
            end
            
            %             [v,idx]=max(tempvec);
            %             sub_lab(mth,(run-1)*nClasses+j,tw_length)=idx;
            %             if idx==j
            %                 n_correct(tw_length,mth)=n_correct(tw_length,mth)+1;
            %             end
            %
            %             [numTrials,numChannels,~] = size(sMatrix);
            %             sMatrix = permute(sMatrix,[3,2,1]);
            %             for i=1:size(sMatrix,3);
            %                 sMatrix(:,:,i) = (CSP.cspFilter*sMatrix(:,:,i)')';
            %             end
            %             instances = zeros(numTrials,numChannels);
            %             for i=1:numTrials
            %                 projectedTrial = sMatrix(:,:,i);
            %                 variances = var(projectedTrial,0,1);
            %                 instances(i,:) = log(variances)';
            %             end
            %             instanceSet = eegtoolkit.util.InstanceSet(instances,labels);
        end
    end
end

