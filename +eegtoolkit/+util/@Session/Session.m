% SESSION class
% Session I/O, splitting sessions into trials and applying filters
%
% Usage:
%init a session
%   session = eegtoolkit.util.Session();
%init a session with a filter (created with 'filterbuilder' function)
%   session = eegtoolkit.util.Session(filt);
%load trials for a subject
%   session.loadSubject(subjectid);
%load a specific session
%   session.loadSubjectSession(subjectid,sessionid);
%load everything
%   session.loadAll();
%clear loaded data
%   session.clearData;
%apply a filter that was created with 'filterbuilder'
%   session.applyFilter(filt);
%
%
classdef Session < handle
    
    properties (Constant)
        THRESHOLD_SPLIT_MILLIS = 2000; %Threshold for splitting the trials based on DIN data
    end
    properties (Access = public)
        trials = {}; % Trials of the loaded sessions.
        filt; % Filter to be applied when data is loaded
        sessions; % Filenames of the dataset
        subjectids; % The subject ids corresponding to the loaded trials
        sessionids;
    end
    
    %DATASETS
    %1. SSVEP Dataset I (SINGLE)
    %2. SSVEP Dataset II (MULTI)
    %3. SSVEP Dataset III (EPOC-MULTI)
    %4. SSVEP Dataset SCCN
    %5. ERRP Dataset 
    %6. MI Dataset
    methods (Access = public)
        function S = Session()
            %S = eegtoolkit.util.Session();
            %Constructs a session object
            %
            %S = eegtoolkit.util.Session(filt);
            %Constructs a session object. A filter will applied to all
            %loaded trials
            %Dataset I
            S.sessions{1,1,1} = 'S001a';
            S.sessions{1,1,2} = 'S001b';
            S.sessions{1,1,3} = 'S001c';
            S.sessions{1,2,1} = 'S002a';
            S.sessions{1,2,2} = 'S002b';
            S.sessions{1,2,3} = 'S002c';
            S.sessions{1,2,4} = 'S002d';
            S.sessions{1,2,5} = 'S002e';
            S.sessions{1,3,1} = 'S003a';
            S.sessions{1,3,2} = 'S003b';
            S.sessions{1,3,3} = 'S003c';
            S.sessions{1,4,1} = 'S004a';
            S.sessions{1,4,2} = 'S004b';
            S.sessions{1,4,3} = 'S004c';
            S.sessions{1,4,4} = 'S004d';
            S.sessions{1,5,1} = 'S005a';
            S.sessions{1,5,2} = 'S005b';
            S.sessions{1,5,3} = 'S005c';
            S.sessions{1,5,4} = 'S005d';
            S.sessions{1,5,5} = 'S005e';
            S.sessions{1,6,1} = 'S006a';
            S.sessions{1,6,2} = 'S006b';
            S.sessions{1,6,3} = 'S006c';
            S.sessions{1,6,4} = 'S006d';
            S.sessions{1,6,5} = 'S006e';
            S.sessions{1,7,1} = 'S007a';
            S.sessions{1,7,2} = 'S007b';
            S.sessions{1,7,3} = 'S007c';
            S.sessions{1,7,4} = 'S007d';
            S.sessions{1,7,5} = 'S007e';
            S.sessions{1,8,1} = 'S008a';
            S.sessions{1,8,2} = 'S008b';
            S.sessions{1,8,3} = 'S008c';
            S.sessions{1,9,1} = 'S009a';
            S.sessions{1,9,2} = 'S009b';
            S.sessions{1,9,3} = 'S009c';
            S.sessions{1,9,4} = 'S009d';
            S.sessions{1,9,5} = 'S009e';
            S.sessions{1,10,1} = 'S010a';
            S.sessions{1,10,2} = 'S010b';
            S.sessions{1,10,3} = 'S010c';
            S.sessions{1,10,4} = 'S010d';
            S.sessions{1,10,5} = 'S010e';
            S.sessions{1,11,1} = 'S013a';
            S.sessions{1,11,2} = 'S013b';
            S.sessions{1,11,3} = 'S013c';
            S.sessions{1,11,4} = 'S013d';
            S.sessions{1,11,5} = 'S013e';
            
            %Dataset II
            S.sessions{2,1,1} = 'T001a';
            S.sessions{2,1,2} = 'T001b';
            S.sessions{2,1,3} = 'T001c';
            S.sessions{2,1,4} = 'T001d';
            S.sessions{2,1,5} = 'T001e';
            S.sessions{2,2,1} = 'T002a';
            S.sessions{2,2,2} = 'T002b';
            S.sessions{2,2,3} = 'T002c';
            S.sessions{2,2,4} = 'T002d';
            S.sessions{2,2,5} = 'T002e';
            S.sessions{2,3,1} = 'T003a';
            S.sessions{2,3,2} = 'T003b';
            S.sessions{2,3,3} = 'T003c';
            S.sessions{2,3,4} = 'T003d';
            S.sessions{2,3,5} = 'T003e';
            S.sessions{2,4,1} = 'T004a';
            S.sessions{2,4,2} = 'T004b';
            S.sessions{2,4,3} = 'T004c';
            S.sessions{2,4,4} = 'T004d';
            S.sessions{2,4,5} = 'T004e';
            S.sessions{2,5,1} = 'T005a';
            S.sessions{2,5,2} = 'T005b';
            S.sessions{2,5,3} = 'T005c';
            S.sessions{2,5,4} = 'T005d';
            S.sessions{2,5,5} = 'T005e';
            S.sessions{2,6,1} = 'T006a';
            S.sessions{2,6,2} = 'T006b';
            S.sessions{2,6,3} = 'T006c';
            S.sessions{2,6,4} = 'T006d';
            S.sessions{2,6,5} = 'T006e';
            S.sessions{2,7,1} = 'T007a';
            S.sessions{2,7,2} = 'T007b';
            S.sessions{2,7,3} = 'T007c';
            S.sessions{2,7,4} = 'T007d';
            S.sessions{2,7,5} = 'T007e';
            S.sessions{2,8,1} = 'T008a';
            S.sessions{2,8,2} = 'T008b';
            S.sessions{2,8,3} = 'T008c';
            S.sessions{2,8,4} = 'T008d';
            S.sessions{2,8,5} = 'T008e';
            S.sessions{2,9,1} = 'T009a';
            S.sessions{2,9,2} = 'T009b';
            S.sessions{2,9,3} = 'T009c';
            S.sessions{2,9,4} = 'T009d';
            S.sessions{2,9,5} = 'T009e';
            S.sessions{2,10,1} = 'T010a';
            S.sessions{2,10,2} = 'T010b';
            S.sessions{2,10,3} = 'T010c';
            S.sessions{2,10,4} = 'T010d';
            S.sessions{2,10,5} = 'T010e';
            S.sessions{2,11,1} = 'T013a';
            S.sessions{2,11,2} = 'T013b';
            S.sessions{2,11,3} = 'T013c';
            S.sessions{2,11,4} = 'T013d';
            S.sessions{2,11,5} = 'T013e';
            
            %Dataset III (Epoc)
            S.sessions{3,1,1} = 'U001a';
            S.sessions{3,1,2} = 'U001b';
            S.sessions{3,1,3} = 'U001c';
            S.sessions{3,1,4} = 'U001d';
            S.sessions{3,1,5} = 'U001e';
            S.sessions{3,2,1} = 'U002a';
            S.sessions{3,2,2} = 'U002b';
            S.sessions{3,2,3} = 'U002c';
            S.sessions{3,2,4} = 'U002d';
            S.sessions{3,2,5} = 'U002e';
            S.sessions{3,3,1} = 'U003a';
            S.sessions{3,3,2} = 'U003b';
            S.sessions{3,3,3} = 'U003c';
            S.sessions{3,3,4} = 'U003d';
            S.sessions{3,3,5} = 'U003e';
            S.sessions{3,4,1} = 'U004a';
            S.sessions{3,4,2} = 'U004b';
            S.sessions{3,4,3} = 'U004c';
            S.sessions{3,4,4} = 'U004d';
            S.sessions{3,4,5} = 'U004e';
            S.sessions{3,5,1} = 'U005a';
            S.sessions{3,5,2} = 'U005b';
            S.sessions{3,5,3} = 'U005c';
            S.sessions{3,5,4} = 'U005d';
            S.sessions{3,5,5} = 'U005e';
            S.sessions{3,6,1} = 'U006a';
            S.sessions{3,6,2} = 'U006b';
            S.sessions{3,6,3} = 'U006c';
            S.sessions{3,6,4} = 'U006d';
            S.sessions{3,6,5} = 'U006e';
            S.sessions{3,7,1} = 'U007a';
            S.sessions{3,7,2} = 'U007b';
            S.sessions{3,7,3} = 'U007c';
            S.sessions{3,7,4} = 'U007d';
            S.sessions{3,7,5} = 'U007e';
            S.sessions{3,8,1} = 'U008a';
            S.sessions{3,8,2} = 'U008b';
            S.sessions{3,8,3} = 'U008c';
            S.sessions{3,8,4} = 'U008d';
            S.sessions{3,8,5} = 'U008e';
            S.sessions{3,9,1} = 'U009a';
            S.sessions{3,9,2} = 'U009b';
            S.sessions{3,9,3} = 'U009c';
            S.sessions{3,9,4} = 'U009d';
            S.sessions{3,9,5} = 'U009e';
            S.sessions{3,10,1} = 'U010a';
            S.sessions{3,10,2} = 'U010b';
            S.sessions{3,10,3} = 'U010c';
            S.sessions{3,10,4} = 'U010d';
            S.sessions{3,10,5} = 'U010e';
            S.sessions{3,11,1} = 'U011a';
            S.sessions{3,11,2} = 'U011b';
            S.sessions{3,11,3} = 'U011c';
            S.sessions{3,11,4} = 'U011d';
            S.sessions{3,11,5} = 'U011e';
       
            %SCCN dataset
            S.sessions{4,1,1} = 's1';
            S.sessions{4,2,1} = 's2';
            S.sessions{4,3,1} = 's3';
            S.sessions{4,4,1} = 's4';
            S.sessions{4,5,1} = 's5';
            S.sessions{4,6,1} = 's6';
            S.sessions{4,7,1} = 's7';
            S.sessions{4,8,1} = 's8';
            S.sessions{4,9,1} = 's9';
            S.sessions{4,10,1} = 's10';
            
            %ERRP dataset
            S.sessions{5,1,1} = 'EEG_s1.mat';
            S.sessions{5,2,1} = 'EEG_s2.mat';
            S.sessions{5,3,1} = 'EEG_s3.mat';
            S.sessions{5,4,1} = 'EEG_s4.mat';
            S.sessions{5,5,1} = 'EEG_s5.mat';
            S.sessions{5,6,1} = 'EEG_s6.mat';
            S.sessions{5,7,1} = 'EEG_s7.mat';
            S.sessions{5,8,1} = 'EEG_s8.mat';
            
            S.sessions{6,1,1} = 'dataset_BCIcomp1.mat';
            
            %MI dataset
