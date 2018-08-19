classdef (Abstract) PSDExtractionBase < eegtoolkit.featextraction.FeatureExtractionBase
    %Base class for a feature transformer based on power spectral density
    %estimates
    properties (Access = public)
        pff; % The frequencies of the spectrum
    end
end