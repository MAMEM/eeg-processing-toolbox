classdef Windsorize < eegtoolkit.preprocessing.PreprocessingBase
    properties
        limit_l;
        limit_h;
        subjectids;
    end
    
    methods
        function obj = Windsorize(low,high)
            if nargin == 0
                obj.limit_l = 0.05;
                obj.limit_h = 0.95;
            elseif nargin == 2
                obj.limit_l = low;
                obj.limit_h = high;
            else
                error('2 inputs are required for windsorize, the low and high limits');
            end
        end
        
        function trials = process(obj,trials)
            subs = unique(obj.subjectids);
            nchannels = size(trials{1}.signal,1);
            trial_length = size(trials{1}.signal,2);
            for i=1:numel(subs)
                ids = find(obj.subjectids == subs(i));
                ntrials = numel(ids);
                % Concatenate signal
                signal = [];
                for j=1:numel(ids)
                    signal = [signal trials{ids(j)}.signal];
                end
                %windsorize
                sorted_sig = sort(signal,2);
                upbound = sorted_sig(:,round(obj.limit_h*size(signal,2)));
                uprep = sorted_sig(:,round(obj.limit_h*size(signal,2))-1);
                lowbound = sorted_sig(:,round(obj.limit_l*size(signal,2)));
                lowrep = sorted_sig(:,round(obj.limit_l*size(signal,2))+1);
                for ch=1:nchannels
                    signal(ch,signal(ch,:)>upbound(ch)) = uprep(ch);
                    signal(ch,signal(ch,:)<lowbound(ch)) = lowrep(ch);
                end
                temp = mat2cell(signal,nchannels,trial_length*ones(ntrials,1));
                for j=1:numel(ids)
                    trials{ids(j)}.signal = temp{j};
                end
            end
            
        end
        
        
        function configInfo = getConfigInfo(CS)
            configInfo = sprintf('Windsorizing\tLow limit: %f, High limit: %f',CS.limit_l,CS.limit_l);
        end
        
        
        function time = getTime(CS)
            time = 0;
        end
        
    end
    
end

