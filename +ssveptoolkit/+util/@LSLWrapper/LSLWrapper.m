classdef LSLWrapper < handle
    %LSLWRAPPER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        lib;
        datastreaminfo;
        datainlet;
        dataoutlet;
        eventstreaminfo;
        eventinlet;
        eventoutlet;
        preprocessing;
        featextraction;
        results;
        trials;
        classification; %pre-trained object required
    end
    
    properties (Access = private)
        streamsOK;
        samplingRate;
    end
    
    methods
        function LSL = LSLWrapper()
            LSL.lib = lsl_loadlib;
            LSL.streamsOK = 0;
        end
        
        function LSL = resolveStreams(LSL,datastream,maxbuffer,eventstream)
            LSL.datastreaminfo = lsl_resolve_byprop(LSL.lib, 'name', datastream);
            LSL.eventstreaminfo = lsl_resolve_byprop(LSL.lib, 'name', eventstream);
            %get samplingRate from stream info
            %samplingRate = ?
            if(length(LSL.datastreaminfo) > 0)
                LSL.datainlet = lsl_inlet(LSL.datastreaminfo{1},maxbuffer);
                LSL.datainlet.pull_chunk;
            else
                error('Cannot resolve data stream');
            end
            if(length(LSL.eventstreaminfo) > 0)
                LSL.eventinlet = lsl_inlet(LSL.eventstreaminfo{1},1);
            else
                error('Cannot resolve event stream');
            end
            eventoutletInfo = lsl_streaminfo(LSL.lib,'CommandStream','Markers',1,0,'cf_int32','myuniquesourceid23442');
            LSL.eventoutlet = lsl_outlet(eventoutletInfo);
            LSL.samplingRate = LSL.datastreaminfo{1}.nominal_srate;
            LSL.streamsOK = 1;
        end
        function LSL = runExperiment(LSL)
            if(LSL.streamsOK ~=1)
                error('error: Did you call \"resolveStreams\"?');
            end
            strings = {'abstract','concept','objectives','structure','consortium'};
            labels = {4,2,3,5,1,2,5,4,2,3,1,5,4,3,2,4,1,2,5,3,4,1,3,1,3};
            [12 6.66 7.5 8.57 10];
            8.57,6.66,7.5,10,12
            %structure,concept,objectives,consortiu,abstract
            LSL.trials = {};
            [y,Fs] = audioread('beep-07.wav');
            tts('get ready');
            pause(10);
            for i=1:length(labels)
                tts(strings{labels{i}});
                pause(1);
                sound(y,Fs);
                pause(5);
                
                chunk = LSL.datainlet.pull_chunk;
                trial = ssveptoolkit.util.Trial(chunk,0,LSL.samplingRate,0,0);
                LSL.trials{length(LSL.trials)+1} = trial;
                tts('ok');
                pause(4);
            end
        end
        %EBNeuro_BePLusLTM_192.168.171.81
        function LSL = visualizeDataStream(LSL,windowlength,datastreamname,channel)
            %             import java.util.Qu
            LSL.datastreaminfo = lsl_resolve_byprop(LSL.lib, 'name', datastreamname);
            LSL.datainlet = lsl_inlet(LSL.datastreaminfo{1},windowlength/LSL.datastreaminfo{1}.nominal_srate);
            %             LSL.eventstreaminfo = lsl_resolve_byprop(LSL.lib,'name',eventstreamname);
            
            %             buffer = ssveptoolkit.util.CQueue(windowlength);
            % %             buffer.capacity = windowlength;
            buffer = zeros(1,windowlength);
            timestampBuffer = zeros(1,windowlength);
            eventBuffer = zeros(1,windowlength);
            indices = 1:windowlength;
            t = 0 ;
            x = 0 ;
            startSpot = 0;
            %             interv = windowlength; % considering 1000 samples
            step = 0.1 ; % lowering step has a number of cycles and then acquire more data
            k =1;
            firstTimestamp = [];
            while ( 1 )
                %                 sample = LSL.datainlet.pull_sample;
                [samples,timestamps] = LSL.datainlet.pull_chunk;
                if isempty(firstTimestamp)
                    firstTimestamp = timestamps;
                end
                [~,numPulled] = size(samples);
                if(numPulled==0)
                    continue;
                end
                %                 buffer.push(sample(1));
                %                 buffermat = cell2mat(buffer.content);
                buffer = circshift(buffer,[1,-numPulled]);
                timestampBuffer = circshift(timestampBuffer,[1,-numPulled]);
                buffer(windowlength-numPulled+1:end) = samples(channel,:);
                timestampBuffer(windowlength-numPulled+1:end) = timestamps-firstTimestamp;
                %                 buffer(windowlength) = sample(1);
                minBuff = min(buffer(buffer~=0));
                maxBuff = max(buffer(buffer~=0));
                plot(timestampBuffer,buffer);
                axis([ timestampBuffer(1), timestampBuffer(end)+1, minBuff , maxBuff+1 ]);
                %                 axis([ timestampBuffer(1), timestampBuffer(end), minBuff , maxBuff ]);
                grid
                
                t = t + step;
                drawnow;
                k = k+1;
                %                 indices = indices + 1;
                %                 pause(0.01)
            end
        end
        function LSL = runSSVEP(LSL,eventStopCode)
            if (LSL.streamsOK ~=1)
                error('error: Did you call \"resolveStreams\" ?');
            end
            while 1
                sample = LSL.eventinlet.pull_sample;
                disp(['sample = ', num2str(sample)]);
                if(sample==eventStopCode)
                    %                     disp('Collecting signal...');
                    pause(5);
                    %                     disp('Processing...');
                    chunk = LSL.datainlet.pull_chunk;
                    trial = {ssveptoolkit.util.Trial(chunk,0,LSL.samplingRate,0,0)};
                    for i=1:length(LSL.preprocessing)
                        trial = LSL.preprocessing{i}.process(trial);
                    end
                    LSL.featextraction.trials = trial;
                    LSL.featextraction.extract;
                    [output, prob, rank] = LSL.classification.classifyInstance(LSL.featextraction.getInstances);
                    result = 0;
                    %                     plot(chunk')
                    rank
                    LSL.results = [LSL.results,output];
                    disp(['classif output = ', num2str(output)]);
                    %                     LSL.eventoutlet.push_sample(output);
                    LSL.eventoutlet.push_sample(output-1);
                    %                     disp(['prob = ', num2str(prob)]);
                end
            end
        end
        
    end
    
    methods(Access = private)
        function wav = tts(txt,voice,pace,fs)
            %TTS text to speech.
            %   TTS (TXT) synthesizes speech from string TXT, and speaks it. The audio
            %   format is mono, 16 bit, 16k Hz by default.
            %
            %   WAV = TTS(TXT) does not vocalize but output to the variable WAV.
            %
            %   TTS(TXT,VOICE) uses the specific voice. Use TTS('','List') to see a
            %   list of availble voices. Default is the first voice.
            %
            %   TTS(...,PACE) set the pace of speech to PACE. PACE ranges from
            %   -10 (slowest) to 10 (fastest). Default 0.
            %
            %   TTS(...,FS) set the sampling rate of the speech to FS kHz. FS must be
            %   one of the following: 8000, 11025, 12000, 16000, 22050, 24000, 32000,
            %       44100, 48000. Default 16.
            %
            %   This function requires the Microsoft Win32 Speech API (SAPI).
            %
            %   Examples:
            %       % Speak the text;
            %       tts('I can speak.');
            %       % List availble voices;
            %       tts('I can speak.','List');
            %       % Do not speak out, store the speech in a variable;
            %       w = tts('I can speak.',[],-4,44100);
            %       wavplay(w,44100);
            %
            %   See also WAVREAD, WAVWRITE, WAVPLAY.
            
            % Written by Siyi Deng; 12-21-2007;
            
            if ~ispc, error('Microsoft Win32 SAPI is required.'); end
            if ~ischar(txt), error('First input must be string.'); end
            
            SV = actxserver('SAPI.SpVoice');
            TK = invoke(SV,'GetVoices');
            
            if nargin > 1
                % Select voice;
                for k = 0:TK.Count-1
                    if strcmpi(voice,TK.Item(k).GetDescription)
                        SV.Voice = TK.Item(k);
                        break;
                    elseif strcmpi(voice,'list')
                        disp(TK.Item(k).GetDescription);
                    end
                end
                % Set pace;
                if nargin > 2
                    if isempty(pace), pace = 0; end
                    if abs(pace) > 10, pace = sign(pace)*10; end
                    SV.Rate = pace;
                end
            end
            
            if nargin < 4 || ~ismember(fs,[8000,11025,12000,16000,22050,24000,32000,...
                    44100,48000]), fs = 16000; end
            
            if nargout > 0
                % Output variable;
                MS = actxserver('SAPI.SpMemoryStream');
                MS.Format.Type = sprintf('SAFT%dkHz16BitMono',fix(fs/1000));
                SV.AudioOutputStream = MS;
            end
            
            invoke(SV,'Speak',txt);
            
            if nargout > 0
                % Convert uint8 to double precision;
                wav = reshape(double(invoke(MS,'GetData')),2,[])';
                wav = (wav(:,2)*256+wav(:,1))/32768;
                wav(wav >= 1) = wav(wav >= 1)-2;
                delete(MS);
                clear MS;
            end
            
            delete(SV);
            clear SV TK;
            pause(0.2);
            
        end % TTS;
    end
end

