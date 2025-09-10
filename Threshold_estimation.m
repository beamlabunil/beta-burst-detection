clear all;
close all;
clc; 

% === PARAMETERS ===
subjects = {'0VX6','0GD4','0ZC8','1D5G','1D7M','1G0J','2O3W','4F5S','4O6C','6I1R','6T1S','12GP','42JC','54AU','A4X7','B78N','B86S','EM08','G8T9','JT19','M1O7','MY49','R6T1','S3I4','V12G','Z6S1','ZA95'};
sessions = {'S1', 'S2', 'S3'};
scout_name = {'M1_LH', 'M1_RH'};

% === PATHS ===
ampEnvDir = 'C:\Users\kschippe\OneDrive\Documents\UNIL\Research\Thesis Project\Longitudinal study\Code\TF\results\beta_frequency_band_source_level\Marker_101\Beta_amplitude';
thresholdDir = 'C:\Users\kschippe\OneDrive\Documents\UNIL\Research\Thesis Project\Longitudinal study\Code\TF\results\beta_frequency_band_source_level\Marker_101\Threshold_sd_beta_amp_group';

if ~exist(thresholdDir, 'dir')
    mkdir(thresholdDir);
end 

% === SD range to test ===
sds = 0.1:0.1:3;
all_corrs = [];
all_amp_data = []; 

% === 1st PASS: Gather all amplitude values and correlation data ===
for subj = 1:length(subjects)
    subj_id = subjects{subj};
    for sess = 1:length(sessions)
        sess_id = sessions{sess};
        for sc = 1:length(scout_name)
            scout_id = scout_name{sc};
            amp_file = sprintf('%s_%s_%s_amp_envelope_norm_peak_freq.mat', subj_id, sess_id, scout_id);
            amp_path = fullfile(ampEnvDir, amp_file); 
            if ~isfile(amp_path), continue; end 
            load(amp_path, 'norm_amp_envelope');
            
            all_amp_data = [all_amp_data; norm_amp_envelope(:)]; 
            
            trials = size(norm_amp_envelope, 1); 
            corr_vec = zeros(1, length(sds));
            for sd_idx = 1:length(sds)
                sd = sds(sd_idx); 
                threshold = median(norm_amp_envelope(:)) + sd * std(norm_amp_envelope(:));
                trial_bursts = zeros(1, trials);
                for t = 1:trials
                    over = norm_amp_envelope(t,:) >= threshold;
                    burst_edges = find(diff([0, over, 0]));
                    trial_bursts(t) = length(burst_edges) / 2;  
                end
                trial_means = mean(norm_amp_envelope, 2);
                corr_vec(sd_idx) = corr(trial_bursts', trial_means, 'type', 'Spearman'); 
            end
            all_corrs = [all_corrs; corr_vec];
        end
    end
end

% === Find best SD based on highest average correlation ===
avg_corrs = mean(all_corrs, 1);
[~, best_idx] = max(avg_corrs);
peak_sd = sds(best_idx);
fprintf('Global peak SD = %.2f\n', peak_sd);

% === Save global peak SD ===
save(fullfile(thresholdDir, 'global_peak_sd_all_scouts.mat'), 'peak_sd');

% === 2nd PASS: Apply global peak SD to each subject's own data ===
for subj = 1:length(subjects)
    subj_id = subjects{subj};
    for sess = 1:length(sessions)
        sess_id = sessions{sess};
        for sc = 1:length(scout_name)
            scout_id = scout_name{sc};
            amp_file = sprintf('%s_%s_%s_amp_envelope_norm_peak_freq.mat', subj_id, sess_id, scout_id);
            amp_path = fullfile(ampEnvDir, amp_file);
            if ~isfile(amp_path), continue; end

            load(amp_path, 'norm_amp_envelope');

            % 👇 APPLY GLOBAL SD TO INDIVIDUAL DISTRIBUTION
            subj_median = median(norm_amp_envelope(:));
            subj_std = std(norm_amp_envelope(:)); 
            global_threshold = subj_median + peak_sd * subj_std;

            % Save threshold
            save_path = fullfile(thresholdDir, sprintf('%s_%s_%s_global_threshold_peak_freq.mat', subj_id, sess_id, scout_id));
            save(save_path, 'global_threshold', 'peak_sd', 'sess_id', 'subj_id', 'scout_id');
            fprintf('Saved threshold for %s %s %s\n', subj_id, sess_id, scout_id);
        end
    end
end

