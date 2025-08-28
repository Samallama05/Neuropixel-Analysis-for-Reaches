%{
This MATLAB script generates summary plots of paw X-position across reaches for multiple behavioral sessions. For each session, it loads a reject vector that marks whether each reach trial should be
classified as accepted or rejected. Then, for every reach, it loads the corresponding CSV file containing the kinematic data (paw_x).
%}

close all;    % Close any open figures
clear all;    % Clear workspace variables

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

% --- Number of reaches for each session (aligned with "sessions") ---
reach_num = [74, 65, 62, 63, 52, 66, 54, 60, 68, 52, 73, 59, 80, 68, 71, ...
    68, 60, 53, 58, 58, 36, 70, 57, 45];

% --- Output directory for generated figures ---
mkdir("C:\Lab\Elbow Data\Real_X_Pos_Graphs")

% --- Loop through selected sessions ---
for session_num = [1, 2, 4, 12, 14, 18, 21, 22]

    % Load the "reject" array for this session (marks whether each reach is rejected)
    load("C:\Lab\neuropixel_reaches\reject_" + sessions(session_num) + ".mat")

    % Create a full-screen invisible figure for plotting
    handle = figure('Units','normalized','OuterPosition',[0 0 1 1], 'Visible','off');
    hold on

    % --- Loop over all reaches in the session ---
    for reach = 1:reach_num(session_num)

        % Load the CSV file containing kinematics (paw position, etc.)
        fileName = "C:\Lab\Elbow Data\elbow adjusted muscle solutions\kinematics_" ...
                   + sessions(session_num) + "\real_kinematics_" + string(reach) + ".csv";
        data = readtable(fileName);  % read as table

        % --- Subplot 1: All reaches (plot every reach regardless of reject status) ---
        subplot(1,3,1)
        hold on
        plot(data.paw_x)
        title("All Reaches")
        xlabel("Time")
        ylabel("Paw X Pos")

        % --- Subplot 2 or 3 depending on rejection flag ---
        if reject(reach) == 0
            % Accepted reaches
            subplot(1,3,2)
            hold on
            plot(data.paw_x)
            title("Accepted Reaches")
            xlabel("Time")
            ylabel("Paw X Pos")
        else
            % Rejected reaches
            subplot(1,3,3)
            hold on
            plot(data.paw_x)
            title("Rejected Reaches")
            xlabel("Time")
            ylabel("Paw X Pos")
        end
    end

    % --- Save figure for this session ---
    filename = "C:\Lab\Elbow Data\Real_X_Pos_Graphs\Session " + string(session_num) + ".png";
    saveas(handle, filename)
end

%{
--- Example code snippet (commented out) that would reject reaches
--- based on deviation from mean paw position at start/end points:

for reach = 1:size(x_pos, 2)
    if abs(x_pos(1) - mean(xp_meta(:,1))) > 1*std(xp_meta(:,1))
        reject(1,k) = 1;
    elseif abs(x_pos(end) - mean(xp_meta(:,end))) > 1*std(xp_meta(:,end))
        reject(1,k) = 1;
    end
end
%}
