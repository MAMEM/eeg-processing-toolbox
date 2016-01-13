classdef SampleSelection < ssveptoolkit.preprocessing.PreprocessingBase
    %CHANNELSELECTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        channels;
        sampleRange;
    end
    
    methods
        function CS = SampleSelection(channels,sampleRange)
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
                        CS.processedTrials{i} = ssveptoolkit.util.Trial(CS.originalTrials{i}.signal(CS.channels,CS.sampleRange(1):CS.sampleRange(2)) ...
                            ,CS.originalTrials{i}.label,CS.originalTrials{i}.samplingRate,CS.originalTrials{i}.subjectid);
                    else
                        %ONLY channels
                        CS.processedTrials{i} = ssveptoolkit.util.Trial(CS.originalTrials{i}.signal(CS.channels,:) ...
                            ,CS.originalTrials{i}.label,CS.originalTrials{i}.samplingRate,CS.originalTrials{i}.subjectid);
                    end
                else
                    if(length(CS.sampleRange) > 0)
                        %ONLY sampleRange
                        CS.processedTrials{i} = ssveptoolkit.util.Trial(CS.originalTrials{i}.signal(:,CS.sampleRange(1):CS.sampleRange(2)) ...
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
                    configInfo = strcat(configInfo,sprintf('\tsampleRange:%d-%d',CS.sampleRange(0),CS.sampleRange(1)));
                else
                    configInfo = 'SampleSelection\tChannels:';
                    for i=1:length(CS.channels)
                        configInfo = strcat(configInfo,sprintf('%d+',CS.channels(i)));
                    end
                end
            else
                if(length(CS.sampleRange) > 0)
                    configInfo = sprintf('SampleSelection\tSampleRange:%d-%d',CS.sampleRange(0),CS.sampleRange(1));
                    %ONLY sampleRange
                else
                    %NOTHING (?)
                    configInfo = sprintf('SampleSelection\tNothing specified');
                end
            end
        end
    end
    
end

