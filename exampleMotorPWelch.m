acc = zeros(37,37);
sess = eegtoolkit.util.Session;
sess.loadSubject(9,1);
sess.loadSubject(10,1);
%
[z,p,k]=butter(3,[8,32]/128);
[s,g]=zp2sos(z,p,k);

% dnotch  = fdesign.notch('N,F0,Q,Ap',6,50,10,1,256);
%     Hd1 = design(dnotch);
%     dnotch2  = fdesign.notch('N,F0,Q,Ap',6,100,10,1,256);
%     Hd3 = design(dnotch2);
% df2 = eegtoolkit.preprocessing.DigitalFilter;
% df2.filt = Hd;
% df3 = eegtoolkit.preprocessing.DigitalFilter;
% df3.filt = Hd;

Hd = dfilt.df2sos(s,g);
for i=[16,17,18,19,20,21,24,26,27,28,29,32,33,34,35,36,37]
    for j=[16,17,18,19,20,21,24,26,27,28,29,32,33,34,35,36,37]
        if(j<i)
            continue;
        end
        df = eegtoolkit.preprocessing.DigitalFilter;
        df.filt = Hd;
        
        lapl = eegtoolkit.preprocessing.LaplacianEBN;
        % load('testingMotorVag1');
        % % load
        % sess = eegtoolkit.util.Session;
        % % sess.loadMOTOR(labels,trials);
        % sess.loadVag(trials,labels);
        
        ss = eegtoolkit.preprocessing.SampleSelection;
        ss.channels = [i,j];
        ss.sampleRange = [256,1024];
        
%         csp = eegtoolkit.preprocessing.CSP([1:80],[81:160]);
%         csp.filterDimension = 3;
        
        extr1 = eegtoolkit.featextraction.PWelch; 
        extr1.channel = 1;
        
        extr2 = eegtoolkit.featextraction.PWelch; 
        extr2.channel = 2;
%         extr1 = eegtoolkit.featextraction.PWelch;
%         extr1.channel = 1;
        
%         extr2 = eegtoolkit.featextraction.PWelch;
%         extr2.channel = 2;
        
        
        aggr = eegtoolkit.aggregation.ChannelConcat;
        
%         classif = eegtoolkit.classification.CSPWrapper;
%         baseClassif = eegtoolkit.classification.MLR;
%         classif.baseClassifier = baseClassif;
        classif = eegtoolkit.classification.LIBSVM;
        
        experiment = eegtoolkit.experiment.Experimenter;
        experiment.session = sess;
        experiment.preprocessing = {ss,df};
        experiment.featextraction = {extr1,extr2};
        experiment.aggregator = aggr;
        experiment.classification = classif;
        experiment.evalMethod = experiment.EVAL_METHOD_SPLIT;
        
        experiment.run(1:80,81:160);
        acc(i,j) = experiment.results{1}.getAccuracy;
        experiment.results{1}.getAccuracy
    end
end
