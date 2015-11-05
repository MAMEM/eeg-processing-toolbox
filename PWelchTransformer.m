classdef PWelchTransformer < FeatureTransformerBase
%Computes the psd using the welch method
%Usage:
%   session = Session();
%   session.loadSubject(Session.ANASTASIA);
%   pwt = PWelchTransformer(session.trials);
%Specify the channel to be used (default = 126)
%   pwt.channel = 150;
%Specify the number of seconds to be used (default = 0, use all signal)
%   pwt.seconds = 3;
%Specify the nfft parameter (default = 512, computes 257 features)
%   pwt.nfft = 512;
%Transform the signal
%   pwt.transform();
%Pass the output to a FeatureExtractor
%   ff = FrequencyFilter(pwt.getInstanceSet, pwt.pff);
    properties (Access = public)
        channel;
        seconds;
        nfft;
        pff;
    end
    
    methods (Access = public)
        function PWT = PWelchTransformer(trials, seconds, channel, nfft)
            if ~iscell(trials)
                error('trials must be cell array of Trial object');
            end
            if nargin == 0
                PWT.trials = {};
                PWT.seconds = 0;
                PWT.channel = 126;
                PWT.nfft = 512;
            elseif nargin == 1
                PWT.trials = trials;
                PWT.seconds = 0;
                PWT.channel = 126;
                PWT.nfft = 512;
            elseif nargin == 2
                PWT.trials = trials;
                PWT.channel = 126;
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
                error('invalid number of arguments');
            end
        end
        
        function transform(PWT)
            numFeatures = PWT.nfft/2+1;
            numTrials = length(PWT.trials);
            instances = zeros(numTrials, numFeatures);
            labels = zeros(numTrials,1);
%             PWT.instances = zeros(numTrials, numFeatures);
%             PWT.labels = zeros(numTrials,1);
            for i=1:numTrials
                numsamples = PWT.trials{i}.samplingRate * PWT.seconds;
                if(numsamples == 0)
                    y = PWT.trials{i}.signal(PWT.channel,:);
                else
                    y = PWT.trials{i}.signal(PWT.channel, 1:numsamples);
                end
                [pxx, pff]=pwelch(y,[],[],PWT.nfft,PWT.trials{i}.samplingRate,'onesided');
                instances(i,:) = pxx;
                labels(i,1) = floor(PWT.trials{i}.label);
            end
            PWT.instanceSet = InstanceSet(instances, labels);
            PWT.pff = pff;
        end
    end
   
end

