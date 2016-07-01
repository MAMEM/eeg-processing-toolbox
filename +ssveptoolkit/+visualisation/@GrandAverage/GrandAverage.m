classdef GrandAverage < handle
    %GRANDAVERAGE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        trials;
        trialsMat;
    end
    
    methods 
        function GA = GrandAverage(trials)
            GA.trials = trials;
            GA.trialsMat = ssveptoolkit.util.Trial.trialsCellToMat(GA.trials);
        end
        
        function GA = plotGrandAverageForChannel(GA,channel)
            close all;
            labels = ssveptoolkit.util.Trial.getLabelsVectorForTrials(GA.trials);
            uniqlabels = unique(labels);
            plots = {};
            for i=1:length(uniqlabels)
                mat = ssveptoolkit.util.Trial.trialsCellToMatForLabel(GA.trials,uniqlabels(i));
                ga = mean(mat,3);
                plots{i} = ga(channel,end-307:end);
            end
            hold on;
            ms = -200:3.8961:999;
            for i=1:length(uniqlabels);
                plot(ms,plots{i});
            end
            ylabel('Amplitude (uV)');
            xlabel('Time (ms)');
            title(sprintf('Channel: %d',channel));
            hold off;
        end
        
        function GA = plotGrandAverageForChannelAndLabel(GA,channel,label)
            close all;
            labels = ssveptoolkit.util.Trial.getLabelsVectorForTrials(GA.trials);
            mat = ssveptoolkit.util.Trial.trialsCellToMatForLabel(GA.trials,label);
            ga = mean(mat,3);
            plot(ga(channel,:));
        end
            
    end
    
end

