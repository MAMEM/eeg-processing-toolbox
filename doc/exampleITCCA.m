m_secs = 0.5:0.5:4;
for ii=1:8
    for jj = 1:8
        sess = eegtoolkit.util.Session;
        % sess.loadAll(4);
        % sess.loadAll(4);
        sess.loadSubject(4,ii);
        ss = eegtoolkit.preprocessing.SampleSelection;
        ss.channels = 1:8;
        ss.sampleRange = [75,74+256*m_secs(jj)];
        % ss.sampleRange = [1,1140];
        % 75:1024+74
        h = fdesign.bandpass('N,F3dB1,F3dB2',10,6,80,256);
        d1 = design(h,'butter');
        df = eegtoolkit.preprocessing.DigitalFilter; %
        df.filt = d1;
        
        refer = eegtoolkit.preprocessing.Rereferencing;
        refer.meanSignal = 1;
        
        extr = eegtoolkit.featextraction.RawSignal;
        
        classif = eegtoolkit.classification.ITCCA;
        classif.baseClassifier = eegtoolkit.classification.MaxChooser;
        
        experiment = eegtoolkit.experiment.Experimenter;
        experiment.session = sess;
        experiment.preprocessing = {ss,refer,df};
        experiment.featextraction = extr;
        experiment.classification = classif;
        % experiment.evalMethod = experiment.EVAL_METHOD_LOOCV;
        % experiment.run();
        experiment.evalMethod = experiment.EVAL_METHOD_LOBO;
        experiment.run();
        for i=1:length(experiment.results)
            accuracy(i) = experiment.results{i}.getAccuracy();
        end
        acc2(ii,jj) = mean(accuracy);
        % accuracy = experiment.results{1}.getAccuracy();
        
    end
end