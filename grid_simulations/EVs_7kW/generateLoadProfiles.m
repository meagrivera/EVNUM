%% generateLoadProfiles.m -- Adds EVs' load to orginial load profiles
clear all

%% Paths
LoadsDir = '../../European_LV_CSV/Load_Profiles/';
SaveDir = 'Load_7kW/';



%% Variables
charging_power = 7; % 4kW charging power
battery_capacity = 24; % 24 kWh
charging_time = battery_capacity/charging_power *60; % in minutes 
arrive_time = 17*60 ; % starting at 5:00 pm


%% Read original load profiles
num_loads = 55;
loads = zeros(60*24,num_loads);

for i=1:num_loads
    FileName = [LoadsDir 'Load_profile_' num2str(i) '.csv'];
    if(i==1)
        T = readtable(FileName,'HeaderLines',0,'Format','%s%f');
        time_label= T{:,1};
        loads(:,i) = T{:,2};
    else
        T = readtable(FileName,'HeaderLines',0,'Format','%s%f');
        loads(:,i) = table2array(T(:,2));
    end
end


%% Write EVs load

load('EVload_7kW.mat')

loads = loads + EVload;

%% Write new load files
for i=1:num_loads
    value = loads(:,i);
    LP_loadi =[SaveDir 'Load_profile_' num2str(i),'.player'];
    fileID = fopen(LP_loadi,'w');
    for j=1:1440
        if j<1440
            fprintf(fileID,'2000-01-01 %s, %f\n',time_label{j,:}, value(j));
        else
            fprintf(fileID,'2000-01-02 %s, %f\n',time_label{j,:}, value(j));
        end
            
    end
    fclose(fileID);
end

