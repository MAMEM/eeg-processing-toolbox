classdef (Abstract) PSDTransformerBase < ssveptoolkit.transformer.FeatureTransformerBase
    %Base class for a feature transformer based on power spectral density
    %estimates
    properties (Access = public)
        pff; % The frequencies of the spectrum
    end
end