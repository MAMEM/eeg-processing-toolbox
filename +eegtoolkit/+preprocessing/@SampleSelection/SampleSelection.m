classdef SampleSelection < eegtoolkit.preprocessing.PreprocessingBase
    properties
        channels;
        sampleRange;
    end
    
    methods
        function CS = SampleSelection(channels,sampleRange)
            CS.channels = [];
            CS.sampleRange = [];
            if nargin==2
                CS.channels = channels;
                CS.sampleRange = sampleRange;
            else
                error('channels and sampleRange parameters are required');
            end
        end
        
        function out = process(CS,in)
            out = {};
            for i=1:length(in)
                if(length(CS.channels) > 0)
                    if(length(CS.sampleRange) > 2)
                        signal = in{i}.signal(CS.channels,CS.sampleRange);
                        out{i} = eegtoolkit.util.Trial(signal ...
                            ,in{i}.label,in{i}.samplingRate,in{i}.subjectid,in{i}.sessionid);
                    elseif(length(CS.sampleRange) > 0)
                        %channels AND sampleRange
                        signal = in{i}.signal(CS.channels,CS.sampleRange(1):CS.sampleRange(2));
                        out{i} = eegtoolkit.util.Trial(signal ...
                            ,in{i}.label,in{i}.samplingRate,in{i}.subjectid,in{i}.sessionid);
                    else
                        %ONLY channels
                        signal = in{i}.signal(CS.channels,:);
                        out{i} = eegtoolkit.util.Trial(signal ...
                            ,in{i}.label,in{i}.samplingRate,in{i}.subjectid,in{i}.sessionid);
                    end
                else
                    if(length(CS.sampleRange) > 0)
                        %ONLY sampleRange
                        signal = in{i}.signal(:,CS.sampleRange(1):CS.sampleRange(2));
                        out{i} = eegtoolkit.util.Trial(signal ...
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