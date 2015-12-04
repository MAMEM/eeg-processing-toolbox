classdef FisherAggregator < ssveptoolkit.aggregation.AggregatorBase
    %FISHERAGGREGATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        codebookInfo;
        numClusters;
        means;
        covariances;
        priors;
    end
    
    methods
        function FA = FisherAggregator(codebookfilename)
            load(codebookfilename);
            FA.means = means;
            FA.covariances = covariances;
            FA.priors = priors;
            FA.numClusters = length(priors);
            FA.codebookInfo = codebookInfo;
        end
        
        function FA = aggregate(FA)
            numTransf = length(FA.transformers);
            numFeatures = FA.transformers{1}.instanceSet.getNumFeatures;
            numTrials = length(FA.transformers{1}.trials);
            instances = zeros(numTrials,numTransf,numFeatures);
            fishers = zeros(numTrials,FA.numClusters*numFeatures*2);
            for i=1:numTransf
                instances(:,i,:) = FA.transformers{i}.getInstances;
            end
            for i=1:numTrials
                dataToBeEncoded = squeeze(instances(i,:,:));
                fishers(i,:) =  vl_fisher(dataToBeEncoded', FA.means, FA.covariances, FA.priors);
            end
            FA.instanceSet = ssveptoolkit.util.InstanceSet(fishers,FA.transformers{1}.getLabels);
        end
        
        function configInfo = getConfigInfo(FA)
            configInfo = sprintf('FisherAggregator:\tcodebook:%s',FA.codebookInfo);
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
            waitbar(i/(length(channels)+10),h,'Computing gmm..');
            [means, covariances, priors] = vl_gmm(instances', numCenters);
%             centers = vl_kmeans(instances',numCenters);
%             waitbar(i+4/(length(channels)+10),h,'Building kdtree..');
%             kdtree = vl_kdtreebuild(centers);
            waitbar(i+5/(length(channels)+10),h,'Saving variables..');
            codebookInfo = sprintf('filename:%s\tnumClusters:%d\tchannels:',codebookfilename, numCenters);
            for i=1:length(channels)
                codebookInfo = sprintf('%s%d ',codebookInfo,channels(i));
            end
            save('occipital','instances');
            save(codebookfilename,'means','covariances','priors','codebookInfo');
            close(h);
        end
    end
    
end

