classdef SampleSelection < ssveptoolkit.preprocessing.PreprocessingBase
    properties
        channels;
        sampleRange;
        samplingRate;
    end
    
    methods
        function CS = SampleSelection(channels,sampleRange)
            if(nargin == 0)
                CS.channels = 126;
                CS.sampleRange = [1,1250];
            end
            if(nargin > 0)
                CS.channels = channels;
            end
            if nargin > 1
                CS.sampleRange = sampleRange;
            end
        end
        
        function out = process(CS,in)
            out = {};
            CS.samplingRate = in{1}.samplingRate;
            for i=1:length(in)
                if(length(CS.channels) > 0)
                    if(length(CS.sampleRange) > 2)
                        signal = in{i}.signal(CS.channels,CS.sampleRange);
                        out{i} = ssveptoolkit.util.Trial(signal ...
                            ,in{i}.label,in{i}.samplingRate,in{i}.subjectid,in{i}.sessionid);
                    elseif(length(CS.sampleRange) > 0)
                        %channels AND sampleRange
                        signal = in{i}.signal(CS.channels,CS.sampleRange(1):CS.sampleRange(2));
                        out{i} = ssveptoolkit.util.Trial(signal ...
                            ,in{i}.label,in{i}.samplingRate,in{i}.subjectid,in{i}.sessionid);
                    else
                        %ONLY channels
                        signal = in{i}.signal(CS.channels,:);
                        out{i} = ssveptoolkit.util.Trial(signal ...
                            ,in{i}.label,in{i}.samplingRate,in{i}.subjectid,in{i}.sessionid);
                    end
                else
                    if(length(CS.sampleRange) > 0)
                        %ONLY sampleRange
                        signal = in{i}.signal(:,CS.sampleRange(1):CS.sampleRange(2));
                        out{i} = ssveptoolkit.util.Trial(signal ...
                            ,in{i}.label,in{i}.samplingRate,in{i}.subjectid,in{i}.sessionid);
                    else
                        %NOTHING (?)
                        disp('Warning: No parameter specified for SampleSelection, using all channels and samples');
                    end
                end
            end
        end
        
        function configInfo = getConfigInfo(CS)
            if(length(CS.channels) > 0)
                if(length(CS.sampleRange) > 0)
                    configInfo = 'SampleSelection\tChannels:';
                    for i=1:length(CS.channels)
                        configInfo = strcat(configInfo,sprintf('%d+',CS.channels(i)));
                    end
                    configInfo = strcat(configInfo,sprintf('\tsampleRange:%d-%d',CS.sampleRange(1),CS.sampleRange(2)));
                else
                    configInfo = 'SampleSelection\tChannels:';
                    for i=1:length(CS.channels)
                        configInfo = strcat(configInfo,sprintf('%d+',CS.channels(i)));
                    end
                end
            else
                if(length(CS.sampleRange) > 0)
                    configInfo = sprintf('SampleSelection\tSampleRange:%d-%d',CS.sampleRange(1),CS.sampleRange(2));
                    %ONLY sampleRange
                else
                    %NOTHING (?)
                    configInfo = sprintf('SampleSelection\tNothing specified');
                end
            end
        end
        
                        
        function time = getTime(CS)
            time = 0;
        end
        
    end
    
end

