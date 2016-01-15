classdef DigitalFilter < ssveptoolkit.preprocessing.PreprocessingBase
    %FILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        filt;
        info;
        avgTime;
    end
    
    methods
        function DF = DigitalFilter(filt)
            if(nargin > 0)
                DF.filt = filt;
            end
        end
        
        function out = process(DF,in )
            tic;
            for i=1:length(in)
                signal = in{i}.signal;
                [numChannels, ~] = size(signal);
                for j=1:numChannels
                    if isa(DF.filt,'dfilt.df2sos') || isa(DF.filt,'dfilt.df2')
                        signal(j,:) = filter(DF.filt,signal(j,:));
                    elseif isa(DF.filt,'dfilt.dffir')
                        signal(j,:) = filtfilt(DF.filt.Numerator,1,signal(j,:));
                    end
                end
                out{i} = ssveptoolkit.util.Trial(signal,in{i}.label,in{i}.samplingRate,in{i}.subjectid);
            end
            total = toc;
            DF.avgTime = total/length(in);
        end
        
        function configInfo = getConfigInfo(DF)
            if isempty(DF.info)
                configInfo = 'DigitalFilter';
            else
                configInfo = strcat('DigitalFilter:\t',info);
            end
        end
        
        function time = getTime(DF)
            time = DF.avgTime;
        end
    end
    
end

