%{
This script performs an exploratory clustering analysis on neural activity aligned to reaches. First, it loads preprocessed neural and kinematic data for a specific session, cell, and feature 
(in this case, acceleration). Using a chosen lag offset, the script extracts repeated segments of neural firing rates (Palt) and corresponding kinematic values (Kalt) across all reaches. These 
segments are organized so that each reach trial becomes one data point, with its temporal firing rate pattern as features. The script then applies K-means clustering to the neural activity, 
testing different numbers of clusters (from 1 to 10) and computing the within-cluster sum of squares (WCSS) for each. Finally, it plots the “Elbow curve,” which helps identify the optimal number
of clusters by finding the point where additional clusters no longer reduce WCSS substantially.
%}

close all;        % Close any open figures
clear all;        % Clear workspace variables

% --- Session identifiers (not directly used in this script) ---
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

% --- Number of reaches per session (parallel to 'sessions') ---
reach_num = [74, 65, 62, 63, 52, 66, 54, 60, 68, 52, 73, 59, 80, 68, 71, ...
    68, 60, 53, 58, 58, 36, 70, 57, 45];

% --- Muscle/joint-related predictor labels ---
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

% --- Combined predictor list (kinematics + model_info) ---
Predictor_names = ["Pos X", "Pos Y", "Pos Z", "Vel", "Vel X", "Vel X Up",  ...
    "Vel X Down", "Vel Y", "Vel Y Up", "Vel Y Down", "Vel Z", "Vel Z Up", ...
    "Vel Z Down", "Acc", "Acc X", "Acc X Up", "Acc X Down", "Acc Y", ...
    "Acc Y Up", "Acc Y Down", "Acc Z", "Acc Z Up", "Acc Z Down", "X Vel", ...
    "Y Vel", "Z Vel", "Vel Norm", "X Acc", "Y Acc", "Z Acc", "Acc Norm", ...
    "X Disp", "Y Disp", "Z Disp", "Disp Norm", model_info];

% --- Create output directory for K-means results ---
mkdir("C:\Lab\Elbow Data\K means")

% --- Select a single session, cell, and feature for analysis ---
session_num = 1;                                 % Session index
cell = 3;                                        % Cell index to analyze
feat = find(strcmp(Predictor_names, "Acc"));     % Feature = "Acc"
mkdir("C:\Lab\Elbow Data\K means\" + Predictor_names(feat))

% --- Parameters for reach segmentation ---
min_lag  = 60;   % samples pre-reach
max_lag  = 15;   % samples post-reach
reach_len = 40;  % samples per reach
dt = 0.01;       % timestep (s)
lag = -0.23;     % chosen lag (s) for alignment
minIndex = (lag/dt) + min_lag + 1;  % convert lag to index

% --- Load pre-sorted data for this session ---
load("C:\Lab\Elbow Data\sorted_data\reject_Session_" + string(session_num) + "_kin_test.mat", "kinematics")
load("C:\Lab\Elbow Data\sorted_data\reject_Session_" + string(session_num) + "_neural_test.mat", "neuro_data")
load("C:\Lab\neuropixel_data\PC_cell_info\session_" + string(session_num) + ".mat", "PC")

% --- Define colormap for plotting ---
je = jet(floor(length(neuro_data)/(reach_len + min_lag + max_lag)));

% --- Build per-reach neural activity matrix (Palt) ---
Palt = [];
startid = minIndex;
for m = 1:floor(length(neuro_data)/(min_lag + reach_len + max_lag))
    % Extract segment of neural data for this cell across one reach window
    Palt(:, m) = neuro_data(startid:startid+reach_len-1, cell);
    startid = startid + (min_lag + reach_len + max_lag);
end

% --- Build per-reach kinematic matrix (Kalt) ---
Kalt = [];
startid = 1;
for k = 1:floor(length(kinematics)/(reach_len))
    % Extract segment of kinematic feature for one reach window
    Kalt(:, k) = kinematics(startid:startid+(reach_len-1), feat);
    startid = startid + (reach_len);
end

% --- K-means clustering preparation ---
data = Palt';     % Transpose so each row = one reach, columns = time samples
max_k = 10;       % Maximum number of clusters to test
wcss = zeros(1, max_k);  % array to hold within-cluster sum of squares (WCSS)

% --- Run K-means for different values of k and store total WCSS ---
for k = 1:max_k
    [~, ~, sumd] = kmeans(data, k, 'Replicates', 5);  % cluster with k groups, multiple replicates for stability
    wcss(k) = sum(sumd);  % total WCSS across all clusters
end

% --- Plot the elbow method curve to select optimal k ---
plot(1:max_k, wcss, '-o');
xlabel('Number of Clusters (k)');
ylabel('Total Within-Cluster Sum of Squares');
title('Elbow Method for Optimal k');
