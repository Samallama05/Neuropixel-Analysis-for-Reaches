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
    "Brachioradialis Activation", "Pectoralis Clavicle Head", "Biceps Short Head", "Biceps Long Head",  ...
    "Deltoid A", "Triceps Short Head", "Triceps Long Head", "Brachialis inner Head", "Brachialis Outer Head",  ...
    "Anconeus", "Deltoid M", "Short Anconeus", "Subscapularis SuperiorHead", "Infraspinatus",  ...
    "Pronator Teres", "Flexor Carpi Radialis", "Brachioradialis"];
Predictor_names = ["Pos X", "Pos Y", "Pos Z", "Vel", "Vel X", "Vel X Up",  ...
    "Vel X Down", "Vel Y", "Vel Y Up", "Vel Y Down", "Vel Z", "Vel Z Up", ...
    "Vel Z Down", "Acc", "Acc X", "Acc X Up", "Acc X Down", "Acc Y", ...
    "Acc Y Up", "Acc Y Down", "Acc Z", "Acc Z Up", "Acc Z Down" "X Vel", ...
    "Y Vel", "Z Vel", "Vel Norm", "X Acc", "Y Acc", "Z Acc", "Acc Norm", ...
    "X Disp", "Y Disp", "Z Disp", "Disp Norm", model_info];

mkdir("C:\Lab\Elbow Data\K means")

session_num = 1;
cell = 3;
feat = find(strcmp(Predictor_names, "Biceps Long Head Activation"));
mkdir("C:\Lab\Elbow Data\K means\" + Predictor_names(feat))

min_lag = 60;
max_lag = 15;
reach_len = 40;
dt = 0.01;
lag = -0.03;
minIndex = (lag/dt) + min_lag + 1;

load("C:\Lab\Elbow Data\sorted_data\Session_" + string(session_num) + "_kin_test.mat", "kinematics")
load("C:\Lab\Elbow Data\sorted_data\Session_" + string(session_num) + "_neural_test.mat", "neuro_data")
load("C:\Lab\neuropixel_data\PC_cell_info\session_" + string(session_num) + ".mat", "PC")

je = jet(floor(length(neuro_data)/(reach_len + min_lag + max_lag)));

Palt = [];
startid = minIndex;
for m = 1:floor(length(neuro_data)/(min_lag + reach_len + max_lag))
    Palt(:, m) = neuro_data(startid:startid+reach_len-1, cell);
    startid = startid + (min_lag + reach_len + max_lag);
end
%kin = find(strcmp(Predictor_names, "Biceps Long Head Activation"));
Kalt = [];
startid = 1;

for k = 1:floor(length(kinematics)/(reach_len))
    Kalt(:, k) = kinematics(startid:startid+(reach_len-1), feat);
    startid = startid + (reach_len);
end
clusters = 2;

[idx, C] = kmeans(Palt', clusters);

Palt_new = [];
Kalt_new = [];
index = 1;
for i = 1:length(idx)
    if idx(i) == 2
        Palt_new(:,index) = Palt(:,i);
        Kalt_new(:,index) = Kalt(:,i);
        index = index + 1;
    end
end

handle = figure('units','normalized','outerposition',[0 0 1 1], 'Visible','on');
set(gcf,'color','w') % This makes the figure white instead of grey.
set(gca, 'TickLabelInterpreter', 'none')

for i = 1:clusters
    subplot(2, clusters, i)
    hold on
    title("Cell " + string(cell) + " Activity Per Reach Cluster " + string(i))
    xlabel("Time")
    ylabel("FR")
    
    subplot(2, clusters, i + clusters)
    hold on
    title("Feature Behaviour Per Reach Cluster " + string(i))
    xlabel("Time")
    ylabel("Behaviour")
    ylim([0,1])
end

for reach = 1:size(Kalt_new, 2)
    if max(Kalt_new(:,reach)) <= 0.4
        subplot(2, clusters, 1)
        hold on
        plot(Palt_new(:,reach), Color=je(reach,:));

        subplot(2, clusters, 3)
        hold on
        plot(Kalt_new(:,reach), Color=je(reach,:));
    else
        subplot(2, clusters, 2)
        hold on
        plot(Palt_new(:,reach), Color=je(reach,:));

        subplot(2, clusters, 4)
        hold on
        plot(Kalt_new(:,reach), Color=je(reach,:));
    end
end

%{

[idx, C] = kmeans(Palt_new', clusters);

handle = figure('units','normalized','outerposition',[0 0 1 1], 'Visible','on');
set(gcf,'color','w') % This makes the figure white instead of grey.
set(gca, 'TickLabelInterpreter', 'none')

for i = 1:clusters
    subplot(2, clusters, i)
    hold on
    title("Cell " + string(cell) + " Activity Per Reach Cluster " + string(i))
    xlabel("Time")
    ylabel("FR")

    subplot(2, clusters, i + clusters)
    hold on
    title("Feature Behaviour Per Reach Cluster " + string(i))
    xlabel("Time")
    ylabel("Behaviour")
end

for reach = 1:length(idx)
    for group = 1:clusters
        if idx(reach) == group
            subplot(2, clusters, group)
            hold on
            plot(Palt_new(:,reach), Color=je(reach,:));

            subplot(2, clusters, group + clusters)
            hold on
            plot(Kalt_new(:,reach), Color=je(reach,:));
        end
    end
end

sgtitle("Session " + string(session_num) + ", Cell " + string(cell) + ", Lag " + string(lag) + ", " + Predictor_names(feat))
filename = "C:\Lab\Elbow Data\K means\" + Predictor_names(feat) + "\Session " + string(session_num) + ", Cell " + string(cell) + ".png";
saveas(handle, filename)
%}
