classdef StressDetection < handle
    %STRESSDETECTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        stressLevelThresholds;
    end
    
    methods (Access = public)
        function SD = StressDetection()
            SD.stressLevelThresholds = zeros(1,5);
        end
        
        function SD = trainThresholds(SD, xdfFilename)
            streams = eegtoolkit.util.load_xdf(xdfFilename);
            for i=1:length(streams)
                if isequal(streams{i}.info.type,'BIO')
                    gsrData = streams{i}.time_series(2,:);
                end
            end
            if(isempty(gsrData))
                error('Error: Could not find a stream with type "BIO" in the specified xdf file');
            end
            SD.trainThresholdsInternal(gsrData);
        end
        
        function stress = detectStress(SD,gsr)
            stress = zeros(1,length(gsr));
            ss = SD.computeSS(gsr);
            for i=1:length(ss)
                if(ss(i) < SD.stressLevelThresholds(1))
                    stress(i) = 1;
                elseif(ss(i) < SD.stressLevelThresholds(2))
                    stress(i) = 2;
                elseif(ss(i) < SD.stressLevelThresholds(3))
                    stress(i) = 3;
                elseif(ss(i) < SD.stressLevelThresholds(4))
                    stress(i) = 4;
                else
                    stress(i) = 5;
                end
            end
        end
        
        function runStressDetectionOutlet(SD)
            lib = lsl_loadlib;
            gsrstream = lsl_resolve_byprop(lib,'type','BIO');
            gsrinlet = lsl_inlet(gsrstream{1});
            stressoutletinfo = lsl_streaminfo(lib,'Stress Levels','Stress',1.0,0,'cf_float32','stressourceid256');
            stressoutlet = lsl_outlet(stressoutletinfo);
            windowlength = 100*256+1;
            buffer = zeros(1,windowlength)-1;
            numPulled = 0;
            while(1)
                [samples,~] = gsrinlet.pull_chunk;
                if(isempty(samples))
                    continue;
                end
                [~,numPulled ]= size(samples(2,:));
                buffer = circshift(buffer,[1,-numPulled]);
                buffer(windowlength-numPulled+1:end) = samples(2,:);
                length(buffer(buffer>=0))
                if(length(buffer(buffer>=0))>=windowlength)
                    stress = SD.detectStress(buffer);
                    stressValue = mean(stress(stress>0))
                    stressoutlet.push_sample(stressValue);
                end
                drawnow;
                pause(1);
            end
        end
                
                
                
