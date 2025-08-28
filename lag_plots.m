%{
This script generates lag distribution boxplots comparing real Purkinje cell (PC) neural activity to shuffled control data across selected behavioral features.
For each chosen feature (e.g., positional or muscle activation predictors), the script loads previously computed “best lag” indices — the time offsets at which PC firing best aligns with the feature. 
These indices are converted into time units (seconds) and aggregated across multiple sessions. The same process is repeated using shuffled neural data to serve as a null distribution.
%}

close all;        % Close all open figures
clear all;        % Clear all workspace variables

% --- Session identifiers (each string corresponds to one dataset) ---
sessions = ["Dylan_210414_WT2_NPresults_short", ...
    "Dylan_210421_fChR2_NPresults_short_stim", "Dylan_210423_fChR2_NPresults_short", ...
    "Dylan_210422_fChR2_NPresults_short", "Dylan_210425_fChR2_NPresults_short", ...
    "Dylan_210511_fChR5_NPresults_short", "Dylan_210512_fChR5_NPresults_short", ...
    "Dylan_210514_fChR2_NPresults_short", "Dylan_210515_fChR5_NPresults_short", ...
    "Dylan_210606_fChR4_NPresults_short", "Dylan_210608_fChR4_NPresults_short", ...
    "Dylan_210614_fChR4_NPresults_short", "Dylan_210619_cChR1_NPresults_short", ...
    "Dylan_210620_cChR1_NPresults_short", "Dylan_210622_cChR1_NPresults_short", ...
    "Dylan_210623_cChR1_NPresults_short", "Dylan_220515_DJC002_NPresults_short", ...
    "Dylan_220516_DJC000_NPresults_short", "Dylan_220517_DJC002_NPresults_short", ...
    "Dylan_220518_DJC000_NPresults_short", "Dylan_220519_DJC000_NPresults_short", ...
    "Dylan_220519_DJC002_NPresults_short", "Dylan_220520_DJC000_NPresults_short", ...
    "Dylan_220520_DJC002_NPresults_short"];

% --- Number of reaches recorded in each session ---
reach_num = [74, 65, 62, 63, 52, 66, 54, 60, 68, 52, 73, 59, 80, 68, 71, ...
    68, 60, 53, 58, 58, 36, 70, 57, 45];

% --- List of biomechanical / muscle features used as predictors ---
model_info = ["Shoulder Elv Angle Value", "Shoulder Extension Angle Value", ...
    "Elbow Flex Value", "Ulna Radius Rot Value", "Wrist Angle Value", ...
    "Shoulder Elv Angle Speed", "Shoulder Extension Angle Speed", ...
    "Elbow Flex Speed", "Ulna Radius Rot Speed", "Wrist Angle Speed", ...
    "Pectoralis Clavicle Head Activation", "Biceps Short Head Activation", ...
    "Biceps Long Head Activation", "Deltoid A Activation", ...
    "Triceps Short Head Activation", "Triceps Long Head Activation", ...
    "Brachialis inner Head Activation", "Brachialis Outer Head Activation", ...
    "Anconeus Activation", "Deltoid M Activation", "Short Anconeus Activation", ...
    "Subscapularis SuperiorHead Activation", "Infraspinatus Activation", ...
    "Pronator Teres Activation", "Flexor Carpi Radialis Activation", ...
    "Brachioradialis  Activation", "Pectoralis Clavicle Head", ...
    "Biceps Short Head", "Biceps Long Head", "Deltoid A", ...
    "Triceps Short Head", "Triceps Long Head", "Brachialis inner Head", ...
    "Brachialis Outer Head", "Anconeus", "Deltoid M", "Short Anconeus", ...
    "Subscapularis SuperiorHead", "Infraspinatus", "Pronator Teres", ...
    "Flexor Carpi Radialis", "Brachioradialis"];

% --- Kinematic predictor names (position, velocity, acceleration, displacement, etc.)
% plus the above model_info features
Predictor_names = ["Pos X", "Pos Y", "Pos Z", "Vel", "Vel X", "Vel X Up", ...
    "Vel X Down", "Vel Y", "Vel Y Up", "Vel Y Down", "Vel Z", "Vel Z Up", ...
    "Vel Z Down", "Acc", "Acc X", "Acc X Up", "Acc X Down", "Acc Y", ...
    "Acc Y Up", "Acc Y Down", "Acc Z", "Acc Z Up", "Acc Z Down", "X Vel", ...
    "Y Vel", "Z Vel", "Vel Norm", "X Acc", "Y Acc", "Z Acc", "Acc Norm", ...
    "X Disp", "Y Disp", "Z Disp", "Disp Norm", model_info];

