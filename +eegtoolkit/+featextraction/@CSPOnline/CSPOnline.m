classdef CSPOnline < eegtoolkit.featextraction.FeatureExtractionBase
    properties
        trainIdx;
        testIdx;
        filterDimension;
        CSPMatrix;
    end
    
    methods
        function CSPOnline = CSPOnline()
            warning('CSPOnline: Experimental version');
        end
        
        function out = extract(CSPOnline)
            if(isempty(CSPOnline.CSPMatrix))
                error('CSP not learned');
            end
            labels = zeros(1,length(CSPOnline.trials));
            [numChannels, numSamples]= size(CSPOnline.trials{1}.signal);
            nTrials = length(CSPOnline.trials);
            trialsMat = zeros(numSamples,numChannels,nTrials);
            samplingRate = CSPOnline.trials{1}.samplingRate;
            for i=1:length(CSPOnline.trials)
                labels(i) = CSPOnline.trials{i}.label;
                trialsMat(:,:,i) = CSPOnline.trials{i}.signal';
            end
            EEGSignals.x = trialsMat;
            EEGSignals.y = labels;
            EEGSignals.s = samplingRate;
            dataset = CSPOnline.extractDiscreteCSPFeatures(EEGSignals, CSPOnline.CSPMatrix, CSPOnline.filterDimension);
            CSPOnline.instanceSet = eegtoolkit.util.InstanceSet(dataset);
        end
        
        function CSPOnline = learnCSP(CSPOnline,in)
            labels = zeros(1,length(in));
            [numChannels, numSamples]= size(in{1}.signal);
            nTrials = length(in);
            trialsMat = zeros(numSamples,numChannels,nTrials);
            samplingRate = in{1}.samplingRate;
            for i=1:length(in)
                labels(i) = in{i}.label;
                trialsMat(:,:,i) = in{i}.signal';
            end
            EEGSignals.x = trialsMat;
            EEGSignals.y = labels;
            EEGSignals.s = samplingRate;
            CSPOnline.CSPMatrix = CSPOnline.learnDiscreteCSP(EEGSignals);
        end
        
        function configInfo = getConfigInfo(CSPOnline)
            configInfo = 'CSP\tChannels:';
        end
        
        
        function time = getTime(CSPOnline)
            time = 0;
        end
        
        function features = extractDiscreteCSPFeatures(CSPOnline, EEGSignals, CSPMatrix, nbFilterPairs)
            %
            %     Copyright (C) 2015  Fabien LOTTE
            %
            %     This program is free software: you can redistribute it and/or modify
            %     it under the terms of the GNU General Public License as published by
            %     the Free Software Foundation, either version 3 of the License, or
            %     (at your option) any later version.
            %
            %     This program is distributed in the hope that it will be useful,
            %     but WITHOUT ANY WARRANTY; without even the implied warranty of
            %     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
            %     GNU General Public License for more details.
            %
            %     You should have received a copy of the GNU General Public License
            %     along with this program.  If not, see <http://www.gnu.org/licenses/>.
            %
            %extract features from an EEG data set using the Common Spatial Patterns (CSP) algorithm
            %
            %Input:
            %EEGSignals: the EEGSignals from which extracting the CSP features. These signals
            %are a structure such that:
            %   EEGSignals.x: the EEG signals as a [Ns * Nc * Nt] Matrix where
            %       Ns: number of EEG samples per trial
            %       Nc: number of channels (EEG electrodes)
            %       nT: number of trials
            %   EEGSignals.y: a [1 * Nt] vector containing the class labels for each trial
            %   EEGSignals.s: the sampling frequency (in Hz)
            %CSPMatrix: the CSP projection matrix, learnt previously (see function learnCSP)
            %nbFilterPairs: number of pairs of CSP filters to be used. The number of
            %   features extracted will be twice the value of this parameter. The
            %   filters selected are the one corresponding to the lowest and highest
            %   eigenvalues
            %
            %Output:
            %features: the features extracted from this EEG data set
            %   as a [Nt * (nbFilterPairs*2 + 1)] matrix, with the class labels as the
            %   last column
            %
            %by Fabien LOTTE (fabien.lotte@inria.fr)
            %created: 19/01/2011
            %last revised: 19/01/2011
            
            %initializations
            nbTrials = size(EEGSignals.x,3);
            features = zeros(nbTrials, 2*nbFilterPairs+1);
            Filter = CSPMatrix([1:nbFilterPairs (end-nbFilterPairs+1):end],:);
            
            %extracting the CSP features from each trial
            for t=1:nbTrials
                %projecting the data onto the CSP filters
                projectedTrial = Filter * EEGSignals.x(:,:,t)';
                
                %generating the features as the log variance of the projected signals
                variances = var(projectedTrial,0,2);
                for f=1:length(variances)
                    features(t,f) = log(variances(f));
                end
                features(t,end) = EEGSignals.y(t);
            end
        end
        function CSPMatrix = learnDiscreteCSP(CSPOnline, EEGSignals)
            %
            %     Copyright (C) 2015  Fabien LOTTE
            %
            %     This program is free software: you can redistribute it and/or modify
            %     it under the terms of the GNU General Public License as published by
            %     the Free Software Foundation, either version 3 of the License, or
            %     (at your option) any later version.
            %
            %     This program is distributed in the hope that it will be useful,
            %     but WITHOUT ANY WARRANTY; without even the implied warranty of
            %     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
            %     GNU General Public License for more details.
            %
            %     You should have received a copy of the GNU General Public License
            %     along with this program.  If not, see <http://www.gnu.org/licenses/>.
            %
            %this function learn the CSP (Common Spatial Patterns) filters to
            %discriminate two mental states in EEG/ECoG signals.
            %
            %Input:
            %EEGSignals: the training EEG signals, composed of 2 classes. These signals
            %are a structure such that:
            %   EEGSignals.x: the EEG signals as a [Ns * Nc * Nt] Matrix where
            %       Ns: number of EEG samples per trial
            %       Nc: number of channels (EEG electrodes)
            %       nT: number of trials
            %   EEGSignals.y: a [1 * Nt] vector containing the class labels for each trial
            %   EEGSignals.s: the sampling frequency (in Hz)
            %
            %Output:
            %CSPMatrix: the learnt CSP filters (a [Nc*Nc] matrix with the filters as rows)
            %
            %by Fabien LOTTE (fabien.lotte@inria.fr)
            %created: 19/01/2011
            %last revised: 19/01/2011
            %
            %See also: extractCSPFeatures
            
            %check and initializations
            nbChannels = size(EEGSignals.x,2);
            nbTrials = size(EEGSignals.x,3);
            classLabels = unique(EEGSignals.y);
            nbClasses = length(classLabels);
            if nbClasses ~= 2
                disp('ERROR! CSP can only be used for two classes');
                return;
            end
            covMatrices = cell(nbClasses,1); %the covariance matrices for each class
            
            %computing the normalized covariance matrices for each trial
            trialCov = zeros(nbChannels,nbChannels,nbTrials);
            for t=1:nbTrials
                E = EEGSignals.x(:,:,t)';
                EE = E * E';
                trialCov(:,:,t) = EE ./ trace(EE);
            end
            clear E;
            clear EE;
            
            %computing the covariance matrix for each class
            for c=1:nbClasses
                covMatrices{c} = mean(trialCov(:,:,EEGSignals.y == classLabels(c)),3);
            end
            
            %generalized eigen value decomposition of C1 and C2
            [U D] = eig(covMatrices{1},covMatrices{2});
            eigenvalues = diag(D);
            [nothing, egIndex] = sort(eigenvalues, 'descend');
            U = U(:,egIndex);
            CSPMatrix = U';
        end
        
    end
    
end

