# Beta-burst-detection

## DESCRIPTION
This README outlines three scripts customized to detect and extract Beta bursts parameters, for each subject, using personalized thresholds.
1. "Amplitude_enveloppe_extraction.m" was created to exctract and normalise amplitude enveloppe for Beta frequency (+/- 3 Hz around subject Beta peak frequency) of each subject, during each session, for each scout (Primary motor cortex (M1) right and left hemispheres). Peak frequancies were previously extracted and scouts extracted using Brainstorm...
2."Threshold_estimation.m" was created using square difference to test differents thresholds to find the most representative of beta amplitude variations in each subject. Then it find and applied to all subjects the threshold with the best average correlation between subjects ("global threshold") .
3. "beta_bursts_parameters_extraction.m" aim is to apply the "global threshold" to the subjects and extract the paramaters of the bursts (temporal localisation, duration, peak amplitude).

## SUPPORT

Refer to software documentation for additional details or updates here : 
- eeglab: https://eeglab.org/
- fieldtrip: https://www.fieldtriptoolbox.org/
- brainstorm: https://github.com/brainstorm-tools/brainstorm3
- eeg-preprocessing : https://github.com/beamlabunil/eeg-preprocessing/

## BUILT WITH
-	Matlab
-	eeglab scripts

## GETTING STARTED
Prerequisites 
- FieldTrip
-	peak frequencies folder 
- eeg-preprocessing 
- Brainstorm 

## Instructions
Use these scripts after preprocessing and scouts extraction in BRAINSTORM.
1. Customize the Paths and names: adjust the folder paths and names to match the directories on your system.
2. Run each script following order

## CONTACT
Kate Schipper : kate.schipper@unil.ch

Paolo Ruggeri : paolo.ruggeri@unil.ch
