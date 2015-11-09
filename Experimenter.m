classdef Experimenter < EvaluatorBase
    
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
            E.transformer.transform;
            if ~isempty(E.extractor)
                E.extractor.originalInstanceSet = E.transformer.getInstanceSet;
                E.extractor.filter;
                E.classifier.instanceSet = E.extractor.filteredInstanceSet;
            else
                E.classifier.instanceSet = E.transformer.getInstanceSet;
            end
            E.instanceSet = InstanceSet(E.classifier.instanceSet.getDataset);
            E.leaveOneOutCV();
        end
        
    end
    
end

