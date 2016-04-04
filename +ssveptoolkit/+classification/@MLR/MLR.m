classdef MLR < ssveptoolkit.classification.ClassifierBase
    
    properties (Constant)
        
    end
    
    properties
        W_mlr;
        PCA_mat;
        trainFeat;
    end
    
    methods (Access = public)
        function MLR = MLR(instanceSet)
            if nargin > 0
                MLR.instanceSet = instanceSet;
            end
            
        end
        
        function MLR = build(MLR)
            MLR.reset();
            data = MLR.instanceSet.getInstances;
            data = data';
            labels = MLR.instanceSet.getLabels;
            numTrials = length(labels);
            train_Y = zeros(length(unique(labels)),numTrials);
            for i = 1 : numTrials
                train_Y(labels(i),i) = 1;
            end
            [Ydim,Num]=size(train_Y);
            PCA_W=MLR.pca_func(data);
            train_Data=PCA_W'*data;
            train_Data=[ones(1,numTrials);train_Data];
            MLR.W_mlr = MLR.MultiLR(train_Data,train_Y);%inv(train_Data*train_Data')*train_Data*train_Y';%(train_Data'*train_Data)\train_Data'*train_Y;%MultiLR(train_Data,train_Y);
            MLR.PCA_mat=PCA_W;
            mtrainFeat=MLR.W_mlr'*train_Data;
            MLR.trainFeat=mtrainFeat;
        end
        
        function [output, probabilities, ranking] = classifyInstance(MLR,instance)
            
            N = size(instance,1);
            instance = instance';
            test_Data=MLR.PCA_mat'*instance;
            test_Data=[ones(1,N);test_Data];
            testFeat=MLR.W_mlr'*test_Data;
            output=knnclassify(testFeat',MLR.trainFeat',MLR.instanceSet.getLabels,5,'euclidean');
            probabilities=zeros(N,1);
            ranking=zeros(N,1);
            
        end
        
        function MLR = reset(MLR)
            %delete all stored models
            MLR.W_mlr=[];
            MLR.PCA_mat=[];
            MLR.trainFeat=[];
        end
        
        function configInfo = getConfigInfo(MLR)
            configInfo = sprintf('MLR_Classifier');
        end
        
        
        function time = getTime(MLR)
            time = 0;
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
        function W_mlr=MultiLR(MLR,train_Feat,train_Y)
            
            % Multiple linear regression
            % train_Feat: training samples
            % train_Y: label matrix
            
            [U,Sigma,V]=svd(train_Feat,'econ');
            r=rank(Sigma);
            U1=U(:,1:r);
            V1=V(:,1:r);
            Sigma_r=diag(Sigma(1:r, 1:r));
            W_mlr=U1*diag(1./Sigma_r)*V1'*train_Y';
            
            
        end
    end
end

