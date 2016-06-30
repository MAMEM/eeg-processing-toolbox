% load filters/errpbp.mat;
% load filters/BPforERRP.mat;
load firfilter;
load filters/NotchForERRP.mat;
% 
sess = ssveptoolkit.util.Session;
% sess.loadERRPSession(3,[-200,1000],Notch50,FIRMinimum);
sess.loadERRPSession(1,[-200,1000],Notch50,Hbp);

notch = ssveptoolkit.preprocessing.DigitalFilter;
notch.filt = Notch50;
% 
refer = ssveptoolkit.preprocessing.Rereferencing;
% 
bp = ssveptoolkit.preprocessing.DigitalFilter;
bp.filt = Hbp;
% 
% sess.trials = refer.process(sess.trials);
% sess.trials = notch.process(sess.trials);
sess.trials = bp.process(sess.trials);

ga = ssveptoolkit.visualisation.GrandAverage(sess.trials);
ga.plotGrandAverageForChannel(9);