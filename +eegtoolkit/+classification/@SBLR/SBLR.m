classdef SBLR < eegtoolkit.classification.ClassifierBase
    
    properties (Constant)

    end
    
    properties
       %Coding; % Coding design 'onevsall' (default) | 'allpairs' | 'binarycomplete' | 'denserandom' | 'onevsone' | 'ordinal' | 'sparserandom' | 'ternarycomplete' | numeric matrix
       %FitPosterior; % Flag indicating whether to transform scores to posterior probabilities false or 0 (default) | true or 1
       %Prior % 'empirical' (default) or 'uniform'.  Prior probabilities for each class. 
       models;
       Wmatrix;
    end
    
    methods (Access = public)
        function SBLR = SBLR(instanceSet)
            %set default parameters
            if nargin > 0
                SBLR.instanceSet = instanceSet;
            end                   
        end
        
        function SBLR = build(SBLR)
            %clear all from previous calls to "build"
            SBLR.reset;
            numLabels = SBLR.instanceSet.getNumLabels;
            uniqueLabels = unique(SBLR.instanceSet.getLabels);
           
            % ---- Multi-Class ----- %
            instances=SBLR.instanceSet.instances;
            labels=SBLR.instanceSet.labels;
            [~,Nfeat] = size(instances)
            size(instances)
            %X = instances*instances;
          %[w, ix_eff, W, AX] = slr_learning_var2(labels, instances,'nlearn', 100, 'nstep', 10);
          [w, ix_eff, W, AXall] = smlr_learning(labels, instances, Nfeat,'nlearn', 0,'gamma0', 0);%,...
              %'wdisp_mode', 'off', 'nlearn',10,'mean_mode', 'none', 'scale_mode', 'none');%, ...
            %'wdisplay', wdisp_mode, 'wmaxiter', wmaxiter', 'nlearn', Nlearn, 'nstep', Nstep,...
            %'amax', AMAX, 'isplot', isplot', 'gamma0', gamma0);
        
          SBLR.Wmatrix = reshape(w, [Nfeat, 5]);           
        
        end
        
        function [output, probabilities, ranking] = classifyInstance(SBLR,instance)
            %input = instance matrix rows = instances, cols = attributes
            %output = predicted class
            %probabilities = probability for predicted class
            %ranking = propabilities for all classes (e.g. to use with mAP)
            
            
            %TODO:should print an error if 'build' has not been called
%             numModels = length(MLSVM.models);
            [numinstance, ~] = size(instance);
            %scores = zeros(numModels,numinstance);                  
            
            [output, Pte] = calc_label(instance, SBLR.Wmatrix);
            % ---- One (vs) All -----%
%              for i=1:numModels
%                  %predict using the stored models
%                  [label,score,cost] = predict(LDA.models{i},instance);
%                  %libsvmpredict(eye(numinstance,1),instance, LSVM.models{i},'-b 1 -q');
%                 %store probability for each class
%                 scores(i,:) = score(:,1);
%             end

            ranking=zeros(5,1)';
            probabilities=0;          
        end
        
        function SBLR = reset(SBLR)
            %delete all stored models
            SBLR.models = {};
            SBLR.Wmatrix=[];
        end
        
        function configInfo = getConfigInfo(SBLR)
           
            configInfo = 'SBLR_Classifier (Config info not supported yet)';
        end
        
        function time = getTime(MLR_Classifier)
            time = 0;
        end
                
    end
end

