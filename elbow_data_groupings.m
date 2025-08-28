%{
This MATLAB script generates visualization figures that align neural activity from individual cells with behavioral kinematic features on a per-reach basis. For a selected predictor (e.g., a muscle activation or 
joint angle) and session, it loads the sorted neural and kinematic data along with precomputed RMSE and correlation values. It identifies the optimal lag (time offset) where the cell’s activity best predicts the 
chosen feature, provided the fit is sufficiently good (RMSE ≤ 0.2). Using this lag, the code extracts repeated reach-aligned segments of both the neural signal and the behavioral feature, organizes them into 
per-reach trials, and then plots: (1) the neural activity per reach, (2) the behavioral feature per reach, (3) the mean neural activity across reaches, and (4) the mean behavioral profile across reaches. Each 
figure is annotated with the cell ID, predictor name, session, and computed optimal lag, then saved in multiple formats for use in analysis
%}

close all;        % Close any open figures
clear all;        % Clear workspace variables

% --- Session names and metadata (not directly used in this plotting script) ---
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

reach_num = [74, 65, 62, 63, 52, 66, 54, 60, 68, 52, 73, 59, 80, 68, 71, ...
    68, 60, 53, 58, 58, 36, 70, 57, 45];

% --- Model (biomechanical) feature labels ---
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

% --- Predictor names (kinematics/derived + model_info) ---
Predictor_names = ["Pos X", "Pos Y", "Pos Z", "Vel", "Vel X", "Vel X Up",  ...
    "Vel X Down", "Vel Y", "Vel Y Up", "Vel Y Down", "Vel Z", "Vel Z Up", ...
    "Vel Z Down", "Acc", "Acc X", "Acc X Up", "Acc X Down", "Acc Y", ...
    "Acc Y Up", "Acc Y Down", "Acc Z", "Acc Z Up", "Acc Z Down", "X Vel", ...  % <-- comma here
    "Y Vel", "Z Vel", "Vel Norm", "X Acc", "Y Acc", "Z Acc", "Acc Norm", ...
    "X Disp", "Y Disp", "Z Disp", "Disp Norm", model_info];

% --- Output directories for figures (PC/Non-PC groupings & rejects) ---
mkdir("C:\Lab\Elbow Data\lag_graphs\30ms_RMSE")
mkdir("C:\Lab\Elbow Data\lag_graphs\30ms_RMSE\reject PC groupings")
mkdir("C:\Lab\Elbow Data\lag_graphs\30ms_RMSE\reject Non PC groupings")

% --- Windowing/stride and time base settings ---
min_lag  = 60;    % samples before reach window (used as pre-window spacing)
max_lag  = 15;    % samples after reach window (used as post-window spacing)
reach_len = 40;   % samples per reach window
dt = 0.01;        % sample period in seconds (used for labeling optimal lag)