%                   
%             counterGreaterL5 = 0;
%             counterObservations = 0;
%             
%             for i = 1 : frequency*60 : size(SS, 1);
%                 
%                 counterObservations = counterObservations + 1;
%                 
%                 if (i + frequency*60 - 1 < size(SS, 1))
%                     meanValue = mean(nonzeros(SS(i : i + frequency*60)));
%                 else
%                     meanValue = mean(nonzeros(SS(i : size(SS, 1))));
%                 end
%                 
%                 if (l0 < meanValue && meanValue < l1);
%                     dlmwrite(pathofFile, 1, '-append');
%                 elseif (l1 < meanValue && meanValue < l2)
%                     dlmwrite(pathofFile, 2, '-append');
%                 elseif (l2 < meanValue && meanValue < l3);
%                     dlmwrite(pathofFile, 3, '-append');
%                 elseif (l3 < meanValue && meanValue < l4)
%                     dlmwrite(pathofFile, 4, '-append');
%                 elseif (l4 < meanValue && meanValue < l5)
%                     dlmwrite(pathofFile, 5, '-append');
%                 elseif (meanValue>l5);
%                     counterGreaterL5 = counterGreaterL5 + 1;
%                 end
%             end
%             
%             if counterGreaterL5/counterObservations > 0.4
%                 Disp('40% of observations greater than L5');
%             end
%         end
        
    end
    
    methods (Access = private)
        
        function SS = computeSS(SD,data)
            F = data';
            %aquisition frequency = 256;
            frequency = 256;
            %convert kŸ to ÏS
            M = 1000./F;
            %initialise the reconstructed data matrix
            K = zeros(size(M, 1), 1);
            %windowNoise = zeros(ceil(size(K,1)/(frequency*5)));
            %f = 1;
            %check when the sensor has no contact
            for i = 1 : frequency*5 : size(M, 1);
                if (i + frequency*5 - 1 < size(M, 1))
                    endMatrix = i + frequency*5;
                    tempMatrix = M(i : i + frequency*5);
                else
                    endMatrix = size(M,1);
                    tempMatrix = M(i : size(M, 1));
                end
                counter = 0;
                for l = 1 : size(tempMatrix,1)
                    if tempMatrix(l,1) < 0.001
                        counter = counter + 1;
                    end
                end
                if counter/size(tempMatrix,1) > 0.9
                    %windowNoise(f,1) = 1;
                    %counter/size(tempMatrix,1);
                    M(i : endMatrix ) = 0;
                end
                %f = f + 1;
            end
            %check for noisy windows (increasing/decreasing values)
            for i = 1 : size(M,1) - 1; 
                if M(i+1,1) > M(i,1)
                    if ((M(i+1) - M(i,1))/M(i+1) > 0.2)
                        G(i,1) = 0;
                    else
                        G(i,1) = M(i,1);
                    end
                else
                    if ((M(i) - M(i+1,1))/M(i) > 0.1)
                        G(i,1) = 0;
                    else
                        G(i,1) = M(i,1);
                    end
                end
            end
            %median one second filter
            for i = frequency/2 +  1 : size(G,1) - frequency/2 
                matrixForMedian = G(i - frequency/2 : i + frequency/2);
                sortedMatrix = sortrows(matrixForMedian);
                S(i - frequency/2 ,1) = sortedMatrix(frequency/2,1);
            end
            %median 1 minute median filter
            for i = (frequency*60)/2 +  1 : size(S,1) - (frequency*60)/2 
                matrixForMedianN = S(i - (frequency*60)/2 : i + (frequency*60)/2);
                sortedMatrixN = sortrows(matrixForMedianN);
                SS(i - (frequency*60)/2 ,1) = sortedMatrixN((frequency*60)/2,1);
            end
        end
        function SD = trainThresholdsInternal(SD, data)
            %find the most calm 5minute window
            SS = SD.computeSS(data);
            frequency = 256;
            minimum = 100000;
            counter = 0;
            if size(SS,1) > frequency*60*5
                for i = i :frequency*60*5 : size(SS,1)
                    
                    if (i + frequency*60*5) > size(SS,1)
                        endMatrix = i + frequency*60*5;
                    else
                        endMatrix = size(SS,1);
                    end
                    
                    mn = mean(nonzeros(SS(i:endMatrix)));
                    
                    if mn< minimum
                        minimum = mn;
                        counter1 = i;
                        counter2 = endMatrix;
                        l0 = max(SS(counter1:counter2));
                    end
                    
                end
                
            else
                
                l0 = min(SS(SS>0));
            end
            
            
            
            %compute the input without zeros to create the histogram
            matrixForHist = SS(SS~=0);
            
            %compute the histogram
            [n,xout] = hist(matrixForHist, 300);
            index = find(~n);
            
            %compute the l5 value
            l5 = xout(1,index(1));
            
            %compute the delta value which forms the thresholds
            delta = (l5 - l0) / 4.5;
            
            %compute the values for the four thesholds
            l1 = l0 + delta / 2;
            l2 = l1 + delta;
            l3 = l2 + delta;
            l4 = l3 + delta;
            %classify according to mean SC value the stress level of each patient
            %for each minute
            SD.stressLevelThresholds(1) = l1;
            SD.stressLevelThresholds(2) = l2;
            SD.stressLevelThresholds(3) = l3;
            SD.stressLevelThresholds(4) = l4;
            SD.stressLevelThresholds(5) = l5;

        end
    end
end
    
