classdef L1MCCA < eegtoolkit.featextraction.PSDExtractionBase%FeatureExtractionBase
    %
    % works only on our datasets, for other datasets needs modifications
    %
    properties (Access = public)
        channel;
        avgTime;
        stimulus_freqs;
        FreqSamp;
        NumHarm;
    end
    methods (Access = public)
        function L1MCCA = L1MCCA()
        end
        
        function extract(L1MCCA)
            L1MCCA.instanceSet = eegtoolkit.util.L1MCCAInstanceSet(L1MCCA.trials);
        end
        
        function configInfo = getConfigInfo(L1MCCA)
            configInfo = sprintf('L1MCCA');
        end
        function time = getTime(L1MCCA)
            time = 0;
        end
    end
end