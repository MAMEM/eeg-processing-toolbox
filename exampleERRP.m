load filters/errpbp.mat;
load filters/errpnotch.mat;
% 
sess = ssveptoolkit.util.Session;
sess.loadERRPSession(3);

notch = ssveptoolkit.preprocessing.DigitalFilter;
notch.filt = Notch50;
% 
% refer = ssveptoolkit.preprocessing.Rereferencing;
% 
% bp = ssveptoolkit.preprocessing.DigitalFilter;
% bp.filt = BP1_10;
% 
% csess.trials = refer.process(sess.trials);
sess.trials = notch.process(sess.trials);
% sess.trials = bp.process(sess.trials);

ga = ssveptoolkit.visualisation.GrandAverage(sess.trials);
ga.plotGrandAverageForChannel(4);