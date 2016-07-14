classdef PWelchExperimental < eegtoolkit.featextraction.FeatureExtractionBase
%Computes the psd using the welch method
%Usage:
%   session = eegtoolkit.util.Session();
%   session.loadSubject(1);
%   pwt = ssveptolkit.transform.PWelchTransformer(session.trials);
%Specify the channel to be used (default = 126)
%   pwt.channel = 150;
%Specify the number of seconds to be used (default = 0, use all signal)
%   pwt.seconds = 3;
%Specify the nfft parameter (default = 512, computes 257 features)
%   pwt.nfft = 512;
%Transform the signal
%   pwt.transform();
    properties (Access = public)
        channel;
        seconds;
        nfft;
        pff;
        win_len;
        over_len;
        avgTime;
    end
    
    methods (Access = public)
        function PWT = PWelchExperimental(trials, seconds, channel, nfft,win_len,over_len)
%             if ~iscell(trials)
%                 error('trials must be cell array of Trial object');
%             end
            if nargin == 0
                PWT.trials = {};
                PWT.seconds = 0;
                PWT.channel = 1;
                PWT.nfft = 512;
                PWT.win_len=[];
                PWT.over_len=[];
            elseif nargin == 1
                PWT.trials = trials;
                PWT.seconds = 0;
                PWT.channel = 1;
                PWT.nfft = 512;
                PWT.win_len=[];
                PWT.over_len=[];
            elseif nargin == 2
                PWT.trials = trials;
                PWT.channel = 1;
                PWT.seconds = seconds;
                PWT.nfft = 512;
                PWT.win_len=[];
                PWT.over_len=[];
            elseif nargin == 3
                PWT.trials = trials;
                PWT.channel = channel;
                PWT.seconds = seconds;
                PWT.nfft = 512;
                PWT.win_len=[];
                PWT.over_len=[];
            elseif nargin == 4
                PWT.trials = trials;
                PWT.channel = channel;
                PWT.seconds = seconds;
                PWT.nfft = nfft;
                PWT.win_len=[];
                PWT.over_len=[];
            elseif nargin == 5
                PWT.trials = trials;
                PWT.channel = channel;
                PWT.seconds = seconds;
                PWT.nfft = nfft;
                PWT.win_len=win_len;
                PWT.over_len=[];
            elseif nargin == 6
                PWT.trials = trials;
                PWT.channel = channel;
                PWT.seconds = seconds;
                PWT.nfft = nfft;
                PWT.win_len=win_len;
                PWT.over_len=over_len;
            else
%                 error('invalid number of arguments');
            end
        end
        
        function extract(PWT)
            if length(PWT.nfft)==1
                numFeatures = PWT.nfft/2+1;
            else
                numFeatures = length(PWT.nfft);
            end
            numTrials = length(PWT.trials);
            instances = zeros(numTrials, numFeatures);
            labels = zeros(numTrials,1);
%             PWT.instances = zeros(numTrials, numFeatures);
%             PWT.labels = zeros(numTrials,1);
            tic;
            for i=1:numTrials
                numsamples = PWT.trials{i}.samplingRate * PWT.seconds;
                if(numsamples == 0)
                    y = PWT.trials{i}.signal(PWT.channel,:);
                else
                    y = PWT.trials{i}.signal(PWT.channel, 1:numsamples);
                end
%                 if length(PWT.nfft>1)
%                     [pxx, pff]=pwelch(y,[],[],PWT.nfft,PWT.trials{i}.samplingRate);
%                 else
                    [pxx, pff]=pwelch(y,PWT.win_len,round(PWT.over_len*PWT.win_len),PWT.nfft,PWT.trials{i}.samplingRate,'onesided');
%                 end
                %xv = [1 -2 1 zeros(1,length(pxx)-3)];
%                 xv = [1/5 1/5 1/5 1/5 1/5 zeros(1,length(pxx)-5)];
%                 A = gallery('circul',xv);
                instances(i,:) = pxx;
                labels(i,1) = floor(PWT.trials{i}.label);
            end
            PWT.avgTime = toc/numTrials;
            PWT.instanceSet = eegtoolkit.util.InstanceSet(instances, labels);
            PWT.pff = pff;
        end
        
        function configInfo = getConfigInfo(PWT)
            if length(PWT.nfft)>1
                configInfo = sprintf('PWelchExperimental\tchannel:%d\tseconds:%d\t freq range:%.3f to %.3f',PWT.channel,PWT.seconds,PWT.nfft(1),PWT.nfft(end));
            else
                configInfo = sprintf('PWelchExperimental\tchannel:%d\tseconds:%d\tnfft:%d',PWT.channel,PWT.seconds,PWT.nfft);
            end
        end
        
        function time = getTime(PWT)
            time = PWT.avgTime;
        end
    end
   
end

