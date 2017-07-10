classdef WPDec < eegtoolkit.featextraction.FeatureExtractionBase
    
    properties (Access = public)
        channel;
        order;
        wavFamily;
    end
    
    methods (Access = public)
        function WP = WP()
            WP.wavFamily = 'sym5';
        end
        
        function extract(WP)
            numTrials = length(WP.trials);
%             nNodes = (1-2^(WP.order+1))/(1-2);
            nNodes = 31;
            instances = zeros(numTrials,nNodes);
            labels = zeros(numTrials,1);
            for i=1:numTrials
                T = wpdec(WP.trials{i}.signal(WP.channel,:),WP.order,'sym5');
                for j=1:nNodes
                    instances(i,j) = std(wprcoef(T,j));
                end
                labels(i) = WP.trials{i}.label;
            end
            WP.instanceSet = eegtoolkit.util.InstanceSet(instances,labels);
        end
        
        function configInfo = getConfigInfo (WP)
            configInfo = 'WPDec';
        end
        
        function time = getTime(WP)
            time = 0;
        end
                
    end
%     T = wpdec(trialsCal(:,n,k),5,'sym5');
%         rwpc1 = wprcoef(T,34);
%         rwpc2 = wprcoef(T,33);
%         rwpc3 = wprcoef(T,36);
%         rwpc4 = wprcoef(T,35);
    
end

