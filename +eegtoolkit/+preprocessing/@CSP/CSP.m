classdef CSP < eegtoolkit.preprocessing.PreprocessingBase
    properties
        trainIdx;
        testIdx;
        filterDimension;
    end
    
    methods
        function CSP = CSP(trainIdx,testIdx)
            CSP.trainIdx = trainIdx;
            CSP.testIdx = testIdx;
        end
        
        function out = process(CSP,in)
            out = {};
            [trialsMat,labels] = eegtoolkit.util.Trial.transformTrials(in);
%             trialsMat =permute(trialsMat,[2 1 3]);
            trialsMat =permute(trialsMat,[3 2 1]);
            [N1, Nch1, Ntr1] = size(trialsMat);
            for i = 1:Nch1
                for j = 1:Ntr1
                    trialsMat(:,i,j) = (trialsMat(:,i,j) - mean(trialsMat(:,i,j)));
                end
            end
            x_train = trialsMat(:,:,CSP.trainIdx);
            y_train = labels(CSP.trainIdx);
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
            U = U(:,[ind(1:CSP.filterDimension);ind(end-CSP.filterDimension+1:end)]);
            CSP_Filter = U';
            
            t=zeros(N,CSP.filterDimension*2,Ntr);
            for i = 1:size(trialsMat,3)
                t(:,:,i)= (CSP_Filter*trialsMat(:,:,i)')';
            end               
            
            trialsMat = t;
            trialsMat =permute(t,[2 1 3]);
            [~,~,numTrials] = size(trialsMat);
            for i=1:numTrials
                out{i} = eegtoolkit.util.Trial(squeeze(trialsMat(:,:,i)),labels(i),in{i}.samplingRate,in{i}.subjectid,in{i}.sessionid,in{i}.type);
            end
            
        end
        
        function configInfo = getConfigInfo(CS)
            configInfo = 'CSP\tChannels:';
        end
        
                        
        function time = getTime(CS)
            time = 0;
        end
        
    end
    
end

