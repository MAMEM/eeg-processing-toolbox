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
                trial = ssveptoolkit.util.Trial(chunk,0,128,0,0);
                LSL.trials{length(LSL.trials)+1} = trial;
                tts('ok');
                pause(4);
            end
        end
                
        function LSL = run(LSL,eventStopCode)
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
                    trial = {ssveptoolkit.util.Trial(chunk,0,128,0,0)};
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
    
end

