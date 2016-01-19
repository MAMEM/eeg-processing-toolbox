% Leave one subject out testing
% sess = ssveptoolkit.util.Session(Hhp);
% sess.loadAll(); %its best to do this once, outside the script (too much
% time)
% transf = ssveptoolkit.transformer.PWelchTransformer();
transf = ssveptoolkit.featextraction.PWelch;
% (optional) define the parameters
% transf.filter = Hhp;
% transf.nfft = 256;

prepr1 = ssveptoolkit.preprocessing.SampleSelection;
prepr1.sampleRange = [1,1250]; % Specify the sample range to be used for each Trial
prepr1.channels = 126; % Specify the channel(s) to be used

prepr2 = ssveptoolkit.preprocessing.DigitalFilter;
prepr2.filt = Hbp; % Hbp is a filter built with "filterbuilder" matlab function

featsel = ssveptoolkit.featselection.FEAST;


classif = ssveptoolkit.classification.ML;

experiment = ssveptoolkit.experiment.Experimenter;
experiment.session = sess;
experiment.preprocessing = {prepr1,prepr2};
experiment.featextraction = transf;
% experiment.featsel = ssveptoolkit.featselection.FEAST;
experiment.classification = classif;
experiment.evalMethod = experiment.EVAL_METHOD_LOSO; % specify that you want a "leave one subject out" (default is LOOCV)
%run the experiment
experiment.run();
accuracies = [];
for i=1:length(experiment.results)
    accuracies(i) = experiment.results{i}.getAccuracy();
end
accuracies'
%mean accuracy for all subjects
fprintf('mean acc = %f\n', mean(accuracies));
%get the configuration used (for reporting)
experiment.getExperimentInfo
experiment.getTime;
