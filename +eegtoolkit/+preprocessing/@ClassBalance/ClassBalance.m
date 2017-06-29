classdef ClassBalance < eegtoolkit.preprocessing.PreprocessingBase
    %works for 2 classes only
    properties
        seed
        info;
        avgTime;
    end
    
    methods
        function CB = ClassBalance(seed)
            if(nargin==1)
                CB.seed = seed;
            else
                CB.seed = 1;
            end
        end
        
        function out = process(CB,in )
            tic;
            for i=1:length(in)
                labels(i) = in{i}.label;
            end
            unlabels = unique(labels);
            clabels = zeros(1,length(unlabels));
            for i=1:length(in)
                label = labels(i);
                for j=1:length(unlabels)
                    if(label==unlabels(j))
                        clabels(j) = clabels(j) + 1;
                    end
                end
            end
            [minLabelCount, minLabelIndex] = min(clabels);
            minLabel = unlabels(minLabelIndex);
            maxLabel = unlabels(unlabels~=minLabelIndex);
            maxLabelIndices = find(labels==maxLabel);
            minLabelIndices = find(labels==minLabel);
            rng('default');
            rng(CB.seed);
            selectedIndices = randperm(length(maxLabelIndices));
            selectedIndices = maxLabelIndices(selectedIndices(1:length(minLabelIndices)));
%             selectedIndices = selectedIndices(1:length(minLabelIndices));
            allSelectedIndices = horzcat(selectedIndices,minLabelIndices);
            allSelectedLabels = horzcat(labels(selectedIndices),labels(minLabelIndices));
            [allSelectedIndicesSorted, I] = sort(allSelectedIndices);
            allSelectedLabelsSorted = allSelectedLabels(I);
            out = {};
            for i=1:length(allSelectedIndicesSorted)
                out{length(out) + 1} = eegtoolkit.util.Trial(in{allSelectedIndicesSorted(i)}.signal,allSelectedLabelsSorted(i),256,1,1,in{i}.type);
            end
%             for i=selectedIndices
%                 out{length(out) + 1} = eegtoolkit.util.Trial(in{i}.signal,in{i}.label,256,1,1,in{i}.type);
%             end
%             maxLabelCount = 0;
%             out = {};
%             for i=1:length(in)
%                 if(in{i}.label~=minLabel)
%                     if(maxLabelCount >= minLabelCount)
%                         continue;
%                     else
%                         out{length(out) + 1} = eegtoolkit.util.Trial(in{i}.signal,in{i}.label,256,1,1,in{i}.type);
%                         maxLabelCount = maxLabelCount + 1;
%                     end
%                 else
%                     out{length(out) + 1} = eegtoolkit.util.Trial(in{i}.signal, in{i}.label,256,1,1,in{i}.type);
%                 end
%             end
        end
        
        function configInfo = getConfigInfo(CB)
            if isempty(CB.info)
                configInfo = 'ClassBalance';
            else
                configInfo = strcat('ClassBalance:\t');
            end
        end
        
        function time = getTime(CB)
            time = 0;
        end
    end
    
end

