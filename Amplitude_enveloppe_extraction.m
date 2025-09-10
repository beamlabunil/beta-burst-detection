% === Clear workspace and initialize toolboxes ===
clear all;
close all;
clc;

addpath('/Users/dkane/MATLAB_Add-Ons/Collections\FieldTrip');
ft_defaults;

% === Define subjects, sessions, scouts ===
subjects = {'0VX6','0GD4','0ZC8','1D5G','1D7M','1G0J','2O3W','4F5S','4O6C','6I1R','6T1S','12GP','42JC','54AU','A4X7','B78N','B86S','EM08','G8T9','JT19','M1O7','MY49','R6T1','S3I4','V12G','Z6S1','ZA95'};
sessions = {'S1', 'S2', 'S3'};
scouts = {'M1_LH', 'M1_RH'};

% === Define paths ===
inputDir = '/Users/dkane/Documents/MATLAB/scout_time_series/';
outputDir = '/Users/dkane/Documents/MATLAB/Beta_amplitude';
peakFreqDir = '/Users/dkane/Documents/MATLAB/Peak_frequency/';

% === Loop through subjects, sessions, scouts ===
for subj = 1:length(subjects)
    subj_id = subjects{subj};
    
    for sess = 1:length(sessions)
        sess_id = sessions{sess};

        for scout_i = 1:length(scouts)
            scout_name = scouts{scout_i};

            % === Load subject-specific peak frequency (always from S3) ==
            peak_file_name = sprintf('%s_S3_%s.mat', subj_id, scout_name);
            peak_file_path = fullfile(peakFreqDir, peak_file_name);

            if ~isfile(peak_file_path)
                fprintf('Peak frequency file not found: %s\n', peak_file_path);
                continue;
            end

            peak_data = load(peak_file_path);
            if ~isfield(peak_data, 'PeakFrequencyData') || ~isfield(peak_data.PeakFrequencyData, 'max_freq')
                fprintf('max_freq not found in: %s\n', peak_file_path);
                continue;
            end

            max_freq = peak_data.PeakFrequencyData.max_freq;
            freq_range = [max_freq - 3, max_freq + 3];

            % === Define scout folder ===
            scout_folder = fullfile(inputDir, sprintf('%s_%s', subj_id, sess_id), scout_name);
            if ~exist(scout_folder, 'dir')
                fprintf('Missing folder: %s\n', scout_folder);
                continue;
            end

            % === REORDERS THE TRIALS FROM 1 TO 60 (brainstorm lists them  01,10,11 etc) ===
            % scouts exctracted from brainstorm 
            scout_files = dir(fullfile(scout_folder, '*.mat'));
            trial_nums = zeros(length(scout_files), 1);
            for k = 1:length(scout_files)
                fname = scout_files(k).name;
                match = regexp(fname, '_trial(\d+)', 'tokens');
                if ~isempty(match)
                    trial_nums(k) = str2double(match{1}{1});
                else
                    warning('No trial number found in filename: %s', fname);
                    trial_nums(k) = Inf;
                end
            end
            [~, sort_idx] = sort(trial_nums);
            scout_files = scout_files(sort_idx);
            n_trials = length(scout_files);

            if n_trials == 0
                fprintf('No trials in: %s\n', scout_folder);
                continue;
            end

            % === Load one trial to get time info ===
            tmp = load(fullfile(scout_folder, scout_files(1).name));
            Time = tmp.Time;
            srate = 1 / mean(diff(Time));
            n_times = length(Time);
            n_scouts = size(tmp.Value, 1);

            % === Initialize envelope matrix ===
            amp_envelope = zeros(n_trials, n_times); 

            % === Loop through trials ===
            for trial = 1:n_trials
                trial_data = load(fullfile(scout_folder, scout_files(trial).name));
                scout_signal = squeeze(trial_data.Value(1, :, 1));  % scout= mean of the amplitude in M1

                % Pad to avoid edge effects
                dc = mean(scout_signal);
                padded = [repmat(dc, 1, srate), scout_signal, repmat(dc, 1, srate)];

                % Bandpass filter and get Hilbert envelope
                filtered = ft_preproc_bandpassfilter(padded, srate, freq_range, ...
                    4, 'but', 'twopass', 'reduce')';
                analytic = abs(hilbert(filtered));
                scout_amp = analytic(srate+1 : srate+n_times);

                amp_envelope(trial, :) = scout_amp;
            end

            % === Normalize by grand mean ===
            grand_mean_amp = mean(amp_envelope(:));
            norm_amp_envelope = amp_envelope / grand_mean_amp;

            % === Save ===
            save_name = sprintf('%s_%s_%s_amp_envelope_norm_peak_freq.mat', subj_id, sess_id, scout_name);
            save_path = fullfile(outputDir, save_name);
            save(save_path, 'norm_amp_envelope', 'Time', 'scout_name', 'freq_range');
            fprintf('Saved: %s\n', save_path);
        end
    end
end
