# Beta-burst-detection
These scripts allow to detect and extract Beta bursts parameters, for each subject, using personalized thresholds.
1. "run1_Amplitude_compute_norm_per_trial_peak_freq.m" was created to exctract and normalise Beta amplitude (+/- 3 Hz) enveloppe for each subject, during each session, for each scout (M1 right and M1 left). Peak frequancies were previously extracted and scouts extracted using Brainstorm...
2."run2_estimate_theshold_sd_group_level_fixed_thresh.m" was created using sd to test different threshold to find the one representing the best the Beta signal in each subject.  Then it find and applied to all subjects the threshold with the best average correlation between subjects ("global threshold") .
3. "run3_extracting_beta_bursts_group_thresh.m" aim is to apply the "global threshold" to the subjects and extract the paramaters of the bursts (temporal localisation, duration, peak amplitude).