% --- Create output directory for lag boxplots ---
mkdir("C:\Lab\Elbow Data\lag_boxplots")

% --- Pre-allocate cell arrays to store lag data ---
all_PC_same   = cell(1, length(Predictor_names));   % best lags for real PC data
shuff_same    = cell(1, length(Predictor_names));   % best lags for shuffled control data

dt = 0.01;        % time step (s)
min_lag = 60;     % offset used to convert indices to seconds

% -------------------------------
% Collect lag values for selected features across sessions
% -------------------------------

selected_feats = [1, 2, 48, 69];  % indices of features to analyze
all_PC_same_combined = cell(1, length(selected_feats)); % store real PC lag data
shuff_combined       = cell(1, length(selected_feats)); % store shuffled lag data

% --- Loop through real data sessions and collect PC_same lags ---
for session_num = [1, 2, 3, 4, 12, 14, 18, 21]
    for idx = 1:length(selected_feats)
        feat = selected_feats(idx);

        % Load previously computed best lags for this feature and session
        load("C:\Lab\Elbow Data\Best Lags\" + string(Predictor_names(feat)) + ...
             "\30 ms Session " + string(session_num) + " PC same", "PC_same")

        % Convert lag indices to time (seconds)
        PC_same_lags = (PC_same(:) - (min_lag + 1)) * dt;

        % Append to combined dataset
        all_PC_same_combined{idx} = [all_PC_same_combined{idx}; PC_same_lags];
    end
end

% --- Loop through shuffled datasets for comparison ---
for session_num = [1, 2, 3, 4, 12, 14, 18, 21]
    for iter = 1:10
        for idx = 1:length(selected_feats)
            feat = selected_feats(idx);

            % Load best lags from shuffled neural data
            load("C:\Lab\Elbow Data\Best Lags\" + string(Predictor_names(feat)) + ...
                 "\shuff " + string(iter) + "Session " + string(session_num) + " PC same", "PC_same")

            % Convert lag indices to time
            shuff_lags = (PC_same(:) - (min_lag + 1)) * dt;

            % Append to shuffled dataset
            shuff_combined{idx} = [shuff_combined{idx}; shuff_lags];
        end
    end
end

% -------------------------------
% Plot boxplots comparing real vs shuffled lag distributions
% -------------------------------

data_sets = {all_PC_same_combined, shuff_combined};

handle = figure('units','normalized','outerposition',[0 0 1 1], 'Visible','on');
set(gcf, 'Color', 'w');
set(gca, 'TickLabelInterpreter', 'none');

% --- Top subplot: real PC lags ---
subplot(2, 1, 1)
hold on
data_mat = all_data_to_matrix(data_sets{1});   % convert cell array to matrix
boxplot(data_mat, 'Labels', selected_feats);   % plot boxplots
title("PC Lags", FontSize=22);
ylabel('Time Lag (s)', FontSize=18);
ylim([-0.5, 0.5])
xlabel("Feature Index", FontSize=18)
xtickangle(45);
set(gca, 'FontSize', 14)

% --- Bottom subplot: shuffled lag controls ---
subplot(2, 1, 2)
hold on
data_mat = all_data_to_matrix(data_sets{2});
boxplot(data_mat, 'Labels', selected_feats);
title("Shuffled Lags", FontSize=22);
ylabel('Time Lag (s)', FontSize=18);
ylim([-0.5, 0.5])
xlabel("Feature Index", FontSize=18)
xtickangle(45);
set(gca, 'FontSize', 14)

% Save figures to thesis folder
filename = ("C:\Lab\Elbow Data\thesis_figs\lag corr.svg");
saveas(handle, filename)
filename = ("C:\Lab\Elbow Data\thesis_figs\lag corr.png");
saveas(handle, filename)

% -------------------------------
% Helper function: convert cell array of vectors to padded matrix
% -------------------------------
function M = all_data_to_matrix(cell_data)
    max_len = max(cellfun(@numel, cell_data));     % find maximum length
    M = NaN(max_len, numel(cell_data));            % preallocate with NaNs
    for i = 1:numel(cell_data)
        len = numel(cell_data{i});
        M(1:len, i) = cell_data{i};                % fill each column
    end
end