%             S.sessions{6,1,1} = ;
            
            
            S.subjectids = [];
            S.sessionids = [];
        end
        function S = loadAll(S,experiment)
            %loads everything
            [~,l,~] = size(S.sessions);
            h = waitbar(0,'Loading...');
            for i=1:l
                waitbar(i/l,h,'Loading...');
                S.loadSubject(experiment,i);
            end
            close(h);
        end
        
        function S = loadSubject(S,experiment,subject)
            %loads all trials for a specific subject
            %
            %Example:
            %   session.loadSubject(1);
            %loads all the trials of the 1st subject
            [~,~, y] = size(S.sessions);
            for i=1:y
                if ~isempty(S.sessions{experiment,subject,i})
                    S.loadSubjectSession(experiment,subject,i);
                end
            end
        end
        function S = loadSubjectSession(S,experiment,subject,session)
            %loads all trials for a specific session
            %
            %Example:
            %   session.loadSubjectSession(1,2);
            %loads the 2nd session of the 1st subject
            %
            switch(experiment)
                case 1
                    %Load Dataset I (SINGLE)
                    load(S.sessions{experiment,subject,session});
                    signal = eval('eeg');
                    numTrials = length(S.trials) + 1;
                    curTrials = S.split(signal,DIN_1,subject,session);
                    for i=1:length(curTrials)
                        S.trials{numTrials} = curTrials{i};
                        numTrials = numTrials + 1;
                    end
                case 2
                    %Load Dataset II (MULTI)
                    load(S.sessions{experiment,subject,session});
                    signal = eval('eeg');
                    numTrials = length(S.trials) + 1;
                    curTrials = S.split(signal,DIN_1,subject,session,labels);
                    for i=1:length(curTrials)
                        S.trials{numTrials} = curTrials{i};
                        numTrials = numTrials + 1;
                    end
                case 3
                    %Dataset III (EPOC-MULTI)
                    SAMPLING_RATE = 128;
                    load(strcat(S.sessions{experiment,subject,session},'i'));
                    events = eval('events');
                    marks = events(events(:,2)==32779,3);
                    stops = events(events(:,2)==32780,3);
                    numTrials = length(S.trials) + 1;
                    labels = {4,2,3,5,1,2,5,4,2,3,1,5};
                    for i=1:length(marks)
                        signal = eeg(:,marks(i):stops(i) -1);
                        label = labels{i};
                        S.trials{numTrials} = eegtoolkit.util.Trial(signal,label,SAMPLING_RATE,subject,session,eegtoolkit.util.Trial.SSVEP);
                        numTrials = numTrials + 1;
                        S.subjectids = [S.subjectids subject];
                        S.sessionids = [S.sessionids session];
                    end
                    %load part 2
                    load(strcat(S.sessions{experiment,subject,session},'ii'));
                    events = eval('events');
                    marks = events(events(:,2)==32779,3);
                    stops = events(events(:,2)==32780,3);
                    numTrials = length(S.trials) + 1;
                    labels = {4,3,2,4,1,2,5,3,4,1,3,1,3};
                    for i=1:length(marks)
                        signal = eeg(:,marks(i):stops(i) -1);
                        label = labels{i};
                        S.trials{numTrials} = eegtoolkit.util.Trial(signal,label,SAMPLING_RATE,subject,session,eegtoolkit.util.Trial.SSVEP);
                        numTrials = numTrials + 1;
                        S.subjectids = [S.subjectids subject];
                        S.sessionids = [S.sessionids session];
                    end
                case 4
                    %SCCN Dataset
                    SAMPLING_RATE = 256;
                    load(S.sessions{experiment,subject,session});
                    [x,y,z,zz] = size(eeg);
                    numTrials = length(S.trials) + 1;
                    for i=1:x
                        for j=1:zz
                            S.trials{numTrials} = eegtoolkit.util.Trial(squeeze(eeg(i,:,:,j)),i,SAMPLING_RATE,subject,j);
                            numTrials = numTrials+1;
                            S.subjectids = [S.subjectids subject];
                            S.sessionids = [S.sessionids j];
                        end
                    end
                case 5
                    %ERRP Dataset
                    SAMPLING_RATE = 256;                    
                    %range of trial in milliseconds based on the stimulus
                    %event
                    range = [200,800];
                    xstart = round(range(1)*SAMPLING_RATE/1000)-1500;
                    xend = round(range(2)*SAMPLING_RATE/1000);
                    load(S.sessions{experiment,subject,session});
                    events = {'correct_movement', 'error_movement'};
                    numTrials = length(S.trials) + 1;
                    for ev=1:length(events)
                        idxev = find(strcmp(EEG.events.name, events{ev}));
                        epochs.(events{ev}) = zeros(length(xstart:xend), size(EEG.signal,2), length(idxev));
                        for i=1:length(idxev)
                            epochs.(events{ev})(:,:,i) = EEG.signal(EEG.events.position(idxev(i))+xstart:EEG.events.position(idxev(i))+xend,:);
                        end
                        GrandAverages.(events{ev}) = mean(epochs.(events{ev}),3);
                    end
                    [~,~,numCorrect] = size(epochs.correct_movement);
                    [~,~,numError] = size(epochs.error_movement);
                    for i=1:numCorrect
                        S.trials{numTrials} = eegtoolkit.util.Trial(squeeze(epochs.correct_movement(:,:,i))',1,SAMPLING_RATE,subject,session,eegtoolkit.util.Trial.ERRP);
                        numTrials = numTrials + 1;
                        S.subjectids = [S.subjectids subject];
                        S.sessionids = [S.sessionids session];
                        
                    end
                    for i=1:numError
                        S.trials{numTrials} = eegtoolkit.util.Trial(squeeze(epochs.error_movement(:,:,i))',2,SAMPLING_RATE,subject,session,eegtoolkit.util.Trial.ERRP);
                        numTrials = numTrials + 1;
                        S.subjectids = [S.subjectids subject];
                        S.sessionids = [S.sessionids session];
                    end
                case 6
                    load(S.sessions{experiment,subject,session});
                    [~,~,n] = size(x_train);
                    numTrials = length(S.trials) + 1;
                    for i=1:n
                        signal = squeeze(x_train(:,:,i));
                        label = y_train(i);
                        S.trials{numTrials} = eegtoolkit.util.Trial(signal',label,128,1,1,eegtoolkit.util.Trial.MI);
                        S.subjectids = [S.subjectids subject];
                        S.sessionids = [S.sessionids session];
                        numTrials = numTrials + 1;
                    end
                otherwise
                    error('invalid experiment id');
            end
        end
        
        function S = clearData(S)
            %clears loaded data
            S.trials = {};
            S.subjectids = [];
            S.sessionids = [];
        end
    end
    
    methods (Access = private)
        function trials = split(S, signal, dins, subjectid, session,labels)
            SAMPLING_RATE = 250;
            timestamps = cell2mat(dins(2,:));
            samples = cell2mat(dins(4,:));
            [a numDins ]= size(dins);
            sampleA= samples(1);
            timeA = timestamps(1);
            previous = timestamps(1);
            ranges = [];
            freqs = [];
            times = [];
            sum = 0;
            count = 0;
            i=2;
            for i=2:numDins
                current = timestamps(i);
                if(current - previous) > S.THRESHOLD_SPLIT_MILLIS;
                    sampleB = samples(i-1);
                    timeB = timestamps(i-1);
                    freqs = [freqs; (sum/count)];
                    % don't ask why
                    if(sampleB - sampleA>382)
                        ranges = [ranges ; [sampleA (sampleA+1249)]];
                        times = [times; [timeA timeB]];
                    end
                    sampleA = samples(i);
                    timeA = timestamps(i);
                    sum = 0;
                    count = 0;
                else
                    sum = sum + (current-previous);
                    count = count +1;
                end
                previous = timestamps(i);
            end
            %             if(isempty(labels))
            sampleB = samples(i-1);
            timeB = timestamps(i-1);
            freqs = [freqs; (sum/count)];
            ranges = [ranges; [sampleA sampleA+1249]];
            times = [times; [timeA timeB]];
            freqs = freqs*2;
            freqs = 1000./freqs;
            %             end
            [numSplits a] = size(ranges);
            trials = {};
            i = 1;
            for i=1:numSplits
                if(nargin>5)
                    trials{i} = eegtoolkit.util.Trial(signal(:, ranges(i,1):ranges(i,2)), labels{i},SAMPLING_RATE, subjectid,session,eegtoolkit.util.Trial.SSVEP);
                    S.subjectids = [S.subjectids subjectid];
                    S.sessionids = [S.sessionids session];
                else
                    trials{i} = eegtoolkit.util.Trial(signal(:,ranges(i,1):ranges(i,2)), freqs(i), SAMPLING_RATE, subjectid,session,eegtoolkit.util.Trial.SSVEP);
                    S.subjectids = [S.subjectids subjectid];
                    S.sessionids = [S.sessionids session];
                end
            end
        end
        
        
    end
end

