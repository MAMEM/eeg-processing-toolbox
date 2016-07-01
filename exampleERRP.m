% load filters/errpbp.mat;
% load filters/BPforERRP.mat;
load errpfilters;
load filters/NotchForERRP.mat;
% 

d2 = designfilt('bandpassiir', 'SampleRate', 256, 'FilterOrder', 8 ,'HalfPowerFrequency1', 1, 'HalfPowerFrequency2', 10,'DesignMethod', 'butter');

sess = ssveptoolkit.util.Session;
% sess.loadERRPSession(3,[-200,1000],Notch50,FIRMinimum);
% sess.loadERRPSession(3,[-200,1000],Notch50,FIR);
sess.loadERRPAll([-200,1000],[],[]);
notch = ssveptoolkit.preprocessing.DigitalFilter;
notch.filt = Notch50;
% 
refer = ssveptoolkit.preprocessing.Rereferencing;
% % 
bp = ssveptoolkit.preprocessing.DigitalFilter;
bp.filt = d2;
% 
% sess.trials = refer.process(sess.trials);
% sess.trials = notch.process(sess.trials);
sess.trials = bp.process(sess.trials);

ga = ssveptoolkit.visualisation.GrandAverage(sess.trials);
ga.plotGrandAverageForChannel(9);