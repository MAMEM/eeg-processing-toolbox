
sess = eegtoolkit.util.Session;
sess.loadSubject(4,1);
% load filters/epocfilter;

sti_f = [9.25, 11.25, 13.25, 9.75, 11.75, 13.75, 10.25, 12.25, 14.25, 10.75, 12.75, 14.75];%Reference signals -
extr = eegtoolkit.featextraction.L1MCCA;

refer = eegtoolkit.preprocessing.Rereferencing;
refer.meanSignal = 1;

[z,p,k]=butter(3,[6,80]/128);
% [z,p,k]=butter(3,[5,48]/125);
[s,g]=zp2sos(z,p,k);
Hd = dfilt.df2sos(s,g);

m_secs = 5;
ss = eegtoolkit.preprocessing.SampleSelection;
ss.sampleRange = [1,1114]; % Specify the sample range to be used for each Trial
ss.channels = [1:8];%Specify the channel(s) to be used
% 
df = eegtoolkit.preprocessing.DigitalFilter; % Apply a filter to the raw data
df.filt = Hd; % Hbp is a filter built with "filterbuilder" matlab function

lcca = eegtoolkit.classification.L1MCCA(256,1114/256,4,sti_f);

experiment = eegtoolkit.experiment.Experimenter;
experiment.session = sess;
experiment.preprocessing = {ss,refer,df};% Order of preprocessing steps matters.
experiment.featextraction = extr;
experiment.classification = lcca;
experiment.evalMethod = experiment.EVAL_METHOD_LOBO; % specify that you want a "leave one subject out" (default is LOOCV)
%run the experiment
experiment.run();
accuracies = [];
for i=1:length(experiment.results)
    accuracies(i) = experiment.results{i}.getAccuracy();    
end
accuracies'
%mean accuracy for all subjects
fprintf('mean acc = %.2f\n', mean(accuracies));