% SESSION class
% Session I/O, splitting sessions into trials and applying filters
% 
% Usage: 
%init a session
%   session = Session();
%load trials for a subject
%   session.loadSubject(Session.ANASTASIA);
%load a specific session
%   session.loadSubjectSession(Session.ANASTASIA_1);
%load everything
%   session.loadAll();
%load all except 1 subject
%   session.loadAllExceptSubject(Session.ANASTASIA);
%clear loaded data
%   session.clearData;
%apply a filter that was created with 'filterbuilder' (e.g. filtMAMEM.mat)
%   session.applyFilter(filt);
%pass the trials to a Transformer class
%   pwt = PWelchTransformer(session.trials)
%   
% 
classdef Session < handle
    
    properties (Constant)
        SAMPLING_RATE = 250; %Sampling Rate of the sessions
        THRESHOLD_SPLIT_MILLIS = 2000; %Threshold for splitting the trials based on DIN data
        ANASTASIA_1 = 'Anastasia 20151019 1227'; %Anastasia session 1 filename
        ANASTASIA_2 = 'Anastasia 20151019 1244';
        ANASTASIA_3 = 'Anastasia 20151019 1254';
        ANASTASIA_4 = 'Anastasia 20151019 1306';
        ANASTASIA_5 = 'Anastasia 20151019 1317';
        ANASTASIA = [Session.ANASTASIA_1;Session.ANASTASIA_2;Session.ANASTASIA_3;Session.ANASTASIA_4;Session.ANASTASIA_5]; % All sessions of Anastasia
        DIMITRIS_1 = 'Dimitris 20151020 1226';
        DIMITRIS_2 = 'Dimitris 20151020 1252';
        DIMITRIS_3 = 'Dimitris 20151020 1304';
        DIMITRIS_4 = 'Dimitris 20151020 1317';
        DIMITRIS_5 = 'Dimitris 20151020 1329';
        DIMITRIS = [Session.DIMITRIS_1;Session.DIMITRIS_2;Session.DIMITRIS_3;Session.DIMITRIS_4;Session.DIMITRIS_5];
        ELISAVET_1 = 'Elisavet 20151019 1651';
        ELISAVET_2 = 'Elisavet 20151019 1711';
        ELISAVET_3 = 'Elisavet 20151019 1723';
        ELISAVET = [Session.ELISAVET_1;Session.ELISAVET_2;Session.ELISAVET_3];
        GIWRGOS_1 = 'Giwrgos 20151021 1605';
        GIWRGOS_2 = 'Giwrgos 20151021 1638';
        GIWRGOS_3 = 'Giwrgos 20151021 1649';
        GIWRGOS_4 = 'Giwrgos 20151021 1703';
        GIWRGOS_5 = 'Giwrgos 20151021 1726';
        GIWRGOS = [Session.GIWRGOS_1;Session.GIWRGOS_2;Session.GIWRGOS_3;Session.GIWRGOS_4;Session.GIWRGOS_5];
        GEORGE_1 = 'George 20151013 1625';
        GEORGE_2 = 'George 20151013 1634';
        GEORGE_3 = 'George 20151013 1644';
        GEORGE = [Session.GEORGE_1;Session.GEORGE_2;Session.GEORGE_3];
        KATERINA_1 = 'Katerina 20151019 1028';
        KATERINA_2 = 'Katerina 20151019 1114';
        KATERINA_3 = 'Katerina 20151019 1128';
        KATERINA_4 = 'Katerina 20151019 1140';
        KATERINA_5 = 'Katerina 20151019 1153';
        KATERINA = [Session.KATERINA_1;Session.KATERINA_2;Session.KATERINA_3;Session.KATERINA_4;Session.KATERINA_5];
        KOSTAS_1 = 'Kostas 20151022 1559';
        KOSTAS_2 = 'Kostas 20151022 1624';
        KOSTAS_3 = 'Kostas 20151022 1636';
        KOSTAS_4 = 'Kostas 20151022 1657';
        KOSTAS_5 = 'Kostas 20151022 1707';
        KOSTAS = [Session.KOSTAS_1;Session.KOSTAS_2;Session.KOSTAS_3;Session.KOSTAS_4;Session.KOSTAS_5];
        SPIROS_1 = 'spiros 20151016 1028';
        SPIROS_2 = 'Spiros 20151016 1055';
        SPIROS_3 = 'spiros 20151016 1113';
        SPIROS_4 = 'spiros 20151016 1128';
        SPIROS_5 = 'Spiros 20151016 1146';
        SPIROS = [Session.SPIROS_1;Session.SPIROS_2;Session.SPIROS_3;Session.SPIROS_4;Session.SPIROS_5];
        STATHIS_1 = 'Stathis 20151020 1022';
        STATHIS_2 = 'Stathis 20151020 1052';
        STATHIS_3 = 'Stathis 20151020 1108';
        STATHIS_4 = 'Stathis 20151020 1132';
        STATHIS_5 = 'Stathis 20151020 1149';
        STATHIS = [Session.STATHIS_1;Session.STATHIS_2;Session.STATHIS_3;Session.STATHIS_4;Session.STATHIS_5];
        SWTIRIS_1 = 'Swtiris 20151019 1417';
        SWTIRIS_2 = 'Swtiris 20151019 1440';
        SWTIRIS_3 = 'Swtiris 20151019 1456';
        SWTIRIS_4 = 'Swtiris 20151019 1509';
        SWTIRIS_5 = 'Swtiris 20151019 1521';
        SWTIRIS = [Session.SWTIRIS_1;Session.SWTIRIS_2;Session.SWTIRIS_3;Session.SWTIRIS_4;Session.SWTIRIS_5];
        TASOSMA_1 = 'TasosMa 20151016 1630';
        TASOSMA_2 = 'TasosMa 20151016 1704';
        TASOSMA_3 = 'TasosMa 20151016 1716';
        TASOSMA_4 = 'TasosMa 20151016 1728';
        TASOSMA = [Session.TASOSMA_1;Session.TASOSMA_2;Session.TASOSMA_3;Session.TASOSMA_4];
        THODORIS_1 = 'Thodoris 20151021 1338';
        THODORIS_2 = 'Thodoris 20151021 1401';
        THODORIS_3 = 'Thodoris 20151021 1415';
        THODORIS_4 = 'Thodoris 20151021 1454';
        THODORIS_5 = 'Thodoris 20151021 1505';
        THODORIS = [Session.THODORIS_1;Session.THODORIS_2;Session.THODORIS_3;Session.THODORIS_4;Session.THODORIS_5];
        VANGELIS_1 = 'Vangelis 20151016 1228';
        VANGELIS_2 = 'Vangelis 20151016 1259';
        VANGELIS_3 = 'Vangelis 20151016 1318';
        VANGELIS = [Session.VANGELIS_1;Session.VANGELIS_2;Session.VANGELIS_3];
        ALL = {Session.ANASTASIA, Session.DIMITRIS, Session.ELISAVET, Session.GIWRGOS, Session.GEORGE, Session.KATERINA, Session.KOSTAS, Session.SPIROS, Session.STATHIS, Session.SWTIRIS, Session.TASOSMA, Session.THODORIS, Session.VANGELIS}; %All sessions
        
    end
    properties (Access = public)
        trials = {}; % Trials of the loaded sessions.
        filt; % Filter to be applied when data is loaded
    end
    
    properties (Access = private)
        rest;
    end
    
    methods (Access = public)
        function S = Session(filt, rest)
            %S = Session();
            %Constructs a session object
            %
            %S = Session(rest);
            %(Experimental) includes trials for resting with duration =
            %rest number of samples
            %
            %Example: 
            %    S = Session(1000);
            %For each trial an additional trial with duration 4 seconds
            %before each trial is included
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
        end
       
        function S = loadSubjectSession(S,sessioname)
            %loads all trials for a specific session
            %
            %Example:
            %   session.loadSubjectSession(Session.ANASTASIA_1);
            %
            %loads the first session of Anastasia
            load(sessioname);
            varname = strrep(sessioname, ' ', '_');
            signal = eval(varname);
            curTrials = S.split(signal, DIN_1);
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
            %   session.loadSubject(Session.ANASTASIA);
            %loads all the trials of Anastasia 
            
            [x, ~] = size(subject);
            for i=1:x
                S.loadSubjectSession(subject(i,:));
            end
        end
        function S = loadAll(S)
            %loads everything
            %(Careful for memory issues)
            l = length(Session.ALL);
            h = waitbar(0,'Loading...');
            for i=1:length(Session.ALL)
                waitbar(i/l,h,'Loading...');
                S.loadSubject(Session.ALL{i});
            end
            close(h);
        end
        function S = loadAllExceptSubject(S, subject)
            %loads all trials except the trials of a specific subject
            %(useful for leave-one-subject-out training
            %
            %Example:
            %   session.loadAllExceptSubject(Session.DIMITRIS);
            %loads all sessions except the trials of Dimitris
            %(Careful for memory issues)
            h = waitbar(0,'Loading...');
            for i=1:length(Session.ALL)
                waitbar(i/length(Session.ALL),h,'Loading...');
                if(isequal(Session.ALL{i},subject))
                    continue;
                end
                S.loadSubject(Session.ALL{i});
            end
            close(h);
        end     
        function S = clearData(S)
            %clears loaded data
            S.trials = {};
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
        function trials = split(S, signal, dins)
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
                trials{i} = Trial(signal(:, ranges(i,1):ranges(i,2)), freqs(i), S.SAMPLING_RATE);
            end
            i = i +1;
            if(S.rest > 0)
                for i=i:(numSplits*2)
                    trials{i} = Trial(signal(:,ranges(i-numSplits,1)-S.rest:ranges(i-numSplits,1)), -1, S.SAMPLING_RATE);
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
    

