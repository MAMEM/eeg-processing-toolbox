classdef SampleSelection < ssveptoolkit.preprocessing.PreprocessingBase
    %CHANNELSELECTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        channels;
        sampleRange;
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
            CS.processedTrials = {};
        end
        
        function CS = process(CS)
            for i=1:length(CS.originalTrials)
                if(length(CS.channels) > 0)
                    if(length(CS.sampleRange) > 0)
                        %channels AND sampleRange
                        signal = CS.originalTrials{i}.signal(CS.channels,CS.sampleRange(1):CS.sampleRange(2));
                        signal = signal - mean(signal);
                        CS.processedTrials{i} = ssveptoolkit.util.Trial(signal ...
                            ,CS.originalTrials{i}.label,CS.originalTrials{i}.samplingRate,CS.originalTrials{i}.subjectid);
                    else
                        %ONLY channels
                        signal = CS.originalTrials{i}.signal(CS.channels,:);
                        signal = signal - mean(signal);
                        CS.processedTrials{i} = ssveptoolkit.util.Trial(signal ...
                            ,CS.originalTrials{i}.label,CS.originalTrials{i}.samplingRate,CS.originalTrials{i}.subjectid);
                    end
                else
                    if(length(CS.sampleRange) > 0)
                        %ONLY sampleRange
                        signal = CS.originalTrials{i}.signal(:,CS.sampleRange(1):CS.sampleRange(2));
                        signal = signal - mean(signal);
                        CS.processedTrials{i} = ssveptoolkit.util.Trial(signal ...
                            ,CS.originalTrials{i}.label,CS.originalTrials{i}.samplingRate,CS.originalTrials{i}.subjectid);
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

