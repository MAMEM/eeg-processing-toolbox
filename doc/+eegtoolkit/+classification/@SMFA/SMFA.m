classdef SMFA < eegtoolkit.classification.ClassifierBase
    
    properties (Constant)

    end
    
    properties (Access = public)
      W_SMFA;
      PCA_mat;
      trainFeat;
      NumSubclasses;
      SigmaCoeff;
      kInt;
      kPen;
    end
    
    methods (Access = public)
        function SMFA = SMFA(instanceSet,NumS,S,kInt,kPen)%,NumSubclasses,SigmaCoeff,kInt,kPen)
            if nargin == 1
                SMFA.instanceSet = instanceSet;
            else
                SMFA.NumSubclasses = NumS;
                SMFA.SigmaCoeff = S;
                SMFA.kInt = kInt;
                SMFA.kPen = kPen;
            end
           
        end
            
        
        function SMFA = build(SMFA)
            SMFA.reset();
            data = SMFA.instanceSet.getInstances;
            data = data';  
            labels = SMFA.instanceSet.getLabels;    
            unique(labels)           
            numTrials = length(labels);

            PCA_W=SMFA.pca_func(data);
%             PCA_W=eye(size(data,1));
            train_Data=PCA_W'*data; 
            
%             Sigma = SMFA_Classifier.SigmaCoeff;
            NSubClasses = SMFA.NumSubclasses;
            D=pdist2(train_Data',train_Data');
%             STrain = SGE_GramMatrix(train_Data,'gau',Sigma*mean(D(:)));
            STrain = 1-(D/max(D(:)));
            
            pt=0;
            ct=0;
            ClustersOfClasses = SGE_SubclassExtract(train_Data,labels,NSubClasses,pt,ct);
            [yyTrain,~,~] = SGE_SubclassLabels(ClustersOfClasses,labels);
           
            
            Par.mode = 'SMFA';
            Par.SimilMatrix = STrain;
            Par.kInt = SMFA.kInt;
            Par.kPen = SMFA.kPen;
            dim = min([Par.kPen,size(train_Data,1)]);
            
            [W,Wp] = SGE_GraphConstruct(yyTrain,Par);
            [TransMatrix,~] = SGE_Mapping(train_Data,dim,W,Wp);
            SMFA.W_SMFA = TransMatrix;
            SMFA.PCA_mat=PCA_W;
            mtrainFeat=SGE_Projection(train_Data,1:dim,TransMatrix);
            SMFA.trainFeat=mtrainFeat;                       
%             figure,gplotmatrix(mtrainFeat',[],labels)
        end
        
        function [output, probabilities, ranking] = classifyInstance(SMFA,instance)
            
            N = size(instance,1);            
            instance = instance'; 
            
            test_Data=SMFA.PCA_mat'*instance;               
%             test_Data=[ones(1,N);test_Data]; 
            testFeat=SMFA.W_SMFA'*test_Data;
%             output=knnclassify(testFeat',SMFA_Classifier.trainFeat',SMFA_Classifier.instanceSet.getLabels,5,'euclidean');  
            X = SMFA.trainFeat;
            y = SMFA.instanceSet.getLabels;
            
            %Nearest Centroid
            [~,output] = SGE_Classification(X,y',testFeat,0,'euc');
            
%             %SVM Linear
%             [~,output] = SGE_Classification(X,y',testFeat,[1,1,1,0,1],'euc');

%             %SVM RBF
%             [~,output] = SGE_Classification(X,y',testFeat,[2,3,2/size(X,1),0,1],'euc');
            
            output = output(1,:)';
            probabilities=zeros(N,1);
            ranking=zeros(N,1);
%             figure,gplotmatrix(testFeat',[],output)
          
        end
        
        function SMFA = reset(SMFA)
            %delete all stored models 
            SMFA.W_SMFA=[];
            SMFA.PCA_mat=[];
            SMFA.trainFeat=[];
        end
        
        function configInfo = getConfigInfo(SMFA)
            configInfo = sprintf('MLR_Classifier');
        end
        
                        
        function time = getTime(SMFA)
            
        end
                
    end
    methods (Access = private)
        function Proj_W=pca_func(MLR,data)
            Proj_W=[];
            meanData=mean(data,2);
            data=data-repmat(meanData,1,size(data,2));
            % stdVar=std(data')';
            % staData=(data-repmat(meanData,1,size(data,2)))./repmat(stdVar,1,size(data,2));
            % data=staData;
            [V,S]=eig(data'*data);
            [sorted_diagS,sorted_rank]=sort(diag(S),'descend');
            sorted_S=diag(sorted_diagS);
            V=V(:,sorted_rank);
            r=rank(sorted_S);
            S1=sorted_S(1:r,1:r);
            V1=V(:,1:r);
            U=data*V1*S1^(-0.5);
            %[sorted_S,sorted_rank]=sort(diag(S),'descend');
            All_energy=sum(diag(S1));
            sorted_energy=diag(S1);
            for j=1:r
                if (sum(sorted_energy(1:j))/All_energy)>0.99
                    break
                end
            end
            Proj_W=U(:,1:j);
        end
    end
end

