classdef PWelchTransformer < ssveptoolkit.transformer.PSDTransformerBase
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
    end
    
    methods (Access = public)
        function PWT = PWelchTransformer(trials, seconds, channel, nfft)
%             if ~iscell(trials)
%                 error('trials must be cell array of Trial object');
%             end
            if nargin == 0
                PWT.trials = {};
                PWT.seconds = 0;
                PWT.channel = 1;
                PWT.nfft = 512;
            elseif nargin == 1
                PWT.trials = trials;
                PWT.seconds = 0;
                PWT.channel = 1;
                PWT.nfft = 512;
            elseif nargin == 2
                PWT.trials = trials;
                PWT.channel = 1;
                PWT.seconds = seconds;
                PWT.nfft = 512;
            elseif nargin == 3
                PWT.trials = trials;
                PWT.channel = channel;
                PWT.seconds = seconds;
                PWT.nfft = 512;
            elseif nargin == 4
                PWT.trials = trials;
                PWT.channel = channel;
                PWT.seconds = seconds;
                PWT.nfft = nfft;
            else
%                 error('invalid number of arguments');
            end
        end
        
        function transform(PWT)
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
            for i=1:numTrials
                if length(PWT.seconds) == 1
                    numsamples = PWT.trials{i}.samplingRate * PWT.seconds;
                    if(numsamples == 0)
                        y = PWT.trials{i}.signal(PWT.channel,:);
                    else
                        y = PWT.trials{i}.signal(PWT.channel, 1:numsamples);
                    end
                elseif length(PWT.seconds) == 2
                    sampleA = PWT.trials{i}.samplingRate*PWT.seconds(1) +1;
                    sampleB = PWT.trials{i}.samplingRate*PWT.seconds(2);
                    y = PWT.trials{i}.signal(PWT.channel, sampleA:sampleB);
                else 
                    error('invalid seconds parameter');
                end
                if isa(PWT.filter,'dfilt.df2sos') || isa(PWT.filter,'dfilt.df2')
                    y = filter(PWT.filter,y);
                elseif isa(PWT.filter,'dfilt.dffir')
                    y = filtfilt(PWT.filter.Numerator,1,y);
                end
                if length(PWT.nfft>1)
                    [pxx, pff]=pwelch(y,[],[],PWT.nfft,PWT.trials{i}.samplingRate);
                else
                    [pxx, pff]=pwelch(y,[],[],PWT.nfft,PWT.trials{i}.samplingRate,'onesided');
                end
                instances(i,:) = pxx;
                labels(i,1) = floor(PWT.trials{i}.label);
            end
            PWT.instanceSet = ssveptoolkit.util.InstanceSet(instances, labels);
            PWT.pff = pff;
        end
        
        function configInfo = getConfigInfo(PWT)
            if length(PWT.nfft)>1
                configInfo = sprintf('PWelchTransformer\tchannel:%d\tseconds:%d\t freq range:%.3f to %.3f',PWT.channel,PWT.seconds,PWT.nfft(1),PWT.nfft(end));
            else
                configInfo = sprintf('PWelchTransformer\tchannel:%d\tseconds:%d\tnfft:%d',PWT.channel,PWT.seconds,PWT.nfft);
            end
        end
    end
   
end

