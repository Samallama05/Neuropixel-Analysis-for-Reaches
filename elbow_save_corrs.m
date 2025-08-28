%{
This MATLAB script computes lag-dependent correlations and prediction errors between shuffled neural activity and kinematic features across multiple experimental sessions. For each session and shuffle iteration, it 
loads preprocessed kinematic signals and shuffled neural cell activity. It then systematically tests different temporal lags (from –60 to +15 samples) to align neural firing with kinematic features. For each lag and 
feature, it builds reach-aligned segments of both neural and kinematic data, averages across trials, and compares the signals. Two metrics are calculated: 
RMSE (Root Mean Squared Error) from a linear regression fit between neural and kinematic averages.
Pearson correlation coefficient between the same normalized averages.
%}

close all;        % Close any open figures
clear all;        % Clear all variables from workspace

% --- Session identifiers (dataset names) ---
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

% --- Number of reaches per session (aligned with 'sessions') ---
reach_num = [74, 65, 62, 63, 52, 66, 54, 60, 68, 52, 73, 59, 80, 68, 71, ...
    68, 60, 53, 58, 58, 36, 70, 57, 45];

% --- Model feature names (joint angles, speeds, muscle activations, etc.) ---
model_info = ["Shoulder Elv Angle Value", "Shoulder Extension Angle Value", "Elbow Flex Value", ...
    "Ulna Radius Rot Value", "Wrist Angle Value", "Shoulder Elv Angle Speed", "Shoulder Extension Angle Speed", ...
    "Elbow Flex Speed", "Ulna Radius Rot Speed", "Wrist Angle Speed", ...
    "Pectoralis Clavicle Head Activation", "Biceps Short Head Activation", "Biceps Long Head Activation", ...
    "Deltoid A Activation", "Triceps Short Head Activation", "Triceps Long Head Activation", ...
    "Brachialis inner Head Activation", "Brachialis Outer Head Activation", "Anconeus Activation", ...
    "Deltoid M Activation", "Short Anconeus Activation", "Subscapularis SuperiorHead Activation", ...
    "Infraspinatus Activation", "Pronator Teres Activation", "Flexor Carpi Radialis Activation", ...
    "Brachioradialis Activation", "Pectoralis Clavicle Head", "Biceps Short Head", "Biceps Long Head", ...
    "Deltoid A", "Triceps Short Head", "Triceps Long Head", "Brachialis inner Head", "Brachialis Outer Head", ...
    "Anconeus", "Deltoid M", "Short Anconeus", "Subscapularis SuperiorHead", "Infraspinatus", ...
    "Pronator Teres", "Flexor Carpi Radialis", "Brachioradialis"];

% --- Combined list of predictors (position, velocity, acceleration + model_info) ---
Predictor_names = ["Pos X", "Pos Y", "Pos Z", "Vel", "Vel X", "Vel X Up", ...
    "Vel X Down", "Vel Y", "Vel Y Up", "Vel Y Down", "Vel Z", "Vel Z Up", ...
    "Vel Z Down", "Acc", "Acc X", "Acc X Up", "Acc X Down", "Acc Y", ...
    "Acc Y Up", "Acc Y Down", "Acc Z", "Acc Z Up", "Acc Z Down", "X Vel", ...
    "Y Vel", "Z Vel", "Vel Norm", "X Acc", "Y Acc", "Z Acc", "Acc Norm", ...
    "X Disp", "Y Disp", "Z Disp", "Disp Norm", model_info];

% --- Output directory for correlation/RMSE results ---
mkdir("C:\Lab\Elbow Data\corrs")

% --- Analysis parameters ---
min_lag = 60;        % # of samples before reach onset
max_lag = 15;        % # of samples after reach onset
reach_len = 40;      % # of samples in each reach window
corrs = [];          % Initialize correlation matrix
RMSE = [];           % Initialize RMSE matrix

% --- Loop over selected sessions ---
for session_num = [1, 2, 3, 4, 12, 14, 18, 21]
    % --- Repeat analysis with shuffled neural data (10 iterations) ---
    for iter = 1:10
        disp("Session Num: " + string(session_num) + ", Iteration: " + string(iter))

        lag_t = 60;           % lag window size
        step_size = 1;        % step size for lag search
        lag = lag_t/step_size;

        % --- Make session-specific output folder ---
        mkdir("C:\Lab\Elbow Data\corrs\Session " + string(session_num))

        % --- Load kinematic data, shuffled neural data, and PC cell info ---
        load("C:\Lab\Elbow Data\sorted_data\Session_" + string(session_num) + "_kin_test.mat", "kinematics")
        load("C:\Lab\Elbow Data\shuffled\Session " + string(session_num) + "\shuffled_" + string(iter) + "_neural.mat", "shuff_all_cells")
        load("C:\Lab\neuropixel_data\PC_cell_info\session_" + string(session_num) + ".mat")

        % --- Loop through each cell in shuffled neural dataset ---
        for i = 1:size(shuff_all_cells, 2)
            % --- Sweep across lags (negative to positive relative offsets) ---
            for n = -min_lag:max_lag
                % Extract neural data aligned at this lag
                Palt = [];
                startid = min_lag + n + 1;
                for m = 1:floor(length(shuff_all_cells)/(min_lag + reach_len + max_lag))
                    Palt(:, m) = shuff_all_cells(startid:startid+reach_len-1, i);
                    startid = startid + (min_lag + reach_len + max_lag);
                end

                % --- Loop through all kinematic features ---
                for j = 1:size(kinematics, 2)
                    % Extract kinematic data aligned to reaches
                    Kalt = [];
                    startid = 1;
                    for k = 1:floor(length(kinematics)/(reach_len))
                        Kalt(:, k) = kinematics(startid:startid+(reach_len-1), j);
                        startid = startid + reach_len;
                    end

                    % --- Compute model fit and errors ---
                    % Fit linear model between average kinematics and average neural activity
                    r2 = fitlm(normalize(mean(Kalt')', "range"), normalize(mean(Palt')', "range"));

                    % Store RMSE value for this lag and feature
                    RMSE(n + (min_lag + 1), j) = r2.RMSE;

                    % Remove NaN trials before computing Pearson correlation
                    Kalt = Kalt(:, all(~isnan(Kalt)));
                    Palt = Palt(:, all(~isnan(Palt)));

                    % Compute Pearson correlation between normalized averages
                    pearson_corr = corr(normalize(mean(Kalt')', "range"), normalize(mean(Palt')', "range"));
                    corrs(n + (min_lag + 1), j) = pearson_corr;
                end
            end

            % --- Save results for this cell and shuffle iteration ---
            save("C:\Lab\Elbow Data\corrs\Session " + string(session_num) + ...
                 "\shuffled_" + string(iter) + "cell_" + string(i) + "_rmse", "RMSE")
            save("C:\Lab\Elbow Data\corrs\Session " + string(session_num) + ...
                 "\shuffled_" + string(iter) + "cell_" + string(i) + "_corrs", "corrs")
        end
    end
end
