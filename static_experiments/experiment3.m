% experiment 3

% experiment2
% Varying the number of EVs


% Experiment convergence to optimal result
clear all


%% Expriment parameters
step_size_primal = 1;
step_size_dual = 1e-6;
M = [100 200 300 400 500 600 700 800 900];

%% Deifine grid
data = load('../experiment_data/grid.mat');
data.convergence= 0;  % (1) stop on convergence (0) keep going
data.stop_fopt = 1; % Stop when distance to optimal small enough
%% Define time
data.c = data.c(:,18*60) ; % take load at 18:00 hours
data.cload = data.cload(:,18*60) ; % take load at 18:00 hours
data.x_max = 80 ; % 80 amps as maximal current
%% experiemnt
Rorg = data.R;
corg = data.c;
cloadorg = data.cload;
for i = 1:length(M)
    data.R = Rorg(1:M(i),:);
    data.c = corg(1:M(i),:);
    data.cload = cloadorg(1:M(i),:);
    %centralized
    fprintf('\n\n Computing centralized results')
    [x cost_central sol]=centralized(data);
    data.fopt= cost_central; % store cost to stop optimization of primal/dual
    
    %primal
    fprintf('\n\n Computing primal results')
    % primal values
    step_size_primal =1;
    [x_primal history_primal] = primal(data,step_size_primal);
    primal_iterations(i) = length(history_primal.cost);
    
    
    
    %dual
    Lmax = max(sum(data.R)); % maximal number of lines used by an EV
    Smax = max(sum(data.R')); % maximal number of EVs
    step_size_dual =1e-6; % 2/(80^2*Lmax*Smax); % (for minimal multiply by 2)
    fprintf('\n\n Computing dual results')
    [x_dual history_dual] = dual(data,step_size_dual);
    dual_iterations(i) = length(history_dual.cost);
end



%% plotting
set(0,'defaultlinelinewidth',3)
figure
plot(M,primal_iterations)
xlabel('Number of grid lines')
ylabel('Iterations')
%legend('primal','dual')
set(gca,'FontSize',16)


figure
plot(M,dual_iterations,'-')
xlabel('Number of grid lines')
ylabel('Iterations')
%legend('primal','dual')
set(gca,'FontSize',16)

