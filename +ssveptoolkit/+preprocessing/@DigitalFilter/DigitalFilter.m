classdef DigitalFilter < ssveptoolkit.preprocessing.PreprocessingBase
    %FILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        filt;
    end
    
    methods
        function DF = DigitalFilter(filt)
            if(nargin > 0)
                DF.filt = filt;
            end
        end
        
        function DF = process(DF)
            for i=1:length(DF.originalTrials)
                i
                signal = DF.originalTrials{i}.signal;
                [numChannels, ~] = size(signal);
                for j=1:numChannels
                    if isa(DF.filt,'dfilt.df2sos') || isa(DF.filt,'dfilt.df2')
                        signal(j,:) = filter(DF.filt,signal(j,:));
                    elseif isa(DF.filt,'dfilt.dffir')
                        signal(j,:) = filtfilt(DF.filt.Numerator,1,signal(j,:));
                    end
                end
                DF.processedTrials{i} = ssveptoolkit.util.Trial(signal,DF.originalTrials{i}.label,DF.originalTrials{i}.samplingRate,DF.originalTrials{i}.subjectid);
            end
        end
    end
    
end

