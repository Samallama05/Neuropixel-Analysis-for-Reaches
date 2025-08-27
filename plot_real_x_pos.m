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

mkdir("C:\Lab\Elbow Data\Real_X_Pos_Graphs")

for session_num = [1, 2, 4, 12, 14, 18, 21, 22]
%for session_num = 2
    load("C:\Lab\neuropixel_reaches\reject_" + sessions(session_num) + ".mat")
    handle = figure('Units','normalized','OuterPosition',[0 0 1 1], 'Visible','off');
    hold on
    for reach = 1:reach_num(session_num)
        %for reach = 1
        fileName = "C:\Lab\Elbow Data\elbow adjusted muscle solutions\kinematics_" + sessions(session_num) + "\real_kinematics_" + string(reach) + ".csv";
        data = readtable(fileName);
        subplot(1,3,1)
        hold on
        plot(data.paw_x)
        title("All Reaches")
        xlabel("Time")
        ylabel("Paw X Pos")
        if reject(reach) == 0
            subplot(1,3,2)
            hold on
            plot(data.paw_x)
            title("Accepted Reaches")
            xlabel("Time")
            ylabel("Paw X Pos")
        else
            subplot(1,3,3)
            hold on
            plot(data.paw_x)
            title("Rejected Reaches")
            xlabel("Time")
            ylabel("Paw X Pos")
        end
    end
    filename = "C:\Lab\Elbow Data\Real_X_Pos_Graphs\Session " + string(session_num) + ".png";
    saveas(handle, filename)
end

% for reach = 1:size(x_pos, 2)
% 	if abs(x_pos(1) - mean(xp_meta(:,1))) > 1*std(xp_meta(:,1))
% 	reject(1,k) = 1;
% 	elseif abs(x_pos(end) - mean(xp_meta(:,end))) > 1*std(xp_meta(:,end))
% 	reject(1,k) = 1;
% end