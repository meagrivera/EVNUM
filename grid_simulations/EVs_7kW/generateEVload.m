% generateEVarrival.m
clear all
%% Variables
charging_rate = 7;
arrive_time = 17*60 ; % starting at 5:00 pm
charging_slots = ceil(24/charging_rate*60); % number of required charging slots in min

%% Define EV Charging

% lambda variable
paper_lamda = 0.1; % Of Ardakanian paper 1 every 10 seconds
lamda = 1; %I am gonna make one every minute


EVload=zeros(24*60,55);

take_load = linspace(1,55,55); %to select loads randomly
count=0; %how many EVs have dep/arrived
i=0; % to count minute of EV arrival. Start in 18:00
while (count~=55)
    EVs_pm = poissrnd(lamda); %how many cars depart/arrive in this minute
    
     if (count+EVs_pm>55) %to not exceed number of EVs/loads
         EVs_pm = 55-count;
         count_test=count;
     end
     count = count + EVs_pm;
     
    %  to selected load
    for e=1:EVs_pm
        [take_me,idx] = datasample(take_load,1); %take one random load
        
        % modify LP of taked load
        in = arrive_time +i; %to measure the minute of arrival
        
        EVload(in+1:in+charging_slots,take_me) = charging_rate* ones(charging_slots,1);
        
        take_load(:,idx)=[]; %delete used load
    end
    
    i=i+1; %sum one minute to next EVs poisson arrival
end

%% plot
spy(EVload, 's')
ylim([1000 24*60])

%% Save the EV load
save('EVload_7kW.mat','EVload')

