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
            plots = {};
            [~,~,~,numLabels] = size(GA.trialsMat);
            for i=1:numLabels
                plots{i} = mean(GA.trialsMat(channel,:,:,i),3);
            end
            hold on;
            for i=1:numLabels
                plot(plots{i});
            end
            hold off;
        end
            
    end
    
end

