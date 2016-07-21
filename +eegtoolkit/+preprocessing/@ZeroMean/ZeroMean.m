classdef ZeroMean < eegtoolkit.preprocessing.PreprocessingBase
    
    properties
        avgTime;
    end
    
    methods
        function ZM = ZeroMean()

        end
        
        function out = process(ZM,in)
            out = {};
            tic;
            for i=1:length(in)
                [numChannels,~] = size(in{i}.signal);
                for j=1:numChannels
                    in{i}.signal(j,:) = in{i}.signal(j,:) - mean(in{i}.signal(j,:));
                end
                out = in;
            end
            ZM.avgTime = toc/length(in);
        end
        
        function configInfo = getConfigInfo(ZM)
            configInfo = 'ZeroMean';
        end
        
                        
        function time = getTime(ZM)
            time = ZM.avgTime;
        end
        
    end
    
end

