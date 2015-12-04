classdef VladAggregator < ssveptoolkit.aggregation.AggregatorBase;
    
    properties
        kdtree;
        centers;
        codebookInfo;
        numClusters;
    end
    
    methods
        
        function VA = VladAggregator(codebookfilename)
            load(codebookfilename);
            VA.kdtree = kdtree;
            VA.centers = centers;
            VA.codebookInfo = codebookInfo;
            [~,VA.numClusters] = size(centers);
        end
        
        function VA = aggregate(VA)
            numTransf = length(VA.transformers);
            numFeatures = VA.transformers{1}.instanceSet.getNumFeatures;
            numTrials = length(VA.transformers{1}.trials);
            instances = zeros(numTrials,numTransf,numFeatures);
            vlads = zeros(numTrials,VA.kdtree.numData*numFeatures);
            for i=1:numTransf
                instances(:,i,:) = VA.transformers{i}.getInstances;
            end
            for i=1:numTrials
                dataToBeEncoded = squeeze(instances(i,:,:));
                nn = vl_kdtreequery(VA.kdtree, VA.centers, dataToBeEncoded');
                assignments = zeros(VA.numClusters, numTransf);
                assignments(sub2ind(size(assignments), nn, 1:length(nn))) = 1;
                vlads(i,:) = vl_vlad(dataToBeEncoded',VA.centers,assignments);
            end
            VA.instanceSet = ssveptoolkit.util.InstanceSet(vlads,VA.transformers{1}.getLabels);
        end
        
        function configInfo = getConfigInfo(VA)
            configInfo = sprintf('VladAggregator:\tcodebook:%s',VA.codebookInfo);
        end
    end
    
    methods (Static)
        function [] = trainCodebook(session, channels, numCenters, codebookfilename)
            nfft = 512;
            transformers = {};
            numChannels = length(channels);
            numTrials = length(session.trials);
            numFeatures = nfft/2+1;
            instances = zeros(numTrials,numChannels,numFeatures);
            h = waitbar(0,'message');
            for i=1:length(channels)
                waitbar(i/(length(channels)+10),h,sprintf('Computing channel:%d',channels(i)));
                transformers{i} = ssveptoolkit.transformer.PWelchTransformer;
                transformers{i}.trials = session.trials;
                transformers{i}.channel = channels(i);
                transformers{i}.nfft = nfft;
                transformers{i}.seconds = 5;
                transformers{i}.transform;
                instances(:,i,:) = transformers{i}.getInstances;
            end
            instances = reshape(instances,numTrials*numChannels,numFeatures);
            waitbar(i/(length(channels)+10),h,'Clustering..');
            centers = vl_kmeans(instances',numCenters);
            waitbar(i+4/(length(channels)+10),h,'Building kdtree..');
            kdtree = vl_kdtreebuild(centers);
            waitbar(i+5/(length(channels)+10),h,'Saving variables..');
            codebookInfo = sprintf('filename:%s\tnumClusters:%d\tchannels:',codebookfilename, numCenters);
            for i=1:length(channels)
                codebookInfo = sprintf('%s%d ',codebookInfo,channels(i));
            end
            save(codebookfilename,'centers','kdtree','codebookInfo');
            close(h);
        end
    end
end

