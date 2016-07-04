d2 = designfilt('bandpassiir', 'SampleRate', 256, 'FilterOrder', 8 ,'HalfPowerFrequency1', 1, 'HalfPowerFrequency2', 10,'DesignMethod', 'butter');

sess = ssveptoolkit.util.Session;
% sess.loadERRPAll([200,800],[],[]);
sess.loadERRPSession(6,[200,800],[],[]);
df = ssveptoolkit.preprocessing.DigitalFilter;
df.filt = d2;

ss = ssveptoolkit.preprocessing.SampleSelection;
ss.channels = [4,9,14];
ss.sampleRange = 1500:1:1655;

extr = {};
for i=1:3
    extr{i} = ssveptoolkit.featextraction.ERRPFeatures;
    extr{i}.channel = 1;
end

aggr = ssveptoolkit.aggregation.ChannelConcat;

classif = ssveptoolkit.classification.LIBSVM;

%Setup experiment
experiment = ssveptoolkit.experiment.Experimenter;
experiment.session = sess;
experiment.preprocessing = {df,ss};
experiment.featextraction = extr;
experiment.aggregator = aggr;
experiment.classification = classif;
experiment.evalMethod = experiment.EVAL_METHOD_LOOCV;

experiment.run();

accuracies = [];
for i=1:length(experiment.results)
    accuracies(i) = experiment.results{i}.getAccuracy();
end

accuracies'
fprintf('mean acc = %.2f\n',mean(accuracies));
