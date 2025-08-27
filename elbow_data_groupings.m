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

mkdir("C:\Lab\Elbow Data\lag_graphs\30ms_RMSE")
mkdir("C:\Lab\Elbow Data\lag_graphs\30ms_RMSE\reject PC groupings")
mkdir("C:\Lab\Elbow Data\lag_graphs\30ms_RMSE\reject Non PC groupings")

min_lag = 60;
max_lag = 15;
reach_len = 40;
dt = 0.01;

%feat = find(strcmp(Predictor_names, "Triceps Short Head Activation"));
%for feat = 14:length(Predictor_names)
for feat = 48
    mkdir("C:\Lab\Elbow Data\lag_graphs\30ms_RMSE\\PC groupings\" + Predictor_names(feat))
    mkdir("C:\Lab\Elbow Data\lag_graphs\30ms_RMSE\\PC groupings\" + Predictor_names(feat) + "\mirror")
    mkdir("C:\Lab\Elbow Data\lag_graphs\30ms_RMSE\\PC groupings\" + Predictor_names(feat) + "\reflect")

    mkdir("C:\Lab\Elbow Data\lag_graphs\30ms_RMSE\Non PC groupings\" + Predictor_names(feat))
    mkdir("C:\Lab\Elbow Data\lag_graphs\30ms_RMSE\Non PC groupings\" + Predictor_names(feat) + "\mirror")
    mkdir("C:\Lab\Elbow Data\lag_graphs\30ms_RMSE\Non PC groupings\" + Predictor_names(feat) + "\reflect")

    best_lags = [];
    for session_num = 12
    %for session_num = [1, 2, 3, 4, 12, 14, 18, 21]
    %for session_num = [12, 14, 18, 21]
        load("C:\Lab\Elbow Data\sorted_data\Session_" + string(session_num) + "_kin_test.mat", "kinematics")
        load("C:\Lab\Elbow Data\sorted_data\Session_" + string(session_num) + "_neural_test.mat", "neuro_data")
        load("C:\Lab\neuropixel_data\PC_cell_info\session_" + string(session_num) + ".mat", "PC")

        je = jet(floor(length(neuro_data)/(reach_len + min_lag + max_lag)));

        for i = 19
        %for i = 1:size(neuro_data, 2)
            load("C:\Lab\Elbow Data\corrs\Session " + string(session_num) + "\aligned_cell_" + string(i) + "_rmse", "RMSE")
            load("C:\Lab\Elbow Data\corrs\Session " + string(session_num) + "\aligned_cell_" + string(i) + "_corrs", "corrs")
            %[minValue, minIndex] = min(RMSE(:, 1));

            %[minValue, minIndex] = min(RMSE(:, feat));

            [minValue, relIndex] = min(RMSE(31:end, feat));
            minIndex = relIndex + 30;
            if minValue <= 0.2
                Palt = [];
                startid = minIndex;
                for m = 1:floor(length(neuro_data)/(min_lag + reach_len + max_lag))
                    Palt(:, m) = neuro_data(startid:startid+reach_len-1, i);
                    startid = startid + (min_lag + reach_len + max_lag);
                end
                %kin = find(strcmp(Predictor_names, "Biceps Long Head Activation"));
                Kalt = [];
                startid = 1;

                for k = 1:floor(length(kinematics)/(reach_len))
                    Kalt(:, k) = kinematics(startid:startid+(reach_len-1), feat);
                    startid = startid + (reach_len);
                end

                handle = figure('units','normalized','outerposition',[0 0 1 1], 'Visible','off');
                set(gcf,'color','w') % This makes the figure white instead of grey.
                set(gca, 'TickLabelInterpreter', 'none')

                subplot(2,2,1)
                hold on
                title("Cell " + string(i) + " Activity Per Reach", FontSize=22)
                xlabel("Time (ms)", FontSize=18)
                ylabel("Firing Rate (Hz)", FontSize=18)
                set(gca, 'FontSize', 14)
                for reach = 1:size(Palt, 2)
                    plot(Palt(:,reach), Color=je(reach,:), LineWidth=2);
                end

                subplot(2, 2, 3)
                hold on
                title(Predictor_names(feat) + " Behaviour Per Reach", FontSize=22)
                xlabel("Time (ms)", FontSize=18)
                ylabel("Behaviour", FontSize=18)
                set(gca, 'FontSize', 14)
                for reach = 1:size(Kalt, 2)
                    plot(Kalt(:,reach), Color=je(reach,:), LineWidth=2);
                end

                subplot(2, 2, 4)
                hold on
                plot(mean(Kalt'), LineWidth=2)
                title(Predictor_names(feat) + " Mean Behaviour", FontSize=22)
                xlabel("Time (ms)", FontSize=18)
                ylabel("Behaviour", FontSize=18)
                set(gca, 'FontSize', 14)

                subplot(2, 2, 2)
                hold on
                plot(mean(Palt'), LineWidth=2)
                title(Predictor_names(feat) + " Mean Cell Activity", FontSize=22)
                xlabel("Time (ms)", FontSize=18)
                ylabel("Firing Rate (Hz)", FontSize=18)
                set(gca, 'FontSize', 14)
                
                %{
                if corrs(minIndex, feat) < 0
                    if PC(i) == 1
                        sgtitle("RMSE " + string(minValue) + " (PC Cell " + string(i) + ", " + Predictor_names(feat) + ", Optimal Lag " + string((minIndex - (min_lag + 1))*dt) + ", Session " + string(session_num) + ")")
                        filename = "C:\Lab\Elbow Data\lag_graphs\30ms_RMSE\PC groupings\" + Predictor_names(feat) + "\mirror\Session " + string(session_num) + ", PC Cell " + string(i) + ".png";
                    else
                        sgtitle("RMSE " + string(minValue) + " (Cell " + string(i) + ", " + Predictor_names(feat) + ", Optimal Lag " + string((minIndex - (min_lag + 1))*dt) + ", Session " + string(session_num) + ")")
                        filename = "C:\Lab\Elbow Data\lag_graphs\30ms_RMSE\Non PC groupings\" + Predictor_names(feat) + "\mirror\Session " + string(session_num) + ", Cell " + string(i) + ".png";
                    end
                else
                    if PC(i) == 1
                        sgtitle("RMSE " + string(minValue) + " (PC Cell " + string(i) + ", " + Predictor_names(feat) + ", Optimal Lag " + string((minIndex - (min_lag + 1))*dt) + ", Session " + string(session_num) + ")")
                        filename = "C:\Lab\Elbow Data\lag_graphs\30ms_RMSE\PC groupings\" + Predictor_names(feat) + "\reflect\Session " + string(session_num) + ", PC Cell " + string(i) + ".png";
                    else
                        sgtitle("RMSE " + string(minValue) + " (Cell " + string(i) + ", " + Predictor_names(feat) + ", Optimal Lag " + string((minIndex - (min_lag + 1))*dt) + ", Session " + string(session_num) + ")")
                        filename = "C:\Lab\Elbow Data\lag_graphs\30ms_RMSE\Non PC groupings\" + Predictor_names(feat) + "\reflect\Session " + string(session_num) + ", Cell " + string(i) + ".png";
                    end
                end

                saveas(handle,filename)
                %}

                sgtitle("PC Cell " + string(i) + ", " + Predictor_names(feat) + ", Optimal Lag " + string((minIndex - (min_lag + 1))*dt) + ", Session " + string(session_num) + ")", fontsize = 24)

                filename = ("C:\Lab\Elbow Data\thesis_figs\sample cell feat reflect.svg");
                saveas(handle, filename)


                filename = ("C:\Lab\Elbow Data\thesis_figs\sample cell feat reflect.png");
                saveas(handle, filename)
                close all;
            end
        end
    end
end

close all;
