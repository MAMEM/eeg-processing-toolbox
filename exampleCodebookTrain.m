% occipital =[ 126 138	150	139	137	149	125	113	114	115	116	117	118	119	120	121	122	123	124	127	133	134	135	136	145	146	147	148	156	157	158	159	165	166	167	168	174	175	176	187];
occipital = [150, 138];
numClusters = 5;
codebookFilename = 'vlad5';
ssveptoolkit.aggregation.VladAggregator.trainCodebook(sess,occipital,numClusters,'vlad5',0);
% ssveptoolkit.aggregation.FisherAggregator.trainCodebook(sess,occipital,numClusters,codebookFilename,80);

% ssveptoolkit.aggregation.VladAggregator.trainCodebook(sess,occipital,2,'vlad2');
% ssveptoolkit.aggregation.VladAggregator.trainCodebook(sess,occipital,4,'vlad4');
% ssveptoolkit.aggregation.VladAggregator.trainCodebook(sess,occipital,8,'vlad8');
% ssveptoolkit.aggregation.VladAggregator.trainCodebook(sess,occipital,16,'vlad16');
% ssveptoolkit.aggregation.VladAggregator.trainCodebook(sess,occipital,32,'vlad32');
% ssveptoolkit.aggregation.VladAggregator.trainCodebook(sess,occipital,64,'vlad64');
% Train codebook for vlad

%specify channels
channels = [126,138];
%number of clusters
numClusters = 16;
%filename to save the codebook
codebookFilename = 'vlad16';

ssveptoolkit.aggregation.VladAggregator.trainCodebook(sess,occipital,numClusters,codebookFilename);
% Train codebook for fisher vector

%specify channels
channels = [150,138];
%number of clusters
numClusters = 16;
%filename to save the codebook
codebookFilename = 'vlad5';

%number of pca components
numpca = 60;

ssveptoolkit.aggregation.FisherAggregator.trainCodebook(sess,channels,numClusters,codebookFilename,numpca);

