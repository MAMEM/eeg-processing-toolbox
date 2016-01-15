% Leave one subject out testing
% sess = ssveptoolkit.util.Session(Hhp);
% sess.loadAll(); %its best to do this once, outside the script (too much
% time)
% transf = ssveptoolkit.transformer.PWelchTransformer();
transf = ssveptoolkit.transformer.PWelchTransformer;
% (optional) define the parameters
% transf.filter = Hhp;
% transf.nfft = 256;

prepr1 = ssveptoolkit.preprocessing.SampleSelection;
prepr1.sampleRange = [1,1250]; % Specify the sample range to be used for each Trial
prepr1.channels = 126; % Specify the channel(s) to be used

prepr2 = ssveptoolkit.preprocessing.DigitalFilter;
prepr2.filt = Hbp; % Hbp is a filter built with "filterbuilder" matlab function

filt = ssveptoolkit.extractor.FEASTFilter;
filt.algorithm = filt.ALGORITHM_JMI;

classif = ssveptoolkit.classifier.LIBSVMClassifierFast;

experiment = ssveptoolkit.experiment.Experimenter;
experiment.session = sess;
experiment.preprocessing = {prepr1,prepr2};
experiment.transformer = transf;
experiment.extractor = filt;
%comment this line if you dont want a filter
% experiment.extractor = filt;
experiment.classifier = classif;
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
