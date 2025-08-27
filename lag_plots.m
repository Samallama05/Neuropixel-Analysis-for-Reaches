close all;
clear all;

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
Predictor_names = ["Pos X", "Pos Y", "Pos Z", "Vel", "Vel X", "Vel X Up",  ...
    "Vel X Down", "Vel Y", "Vel Y Up", "Vel Y Down", "Vel Z", "Vel Z Up", ...
    "Vel Z Down", "Acc", "Acc X", "Acc X Up", "Acc X Down", "Acc Y", ...
    "Acc Y Up", "Acc Y Down", "Acc Z", "Acc Z Up", "Acc Z Down" "X Vel", ...
    "Y Vel", "Z Vel", "Vel Norm", "X Acc", "Y Acc", "Z Acc", "Acc Norm", ...
    "X Disp", "Y Disp", "Z Disp", "Disp Norm", model_info];

%feat = find(strcmp(Predictor_names, "Biceps Short Head Activation"));
mkdir("C:\Lab\Elbow Data\lag_boxplots")
all_PC_same = cell(1, length(Predictor_names));
shuff_same    = cell(1, length(Predictor_names));
dt = 0.01;
min_lag = 60;

%{
for session_num = [1, 2, 3, 4, 5, 12, 14, 18, 21]
    all_best_lags = {};       % Cell array to store transformed lags
    
    for feat = [1, 2, 3, 48, 68. 69]
    %for feat = 1:length(Predictor_names)
        load("C:\Lab\Elbow Data\Best Lags\" + string(Predictor_names(feat)) + "\30 ms Session " + string(session_num) + " PC same", "PC_same")
        load("C:\Lab\Elbow Data\Best Lags\" + string(Predictor_names(feat)) + "\30 ms Session " + string(session_num) + " PC opp", "PC_opp")
        load("C:\Lab\Elbow Data\Best Lags\" + string(Predictor_names(feat)) + "\30 ms Session " + string(session_num) + " Non PC opp", "opp")
        load("C:\Lab\Elbow Data\Best Lags\" + string(Predictor_names(feat)) + "\30 ms Session " + string(session_num) + " Non PC same", "same")

        all_PC_same{feat} = (PC_same(:) - (min_lag + 1)) * dt;
        all_PC_opp{feat}  = (PC_opp(:) - (min_lag + 1)) * dt;
        all_same{feat}    = (same(:) - (min_lag + 1)) * dt;
        all_opp{feat}     = (opp(:) - (min_lag + 1)) * dt;
    end

    data_sets = {all_PC_same, all_PC_opp, all_same, all_opp};

    %PC SAME
    handle = figure('units','normalized','outerposition',[0 0 1 1], 'Visible','on');
    set(gcf,'color','w') % This makes the figure white instead of grey.
    set(gca, 'TickLabelInterpreter', 'none')
    data_mat = all_data_to_matrix(data_sets{1});
    

    boxplot(data_mat, 'Labels', Predictor_names([1, 2, 3, 48, 68. 69]));
    hold on

    for j = 1:size(data_mat, 2)  % Loop through each feature (column)
        x_jitter = 0.1 * randn(sum(~isnan(data_mat(:, j))), 1);  % Add small jitter to x-position
        y_vals = data_mat(~isnan(data_mat(:, j)), j);            % Only non-NaN values
        scatter(j + x_jitter, y_vals, 20, 'filled', 'MarkerFaceAlpha', 0.5); % Semi-transparent
    end
    
    title("Session " + string(session_num) + " " + "PC Same Lags");
    ylabel('Time Lag (s)');
    xlabel("Features")
    xtickangle(45);
    fname = "C:\Lab\Elbow Data\lag_boxplots\30 ms Session " + string(session_num) + " PC Same Lags (scatter).png";
    saveas(handle, fname);

    %PC OPP
    handle = figure('units','normalized','outerposition',[0 0 1 1], 'Visible','off');
    set(gcf,'color','w') % This makes the figure white instead of grey.
    set(gca, 'TickLabelInterpreter', 'none')
    data_mat = all_data_to_matrix(data_sets{2});

    boxplot(data_mat, 'Labels', Predictor_names);
    hold on

    for j = 1:size(data_mat, 2)  % Loop through each feature (column)
        x_jitter = 0.1 * randn(sum(~isnan(data_mat(:, j))), 1);  % Add small jitter to x-position
        y_vals = data_mat(~isnan(data_mat(:, j)), j);            % Only non-NaN values
        scatter(j + x_jitter, y_vals, 20, 'filled', 'MarkerFaceAlpha', 0.5); % Semi-transparent
    end

    title("Session " + string(session_num) + " " + "PC Opp Lags");
    ylabel('Time Lag (s)');
    xlabel("Features")
    xtickangle(45);
    fname = "C:\Lab\Elbow Data\lag_boxplots\30 ms Session " + string(session_num) + " PC Opp Lags (scatter).png";
    saveas(handle, fname);

    %PC SAME
    handle = figure('units','normalized','outerposition',[0 0 1 1], 'Visible','off');
    set(gcf,'color','w') % This makes the figure white instead of grey.
    set(gca, 'TickLabelInterpreter', 'none')
    data_mat = all_data_to_matrix(data_sets{3});

    boxplot(data_mat, 'Labels', Predictor_names);
    hold on
    
    for j = 1:size(data_mat, 2)  % Loop through each feature (column)
        x_jitter = 0.1 * randn(sum(~isnan(data_mat(:, j))), 1);  % Add small jitter to x-position
        y_vals = data_mat(~isnan(data_mat(:, j)), j);            % Only non-NaN values
        scatter(j + x_jitter, y_vals, 20, 'filled', 'MarkerFaceAlpha', 0.5); % Semi-transparent
    end

    title("Session " + string(session_num) + " " + "Non PC Same Lags");
    ylabel('Time Lag (s)');
    xlabel("Features")
    xtickangle(45);
    fname = "C:\Lab\Elbow Data\lag_boxplots\30 ms Session " + string(session_num) + " Non PC Same Lags (scatter).png";
    saveas(handle, fname);

    %PC SAME
    handle = figure('units','normalized','outerposition',[0 0 1 1], 'Visible','off');
    set(gcf,'color','w') % This makes the figure white instead of grey.
    set(gca, 'TickLabelInterpreter', 'none')
    data_mat = all_data_to_matrix(data_sets{4});

    boxplot(data_mat, 'Labels', Predictor_names);
    hold on

    for j = 1:size(data_mat, 2)  % Loop through each feature (column)
        x_jitter = 0.1 * randn(sum(~isnan(data_mat(:, j))), 1);  % Add small jitter to x-position
        y_vals = data_mat(~isnan(data_mat(:, j)), j);            % Only non-NaN values
        scatter(j + x_jitter, y_vals, 20, 'filled', 'MarkerFaceAlpha', 0.5); % Semi-transparent
    end

    title("Session " + string(session_num) + " " + "Non PC Opp Lags");
    ylabel('Time Lag (s)');
    xlabel("Features")
    xtickangle(45);
    fname = "C:\Lab\Elbow Data\lag_boxplots\30 ms Session " + string(session_num) + " Non PC Opp Lags (scatter).png";
    saveas(handle, fname);
end

%}
selected_feats = [1, 2, 48, 69];
all_PC_same_combined = cell(1, length(selected_feats));
shuff_combined    = cell(1, length(selected_feats));


for session_num = [1, 2, 3, 4, 12, 14, 18, 21]
    for idx = 1:length(selected_feats)
        feat = selected_feats(idx);

        load("C:\Lab\Elbow Data\Best Lags\" + string(Predictor_names(feat)) + "\30 ms Session " + string(session_num) + " PC same", "PC_same")

        % Transform lags to seconds
        PC_same_lags = (PC_same(:) - (min_lag + 1)) * dt;

        % Append to combined data
        all_PC_same_combined{idx} = [all_PC_same_combined{idx}; PC_same_lags];
    end
end

for session_num = [1, 2, 3, 4, 12, 14, 18, 21]
    for iter = 1:10
        for idx = 1:length(selected_feats)
            feat = selected_feats(idx);

            load("C:\Lab\Elbow Data\Best Lags\" + string(Predictor_names(feat)) + "\shuff " + string(iter) + "Session " + string(session_num) + " PC same", "PC_same")

            % Transform lags to seconds
            shuff_lags    = (PC_same(:)    - (min_lag + 1)) * dt;

            % Append to combined data
            shuff_combined{idx}    = [shuff_combined{idx}; shuff_lags];
        end
    end
end

data_sets = {all_PC_same_combined, shuff_combined};
selected_feats = [1, 2, 48, 69];

% Create figure
handle = figure('units','normalized','outerposition',[0 0 1 1], 'Visible','on');
set(gcf, 'Color', 'w');
set(gca, 'TickLabelInterpreter', 'none');

% --- PC Same
subplot(2, 1, 1)
hold on
data_mat = all_data_to_matrix(data_sets{1});
boxplot(data_mat, 'Labels', selected_feats);
title("PC Lags", FontSize=22);
ylabel('Time Lag (s)', FontSize=18);
ylim([-0.5, 0.5])
xlabel("Feature Index", FontSize=18)
xtickangle(45);
set(gca, 'FontSize', 14)

% --- Non-PC Same
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

filename = ("C:\Lab\Elbow Data\thesis_figs\lag corr.svg");
saveas(handle, filename)

filename = ("C:\Lab\Elbow Data\thesis_figs\lag corr.png");
saveas(handle, filename)

function M = all_data_to_matrix(cell_data)
max_len = max(cellfun(@numel, cell_data));
M = NaN(max_len, numel(cell_data));
for i = 1:numel(cell_data)
    len = numel(cell_data{i});
    M(1:len, i) = cell_data{i};
end
end
