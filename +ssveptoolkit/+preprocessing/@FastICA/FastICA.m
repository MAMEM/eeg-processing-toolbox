classdef FastICA < ssveptoolkit.preprocessing.PreprocessingBase
    
    properties
        first;
        last;
        avgTime;
    end
    
    methods
        function ICA = FastICA()
            ICA.first = 2;
            ICA.last = 256;
        end
        
        function out = process(ICA,in )
            out = {};
            total = 0;
            for i=1:length(in)
                i
%                 in{i}.signal(end,:) = [];
                tic
                signal = in{i}.signal;
%                 signal(end,:) = [];
%                 [W,~,yest] = amuse(signal);
%                 signal = pinv(W(ICA.first:ICA.last,:))*yest(ICA.first:ICA.last,: );
                [icasig, A, W] = fastica (signal);
                signal = A(:,ICA.first:end)*icasig(ICA.first:end,:);
                total = total + toc;
%                 in{i}.signal = signal;
                out{i} = ssveptoolkit.util.Trial(signal,in{i}.label,in{i}.samplingRate,in{i}.subjectid,in{i}.sessionid);
            end
%             out = in;
%             total = toc;
            ICA.avgTime = total/length(in);
        end
        
        function configInfo = getConfigInfo(ICA)
            configInfo = sprintf('FastICA:\t%d-%d',ICA.first,ICA.last);
        end
        
        function time = getTime(ICA)
            time = ICA.avgTime;
        end
    end
    
end

