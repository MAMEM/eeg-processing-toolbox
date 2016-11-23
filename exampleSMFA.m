clear

% fileID = fopen('SMFA_Results.txt','a');
for subn=1:10
    
    %Dataset 4
    sess = eegtoolkit.util.Session;
    % sess.loadAll(4);
    sess.loadSubject(4,subn);
    
    % %Dataset 2
    % sess = ssveptoolkit.util.Session;
    % sess.loadAll(2);
    
    load filters/filt_IIRElliptic;
    
    %Dataset 4
    % sti_f = [9.25, 11.25, 13.25, 9.75, 11.75, 13.75, 10.25, 12.25, 14.25, 10.75, 12.75, 14.75];
    % extr = ssveptoolkit.featextraction.CCA(sti_f,[1:8],256,4);
    
    extr = eegtoolkit.featextraction.MLR_Transf(1:8);
    %         sti_f = [9.25, 9.75, 10.25, 10.75, 11.25, 11.75, 12.25, 12.75, 13.25, 13.75, 14.25, 14.75];
    %         extr = ssveptoolkit.featextraction.CCA(sti_f,1:8,256,4);
    
    %%Dataset 2
    % sti_f = [12 10 8.57 7.50 6.66];
    % sti_f = [6.66 7.5 8.57 10 12];
    % extr = ssveptoolkit.featextraction.CCA(sti_f,[1:2],250,4);
    
    % extr = ssveptoolkit.featextraction.OMP(sti_f,[1:2],250,4,16,0);
    %sti_f: reference signals
    %[1:2]: input=2 channels. Depends on what you set on "ss.channels" e.g. if
    %you select 10 channels you need to set "[1:10]"
    %250: sampling rate (Dataset 1&2=250)
    %4: number of harmonics of the reference signals
    
    % %Dataset 2
    % amu = ssveptoolkit.preprocessing.Amuse;
    % amu.first = 15;
    % amu.last = 252;
    
    refer = eegtoolkit.preprocessing.Rereferencing;
    %Subtract the mean from the signal
    refer.meanSignal = 1;
    
    %Dataset 4
    % m_secs = 2;
    
    % %Dataset 2
    % m_secs = 5;
    
    ss = eegtoolkit.preprocessing.SampleSelection;
    
    %Dataset 4
    onset=39;
    %delay of the visual system
    visual_delay = 35;
    ss.sampleRange = [onset+visual_delay+1,onset+visual_delay+1*256];
    ss.channels = 1:8;
    % ss.channels = 7;
    
    % %Dataset 2
    % ss.sampleRange = [1,250*m_secs]; % Specify the sample range to be used for each Trial
    % % ss.channels = [116,126,137,138,139,147,150];%[126,138]%Specify the channel(s) to be used
    % ss.channels = [126,138];
    
    %Dataset 4
    df = eegtoolkit.preprocessing.DigitalFilter; % Apply a filter to the raw data
    [z,p,k]=butter(3,[6,80]/128);
    [s,g]=zp2sos(z,p,k);
    Hd = dfilt.df2sos(s,g);
    df.filt = Hd;
    
    Res = zeros(length(1:4:10),length(1:4:100));
    
    % Set parameter grid to search
    %         for qq=1:10
    %             for ww=1:25
    
    %Number of subclasses per class
    NumS = 2*ones(1,12);
    
    S = 0.4;
    %                 kInt = qq;
    %                 kPen = 4*(ww-1)+1;
    kInt = 3;
    kPen = 50;
    classif = eegtoolkit.classification.SMFA(0,NumS,S,kInt,kPen);
    
    experiment = eegtoolkit.experiment.Experimenter;
    experiment.session = sess;
    
    %Dataset 4
    experiment.preprocessing = {ss,refer,df};
    
    % %Dataset 2
    % experiment.preprocessing = {amu,ss,refer,df};% Order of preprocessing steps matters.
    
    experiment.featextraction = extr;
    experiment.classification = classif;
    experiment.evalMethod = experiment.EVAL_METHOD_LOBO; % specify that you want a "leave one subject out" (default is LOOCV)
    % experiment.evalMethod = experiment.EVAL_METHOD_LOOCV;
    
    %run the experiment
    experiment.run();
    accuracies = [];
    for i=1:length(experiment.results)
        accuracies(i) = experiment.results{i}.getAccuracy();
    end
    % accuracies'
    % mean accuracy for all subjects
%     fprintf('mean acc = %.2f\n', mean(accuracies));
    subaccuracies(subn) = mean(accuracies);
end
fprintf('mean acc for all subjects %.2f\n',mean(subaccuracies));