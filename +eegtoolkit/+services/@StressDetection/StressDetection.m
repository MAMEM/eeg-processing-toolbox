classdef StressDetection < handle
    %STRESSDETECTION 
    % Detects the stress level of a subject using the GSR measurements from
    % a Shimmer 3+ device
    
    properties
        % The thresholds that are calculated based on calibration data
        stressLevelThresholds;
        datacleaned;
    end
    
    methods (Access = public)
        function SD = StressDetection()
            SD.stressLevelThresholds = zeros(1,5);
        end
        
        % Calculates the thresholds based on a 1xn vector containing the
        % calibration data, where n corresponds to the number of GSR
        % samples in kOhms. 
        % TODO: pass sampling rate as a parameter (256Hz is hardcoded at
        % the moment)
        function SD = trainThresholds(SD, gsrData)
            gsrData = SD.cleanData(gsrData);
            SD.trainThresholdsInternal(gsrData);
        end
        
        % Searches for an appropriate GSR stream in an XDF file and
        % calculates the thresholds.
        function SD = trainThresholdsFromXDF(SD, xdfFilename)
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
        
        % Calculates the stress levels over a period of time based on a 1xn
        % vector containing the GSR samples of the same time period. The
        % trainThresholds method must be executed prior to this method.
        function stress = detectStress(SD,gsr)
            gsr = SD.cleanData(gsr);
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
        
        % Calculates the stress levels in real-time from a GSR LSL stream
        % and outputs the results in a new LSL stream called "Stress
        % Levels". Again the trainThresholds must be executed first before
        % using this method
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
        
    end
    
    methods (Access = private)
        function cleanedData = cleanData(SD,data)
            i=1;
            samplesCleaned = 0;
            while(i<=length(data))
                if(data(i)>10000||data(i)<10)
                    if(i<=10)
                        warning('artifact in beginning of signal using median');
                        data(i) = median(data(data<10000));
%                         if(data(i)<10)
%                             data(i) = 100;
%                         end
                    else
                        data(i) = mean(data(i-10:i-1));
                    end
                    samplesCleaned = samplesCleaned + 1;
                end
                i = i+1;
            end
            cleanedData = data;
            SD.datacleaned = samplesCleaned;
        end
        function SS = computeSS(SD,data)
            F = data';
            %aquisition frequency = 256;
            frequency = 32;
            %convert kÙ to ìS
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
            i
        end
        function SD = trainThresholdsInternal(SD, data)
            %find the most calm 5minute window
            SS = SD.computeSS(data);
            frequency = 32;
            minimum = 100000;
            counter = 0;
            if size(SS,1) > frequency*60*5
                for i = 1:frequency*60*5 : size(SS,1)
                    
                    if (i + frequency*60*5) < size(SS,1)
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
            if(isempty(index))
                l5 = xout(1,300);
            else
                l5 = xout(1,index(1));
            end
            
            
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
    
