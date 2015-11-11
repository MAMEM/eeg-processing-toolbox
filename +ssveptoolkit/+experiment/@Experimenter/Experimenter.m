classdef Experimenter < ssveptoolkit.experiment.EvaluatorBase
    
    properties (Access = public)
        session;
        transformer;
        extractor;
%         classifier; %inheritted from EvaluatorBase
        evaluator;
    end
    
    methods
        function E = Experimenter()
        end
        
        function E = run(E)
            E.transformer.trials = E.session.trials;
            disp('transform ...');
            E.transformer.transform;
            if ~isempty(E.extractor)
                E.extractor.originalInstanceSet = E.transformer.getInstanceSet;
                disp('extract ...');
                E.extractor.filter;
                E.classifier.instanceSet = E.extractor.filteredInstanceSet;
            else
                E.classifier.instanceSet = E.transformer.getInstanceSet;
            end
            E.instanceSet = ssveptoolkit.util.InstanceSet(E.classifier.instanceSet.getDataset);
            disp('cv ...');
            E.leaveOneOutCV();
        end
        
    end
    
end

