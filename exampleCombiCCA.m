m_secs = 0.5:0.5:4;
for ii=1:8
    for jj = 1:8
        sess = eegtoolkit.util.Session;
        % sess.loadAll(4);
        % sess.loadAll(4);
        sess.loadSubject(4,ii);
        
        ss = eegtoolkit.preprocessing.SampleSelection;
        ss.channels = 1:8;
        % ss.sampleRange = [75,1024+74];
        ss.sampleRange = [75,74+256*m_secs(jj)];
        % ss.sampleRange = [1,1140];
        % 75:1024+74
        [z,p,k]=butter(3,[6,80]/128);
        [s,g]=zp2sos(z,p,k);
        Hd = dfilt.df2sos(s,g);
        df = eegtoolkit.preprocessing.DigitalFilter; %
        df.filt = Hd;
        
        refer = eegtoolkit.preprocessing.Rereferencing;
        refer.meanSignal = 1;
        
        extr = eegtoolkit.featextraction.RawSignal;
        sti_f = [9.25, 11.25, 13.25, 9.75, 11.75, 13.75, 10.25, 12.25, 14.25, 10.75, 12.75, 14.75];
        classif = eegtoolkit.classification.CombiCCA(sti_f,4,256*m_secs(jj),256);
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
