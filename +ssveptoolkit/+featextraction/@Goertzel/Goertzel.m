classdef Goertzel < ssveptoolkit.featextraction.FeatureExtractionBase
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
        pff;
        avgTime;
    end
    
    methods (Access = public)
        function GT = Goertzel(trials, seconds, channel, nfft)
%             if ~iscell(trials)
%                 error('trials must be cell array of Trial object');
%             end
            if nargin == 0
                GT.trials = {};
                GT.seconds = 0;
                GT.channel = 126;
                GT.nfft = 512;
            elseif nargin == 1
                GT.trials = trials;
                GT.seconds = 0;
                GT.channel = 126;
                GT.nfft = 512;
            elseif nargin == 2
                GT.trials = trials;
                GT.channel = 126;
                GT.seconds = seconds;
                GT.nfft = 512;
            elseif nargin == 3
                GT.trials = trials;
                GT.channel = channel;
                GT.seconds = seconds;
                GT.nfft = 512;
            elseif nargin == 4
                GT.trials = trials;
                GT.channel = channel;
                GT.seconds = seconds;
                GT.nfft = nfft;
            else
%                 error('invalid number of arguments');
            end
        end
        
        function transform(GT)
           
            numFeatures = length(GT.nfft);
            numTrials = length(GT.trials);
            instances = zeros(numTrials, numFeatures);
            labels = zeros(numTrials,1);
%             PWT.instances = zeros(numTrials, numFeatures);
%             PWT.labels = zeros(numTrials,1);
            tic;
            for i=1:numTrials
                numsamples = GT.trials{i}.samplingRate * GT.seconds;
                if(numsamples == 0)
                    y = GT.trials{i}.signal(GT.channel,:);
                else
                    y = GT.trials{i}.signal(GT.channel, 1:numsamples);
                end
%                 N = (length(y)+1)/2;
%                 f = (PWT.trials{i}.samplingRate/2)/N*(0:N-1);
%                 indxs = find(f>1.2e3 & f<1.3e3);
%                 X = goertzel(x,indxs);
                freq_indices = round(GT.nfft/GT.trials{i}.samplingRate*length(y)) + 1;
%                 ff = [0:1/512:1/2]*250;
%                 freq_indices = round(ff/PWT.trials{i}.samplingRate*length(y))+1
                dft_data = goertzel(y,freq_indices);%goertzel(y,freq_indices); general_shortened              
                instances(i,:) = abs(dft_data) ./ length(y);
                labels(i,1) = floor(GT.trials{i}.label);
            end
            GT.avgTime = toc/numTrials;
            GT.instanceSet = ssveptoolkit.util.InstanceSet(instances, labels);
            GT.pff = GT.nfft;
        end
        
        function configInfo = getConfigInfo(GT)
            configInfo = sprintf('Goertzel\tchannel:%d\tseconds:%d\tfreq range:%.3f to %.3f',GT.channel,GT.seconds,GT.nfft(1),GT.nfft(end));
        end
        
        function time = getTime(GT)
            time = GT.avgTime;
        end
    end
   
end

