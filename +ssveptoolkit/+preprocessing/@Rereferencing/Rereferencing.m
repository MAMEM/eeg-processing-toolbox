classdef Rereferencing < ssveptoolkit.preprocessing.PreprocessingBase
    %CHANNELSELECTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %0:no prepr
        %1: zero mean
        %2: CAR
        meanSignal; 
    end
    
    methods
        function RR = Rereferencing()
            RR.meanSignal = 1;
        end
        
        function out = process(RR,in)
            out = {};
            
            for i=1:length(in)
                if RR.meanSignal == 1
%                     out{i} = ssveptoolkit.util.Trial(in{i}.signal - mean(in{i}.signal),...
%                         in{i}.label,in{i}.samplingRate,in{i}.subjectid);
                    [numChannels,~] = size(in{i}.signal);
                    out{i} = ssveptoolkit.util.Trial(in{i}.signal,...
                            in{i}.label,in{i}.samplingRate,in{i}.subjectid);
                    for j=1:numChannels
                        out{i}.signal(j,:) = out{i}.signal(j,:) - mean(out{i}.signal(j,:));
%                         out{i}.signal(j,:) = out{i}.signal(j,:) - mean(out{i}.signal(j,:));
                    end
                elseif RR.meanSignal == 2
                    meanChann = mean(in{i}.signal);
                    out{i} = ssveptoolkit.util.Trial(in{i}.signal-repmat(meanChann,257,1),...
                        in{i}.label,in{i}.samplingRate,in{i}.subjectid);
%                     out{i}.signal = in{i}.signal-repmat(meanChann,257,1);
                end
            end
        end
        
        function configInfo = getConfigInfo(CS)
            configInfo = ' ';
        end
        
                        
        function time = getTime(CS)
            time = 0;
        end
        
    end
    
end

