% SESSION class
% Session I/O, splitting sessions into trials and applying filters
% 
% Usage: 
%init a session
%   session = ssveptoolkit.util.Session();
%init a session with a filter (created with 'filterbuilder' function)
%   session = ssveptoolkit.util.Session(filt);
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
        SAMPLING_RATE = 250; %Sampling Rate of the sessions
        THRESHOLD_SPLIT_MILLIS = 2000; %Threshold for splitting the trials based on DIN data
    end
    properties (Access = public)
        trials = {}; % Trials of the loaded sessions.
        filt; % Filter to be applied when data is loaded
        sessions; % Filenames of the dataset
        subjectids; % The subject ids corresponding to the loaded trials
        skipSamples; % Number of samples to skip, at the beginning of each Trial
    end
    
    properties (Access = private)
        rest; % Experimental
    end
    
    methods (Access = public)
        function S = Session(filt, rest)
            %S = ssveptoolkit.util.Session();
            %Constructs a session object
            %
            %S = ssveptoolkit.util.Session(filt);
            %Constructs a session object. A filter will applied to all
            %loaded trials
            if(nargin==1)
                S.filt = filt;
                S.rest = 0;
            elseif nargin == 2
                S.filt = filt;
                S.rest = rest;
            else
                S.rest = 0;
                S.filt = 0;
            end
            S.sessions{1,1} = 'S001a';
            S.sessions{1,2} = 'S001b';
            S.sessions{1,3} = 'S001c';
            S.sessions{2,1} = 'S002a';
            S.sessions{2,2} = 'S002b';
            S.sessions{2,3} = 'S002c';
            S.sessions{2,4} = 'S002d';
            S.sessions{2,5} = 'S002e';
            S.sessions{3,1} = 'S003a';
            S.sessions{3,2} = 'S003b';
            S.sessions{3,3} = 'S003c';
            S.sessions{4,1} = 'S004a';
            S.sessions{4,2} = 'S004b';
            S.sessions{4,3} = 'S004c';
            S.sessions{4,4} = 'S004d';
            S.sessions{5,1} = 'S005a';
            S.sessions{5,2} = 'S005b';
            S.sessions{5,3} = 'S005c';
            S.sessions{5,4} = 'S005d';
            S.sessions{5,5} = 'S005e';
            S.sessions{6,1} = 'S006a';
            S.sessions{6,2} = 'S006b';
            S.sessions{6,3} = 'S006c';
            S.sessions{6,4} = 'S006d';
            S.sessions{6,5} = 'S006e';
            S.sessions{7,1} = 'S007a';
            S.sessions{7,2} = 'S007b';
            S.sessions{7,3} = 'S007c';
            S.sessions{7,4} = 'S007d';
            S.sessions{7,5} = 'S007e';
            S.sessions{8,1} = 'S008a';
            S.sessions{8,2} = 'S008b';
            S.sessions{8,3} = 'S008c';
            S.sessions{9,1} = 'S009a';
            S.sessions{9,2} = 'S009b';
            S.sessions{9,3} = 'S009c';
            S.sessions{9,4} = 'S009d';
            S.sessions{9,5} = 'S009e';
            S.sessions{10,1} = 'S010a';
            S.sessions{10,2} = 'S010b';
            S.sessions{10,3} = 'S010c';
            S.sessions{10,4} = 'S010d';
            S.sessions{10,5} = 'S010e';
%             S.sessions{11,1} = 'S011a';
%             S.sessions{11,2} = 'S011b';
%             S.sessions{11,3} = 'S011c';
%             S.sessions{11,4} = 'S011d';
%             S.sessions{11,5} = 'S011e';
%             S.sessions{12,1} = 'S012a';
%             S.sessions{12,2} = 'S012b';
%             S.sessions{12,3} = 'S012c';
%             S.sessions{12,4} = 'S012d';
%             S.sessions{12,5} = 'S012e';
            S.sessions{11,1} = 'S013a';
            S.sessions{11,2} = 'S013b';
            S.sessions{11,3} = 'S013c';
            S.sessions{11,4} = 'S013d';
            S.sessions{11,5} = 'S013e';
            S.skipSamples = 0;
            S.subjectids = [];
        end
       
        function S = loadSubjectSession(S,subject,session)
            %loads all trials for a specific session
            %
            %Example:
            %   session.loadSubjectSession(1,2);
            %loads the 2nd session of the 1st subject
            %
            load(S.sessions{subject,session});
            signal = eval('eeg');
            curTrials = S.split(signal, DIN_1,subject);
            numTrials = length(S.trials) + 1;
            for i=1:length(curTrials)
                S.trials{numTrials} = curTrials{i};
                numTrials = numTrials + 1;
            end
        end
        function S = loadSubject(S,subject)
            %loads all trials for a specific subject
            %
            %Example: 
            %   session.loadSubject(1);
            %loads all the trials of the 1st subject
            [~, y] = size(S.sessions);
            for i=1:y
                if ~isempty(S.sessions{subject,i})
                    S.loadSubjectSession(subject,i);
                end
            end
        end
        function S = loadAll(S)
            %loads everything
            [l,~] = size(S.sessions);
            h = waitbar(0,'Loading...');
            for i=1:l
                waitbar(i/l,h,'Loading...');
                S.loadSubject(i);
            end
            close(h);
        end
        
        function S = clearData(S)
            %clears loaded data
            S.trials = {};
            S.subjectids = [];
        end
        
        function applyFilter(S, filt)
            %apply a filter to the loaded data 
            %supports filter type that was build using 'filterbuilder'
            h = waitbar(0,'Applying filter..');
            for i=1:length(S.trials)
                waitbar(i/length(S.trials),h,'Applying filter..');
                [numchan,~] = size(S.trials{i}.signal)
                for j=1:numchan
                    S.trials{i}.signal(j,:) = filter(filt,S.trials{i}.signal(j,:));
                end
            end
            close(h);
        end
        
    end
    
    methods (Access = private)
        function trials = split(S, signal, dins, subjectid)
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
                    ranges = [ranges ; [sampleA (sampleA+1249)]];
                    times = [times; [timeA timeB]];
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
            sampleB = samples(i-1);
            timeB = timestamps(i-1);
            freqs = [freqs; (sum/count)];
            ranges = [ranges; [sampleA sampleA+1249]];
            times = [times; [timeA timeB]];
            freqs = freqs*2;
            freqs = 1000./freqs;
            [numSplits a] = size(ranges);
            trials = {};
            i = 1;
            for i=1:numSplits
                trials{i} = ssveptoolkit.util.Trial(signal(:, (ranges(i,1)+S.skipSamples):ranges(i,2)), freqs(i), S.SAMPLING_RATE, subjectid);
                S.subjectids = [S.subjectids subjectid];
            end
            i = i +1;
            if(S.rest > 0)
                for i=i:(numSplits*2)
                    trials{i} = ssveptoolkit.util.Trial(signal(:,ranges(i-numSplits,1)-S.rest:ranges(i-numSplits,1)), -1, S.SAMPLING_RATE, subjectid);
                    S.subjectids = [S.subjectids subjectid];
                end
            end
            %filter the trials (if a filter is set)
            if ~(S.filt==0)
                for i=1:length(trials)
                    [numchan, ~] = size(trials{i}.signal);
                    for j=1:numchan
                        trials{i}.signal(j,:) = filter(S.filt,trials{i}.signal(j,:));
                    end
                end
            end
        end
        

    end
end
    

