classdef LDA < eegtoolkit.classification.ClassifierBase
    
    properties (Constant)

    end
    
    properties (Access = public)
      W_LDA;
      PCA_mat;
      trainFeat;
    end
    
    methods (Access = public)
        function LDA = LDA(instanceSet)
            if nargin > 0
                LDA.instanceSet = instanceSet;
            end
           
        end
        
        function LDA = build(LDA)
            LDA.reset();
            data = LDA.instanceSet.getInstances;
            data = data';  
            labels = LDA.instanceSet.getLabels;   
            unique(labels)           
            numTrials = length(labels);

            PCA_W=pca_func(data);
%             PCA_W=eye(8000);
            train_Data=PCA_W'*data; 
            
            Par.mode = 'LDA';
            dim = length(unique(labels))-1;
            [W,Wp] = SGE_GraphConstruct(labels,Par);
            [TransMatrix,~] = SGE_Mapping(train_Data,dim,W,Wp);
            LDA.W_LDA = TransMatrix;
            LDA.PCA_mat=PCA_W;
            mtrainFeat=SGE_Projection(train_Data,1:dim,TransMatrix);
            LDA.trainFeat=mtrainFeat;                       
%             figure,gplotmatrix(mtrainFeat',[],labels)
        end
        
        function [output, probabilities, ranking] = classifyInstance(LDA,instance)
            
            N = size(instance,1);            
            instance = instance'; 

            test_Data=LDA.PCA_mat'*instance;               
%             test_Data=[ones(1,N);test_Data]; 

            testFeat=LDA.W_LDA'*test_Data;  
            X = LDA.trainFeat;
            y = LDA.instanceSet.getLabels;
            [~,output] = SGE_Classification(X,y',testFeat,0,'euc');
            output = output(1,:)';
            probabilities=zeros(N,1);
            ranking=zeros(N,1);
%             figure,gplotmatrix(testFeat',[],output)
          
        end
        
        function LDA = reset(LDA)
            %delete all stored models 
            LDA.W_LDA=[];
            LDA.PCA_mat=[];
            LDA.trainFeat=[];
        end
        
        function configInfo = getConfigInfo(LDA)
            configInfo = sprintf('MLR_Classifier');
        end
        
                        
        function time = getTime(LDA)
            
        end
                
    end
end

