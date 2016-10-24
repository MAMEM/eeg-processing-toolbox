# EEG processing toolbox
## Description
This software is released as part of the EU-funded research project [MAMEM](https://www.mamem.eu/) for supporting experimentation in EEG signals.
It follows a modular architecture that allows the fast execution of experiments of different configurations with minimal adjustments of the code. The experimental pipeline consists of the **Experimenter** class which acts as a wrapper of five more underlying parts;

- The **Session** object: Used for loading the dataset and segmenting the signal according to the periods that the SSVEP stimuli were presented during the experiment. The signal parts are also annotated with a label according to the stimulus frequency.
- The **Preprocessing** object: Includes methods for modifying the raw EEG signal.
- The **Feature Extraction** object: Performs feature extraction algorithms for extracting numerical features from the EEG signals.
- The **Feature Selection** object: Selects the most important features that were extracted in the previous step.
- The **Classification** object: Trains a classification model for predicting the label of unknown samples.

## Instructions
The usage of some classes of the framework is limited by the following requirements.

| Package | Class | Description |
| --- | --- | --- |
| preprocessing | FastICA | Requires the [FastICA](http://research.ics.aalto.fi/ica/fastica/code/dlcode.shtml) library 
| aggregation | Vlad | Requires the [vlfeat](http://www.vlfeat.org/) library
| aggregation | Fisher | Requires the [vlfeat](http://www.vlfeat.org/) library
| featselection | FEAST | Requires the [FEAST](http://mloss.org/software/view/386/) library (download link is next to "Archive" somewhere in the middle of the page) and MIToolbox (included in the FEAST zip file) |
| classification | L1MCCA | Requires the [tensor] (http://www.sandia.gov/~tgkolda/TensorToolbox/index-2.6.html) toolbox|
| classification | LIBSVMFast | Requires the [libsvm](https://www.csie.ntu.edu.tw/~cjlin/libsvm/) library|
| classification | MLTboxMulticlass | Requires Matlab version r2015a or newer |
| classification | MLDA | Requires Matlab version r2014 or newer |
| classification | SMFA | Requires [SGE-SMFA] (https://github.com/amaronidis/SGE-SMFA) |
| util | LSLWrapper | Requires the [Labstreaminglayer](https://github.com/sccn/labstreaminglayer) library|

## Examples

Some examples are available that are based on the datasets that can be found below.
- **exampleCSP**, extract common spatial patterns in dataset III of [BCI competition II] (http://www.bbci.de/competition/ii/)
- **exampleCombiCCA**, SSVEP recognition using the CombinedCCA method from [2]. Based on this [dataset] (ftp://sccn.ucsd.edu/pub/cca_ssvep)
- **exampleDefault**, performs a simple experiment on Dataset I & II
- **exampleEPOCCCASVM**, SSVEP recognition using SVM on the CCA coefficients, based on Dataset III
- **exampleERRP**, recognition of error related potentials, based on the [dataset] (https://github.com/flowersteam/self_calibration_BCI_plosOne_2015) provided by [3]
- **exampleEarlyFusion**, demonstrates how to merge features extracted by different electrode channels, based on Dataset II.
- **exampleEpoc**, performs an experiment for the dataset that was recorded with an EPOC device (Dataset III)
- **exampleITCCA**, SSVEP recognition using the ITCCA method from [2]. Based on this [dataset] (ftp://sccn.ucsd.edu/pub/cca_ssvep)
- **exampleL1MCCA**, SSVEP recognition using the L1MCCA method from [2]. Based on this [dataset] (ftp://sccn.ucsd.edu/pub/cca_ssvep)
- **exampleLSL**, Online recognition of SSVEP signals using the [LSL library] (https://github.com/sccn/labstreaminglayer).
- **exampleLateFusion**, merging the output of different classifiers by majority voting, based on Dataset II.
- **exampleMotorPWelch**, classification of right/left hand motor imagery based on the dataset III of [BCI competition II] (http://www.bbci.de/competition/ii/)
- **exampleOptimal**, performs an experiment with the optimal settings for Dataset I & II
- **exampleSMFA**, SSVEP recognition with using SMFA [4]

## Datasets

| Title | Description | Download Link |
| --- | --- | --- |
|EEG SSVEP Dataset I | EEG signals with 256 channels captured from 11 subjects executing a SSVEP-based experimental protocol. **Five different frequencies (6.66, 7.50, 8.57, 10.00 and 12.00 Hz) presented in isolation** have been used for the visual stimulation. The EGI 300 Geodesic EEG System (GES 300), using a 256-channel HydroCel Geodesic Sensor Net (HCGSN) and a sampling rate of 250 Hz has been used for capturing the signals. | [Dataset I](https://dx.doi.org/10.6084/m9.figshare.2068677) | 
|EEG SSVEP Dataset II | EEG signals with 256 channels captured from 11 subjects executing a SSVEP-based experimental protocol. **Five different frequencies (6.66, 7.50, 8.57, 10.00 and 12.00 Hz) presented simultaneously** have been used for the visual stimulation. The EGI 300 Geodesic EEG System (GES 300), using a 256-channel HydroCel Geodesic Sensor Net (HCGSN) and a sampling rate of 250 Hz has been used for capturing the signals. | [Dataset II](https://dx.doi.org/10.6084/m9.figshare.3153409) |
|EEG SSVEP Dataset III | EEG signals with 14 channels captured from 11 subjects executing a SSVEP-based experimental protocol. **Five different frequencies (6.66, 7.50, 8.57, 10.00 and 12.00 Hz) presented simultaneously** have been used for the visual stimulation, **and the Emotiv EPOC, using 14 wireless channels** has been used for capturing the signals. | [Dataset III](https://dx.doi.org/10.6084/m9.figshare.3413851) |

## References
[\[1\]](http://arxiv.org/abs/1602.00904) Vangelis P. Oikonomou, Georgios Liaros, Kostantinos Georgiadis, Elisavet Chatzilari, Katerina Adam, Spiros Nikolopoulos and Ioannis Kompatsiaris, "Comparative evaluation of state-of-the-art algorithms for SSVEP-based BCIs", Technical Report - eprint arXiv:1602.00904, February 2016 

\[2\] M. Nakanishi, Y. Wang, Y.T. Wang, and T.P. Jung, “A comparison study of canonical correlation analysis based methods for detecting steady-state visual evoked potentials,” PLoS ONE, p. e0140703, October 2015.

\[3\] Iturrate, Iñaki, Jonathan Grizou, Jason Omedes, Pierre-Yves Oudeyer, Manuel Lopes, and Luis Montesano. "Exploiting task constraints for self-calibrated brain-machine interface control using error-related potentials." PloS one 10, no. 7 (2015): e0131491.
Harvard

\[4\] Maronidis, Anastasios, Anastasios Tefas, and Ioannis Pitas. "Subclass Marginal Fisher Analysis." In Computational Intelligence, 2015 IEEE Symposium Series on, pp. 1391-1398. IEEE, 2015.


