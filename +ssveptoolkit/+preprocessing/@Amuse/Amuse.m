classdef Amuse < ssveptoolkit.preprocessing.PreprocessingBase
    %FILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        first;
        last;
        avgTime;
    end
    
    methods
        function AM = Amuse()
            AM.first = 1;
            AM.last = 2;
            out = {};
        end
        
        function out = process(AM,in )
            tic;
            for i=1:length(in)
                [W,~,yest] = amuse(in{i}.signal);
                signal = pinv(W(AM.first:end-AM.last,:))*yest(AM.first:end-AM.last,: );
                out{i} = ssveptoolkit.util.Trial(signal,in{i}.label,in{i}.samplingRate,in{i}.subjectid);
            end
            total = toc;
            AM.avgTime = total/length(in);
        end
        
        function configInfo = getConfigInfo(AM)
            configInfo = sprintf('Amuse:\t%d-%d',AM.first,AM.last);
        end
        
        function time = getTime(AM)
            time = AM.avgTime;
        end
    end
    
end

