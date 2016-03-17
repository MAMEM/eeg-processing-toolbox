classdef LSLWrapper < handle
    %LSLWRAPPER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        lib;
        datastreaminfo;
        datainlet;
        eventstreaminfo;
        eventinlet;
        preprocessing;
        featextraction;
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
            LSL.streamsOK = 1;
        end
        
        function LSL = run(LSL,eventStopCode)
            if (LSL.streamsOK ~=1)
                error('error: Did you call \"resolveStreams\" ?');
            end
            while 1
                sample = LSL.eventinlet.pull_sample;
                disp(['sample = ', num2str(sample)]);
                if(sample==eventStopCode)
                    chunk = LSL.datainlet.pull_chunk;
                    trial = {ssveptoolkit.util.Trial(chunk,0,128,0,0)};
                    for i=1:length(LSL.preprocessing)
                        trial = LSL.preprocessing{i}.process(trial);
                    end
                    LSL.featextraction.trials = trial;
                    LSL.featextraction.extract;
                    [output, prob, rank] = LSL.classification.classifyInstance(LSL.featextraction.getInstances);
                    rank
                    disp(['classif output = ', num2str(output)]);
                    disp(['prob = ', num2str(prob)]);
                end
            end
        end
            
    end
    
end

