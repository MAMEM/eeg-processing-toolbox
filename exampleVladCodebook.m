occipital =[ 126 138	150	139	137	149	125	113	114	115	116	117	118	119	120	121	122	123	124	127	133	134	135	136	145	146	147	148	156	157	158	159	165	166	167	168	174	175	176	187];
numClusters = 64;
codebookFilename = 'codebook2';
ssveptoolkit.aggregation.VladAggregator.trainCodebook(sess,occipital,numClusters,'codebook2');
