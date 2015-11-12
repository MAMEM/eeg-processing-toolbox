%comment
session = ssveptoolkit.util.Session();

session.loadSubject(1); % load first subject trials
session.loadSubjectSession(1,2) % load session 2 of subject 1
% session.loadAll(); %load all Sessions (if you can handle the memory, i think you need 8 GB and 64 bit Matlab)

% session.applyFilter(filt) %- Apply a filter created by filterbuilder
pwt = ssveptoolkit.transformer.PWelchTransformer(session.trials); % init "transformer"
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

ff = ssveptoolkit.extractor.FrequencyFilter(pwt.getInstanceSet, pwt.pff, 2); %get only fundamental and 1st harmonic freq
ff.filter; % do the filtering
ff.filteredInstanceSet.writeArff('filtered') %write the filtered dataset


