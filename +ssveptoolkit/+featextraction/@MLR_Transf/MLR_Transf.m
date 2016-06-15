classdef MLR_Transf < ssveptoolkit.featextraction.PSDExtractionBase%FeatureExtractionBase
    %Computes the psd using the welch method
    %Usage:
    %   session = ssveptoolkit.util.Session();
    %   session.loadSubject(1);
    %   pwt = ssveptolkit.transform.PWelchTransformer(session.trials);
    %Specify the channel to be used (default = 126)
    %   pwt.channel = 150;
    %Specify the number of seconds to be used (default = 0, use all signal)
    %   pwt.seconds = 3;
    %Specify the nfft parameter (default = 512, computes 257 features)
    %   pwt.nfft = 512;
    %Transform the signal
    %   pwt.transform();
    properties (Access = public)
        channel;
        avgTime;
    end
    methods (Access = public)
        function PWT = MLR_Transf(chns)
            if nargin == 1
                PWT.trials = {};
                PWT.channel = [1:length(chns)];
            else
                error('invalid number of arguments');
            end
        end
        
        function extract(PWT)
            
            numTrials = length(PWT.trials);
            [m n]=size(PWT.trials{1}.signal(PWT.channel,:));
            data = zeros(m,n,numTrials);
            labels = zeros(numTrials,1);
            
            for i = 1 : numTrials   %
                for j=1:m
                    data(j,:,i) = PWT.trials{i}.signal(j,:);%data(j,:,i)./norm(data(j,:,i));
                    data(j,:,i) = (data(j,:,i) - mean(data(j,:,i)));%./std(data(j,:,i));
                    %data(j,:,i) = data(j,:,i)./norm(data(j,:,i));
                end%
                labels(i) = floor(PWT.trials{i}.label);
            end
            data= reshape(data,m*n,size(data,3));
            %             MeanTrainData=mean(data,2);
            %             data=data-repmat(MeanTrainData,1,numTrials);
            data = data';
            PWT.instanceSet = ssveptoolkit.util.InstanceSet(data, labels);
        end
        
        function configInfo = getConfigInfo(PWT)
            configInfo = sprintf('MLR_Transf_rawdata');
        end
        
        function time = getTime(PWT)
            time = PWT.avgTime;
        end
    end
    
end

