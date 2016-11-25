classdef Rereferencing < eegtoolkit.preprocessing.PreprocessingBase
    
    properties
        %meanSignal=1: Subtract the mean from the signal
        %meanSignal=2: Average rereferencing
        meanSignal;
        avgTime;
    end
    
    methods
        function RR = Rereferencing()
            RR.meanSignal = 1;
        end
        
        function out = process(RR,in)
            out = {};
            tic;
            for i=1:length(in)
                if RR.meanSignal == 1
                    [numChannels,~] = size(in{i}.signal);
                    for j=1:numChannels
                        in{i}.signal(j,:) = in{i}.signal(j,:) - mean(in{i}.signal(j,:));
                    end
                elseif RR.meanSignal == 2
                    meanChann = mean(in{i}.signal);
                      in{i}.signal = in{i}.signal-repmat(meanChann,257,1);
                end
                out = in;
            end
            RR.avgTime = toc/length(in);
        end
        
        function configInfo = getConfigInfo(RR)
            configInfo = sprintf('Rereferencing:\tmeanSignal:%d',RR.meanSignal);
        end
        
                        
        function time = getTime(RR)
            time = RR.avgTime;
        end
        
    end
    
end

