classdef LaplacianEBN < eegtoolkit.preprocessing.PreprocessingBase
    
    properties
        info;
        avgTime;
    end
    
    methods
        function LF = LaplacianEBN()
        end
        
        function out = process(LF,in)
            tic;
            out = {};
            for i=1:length(in)
                in{i}.signal(25,:) = 0;
                signal = in{i}.signal;
                % Set C3 to zero
                signal(25,:) = zeros(length(signal(25,:)),1);
                for j=16:37
                    if( (j-8==25) | (j+8==25) | (j-1==25) | (j+1==25))
                        avg = (in{i}.signal(j-8,:) + in{i}.signal(j+8,:) + in{i}.signal(j-1,:) + in{i}.signal(j+1,:))./3;
                    else
                        avg = (in{i}.signal(j-8,:) + in{i}.signal(j+8,:) + in{i}.signal(j-1,:) + in{i}.signal(j+1,:))./4;
                    end
                    signal(j,:) = signal(j,:) - avg;
                end
                out{i} = eegtoolkit.util.Trial(signal,in{i}.label,in{i}.samplingRate,in{i}.subjectid,in{i}.sessionid,in{i}.type);
            end
            total = toc;
            DF.avgTime = total/length(in);
        end
        
        function configInfo = getConfigInfo(LF)
            configInfo = 'LaplacianFilter';
        end
        
        function time = getTime(LF)
            time = LF.avgTime;
        end
                
    end
    
    
    
end

