classdef Fisher < ssveptoolkit.aggregation.AggregatorBase
    properties
        codebookInfo;
        numClusters;
        means;
        covariances;
        priors;
        pcanum;
    end
    
    methods
        function FA = Fisher(codebookfilename,pcanum)
            load(codebookfilename);
            FA.means = means;
            FA.covariances = covariances;
            FA.priors = priors;
            FA.numClusters = length(priors);
            FA.codebookInfo = codebookInfo;
            FA.pcanum = pcanum;
        end
        
        function FA = aggregate(FA)
            numExtract = length(FA.featextractors);
            numFeatures = FA.featextractors{1}.instanceSet.getNumFeatures;
            numTrials = length(FA.featextractors{1}.trials);
            instances = zeros(numTrials,numExtract,numFeatures);
            pcainstances = zeros(numTrials,numExtract,FA.pcanum);
            if FA.pcanum > 0
                fishers = zeros(numTrials, FA.numClusters * FA.pcanum *2);
            else
                fishers = zeros(numTrials,FA.numClusters*numFeatures*2);
            end
            for i=1:numExtract
                instances(:,i,:) = FA.featextractors{i}.getInstances;
                if FA.pcanum > 0
                    [~,pcainstances(:,i,:),~,~,~] = pca(squeeze(instances(:,i,:)),'NumComponents',FA.pcanum);
                end
            end
            for i=1:numTrials
                if FA.pcanum > 0
                    dataToBeEncoded = squeeze(pcainstances(i,:,:));
                else
                    dataToBeEncoded = squeeze(instances(i,:,:));
                end
                fishers(i,:) =  vl_fisher(dataToBeEncoded', FA.means, FA.covariances, FA.priors);
            end
            FA.instanceSet = ssveptoolkit.util.InstanceSet(fishers,FA.featextractors{1}.getLabels);
        end
        
        function configInfo = getConfigInfo(FA)
            configInfo = sprintf('Fisher:\tcodebook:%s',FA.codebookInfo);
        end
                        
        function time = getTime(FA)
            time = 0;
        end
    end
    
    methods (Static)
        function [] = trainCodebook(session, channels, numCenters, codebookfilename,pcanum)
            nfft = 512;
            extractors = {};
            numChannels = length(channels);
            numTrials = length(session.trials);
            numFeatures = nfft/2+1;
            instances = zeros(numTrials,numChannels,numFeatures);
            h = waitbar(0,'message');
            for i=1:length(channels)
                waitbar(i/(length(channels)+10),h,sprintf('Computing channel:%d',channels(i)));
                extractors{i} = ssveptoolkit.featextraction.PWelch;
                extractors{i}.trials = session.trials;
                extractors{i}.channel = channels(i);
                extractors{i}.nfft = nfft;
                extractors{i}.seconds = 5;
                extractors{i}.extract;
                instances(:,i,:) = extractors{i}.getInstances;
            end
            instances = reshape(instances,numTrials*numChannels,numFeatures);
            waitbar(i/(length(channels)+10),h,'Computing gmm..');
            if(pcanum > 0)
                [~,instances,~,~,~] = pca(instances,'NumComponents',pcanum);
            end
            [means, covariances, priors] = vl_gmm(instances', numCenters);
            waitbar(i+5/(length(channels)+10),h,'Saving variables..');
            codebookInfo = sprintf('filename:%s\tnumClusters:%d\tnumPCA:%d\tchannels:',codebookfilename, numCenters, pcanum);
            for i=1:length(channels)
                codebookInfo = sprintf('%s%d ',codebookInfo,channels(i));
            end
            save(codebookfilename,'means','covariances','priors','codebookInfo');
            close(h);
        end
        

    end
    
end

