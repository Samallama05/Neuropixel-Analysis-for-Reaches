%{
This MATLAB script automates the identification and categorization of “best lag” values between neural activity and behavioral/biomechanical predictors across multiple sessions, shuffles, and cells. 
For each kinematic or muscle-related feature, it iterates over selected recording sessions and repeated shuffle iterations, loads precomputed RMSE and correlation values for each cell, and determines 
the lag that minimizes RMSE while satisfying a performance threshold (≤ 0.2). Cells are then grouped based on whether they are labeled as Purkinje cells (PCs) or non-PCs, and further subdivided according 
to whether the correlation at the best lag is positive (“same”) or negative (“opposite”). The resulting lag indices for each category (PC same, PC opposite, non-PC same, non-PC opposite) are saved into
organized feature-specific folders
%}

close all;
clear all;

% --- Session identifiers for your datasets (24 sessions total). These are referred to in save files as session 1 - 24 ---
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

% --- Number of reaches per session (aligned with 'sessions' order) ---
reach_num = [74, 65, 62, 63, 52, 66, 54, 60, 68, 52, 73, 59, 80, 68, 71, ...
    68, 60, 53, 58, 58, 36, 70, 57, 45];

% --- Model/feature labels (muscle angles/speeds/activations, etc.) ---
model_info = ["Shoulder Elv Angle Value", "Shoulder Extension Angle Value",   ...
    "Elbow Flex Value", "Ulna Radius Rot Value", "Wrist Angle Value", "Shoulder Elv Angle Speed",  ...
    "Shoulder Extension Angle Speed", "Elbow Flex Speed", "Ulna Radius Rot Speed", "Wrist Angle Speed",  ...
    "Pectoralis Clavicle Head Activation", "Biceps Short Head Activation", "Biceps Long Head Activation",   ...
    "Deltoid A Activation", "Triceps Short Head Activation", "Triceps Long Head Activation",   ...
    "Brachialis inner Head Activation", "Brachialis Outer Head Activation", "Anconeus Activation",   ...
    "Deltoid M Activation", "Short Anconeus Activation", "Subscapularis SuperiorHead Activation",  ...
    "Infraspinatus Activation", "Pronator Teres Activation", "Flexor Carpi Radialis Activation",  ...
    "Brachioradialis  Activation", "Pectoralis Clavicle Head", "Biceps Short Head", "Biceps Long Head",  ...
    "Deltoid A", "Triceps Short Head", "Triceps Long Head", "Brachialis inner Head", "Brachialis Outer Head",  ...
    "Anconeus", "Deltoid M", "Short Anconeus", "Subscapularis SuperiorHead", "Infraspinatus",  ...
    "Pronator Teres", "Flexor Carpi Radialis", "Brachioradialis"];

% --- Kinematic/derived predictor names + model_info combined ---
Predictor_names = ["Pos X", "Pos Y", "Pos Z", "Vel", "Vel X", "Vel X Up",  ...
    "Vel X Down", "Vel Y", "Vel Y Up", "Vel Y Down", "Vel Z", "Vel Z Up", ...
    "Vel Z Down", "Acc", "Acc X", "Acc X Up", "Acc X Down", "Acc Y", ...
    "Acc Y Up", "Acc Y Down", "Acc Z", "Acc Z Up", "Acc Z Down", "X Vel", ...
    "Y Vel", "Z Vel", "Vel Norm", "X Acc", "Y Acc", "Z Acc", "Acc Norm", ...
    "X Disp", "Y Disp", "Z Disp", "Disp Norm", model_info];

% --- Ensure output root folder exists ---
mkdir("C:\Lab\Elbow Data\Best Lags")

% --- Loop over each predictor (feature) ---
for feat = 1:length(Predictor_names)

    % Create a subfolder per predictor to store best-lag results
    mkdir("C:\Lab\Elbow Data\Best Lags\" + string(Predictor_names(feat)))

    % Process only a subset of sessions by index. Sessions were chosen based of most PC cells or good CEBRA R2 correlations. All sessions are to be added eventually
    for session_num = [1, 2, 3, 4, 12, 14, 18, 21]

        % Repeat analysis over multiple shuffles/iterations. Multiple iterations are only to be done for shuffled data
        for iter = 1:10

            % Load PC cell identity (1 = PC, 0 = non-PC) for this session. Gotten from PC sort script.
            load("C:\Lab\neuropixel_data\PC_cell_info\session_" + string(session_num) + ".mat", "PC")

            % Load shuffled neural data (not directly used below, but retained for context)
            load("C:\Lab\Elbow Data\shuffled\Session " + string(session_num) + "\shuffled_" + string(iter) + "_neural.mat", "shuff_all_cells")

            % Initialize arrays of best lags (indices) for each category:
            % PCs with same-sign correlation, PCs with opposite sign, and likewise for non-PCs.
            PC_same = [];
            PC_opp  = [];
            same    = [];
            opp     = [];

            % Iterate through each cell in the shuffled set
            for cell = 1:size(shuff_all_cells, 2)

                % Load per-lag RMSE and correlation arrays for this cell, shuffle, and session
                load("C:\Lab\Elbow Data\corrs\Session " + string(session_num) + "\shuffled_" + string(iter) + "cell_" + string(cell) + "_rmse",  "RMSE")
                load("C:\Lab\Elbow Data\corrs\Session " + string(session_num) + "\shuffled_" + string(iter) + "cell_" + string(cell) + "_corrs", "corrs")

                % Find the minimum RMSE (best lag) for the current feature, but only from row 31 onward
                % (31 onwards is to remove the lag portion we are not interested in. the save files contain lab -600ms to +150ms. We were only interested in -300ms to +150ms)
                [minValue, relIndex] = min(RMSE(31:end, feat));

                % Convert relative index back to absolute row by adding the 30-row offset
                minIndex = relIndex + 30;

                % Apply an RMSE quality threshold before classifying by correlation sign
                if (minValue) <= 0.2

                    % Split PCs vs Non-PCs using 'PC(cell)' flag
                    if PC(cell) == 1
                        % Negative correlation => "opp", positive/non-negative => "same"
                        if corrs(minIndex, feat) < 0
                            PC_opp = [PC_opp minIndex];
                        else
                            PC_same = [PC_same minIndex];
                        end
                    else
                        % Non-PC classification by correlation sign
                        if corrs(minIndex, feat) < 0
                            opp = [opp minIndex];
                        else
                            same = [same minIndex];
                        end
                    end
                end
            end

            % --- Save per-iteration/per-session results grouped by predictor ---
            % PCs (same and opposite)
            save("C:\Lab\Elbow Data\Best Lags\" + string(Predictor_names(feat)) + ...
                 "\shuff " + string(iter) + "Session " + string(session_num) + " PC same", "PC_same")

            save("C:\Lab\Elbow Data\Best Lags\" + string(Predictor_names(feat)) + ...
                 "\shuff " + string(iter) + "Session " + string(session_num) + " PC opp", "PC_opp")

            % Non-PCs (same and opposite)
            save("C:\Lab\Elbow Data\Best Lags\" + string(Predictor_names(feat)) + ...
                 "\shuff " + string(iter) + "Session " + string(session_num) + " Non PC opp", "opp")

            save("C:\Lab\Elbow Data\Best Lags\" + string(Predictor_names(feat)) + ...
                 "\shuff " + string(iter) + "Session " + string(session_num) + " Non PC same", "same")

        end % iter
    end % session_num
end % feat
