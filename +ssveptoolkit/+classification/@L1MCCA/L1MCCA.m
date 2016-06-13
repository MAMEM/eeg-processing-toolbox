classdef L1MCCA< ssveptoolkit.classification.ClassifierBase
    
    properties (Constant)
        
    end
    properties
        samplingRate;
        numHarmonics;
        numSeconds;
        stimulusFrequencies;
        models;
        maxIterations;
        nProjectionComponents;
        lambda;
    end
    
    properties (Access = private)
        referenceSignals;
        optimalReferenceSignals;
        projections;
    end
    
    methods (Access = public)
        function L1MCCA = L1MCCA(samplingRate,numSeconds,numHarmonics,stimulusFrequencies)
            L1MCCA.samplingRate = samplingRate;
            L1MCCA.numSeconds = numSeconds;
            L1MCCA.numHarmonics = numHarmonics;
            L1MCCA.stimulusFrequencies = stimulusFrequencies;
            
            L1MCCA.maxIterations = 200;
            L1MCCA.nProjectionComponents = 1;
            L1MCCA.lambda = 0.02;
            
            L1MCCA.referenceSignals = {};
            L1MCCA.projections = {};
            L1MCCA.optimalReferenceSignals = {};
            
        end
        
        function L1MCCA = build(L1MCCA)
            L1MCCA.reset;
            n_sti = length(L1MCCA.stimulusFrequencies);
            TW = 0.5:0.5:L1MCCA.numSeconds;
            TW_p = round(TW*L1MCCA.samplingRate);
            
            for i=1:n_sti
                L1MCCA.referenceSignals{i} = L1MCCA.squarewave(L1MCCA.stimulusFrequencies(i)...
                    ,L1MCCA.samplingRate,L1MCCA.numSeconds*L1MCCA.samplingRate,L1MCCA.numHarmonics);
            end
            for i=1:n_sti
                a = L1MCCA.instanceSet.matrix4D(:,:,L1MCCA.instanceSet.labelss==i);
                [~,~,numIns] = size(a);
                iniw3 = ones(numIns,1);
                L1MCCA.projections{i} = {};
                [L1MCCA.projections{i}{1},L1MCCA.projections{i}{2},L1MCCA.projections{i}{3}] = L1MCCA.smcca(L1MCCA.referenceSignals{i},...
                    a,L1MCCA.maxIterations,iniw3,L1MCCA.nProjectionComponents,L1MCCA.lambda);
            end
            for i=1:n_sti
                L1MCCA.optimalReferenceSignals{i} = ttm(tensor(L1MCCA.instanceSet.matrix4D(:,:,L1MCCA.instanceSet.labelss==i)),L1MCCA.projections{i}{2}',3);
                L1MCCA.optimalReferenceSignals{i} = tenmat(L1MCCA.optimalReferenceSignals{i},1);
                L1MCCA.optimalReferenceSignals{i} = L1MCCA.optimalReferenceSignals{i}.data;
                L1MCCA.optimalReferenceSignals{i} = L1MCCA.projections{i}{1}'*L1MCCA.optimalReferenceSignals{i};
            end
        end
        
        function [output, probabilities, ranking] = classifyInstance(L1MCCA,instance)
            %input = instance matrix rows = instances, cols = attributes
            %output = predicted class
            %probabilities = probability for predicted class
            %ranking = propabilities for all classes (e.g. to use with mAP)
            
            %TODO:should print an error if 'build' has not been called
            [~, ~,numInstance] = size(instance);
            numLabels = length(L1MCCA.optimalReferenceSignals);
            output = zeros(numInstance,1);
            scores = zeros(numLabels,numInstance);
            for i=1:numInstance
                for j=1:numLabels
                    [~,~,r] = L1MCCA.cca(instance(:,:,i),L1MCCA.optimalReferenceSignals{j});
                    scores(j,i) = max(r);
                    
                end
                [~,output(i,1)] = max(scores(:,i));
            end
            ranking = scores;
            probabilities = max(scores);
        end
        
        function L1MCCA = reset(L1MCCA)
%             'Resets' the classifier.
            L1MCCA.referenceSignals = {};
            L1MCCA.projections = {};
            L1MCCA.optimalReferenceSignals = {};
        end
        
        function configInfo = getConfigInfo(L1MCCA)
            % Prints the parameters of the classifier
            configInfo = 'L1MCCA';
        end
        
        function [Wx, Wy, r] = cca(L1MCCA,X,Y)
            
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
            
            % --- Calculate covariance matrices ---
            
            z = [X;Y];
            C = cov(z.');
            sx = size(X,1);
            sy = size(Y,1);
            Cxx = C(1:sx, 1:sx) + 10^(-8)*eye(sx);
            Cxy = C(1:sx, sx+1:sx+sy);
            Cyx = Cxy';
            Cyy = C(sx+1:sx+sy, sx+1:sx+sy) + 10^(-8)*eye(sy);
            invCyy = inv(Cyy);
            
            % --- Calcualte Wx and r ---
            
            [Wx,r] = eig(inv(Cxx)*Cxy*invCyy*Cyx); % Basis in X
            r = sqrt(real(r));      % Canonical correlations
            
            % --- Sort correlations ---
            
            V = fliplr(Wx);		% reverse order of eigenvectors
            r = flipud(diag(r));	% extract eigenvalues and reverse their order
            [r,I]= sort((real(r)));	% sort reversed eigenvalues in ascending order
            r = flipud(r);		% restore sorted eigenvalues into descending order
            for j = 1:length(I)
                Wx(:,j) = V(:,I(j));  % sort reversed eigenvectors in ascending order
            end
            Wx = fliplr(Wx);	% restore sorted eigenvectors into descending order
            
            % --- Calcualte Wy  ---
            
            Wy = invCyy*Cyx*Wx;     % Basis in Y
            % Wy = Wy./repmat(sqrt(sum(abs(Wy).^2)),sy,1); % Normalize Wy
        end
        function  [w1,w3,v1] = smcca(L1MCCA,refdata,traindata,max_iter,iniw3,n_comp,lmbda)
            % L1-regualrized (Sparse) Multiway CCA
            % traindata:    channel x time x trial
            % refdata:      references by sine-cosine waveforms
            %
            % Rerefence:
            % [1] Y. Zhang, G. Zhou, J. Jin, M. Wang, X. Wang, A. Cichocki.
            %     L1-regularized multiway canonical correlation analysis for SSVEP-based BCI.
            %     IEEE Trans. Neural Syst. Rehabil. Eng., 21(6): 887-896 (2013)
            % [2] T.K. Kim, R. Cipolla. Canonical correlation analysis of video volume tensor for
            %     action categorization and detection. IEEE Trans. PAMI, 31(8): 1415-1428 (2009)
            %
            %
            % by Yu Zhang, ECUST, 2014.4.29
            %
            
            iter=1;
            w3=iniw3;
            w3=w3./norm(w3);
            traindata=tensor(traindata);
            refdata=tensor(refdata);
            
            er=0.00001;     % error for iteration stop
            
            while iter<max_iter
                projx3=ttm(traindata,w3',3);
                projx3=tenmat(projx3,1);                        % unfolding each trial tensor into i-mode matrix
                projx3=projx3.data;
                [v1,w1,r1]=L1MCCA.cca(refdata.data,projx3);
                v1=v1(:,1:n_comp); w1=w1(:,1:n_comp);
                v1=v1./norm(v1); w1=w1./norm(w1);
                projx1=ttm(traindata,w1',1);
                projx1=tenmat(projx1,3);                        % unfolding each trial tensor into i-mode matrix
                projx1=projx1.data;
                projref1=ttm(refdata,v1',1);
                projref1=projref1.data(:)';
                w3=lasso(projx1',projref1','Lambda',lmbda);
                w3=w3./norm(w3);
                if iter>1
                    if all(sign(w1)==-sign(prew1))
                        errw(1,iter-1)=norm(w1+prew1);
                    else
                        errw(1,iter-1)=norm(w1-prew1);
                    end
                    if all(sign(w3)==-sign(prew3))
                        errw(2,iter-1)=norm(w3+prew3);
                    else
                        errw(2,iter-1)=norm(w3-prew3);
                    end
                    if all(sign(v1)==-sign(prev1))
                        errw(3,iter-1)=norm(v1+prev1);
                    else
                        errw(3,iter-1)=norm(v1-prev1);
                    end
                    if errw(1,iter-1)<er && errw(2,iter-1)<er && errw(3,iter-1)<er
                        break
                    end
                end
                prew1=w1;
                prew3=w3;
                prev1=v1;
                iter=iter+1;
            end
            
            fprintf('L1MCCA Iteration is %d \n',iter);
        end
        
        
        function y=squarewave(L1MCCA,f, S, T, H)
            
            % f-- the fundermental frequency
            % S-- the sampling rate
            % T-- the number of sampling points
            % H-- the number of harmonics
            
            
            for i=1:H
                for j=1:T
                    t= j/S;
                    y(2*i-1,j)=sin(2*pi*(i*f)*t);
                    y(2*i,j)=cos(2*pi*(i*f)*t);
                end
            end
        end
        
        function time = getTime(L1MCCA)
            time = 0;
        end
    end
end