session = Session();
%session = Session(1000); %get 4 seconds of rest (1000 samples)

% session.loadSubjectSession(Session.ANASTASIA_1) %load first session of anastasia
session.loadSubject(Session.ANASTASIA); % load Anastasia's trials
% session.loadAll(); %load all Sessions (if you can handle the memory, i think you need 8 GB and 64 bit Matlab)
% session.loadAllExceptSubject(Session.ANASTASIA) %load all except anastasia
% session.applyFilter(filt) %- Apply a filter created by filterbuilder
pwt = PWelchTransformer(session.trials); % init "transformer"
%set options
pwt.channel = 116; %select channel to use
pwt.seconds = 4; %use the first 4 seconds
pwt.nfft = 256; %nfft parameter for pwelch function

pwt.transform(); %extract the features
pwt.getInstances(); %get instances rows = instances, columns = attributes
pwt.getLabels(); %get instance labels;
pwt.getDataset(); %get dataset(labels set as the last attribute)
pwt.getInstanceSet(); % get dataset as an 'InstanceSet' object

pwt.writeArff('test'); %write to weka readable file
pwt.writeCSV('test.csv'); %write to csv file (only instances)

ff = FrequencyFilter(pwt.getInstanceSet, pwt.pff, 2); %get only fundamental and 1st harmonic freq
ff.filter; % do the filtering
ff.filteredDataset.writeArff('filtered') %write the filtered dataset


