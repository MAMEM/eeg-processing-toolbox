classdef PWelch < ssveptoolkit.featextraction.PSDExtractionBase
%Computes the psd using the welch method
%Usage:
%   session = ssveptoolkit.util.Session();
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
        avgTime;
    end
    
    methods (Access = public)
        function PW = PWelch(trials, seconds, channel, nfft)
%             if ~iscell(trials)
%                 error('trials must be cell array of Trial object');
%             end
            if nargin == 0
                PW.trials = {};
                PW.seconds = 0;
                PW.channel = 1;
                PW.nfft = 512;
            elseif nargin == 1
                PW.trials = trials;
                PW.seconds = 0;
                PW.channel = 1;
                PW.nfft = 512;
            elseif nargin == 2
                PW.trials = trials;
                PW.channel = 1;
                PW.seconds = seconds;
                PW.nfft = 512;
            elseif nargin == 3
                PW.trials = trials;
                PW.channel = channel;
                PW.seconds = seconds;
                PW.nfft = 512;
            elseif nargin == 4
                PW.trials = trials;
                PW.channel = channel;
                PW.seconds = seconds;
                PW.nfft = nfft;
            else
%                 error('invalid number of arguments');
            end
        end
        
        function extract(PW)
            if length(PW.nfft)==1
                numFeatures = PW.nfft/2+1;
            else
                numFeatures = length(PW.nfft);
            end
            numTrials = length(PW.trials);
            instances = zeros(numTrials, numFeatures);
            labels = zeros(numTrials,1);
%             PWT.instances = zeros(numTrials, numFeatures);
%             PWT.labels = zeros(numTrials,1);
            tic;
            for i=1:numTrials
                if length(PW.seconds) == 1
                    numsamples = PW.trials{i}.samplingRate * PW.seconds;
                    if(numsamples == 0)
                        y = PW.trials{i}.signal(PW.channel,:);
                    else
                        y = PW.trials{i}.signal(PW.channel, 1:numsamples);
                    end
                elseif length(PW.seconds) == 2
                    sampleA = PW.trials{i}.samplingRate*PW.seconds(1) +1;
                    sampleB = PW.trials{i}.samplingRate*PW.seconds(2);
                    y = PW.trials{i}.signal(PW.channel, sampleA:sampleB);
                else 
                    error('invalid seconds parameter');
                end
                if isa(PW.filter,'dfilt.df2sos') || isa(PW.filter,'dfilt.df2')
                    y = filter(PW.filter,y);
                elseif isa(PW.filter,'dfilt.dffir')
                    y = filtfilt(PW.filter.Numerator,1,y);
                end
                if length(PW.nfft>1)
                    [pxx, pff]=pwelch(y,[],[],PW.nfft,PW.trials{i}.samplingRate);
                else
                    [pxx, pff]=pwelch(y,[],[],PW.nfft,PW.trials{i}.samplingRate,'onesided');
                end
                instances(i,:) = pxx;
                labels(i,1) = floor(PW.trials{i}.label);
            end
            total = toc;
            PW.avgTime = total/numTrials;
            PW.instanceSet = ssveptoolkit.util.InstanceSet(instances, labels);
            PW.pff = pff;
        end
        
        function configInfo = getConfigInfo(PW)
            if length(PW.nfft)>1
                configInfo = sprintf('PWelch\tchannel:%d\tseconds:%d\t freq range:%.3f to %.3f',PW.channel,PW.seconds,PW.nfft(1),PW.nfft(end));
            else
                configInfo = sprintf('PWelch\tchannel:%d\tseconds:%d\tnfft:%d',PW.channel,PW.seconds,PW.nfft);
            end
        end
        
        function time = getTime(PW)
            time = PW.avgTime;
        end
    end
   
end

