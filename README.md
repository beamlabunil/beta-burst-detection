# Beta-burst-detection

## DESCRIPTION
This README outlines three scripts customized to detect and extract Beta bursts parameters, for each subject, using personalized thresholds.
1. "Amplitude_enveloppe_extraction.m" extracts beta-band amplitude envelopes (±3 Hz around each subject’s peak frequency from M1 scouts), normalizes them by the grand mean, and saves trial-wise envelopes for each subject, session, and hemisphere. Peak frequancies were previously extracted and M1 scouts extracted using Brainstorm.
2. "Threshold_estimation.m" was created to estimate a global threshold for beta burst detection by testing a range of SD multipliers and selecting the one that maximizes the correlation between burst counts and trial mean amplitudes across subjects. The chosen SD is then applied to each subject’s data to compute subject-specific thresholds.
3. "beta_bursts_parameters_extraction.m" applies the previously determined global threshold to each subject’s beta amplitude envelope and extracts burst parameters, including onset/offset time, peak time, duration, and peak amplitude, saving them for further analysis.

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
