close all;
clear all;

sessions = ["Dylan_210414_WT2_NPresults_short", ...
    "Dylan_210421_fChR2_NPresults_short_stim", "Dylan_210423_fChR2_NPresults_short", ...
    "Dylan_210422_fChR2_NPresults_short", "Dylan_210425_fChR2_NPresults_short", ...
    "Dylan_210511_fChR5_NPresults_short", "Dylan_210512_fChR5_NPresults_short", ...
    "Dylan_210514_fChR2_NPresults_short", "Dylan_210515_fChR5_NPresults_short", ...
    "Dylan_210606_fChR4_NPresults_short", "Dylan_210608_fChR4_NPresults  short", ...
    "Dylan_210614_fChR4_NPresults_short", "Dylan_210619_cChR1_NPresults_short", ...
    "Dylan_210620_cChR1_NPresults_short", "Dylan_210622_cChR1_NPresults_short", ...
    "Dylan_210623_cChR1_NPresults_short", "Dylan_220515_DJC002_NPresults_short", ...
    "Dylan_220516_DJC000_NPresults_short", "Dylan_220517_DJC002_NPresults_short", ...
    "Dylan_220518_DJC000_NPresults_short", "Dylan_220519_DJC000_NPresults_short", ...
    "Dylan_220519_DJC002_NPresults_short", "Dylan_220520_DJC000_NPresults_short", ...
    "Dylan_220520_DJC002_NPresults_short"];

reach_num = [74, 65, 62, 63, 52, 66, 54, 60, 68, 52, 73, 59, 80, 68, 71, ..., 
    68, 60, 53, 58, 58, 36, 70, 57, 45];

mkdir("C:\Lab\Elbow Data\sorted_data")

exportPrefex = ".mat";

%calculate the clipping points
%initial clipping points (as chosen by Person Lab)
init_s1 =  300;
init_s2 =  700;
%new clip timestamps
inslice  = 590;
outslice = 620;

%inslice  = 1;
%outslice = 1201;

aligned_stamps = init_s1:1:init_s2;
[~,f1] = find(aligned_stamps == inslice);
[~,f2] = find(aligned_stamps == outslice);

