classdef MaxChooser < ssveptoolkit.classification.ClassifierBase
    
    properties (Constant)

    end
    
    properties
      
    end
    
    methods (Access = public)
        function MaxChooser =MaxChooser(instanceSet)
            if nargin > 0
                MaxChooser.instanceSet = instanceSet;
            end
           
        end
        
        function MaxChooser = build(MaxChooser)
            
        end
        
        function [output, probabilities, ranking] = classifyInstance(MaxChooser,instance)
            
            dd_ins=instance;
            N = size(instance,1);
            pred_lab=zeros(N,1);
            for i=1:N
                [v,idx]=max(dd_ins(i,:));                
                pred_lab(i)=idx;                
            end
            
            output = pred_lab;%sum(pred_lab)/length(pred_lab)
            probabilities=zeros(N,1);
            ranking=zeros(N,1);
        end
        
        function MaxChooser = reset(MaxChooser)
            %delete all stored models           
        end
        
        function configInfo = getConfigInfo(MaxChooser)
            configInfo = sprintf('MaxChooser');
        end
        
                        
        function time = getTime(MaxChooser)
            time = 0;
        end
                
    end
end

