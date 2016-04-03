%experiment1.m - primal dynamic experiment for 20 kw charging rate

%Dynamic case
clear all



%% Deifine grid and EV arrival files
data = load('../experiment_data/grid.mat');
load('../grid_simulations/EVs_20kW/EVload_20kW.mat');
EVload = EVload'; % works to indicate if vehicle is there
for i=1:size(EVload,1)
    EVconnectSlot(i) = find(EVload(i,:),1);
    EVload(i,EVconnectSlot(i):end) = ones(size(EVload(i,EVconnectSlot(i):end)));
end

data.convergence= 0;  % (1) stop on convergence (0) keep going
data.stop_fopt = 0;

time = 60*24; % simulation time [min]
slotDur = 1; % time slot duration [min]
step_size_dual = 1e-5;       % dual step size
data.x_max = 20;% 80 ; % 80 amps as maximal current
%% Simulation
numberChanges= size(data.c,2);
ITER=time/numberChanges/slotDur; % Number of iterations without change

N = size(data.R,2); % Number of EVs
M = size(data.R,1); % Number of EVs
history.x = 16* ones(N,1);
history.flows = 0* ones(M,1);

history.price = 1* ones(M,1);



for i = 1:numberChanges
    
    fprintf('\n \t On iteration %i of %i',i,numberChanges)
    dataChange = data;
    dataChange.c = data.c(:,i);
    dataChange.cload = data.cload(:,i);
    dataChange.evload = EVload(:,i); % inmax(peak_line_currents')'dicator of EV start charging
    for j = 1:N % check if battery of EVs is full
        if sum(history.x(j,:)) >= 24*60
            dataChange.evload(j,1) = 0;
        end
    end
    
    dataChange.xstart=history.x(:,end);
    dataChange.pricestart=history.price(:,end);
    [x historyTemp]=dual(dataChange,step_size_dual,ITER);
    
    history.price=[history.price historyTemp.price];
    
    
    history.x= [history.x historyTemp.x ];
    history.flows= [history.flows historyTemp.flows];
    
    
    
end

%%
save('dual_dynamic_result.mat')

%% Plots for control (comment out)
figure
plot(1:1440,history.flows(1,2:end),'k', 1:1440, data.cinit(1,:)*ones(1440,1),'b')
