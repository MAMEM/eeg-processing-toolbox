% d2 = designfilt('bandpassiir', 'SampleRate', 256, 'FilterOrder', 8 ,'HalfPowerFrequency1', 1, 'HalfPowerFrequency2', 10,'DesignMethod', 'butter');

sess = eegtoolkit.util.Session;
sess.loadSubject(5,6);

[z,p,k]=butter(3,[6,40]/128);
[s,g]=zp2sos(z,p,k);
Hd = dfilt.df2sos(s,g);
df = eegtoolkit.preprocessing.DigitalFilter; %
df.filt = Hd;

ss = eegtoolkit.preprocessing.SampleSelection;
ss.channels = [4,9,14];
ss.sampleRange = 1500:1:1655;

extr = {};
for i=1:3
    extr{i} = eegtoolkit.featextraction.ERRPFeatures;
    extr{i}.channel = 1;
end

aggr = eegtoolkit.aggregation.ChannelConcat;

classif = eegtoolkit.classification.LIBSVM;

%Setup experiment
experiment = eegtoolkit.experiment.Experimenter;
experiment.session = sess;
experiment.preprocessing = {df,ss};
experiment.featextraction = extr;
experiment.aggregator = aggr;
experiment.classification = classif;
experiment.evalMethod = experiment.EVAL_METHOD_XFOLD_CV;

experiment.run(10);

accuracies = [];
for i=1:length(experiment.results)
    accuracies(i) = experiment.results{i}.getAccuracy();
end

accuracies'
fprintf('mean acc = %.2f\n',mean(accuracies));