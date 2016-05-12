classdef Dummy < ssveptoolkit.classification.ClassifierBase
    
    properties (Constant)

    end
    
    properties
      
    end
    
    methods (Access = public)
        function Dummy =Dummy(instanceSet)
            if nargin > 0
                Dummy.instanceSet = instanceSet;
            end
           
        end
        
        function Dummy = build(Dummy)
            
        end
        
        function [output, probabilities, ranking] = classifyInstance(Dummy,instance)
            
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
        
        function Dummy = reset(Dummy)
            %delete all stored models           
        end
        
        function configInfo = getConfigInfo(Dummy)
            configInfo = sprintf('Dummy');
        end
        
                        
        function time = getTime(Dummy)
            time = 0;
        end
                
    end
end