% --- Feature selection loop ---
%48 refers to biceps long head activation. using a find string would probably be better
for feat = 48
    % Create per-feature output folders for PCs and Non-PCs, mirror/reflect splits
    mkdir("C:\Lab\Elbow Data\lag_graphs\30ms_RMSE\PC groupings\" + Predictor_names(feat))
    mkdir("C:\Lab\Elbow Data\lag_graphs\30ms_RMSE\PC groupings\" + Predictor_names(feat) + "\mirror")
    mkdir("C:\Lab\Elbow Data\lag_graphs\30ms_RMSE\PC groupings\" + Predictor_names(feat) + "\reflect")

    mkdir("C:\Lab\Elbow Data\lag_graphs\30ms_RMSE\Non PC groupings\" + Predictor_names(feat))
    mkdir("C:\Lab\Elbow Data\lag_graphs\30ms_RMSE\Non PC groupings\" + Predictor_names(feat) + "\mirror")
    mkdir("C:\Lab\Elbow Data\lag_graphs\30ms_RMSE\Non PC groupings\" + Predictor_names(feat) + "\reflect")

    best_lags = [];  % placeholder (not used further below)

    % --- Session loop (here restricted to session 12) ---
    for session_num = 12
        % Load aligned kinematics and neural data for this session
        load("C:\Lab\Elbow Data\sorted_data\Session_" + string(session_num) + "_kin_test.mat", "kinematics")
        load("C:\Lab\Elbow Data\sorted_data\Session_" + string(session_num) + "_neural_test.mat", "neuro_data")
        load("C:\Lab\neuropixel_data\PC_cell_info\session_" + string(session_num) + ".mat", "PC")

        % Build a colormap with one color per reach segment (based on how many
        % non-overlapping windows of length (min_lag + reach_len + max_lag) fit)
        je = jet(floor(length(neuro_data)/(reach_len + min_lag + max_lag)));

        % --- Cell loop (restricted to a single cell index 19) ---
        for i = 19
            % Load precomputed per-lag RMSE and correlations for this cell
            load("C:\Lab\Elbow Data\corrs\Session " + string(session_num) + "\aligned_cell_" + string(i) + "_rmse", "RMSE")
            load("C:\Lab\Elbow Data\corrs\Session " + string(session_num) + "\aligned_cell_" + string(i) + "_corrs", "corrs")

            % Find best lag (minimum RMSE) for this feature, skipping first 30 rows as we are interested in lag from -300ms onwards.
            [minValue, relIndex] = min(RMSE(31:end, feat));
            minIndex = relIndex + 30;  % convert back to absolute row

            % Only continue if fit is good enough (RMSE threshold)
            if minValue <= 0.2
                % --- Build per-reach matrices for neural (Palt) and kinematics (Kalt) ---

                % Palt: neural activity segments, starting at best lag and then
                % stepping by (min_lag + reach_len + max_lag)
                Palt = [];
                startid = minIndex;
                for m = 1:floor(length(neuro_data)/(min_lag + reach_len + max_lag))
                    Palt(:, m) = neuro_data(startid:startid+reach_len-1, i);
                    startid = startid + (min_lag + reach_len + max_lag);
                end

                % Kalt: kinematic segments for the same feature, tiled every reach_len
                Kalt = [];
                startid = 1;
                for k = 1:floor(length(kinematics)/(reach_len))
                    Kalt(:, k) = kinematics(startid:startid+(reach_len-1), feat);
                    startid = startid + (reach_len);
                end

                % --- Figure layout with 4 panels (2x2) ---
                handle = figure('units','normalized','outerposition',[0 0 1 1], 'Visible','off');
                set(gcf,'color','w')               % white background

                % Panel (1,1): Neural activity per reach (colored by reach)
                subplot(2,2,1)
                hold on
                title("Cell " + string(i) + " Activity Per Reach", FontSize=22)
                xlabel("Time (ms)", FontSize=18)   % NOTE: currently plotting sample index, not time
                ylabel("Firing Rate (Hz)", FontSize=18)
                set(gca, 'FontSize', 14)
                for reach = 1:size(Palt, 2)
                    plot(Palt(:,reach), Color=je(reach,:), LineWidth=2);
                end

                % Panel (2,1): Kinematic feature per reach
                subplot(2, 2, 3)
                hold on
                title(Predictor_names(feat) + " Behaviour Per Reach", FontSize=22)
                xlabel("Time (ms)", FontSize=18)   % NOTE: likewise, sample index
                ylabel("Behaviour", FontSize=18)
                set(gca, 'FontSize', 14)
                for reach = 1:size(Kalt, 2)
                    plot(Kalt(:,reach), Color=je(reach,:), LineWidth=2);
                end

                % Panel (2,2): Mean kinematic feature across reaches
                subplot(2, 2, 4)
                hold on
                plot(mean(Kalt'), LineWidth=2)     % mean over reaches, per timepoint
                title(Predictor_names(feat) + " Mean Behaviour", FontSize=22)
                xlabel("Time (ms)", FontSize=18)
                ylabel("Behaviour", FontSize=18)
                set(gca, 'FontSize', 14)

                % Panel (1,2): Mean neural activity across reaches
                subplot(2, 2, 2)
                hold on
                plot(mean(Palt'), LineWidth=2)     % mean over reaches, per timepoint
                title(Predictor_names(feat) + " Mean Cell Activity", FontSize=22)
                xlabel("Time (ms)", FontSize=18)
                ylabel("Firing Rate (Hz)", FontSize=18)
                set(gca, 'FontSize', 14)

                % --- Overall title with session, cell, feature, and optimal lag (in seconds) ---
                sgtitle("PC Cell " + string(i) + ", " + Predictor_names(feat) + ...
                        ", Optimal Lag " + string((minIndex - (min_lag + 1))*dt) + ...
                        ", Session " + string(session_num) + ")", fontsize = 24)

                % --- Save figure to thesis folder (SVG + PNG). Note: filenames are static and will overwrite. ---
                filename = ("C:\Lab\Elbow Data\thesis_figs\sample cell feat reflect.svg");
                saveas(handle, filename)

                filename = ("C:\Lab\Elbow Data\thesis_figs\sample cell feat reflect.png");
                saveas(handle, filename)

                close all;  % close the figure to free resources
            end
        end
    end
end

close all;  % extra safety close
