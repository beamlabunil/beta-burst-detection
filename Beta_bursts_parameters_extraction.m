% Clear workspace and initialize
clear all;
close all;
clc;

% Add necessary paths and initialize toolboxes
addpath('C:\Program Files\MATLAB\R2020b\toolbox\fieldtrip-20230118');
ft_defaults;

% Define subjects and sessions
subjects = {'0VX6'};
sessions = {'S1', 'S2', 'S3'};
scout_name = {'M1_LH', 'M1_RH'};

% Define base paths
thresholdDir = 'C:\Users\kschippe\OneDrive\Documents\UNIL\Research\Thesis Project\Longitudinal study\Code\TF\results\beta_frequency_band_source_level\Marker_101\Threshold_sd_beta_amp_group';
ampEnvDir = 'C:\Users\kschippe\OneDrive\Documents\UNIL\Research\Thesis Project\Longitudinal study\Code\TF\results\beta_frequency_band_source_level\Marker_101\Beta_amplitude';
burstDir = 'C:\Users\kschippe\OneDrive\Documents\UNIL\Research\Thesis Project\Longitudinal study\Code\TF\results\beta_frequency_band_source_level\Marker_101\Beta_bursts_group_thresh';

% Loop through each subject, session, and scout
for sess = 1:length(sessions)
    sess_id = sessions{sess};

    for subj = 1:length(subjects)
        subj_id = subjects{subj};

        for sc = 1:length(scout_name)
            scout_id = scout_name{sc};

            % Load precomputed threshold 
            threshold_file = sprintf('%s_%s_%s_global_threshold_peak_freq.mat', subj_id, sess_id, scout_id);
            threshold_path = fullfile(thresholdDir, threshold_file);
            if ~isfile(threshold_path)
                fprintf('Threshold file not found: %s\n', threshold_path);
                continue;
            end
            load(threshold_path, 'global_threshold');
            fprintf('Loaded threshold for %s %s %s: %.2f \n', subj_id, sess_id, scout_id, global_threshold);

            % Load beta amplitude envelope data
            amp_env_file = sprintf('%s_%s_%s_amp_envelope_norm_peak_freq.mat', subj_id, sess_id, scout_id);
            amp_env_path = fullfile(ampEnvDir, amp_env_file);
            if ~isfile(amp_env_path)
                fprintf('Beta amplitude envelope file not found: %s\n', amp_env_path);
                continue;
            end
            load(amp_env_path, 'norm_amp_envelope', 'Time');

            % Time stamps in each trial
            all_times = Time*1000;% conversion en millis
            trials = size(norm_amp_envelope, 1);

            % Detect bursts for the session
            session_bursts = struct('trial', [],'peak_time',[], 'onset_time', [], 'offset_time', [], 'burst_duration', [], 'peak_amp', []); % creation of a matrice for each burst parameters
            for t_idx = 1:trials % num de l'essai
                over_thresh_idx = norm_amp_envelope(t_idx, :) >= global_threshold;
                over_thresh_diff = diff([0 over_thresh_idx 0]);
                burst_starts = find(over_thresh_diff == 1);
                burst_ends = find(over_thresh_diff == -1) - 1;
                for k = 1:length(burst_starts)
                    start_idx = burst_starts(k);
                    end_idx = burst_ends(k);

                    burst_amp = norm_amp_envelope(t_idx, start_idx:end_idx);
                    [peak_amp, rel_peak_idx] = max(burst_amp); 
                    burst_peak_idx = start_idx + rel_peak_idx - 1;
                    burst_duration = all_times(end_idx) - all_times(start_idx);

                    session_bursts.trial(end+1) = t_idx;
                    session_bursts.peak_time(end+1) = all_times(burst_peak_idx);
                    session_bursts.onset_time(end+1) = all_times(start_idx);
                    session_bursts.offset_time(end+1) = all_times(end_idx);
                    session_bursts.burst_duration(end+1) = burst_duration;
                    session_bursts.peak_amp(end+1) = peak_amp;
                end
            end

            % Save burst data
            burst_filename = sprintf('%s_%s_%s_bursts_global_thresh_peak_freq_scouts.mat', subj_id, sess_id, scout_id);
            burst_filepath = fullfile(burstDir, burst_filename);
            save(burst_filepath, 'session_bursts');
            fprintf('Saved burst data for %s %s %s to %s\n', subj_id, sess_id, scout_id, burst_filepath);
        end
    end
end
