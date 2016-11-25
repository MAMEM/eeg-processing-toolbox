classdef RawSignal < eegtoolkit.featextraction.FeatureExtractionBase
    %RAWSIGNAL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
    end
    
    methods (Access = public)
        function RS = RawSignal()
%             RS.instanceSet = eegtoolkit.util.RawSignalSet(RS.trials);
        end
        
        function RS = extract(RS)
            RS.instanceSet = eegtoolkit.util.RawSignalSet(RS.trials);
        end
        
        function configInfo = getConfigInfo(RS)
            configInfo = '\n';
        end
        
        function time = getTime(RS)
            time = 0;
        end
    end
    
end

