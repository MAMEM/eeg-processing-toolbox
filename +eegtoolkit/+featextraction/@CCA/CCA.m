classdef CCA < eegtoolkit.featextraction.PSDExtractionBase%FeatureExtractionBase
    %
    % works only on our datasets, for other datasets needs modifications
    %
    properties (Access = public)
        channel;
        avgTime;
        stimulus_freqs;
        NumHarm;
        allFeatures;
    end
    methods (Access = public)
        function CCA = CCA(sti_f,chans,numH)
            CCA.stimulus_freq = [12, 10, 8.57, 7.5, 6.66];
            CCA.channel = 1;
            CCA.NumHarm = 4;
            CCA.allFeatures = 0;
            if nargin > 0
                CCA.stimulus_freqs = sti_f;
            end
            if nargin > 1
                CCA.channel = chans;
            end
            if nargin > 2
                CCA.NumHarm = numH;
            end
        end
        
        function extract(CCA)
            sti_f = CCA.stimulus_freqs;
            SAMPLING_RATE = CCA.trials{1}.samplingRate;
            mLen=size(CCA.trials{1}.signal,2);
            refSignals=CCA.ck_signalTrans(sti_f,mLen,SAMPLING_RATE,CCA.NumHarm);
            NumStim = size(refSignals,3);
            numTrials = length(CCA.trials);
            for i=1:numTrials
                data = CCA.trials{i}.signal(CCA.channel,:);
                if(CCA.allFeatures == 1)
                    features=NaN*ones(NumStim,min(rank(data),CCA.NumHarm*2));
                    for j=1:NumStim
                        [wx1,wy1,r1] = canoncorr(data',refSignals(:,:,j)');
                        features(j,:) = r1;
                    end
                    tempfeatures = features(1,:);
                    for j=2:NumStim
                        tempfeatures = horzcat(tempfeatures,features(j,:));
                    end
                    instances(i,:) = tempfeatures(:);
                    labels(i,1) = floor(CCA.trials{i}.label);
                else
                    features=NaN*ones(NumStim,1);
                    for j=1:NumStim
                        %                     [wx1,wy1,r1] = CCA.cca(data,refSignals(:,:,j));
                        [wx1,wy1,r1] = canoncorr(data',refSignals(:,:,j)');
                        features(j) = max(r1);
                    end
                    instances(i,:) = features(:);
                    labels(i,1) = floor(CCA.trials{i}.label);
                end
            end
%             unique(labels)
            if (sum(unique(labels)) == 41)
                labels(labels==6)=1;
                labels(labels==7)=2;
                labels(labels==8)=3;
                labels(labels==9)=4;
                labels(labels==11)=5;
            end
%             unique(labels)
            CCA.instanceSet = eegtoolkit.util.InstanceSet(instances, labels);
        end
        
        function configInfo = getConfigInfo(CCA)
            configInfo = sprintf('CCA');
        end
        
%         function [Wx, Wy, r] = cca(CCA,X,Y)
%             
%             % CCA calculate canonical correlations
%             %
%             % [Wx Wy r] = cca(X,Y) where Wx and Wy contains the canonical correlation
%             
%             % vectors as columns and r is a vector with corresponding canonical
%             % correlations. The correlations are sorted in descending order. X and Y
%             % are matrices where each column is a sample. Hence, X and Y must have
%             % the same number of columns.
%             %
%             % Example: If X is M*K and Y is N*K there are L=MIN(M,N) solutions. Wx is
%             % then M*L, Wy is N*L and r is L*1.
%             %
%             %
%             % ?? 2000 Magnus Borga, Link?pings universitet
%             
%             % --- Calculate covariance matrices ---??????????????
%             
%             z = [X;Y];
%             C = cov(z.');
%             sx = size(X,1);   %X??????(??),
%             sy = size(Y,1);
%             Cxx = C(1:sx, 1:sx) + 10^(-8)*eye(sx);
%             Cxy = C(1:sx, sx+1:sx+sy);
%             Cyx = Cxy';
%             Cyy = C(sx+1:sx+sy, sx+1:sx+sy) + 10^(-8)*eye(sy);%eye()????????
%             invCyy = inv(Cyy);
%             
%             % --- Calcualte Wx and r ---
%             
%             [Wx,r] = eig(inv(Cxx)*Cxy*invCyy*Cyx); % Basis in X eig????????????
%             r = sqrt(real(r));      % Canonical correlations
%             
%             % --- Sort correlations ---
%             
%             V = fliplr(Wx);		% reverse order of eigenvectors??????????????????????i??????????i??????
%             r = flipud(diag(r));	% extract eigenvalues and reverse their order
%             [r,I]= sort((real(r)));	% sort reversed eigenvalues in ascending order
%             r = flipud(r);		% restore sorted eigenvalues into descending order??????????????
%             for j = 1:length(I)
%                 Wx(:,j) = V(:,I(j));  % sort reversed eigenvectors in ascending order
%             end
%             Wx = fliplr(Wx);	% restore sorted eigenvectors into descending order
%             
%             % --- Calcualte Wy  ---
%             
%             Wy = invCyy*Cyx*Wx;     % Basis in Y
%             % Wy = Wy./repmat(sqrt(sum(abs(Wy).^2)),sy,1); % Normalize Wy
%             
%         end
        
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
        function time = getTime(CCA)
            time = CCA.avgTime;
        end
    end
    
end
