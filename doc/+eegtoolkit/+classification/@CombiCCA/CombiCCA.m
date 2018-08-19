classdef CombiCCA < eegtoolkit.classification.ClassifierBase;
    %COMBICCA Summary of this class goes here
    %   Detailed explanation goes here
    %     fprintf('CombitCCA Processing TW %fs, No.crossvalidation %d \n',TW(tw_length),run);
    %                         it=cell(12,1);
    %                         for iN = 1:nClasses
    %                             it{iN} = mean(SSVEPdata(chan_used,1:TW_p(tw_length),idx_traindata,iN),3);
    %                         end
    %                         % recognize SSVEP
    properties
        individualTemplates;
        refSignals;
        %         sti_f;
        baseClassifier;
    end
    
    methods
        function CoCCA = CombiCCA( sti_f, numHarmonics, sampleLength, samplingRate)
            %             CoCCA.sti_f = sti_f;
            %             CoCCA.numHarmonics = numHarmonics;
            CoCCA.refSignals = CoCCA.ck_signalTrans(sti_f,sampleLength, samplingRate, numHarmonics);
        end
        
        function CoCCA = build(CoCCA)
            numLabels = length(unique(CoCCA.instanceSet.labels));
            CoCCA.individualTemplates = cell(numLabels,1);
            unLabels = unique(CoCCA.instanceSet.labels);
            for i=1:numLabels
                trialsIndices = CoCCA.instanceSet.labels==unLabels(i);
                CoCCA.individualTemplates{i} = squeeze(mean(CoCCA.instanceSet.sMatrix(trialsIndices,:,:),1));
            end
            
        end
        
        function [output, probabilities, ranking] = classifyInstance(CoCCA,instance)
            testInstances = CoCCA.extract(instance);
            [output, probabilities, ranking] = CoCCA.baseClassifier.classifyInstance(testInstances);
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
        function instancesOutput = extract(CoCCA,sMatrix)
            numClasses = length(CoCCA.individualTemplates);
            numInstances = size(sMatrix,1);
            instancesOutput = zeros(numInstances,numClasses);
            for i=1:numInstances
                for j=1:numClasses
                    [wxit,wyit,rit] = CoCCA.cca(squeeze(sMatrix(i,:,:)),CoCCA.individualTemplates{j});
                    [wxref,wyref,rref] = CoCCA.cca(squeeze(sMatrix(i,:,:)),CoCCA.refSignals(:,:,j));
                    [wxitref,wyitref,ritref] = CoCCA.cca(CoCCA.individualTemplates{j},CoCCA.refSignals(:,:,j));
                    q1 = squeeze(sMatrix(i,:,:))'*wxref;
                    q2 = CoCCA.refSignals(:,:,j)'*wyref;
                    q3 = squeeze(sMatrix(i,:,:))'*wxit;
                    q4 = CoCCA.individualTemplates{j}'*wxit;
                    q5 = q1;
                    q6 = CoCCA.individualTemplates{j}'*wxref;
                    q7 = squeeze(sMatrix(i,:,:))'*wxitref;
                    q8 = CoCCA.individualTemplates{j}'*wxitref;
                    r_n = [corr(q1(:),q2(:)) corr(q3(:),q4(:)) corr(q5(:),q6(:)) corr(q7(:), q8(:))];
                    rho_n = sum(sign(r_n).*r_n.^2);
                    instancesOutput(i,j) = rho_n;
                end
            end
        end
        %                         for j=1:nClasses
        %                             tempvec=zeros(nClasses,1);
        %                             for jj=1:nClasses
        %                                 [wxit,wyit,rit ]=cca(SSVEPdata(chan_used,1:TW_p(tw_length),run,j),it{jj}(:,1:TW_p(tw_length)));
        %                                 [wxref,wyref,rref ]=cca(SSVEPdata(chan_used,1:TW_p(tw_length),run,j),sc{jj}(:,1:TW_p(tw_length)));
        %                                 [wxitref,wyitref,ritref ]=cca(it{jj}(:,1:TW_p(tw_length)),sc{jj}(:,1:TW_p(tw_length)));
        %                                 q1 = SSVEPdata(chan_used,1:TW_p(tw_length),run,j)'*wxref;
        %                                 q2 = sc{jj}(:,1:TW_p(tw_length))'*wyref;
        %                                 q3 = SSVEPdata(chan_used,1:TW_p(tw_length),run,j)'*wxit;
        %                                 q4 = it{jj}(:,1:TW_p(tw_length))'*wxit;
        %                                 q5 = q1;
        %                                 q6 = it{jj}(:,1:TW_p(tw_length))'*wxref;
        %                                 q7 = SSVEPdata(chan_used,1:TW_p(tw_length),run,j)'*wxitref;
        %                                 q8 = it{jj}(:,1:TW_p(tw_length))'*wxitref;
        %                                 r_n = [corr(q1(:),q2(:)) corr(q3(:),q4(:)) corr(q5(:),q6(:)) corr(q7(:),q8(:))];
        %                                 rho_n = sum(sign(r_n).*r_n.^2);
        %                                 tempvec(jj) = rho_n;%max(r1);
        %                             end
        %
        %                             [v,idx]=max(tempvec);
        %                             sub_lab(mth,(run-1)*nClasses+j,tw_length)=idx;
        %                             if idx==j
        %                                 n_correct(tw_length,mth)=n_correct(tw_length,mth)+1;
        %                             end
        %                         end
        function refSignal=ck_signalTrans(CCA,f,mLen,FreqSamp,NumHarm)
            
            p=mLen;%1250;
            fs=FreqSamp;%250;
            TP=1/fs:1/fs:p/fs;
            for j=1:length(f)
                tempComp=[];
                for k=1:NumHarm
                    Sinh1=sin(2*pi*k*f(j)*TP);
                    Cosh1=cos(2*pi*k*f(j)*TP);
                    tempComp = [tempComp; Sinh1;Cosh1;];
                end
                refSignal(:,:,j)=tempComp;
            end
        end
    end
end

