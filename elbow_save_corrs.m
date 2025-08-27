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

model_info = ["Shoulder Elv Angle Value", "Shoulder Extension Angle Value", "Elbow Flex Value", "Ulna Radius Rot Value", "Wrist Angle Value", "Shoulder Elv Angle Speed", "Shoulder Extension Angle Speed", "Elbow Flex Speed", "Ulna Radius Rot Speed", "Wrist Angle Speed", "Pectoralis Clavicle Head Activation", "Biceps Short Head Activation", "Biceps Long Head Activation", "Deltoid A Activation", "Triceps Short Head Activation", "Triceps Long Head Activation", "Brachialis inner Head Activation", "Brachialis Outer Head Activation", "Anconeus Activation", "Deltoid M Activation", "Short Anconeus Activation", "Subscapularis SuperiorHead Activation", "Infraspinatus Activation", "Pronator Teres Activation", "Flexor Carpi Radialis Activation", "Brachioradialis  Activation", "Pectoralis Clavicle Head", "Biceps Short Head", "Biceps Long Head", "Deltoid A", "Triceps Short Head", "Triceps Long Head", "Brachialis inner Head", "Brachialis Outer Head", "Anconeus", "Deltoid M", "Short Anconeus", "Subscapularis SuperiorHead", "Infraspinatus", "Pronator Teres", "Flexor Carpi Radialis", "Brachioradialis"];
Predictor_names = ["Pos X", "Pos Y", "Pos Z", "Vel", "Vel X", "Vel X Up",  ...
    "Vel X Down", "Vel Y", "Vel Y Up", "Vel Y Down", "Vel Z", "Vel Z Up", ...
    "Vel Z Down", "Acc", "Acc X", "Acc X Up", "Acc X Down", "Acc Y", ...
    "Acc Y Up", "Acc Y Down", "Acc Z", "Acc Z Up", "Acc Z Down" "X Vel", ...
    "Y Vel", "Z Vel", "Vel Norm", "X Acc", "Y Acc", "Z Acc", "Acc Norm", ...
    "X Disp", "Y Disp", "Z Disp", "Disp Norm", model_info];

mkdir("C:\Lab\Elbow Data\corrs")
min_lag = 60;
max_lag = 15;
reach_len = 40;
corrs = [];
RMSE = [];

%for session_num = [1, 2, 3, 4]
for session_num = [1, 2, 3, 4, 12, 14, 18, 21]
    for iter = 1:10
        disp("Session Num: " + string(session_num) + ", Iteration: " + string(iter))
        lag_t = 60;
        step_size = 1;

        lag = lag_t/step_size;

        %session_num = 22;
        mkdir("C:\Lab\Elbow Data\corrs\Session " + string(session_num))
        load("C:\Lab\Elbow Data\sorted_data\Session_" + string(session_num) + "_kin_test.mat", "kinematics")
        load("C:\Lab\Elbow Data\shuffled\Session " + string(session_num) + "\shuffled_" + string(iter) + "_neural.mat", "shuff_all_cells")
        load("C:\Lab\neuropixel_data\PC_cell_info\session_" + string(session_num) + ".mat")

        for i = 1:size(shuff_all_cells, 2)
        %for i = 18

            for n = -min_lag:max_lag
                Palt = [];
                startid = min_lag + n + 1;
                for m = 1:floor(length(shuff_all_cells)/(min_lag + reach_len + max_lag))
                    Palt(:, m) = shuff_all_cells(startid:startid+reach_len -1 , i);
                    startid = startid + (min_lag + reach_len + max_lag);
                end
                %kin = find(strcmp(Predictor_names, "Biceps Long Head Activation"));
                for j = 1:size(kinematics, 2)
                    Kalt = [];
                    startid = 1;

                    for k = 1:floor(length(kinematics)/(reach_len))
                        Kalt(:, k) = kinematics(startid:startid+(reach_len - 1), j);
                        startid = startid + reach_len;
                    end
                    r2 = fitlm(normalize(mean(Kalt')', "range"), normalize(mean(Palt')', "range"));
                    RMSE(n + (min_lag + 1), j) = r2.RMSE;
                    %RMSE(n+121) = r2.RMSE;
                    %RMSE(n+61,j) = r2.RMSE;
                    
                    Kalt = Kalt(:, all(~isnan(Kalt)));  % remove cols with NaNs
                    Palt = Palt(:, all(~isnan(Palt)));
                    pearson_corr = corr(normalize(mean(Kalt')', "range"), normalize(mean(Palt')', "range"));
                    corrs(n  + (min_lag + 1), j) = pearson_corr;
                    %corrs(n+61,j) = r2;
                end
            end
            %save("C:\Lab\Elbow Data\lags\Session " + string(session_num) + "\cell_" + string(i) + "_rmse", "RMSE")
            %save("C:\Lab\Elbow Data\lags\Session " + string(session_num) + "\cell_" + string(i) + "_lags", "corrs")

            save("C:\Lab\Elbow Data\corrs\Session " + string(session_num) + "\shuffled_" + string(iter) + "cell_" + string(i) + "_rmse", "RMSE")
            save("C:\Lab\Elbow Data\corrs\Session " + string(session_num) + "\shuffled_" + string(iter) + "cell_" + string(i) + "_corrs", "corrs")
        end
    end
end