for j = [1]
%for j = [1, 2, 4, 12, 14, 18, 21]
    for l = 0
        fileName = sessions(j);

        load("C:\Lab\neuropixel_data\" + fileName + ".mat", 'cellData', 'ReachS'); % Load the necessary variables from the file

        kinematics = [];
        close all; %close any open figures

        %load Purkinje Cell data file
        %load("C:\Lab\neuropixel_data\" + string(sessions(j)) + ".mat")
        trigger = 1;
        ReachS(1).rast_tot = [];
        load("C:\Lab\neuropixel_reaches\reject_" + sessions(j) + ".mat")
        
        for i=1:reach_num(j)
            %for i=1
            if reject(i) == 0
                path_to_file = "C:\Lab\Elbow Data\elbow adjusted muscle solutions\kinematics_" + string(sessions(j)) + "\muscle_solution_" + string(i) + ".sto";
                %path_to_flen = 'C:\Lab\new_inverse_solutions\solutions_' + string(sessions(j)) + '\muscle_fibers\muscle_params' + string(i) + '\analyze_MuscleAnalysis_FiberLength.sto';
                %path_to_fvel = "C:\Lab\new_inverse_solutions\solutions_" + string(sessions(j)) + "\muscle_fibers\muscle_params" + string(i) + "\analyze_MuscleAnalysis_FiberVelocity.sto";

                switch trigger
                    case 1
                        ReachS(1).rast_tot = ReachS(i).filt_kin(inslice + l:outslice + l,:);
                        %print = 1
                        opts = delimitedTextImportOptions("NumVariables", 43);
                        opts.DataLines = [20, Inf];
                        opts.Delimiter = "\t";
                        opts.VariableNames = ["time", "jointsetshoulderelv_anglevalue", "jointsetshoulderextension_anglevalue", "jointsethumerus_ulnaelbow_flexvalue", "jointsetulna_radius_pjradius_rotvalue", "jointsetwristwrist_anglevalue", "jointsetshoulderelv_anglespeed", "jointsetshoulderextension_anglespeed", "jointsethumerus_ulnaelbow_flexspeed", "jointsetulna_radius_pjradius_rotspeed", "jointsetwristwrist_anglespeed", "forcesetPectoralis_Clavicle_Headactivation", "forcesetBiceps_Short_Headactivation", "forcesetBiceps_Long_Headactivation", "forcesetDeltoid_Aactivation", "forcesetTriceps_Short_Headactivation", "forcesetTriceps_Long_Headactivation", "forcesetMaybeBrachialis_InnerHeadactivation", "forcesetMaybeBrachialis_OuterrHeadactivation", "forcesetAnconeusactivation", "forcesetDeltoid_Mactivation", "forcesetShort_Anconeusactivation", "forcesetSubscapularis_SuperiorHeadactivation", "forcesetInfraspinatusactivation", "forcesetPronatorTeresactivation", "forcesetFlexorCarpiRadialisactivation", "forcesetBrachioradialisactivation", "forcesetPectoralis_Clavicle_Head", "forcesetBiceps_Short_Head", "forcesetBiceps_Long_Head", "forcesetDeltoid_A", "forcesetTriceps_Short_Head", "forcesetTriceps_Long_Head", "forcesetMaybeBrachialis_InnerHead", "forcesetMaybeBrachialis_OuterrHead", "forcesetAnconeus", "forcesetDeltoid_M", "forcesetShort_Anconeus", "forcesetSubscapularis_SuperiorHead", "forcesetInfraspinatus", "forcesetPronatorTeres", "forcesetFlexorCarpiRadialis", "forcesetBrachioradialis"];

                        opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
                        opts.ExtraColumnsRule = "ignore";
                        opts.EmptyLineRule = "read";

                        model_info = readtable(path_to_file , opts);
                        model_info = table2array(model_info(3:70,[2:43]));
                        for r = 12:42
                            model_info(:,r ) = movmean(model_info(:,r ), 5);
                        end
                        model_info = model_info(1:2:end,:);

                        %% Clear temporary variables
                        clear opts

                        fulldata = model_info;
                        ReachS(1).synth_tot = fulldata();
                        trigger = 0;
                    otherwise
                        ReachS(1).rast_tot = vertcat(ReachS(1).rast_tot, ReachS(i).filt_kin(inslice + l:outslice + l,:));
                        opts = delimitedTextImportOptions("NumVariables", 43);
                        opts.DataLines = [20, Inf];
                        opts.Delimiter = "\t";
                        opts.VariableNames = ["time", "jointsetshoulderelv_anglevalue", "jointsetshoulderextension_anglevalue", "jointsethumerus_ulnaelbow_flexvalue", "jointsetulna_radius_pjradius_rotvalue", "jointsetwristwrist_anglevalue", "jointsetshoulderelv_anglespeed", "jointsetshoulderextension_anglespeed", "jointsethumerus_ulnaelbow_flexspeed", "jointsetulna_radius_pjradius_rotspeed", "jointsetwristwrist_anglespeed", "forcesetPectoralis_Clavicle_Headactivation", "forcesetBiceps_Short_Headactivation", "forcesetBiceps_Long_Headactivation", "forcesetDeltoid_Aactivation", "forcesetTriceps_Short_Headactivation", "forcesetTriceps_Long_Headactivation", "forcesetMaybeBrachialis_InnerHeadactivation", "forcesetMaybeBrachialis_OuterrHeadactivation", "forcesetAnconeusactivation", "forcesetDeltoid_Mactivation", "forcesetShort_Anconeusactivation", "forcesetSubscapularis_SuperiorHeadactivation", "forcesetInfraspinatusactivation", "forcesetPronatorTeresactivation", "forcesetFlexorCarpiRadialisactivation", "forcesetBrachioradialisactivation", "forcesetPectoralis_Clavicle_Head", "forcesetBiceps_Short_Head", "forcesetBiceps_Long_Head", "forcesetDeltoid_A", "forcesetTriceps_Short_Head", "forcesetTriceps_Long_Head", "forcesetMaybeBrachialis_InnerHead", "forcesetMaybeBrachialis_OuterrHead", "forcesetAnconeus", "forcesetDeltoid_M", "forcesetShort_Anconeus", "forcesetSubscapularis_SuperiorHead", "forcesetInfraspinatus", "forcesetPronatorTeres", "forcesetFlexorCarpiRadialis", "forcesetBrachioradialis"];

                        opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
                        opts.ExtraColumnsRule = "ignore";
                        opts.EmptyLineRule = "read";

                        model_info = readtable(path_to_file , opts);
                        model_info = table2array(model_info(:,[2:43]));
                        for r = 12:42
                            model_info(:,r ) = movmean(model_info(:,r ), 5);
                        end
                        model_info = model_info(1:2:end,:);

                        %% Clear temporary variables
                        clear opts

                        fulldata = model_info;
                        ReachS(1).synth_tot = (ReachS(1).synth_tot, fulldata);
                end
                plot(ReachS(1).synth_tot())
            end
        end
        opts.VariableNames = ["time", "jointsetshoulderelv_anglevalue", "jointsetshoulderextension_anglevalue", "jointsethumerus_ulnaelbow_flexvalue", "jointsetulna_radius_pjradius_rotvalue", "jointsetwristwrist_anglevalue", "jointsetshoulderelv_anglespeed", "jointsetshoulderextension_anglespeed", "jointsethumerus_ulnaelbow_flexspeed", "jointsetulna_radius_pjradius_rotspeed", "jointsetwristwrist_anglespeed", "forcesetPectoralis_Clavicle_Headactivation", "forcesetBiceps_Short_Headactivation", "forcesetBiceps_Long_Headactivation", "forcesetDeltoid_Aactivation", "forcesetTriceps_Short_Headactivation", "forcesetTriceps_Long_Headactivation", "forcesetMaybeBrachialis_InnerHeadactivation", "forcesetMaybeBrachialis_OuterrHeadactivation", "forcesetAnconeusactivation", "forcesetDeltoid_Mactivation", "forcesetShort_Anconeusactivation", "forcesetSubscapularis_SuperiorHeadactivation", "forcesetInfraspinatusactivation", "forcesetPronatorTeresactivation", "forcesetFlexorCarpiRadialisactivation", "forcesetBrachioradialisactivation", "forcesetPectoralis_Clavicle_Head", "forcesetBiceps_Short_Head", "forcesetBiceps_Long_Head", "forcesetDeltoid_A", "forcesetTriceps_Short_Head", "forcesetTriceps_Long_Head", "forcesetMaybeBrachialis_InnerHead", "forcesetMaybeBrachialis_OuterrHead", "forcesetAnconeus", "forcesetDeltoid_M", "forcesetShort_Anconeus", "forcesetSubscapularis_SuperiorHead", "forcesetInfraspinatus", "forcesetPronatorTeres", "forcesetFlexorCarpiRadialis", "forcesetBrachioradialis"];
        musc_names = opts.VariableNames(2:43);
        model_params = musc_names;

        %data = ReachS(1).rast_tot(1:length(ReachS(1).filt_kin),:);
        data = ReachS(1).rast_tot();
        data(:,9) = gradient(data(:,5));
        data(:,10) = gradient(data(:,6));
        data(:,11) = gradient(data(:,7));
        data(:,12) = gradient(data(:,8));
        %data = ReachS(1).rast_tot();

        % pull out predictors
        pos_x = data(:,2);
        pos_y = data(:,3);
        pos_z = data(:,4);

        vel = data(:,5);
        vel_x = data(:,6);
        vel_x_up_la = data(:,6) >= 0;
        vel_x_up = data(:,6).*vel_x_up_la;
        vel_x_down_la = data(:,6) < 0;
        vel_x_down = data(:,6).*vel_x_down_la;

        clear vel_x_up_la
        clear vel_x_down_la

        vel_y = data(:,7);
        vel_y_up_la = data(:,7) >= 0;
        vel_y_up = data(:,7).*vel_y_up_la;
        vel_y_down_la = data(:,7) < 0;
        vel_y_down = data(:,7).*vel_y_down_la;

        clear vel_y_up_la
        clear vel_y_down_la

        vel_z = data(:,8);
        vel_z_up_la = data(:,8) >= 0;
        vel_z_up = data(:,8).*vel_z_up_la;
        vel_z_down_la = data(:,8) < 0;
        vel_z_down = data(:,8).*vel_z_down_la;

        clear vel_z_up_la
        clear vel_z_down_la

        acc = data(:,9);

        acc_x = data(:,10);
        acc_x_up_la = data(:,10) >= 0;
        acc_x_up = data(:,10).*acc_x_up_la;
        acc_x_down_la = data(:,10) < 0;
        acc_x_down = data(:,10).*acc_x_down_la;

        clear acc_x_up_la
        clear acc_x_down_la

        acc_y = data(:,11);
        acc_y_up_la = data(:,11) >= 0;
        acc_y_up = data(:,11).*acc_y_up_la;
        acc_y_down_la = data(:,11) < 0;
        acc_y_down = data(:,11).*acc_y_down_la;

        clear acc_y_up_la
        clear acc_y_down_la

        acc_z = data(:,12);
        acc_z_up_la = data(:,12) >= 0;
        acc_z_up = data(:,12).*acc_z_up_la;
        acc_z_down_la = data(:,12) < 0;
        acc_z_down = data(:,12).*acc_z_down_la;

        clear acc_z_up_la
        clear acc_z_down_la

        %calculate dimensional velocity for x, y, z
        %Assume starting velocity is the same as velocity between points 1 and
        %2
        x_vel = [];
        x_vel(1) = pos_x(2) - pos_x(1);
        for i = 2:length(pos_x)
            x_vel(i) = pos_x(i) - pos_x(i-1);
        end

        y_vel = [];
        y_vel(1) = pos_y(2) - pos_y(1);
        for i = 2:length(pos_y)
            y_vel(i) = pos_y(i) - pos_y(i-1);
        end

        z_vel = [];
        z_vel(1) = pos_z(2) - pos_z(1);
        for i = 2:length(pos_z)
            z_vel(i) = pos_z(i) - pos_z(i-1);
        end

        %calculate velocity norm
        vel_norm = [];
        for i = 1:length(x_vel)
            vel_norm(i) = sqrt(x_vel(i)^2 + y_vel(i)^2 + z_vel(i)^2);
        end

        %calculate dimensional acc for x, y, z
        %Assume starting acc is the same as acc between points 1 and
        %2
        x_acc = [];
        x_acc(1) = x_vel(2) - x_vel(1);
        for i = 2:length(pos_x)
            x_acc(i) = x_vel(i) - x_vel(i-1);
        end

        y_acc = [];
        y_acc(1) = y_vel(2) - y_vel(1);
        for i = 2:length(pos_x)
            y_acc(i) = y_vel(i) - y_vel(i-1);
        end

        z_acc = [];
        z_acc(1) = z_vel(2) - z_vel(1);
        for i = 2:length(pos_x)
            z_acc(i) = z_vel(i) - z_vel(i-1);
        end

        %Calculate acc vector norm
        acc_norm = [];
        for i = 1:length(x_acc)
            acc_norm(i) = sqrt(x_acc(i)^2 + y_acc(i)^2 + z_acc(i)^2);
        end

        %find ind for max x for index at which the reach is at its peak
        [max_x, max_x_ind] = max(pos_x);

        %calculate x y and z disp. disp is distance between paw and target
        x_disp = [];
        for i = 1:length(pos_x)
            x_disp(i) = pos_x(max_x_ind) - pos_x(i);
        end

        y_disp = [];
        for i = 1:length(pos_x)
            y_disp(i) = pos_y(max_x_ind) - pos_y(i);
        end

        z_disp = [];
        for i = 1:length(pos_x)
            z_disp(i) = pos_z(max_x_ind) - pos_z(i);
        end

        %calculate disp norm
        disp_norm = [];
        for i = 1:length(x_vel)
            disp_norm(i) = sqrt(x_disp(i)^2 + y_disp(i)^2 + z_disp(i)^2);
        end


        kinematics = [pos_x pos_y pos_z vel vel_x vel_x_up vel_x_down...
            vel_y vel_y_up vel_y_down vel_z vel_z_up vel_z_down acc acc_x ...
            acc_x_up acc_x_down acc_y acc_y_up acc_y_down acc_z acc_z_up acc_z_down...
            x_vel' y_vel' z_vel' vel_norm' x_acc' y_acc' z_acc' acc_norm' x_disp' y_disp' ...
            z_disp' disp_norm' ReachS(1).synth_tot(1:length(pos_x),:)];
        %save("C:\Lab\Elbow Data\sorted_data\Session_" + string(j) + "_kin.mat", "kinematics");

    end
%{
%iterate through each session
%for j = 9:length(sessions)
%for j = [1, 2, 4, 12, 14, 18, 21, 22]
    fileName = sessions(j);

    %load("C:\Lab\neuropixel_data\" + fileName + ".mat", 'ReachS'); % Load the necessary variables from the file
    mfile = matfile("C:\Lab\neuropixel_data\" + fileName + ".mat");
    ReachS = mfile.ReachS;
    load("C:\Lab\neuropixel_reaches\reject_" + fileName + ".mat")
    lag_t = 120;
    step_size = 1;

    lag = lag_t/step_size;

    neuro_data = [];
    lag_ind1 = -120;
    lag_ind2 = 15;
    tic
    for k = 1:size(mfile.cellData, 2)
    %for k = [1, 2]
        cellData = mfile.cellData(1, k);
        for i=1:length(ReachS)
            if reject(i) == 0
                idx1(i,1)=knnsearch(cellData.Bin10smooth(:,1),ReachS(i).filt_kin(inslice,1));
                idx2(i,1)=knnsearch(cellData.Bin10smooth(:,1),ReachS(i).filt_kin(outslice,1));
            end
        end

        %{
                    xq = ReachS(i).filt_kin(inslice:outslice, 1)
                    x = cellData(k).Bin10smooth(idx1:idx2, 1)
                    v = Bin10smooth(idx1:idx2, 2)
                    fixed_nd = interp1(x, v, xq)
        %}

        %concatenate FRs
        Gaussian(1).cat_fire = [];
        neuro_endInd = [];
        m=1;
        for i=1:reach_num(j)
            if reject(i) == 0
                %%%%%%
                %x = cellData(k).Bin10smooth(idx1(i,1)-1:idx2(i,1)+1, 1);
                %v = cellData(k).Bin10smooth(idx1(i,1)-1:idx2(i,1)+1, 2);
                x = cellData.Bin10smooth(idx1(i,1)+(lag_ind1*step_size):idx2(i,1)+(lag_ind2*step_size), 1);
                v = cellData.Bin10smooth(idx1(i,1)+(lag_ind1*step_size):idx2(i,1)+(lag_ind2*step_size), 2);
                xq = linspace(min(x), max(x), 31 + (lag_ind2 - lag_ind1))';
                fixed_nd = interp1(x, v, xq, 'linear');
                switch i
                    case 1
                        %Gaussian(1).cat_fire = cellData(k).Bin10smooth(idx1(i,1)+(ii*step_size):idx2(i,1)+(ii*step_size),:);
                        Gaussian(1).cat_fire = [xq fixed_nd];
                        neuro_endInd(m) = length(Gaussian(1).cat_fire);

                        m = m + 1;
                    otherwise
                        %Gaussian(1).cat_fire = vertcat(Gaussian(1).cat_fire, cellData(k).Bin10smooth(idx1(i,1)+(ii*step_size):idx2(i,1)+(ii*step_size),:));
                        Gaussian(1).cat_fire = vertcat(Gaussian(1).cat_fire, [xq fixed_nd]);
                        neuro_endInd(m) = length(Gaussian(1).cat_fire);

                        m = m + 1;
                end
            end
        end
        if k == 1
            neuro_data = zeros(length(Gaussian(1).cat_fire(:,2)), length(cellData));
        end
        neuro_data(:,k) = Gaussian(1).cat_fire(:,2);
        %plot(neuro_data(:,k))
        disp(toc)
    end

    %save("C:\Lab\Elbow Data\sorted_data\Session_" + string(j) + "_neural.mat", "neuro_data");
%}
end

disp(j)


