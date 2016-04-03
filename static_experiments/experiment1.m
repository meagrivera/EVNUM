% Experiment convergence to optimal result
clear all


%% Expriment parameters
% Define primal step size
%K= 55/4; % upper bound of primal function
%gamma = 2/K^2;
step_size_primal = [1 0.1 0.01];

%Define dual step size
Lmax = 157; % maximal number of lines used by an EV
Smax = 55; % maximal number of EVs
lambda = 2/(80^2*Lmax*Smax); % (for minimal multiply by 2) % difficult to converge
step_size_dual = [1e-4 1e-5 lambda];

%% Deifine grid
data = load('../experiment_data/grid.mat');
data.convergence= 0;  % (1) stop on convergence (0) keep going
data.stop_fopt = 0;
%% Define time
data.c = data.c(:,18*60) ; % take load at 18:00 hours
data.cload = data.cload(:,18*60) ; % take load at 18:00 hours
data.x_max = 80 ; % 80 amps as maximal current
%% experiemnt

%centralized
fprintf('\n\n Computing centralized results')
[x cost_central sol]=centralized(data);

%primal
fprintf('\n\n Computing primal results')
for i = 1:length(step_size_primal)
    % primal values
    [x_primal history_primal] = primal(data,step_size_primal(i));
    cost_primal(:,i) = history_primal.cost';
    feasibility_primal(:,i) = history_primal.violationLevel;
end

%dual
fprintf('\n\n Computing dual results')
for i = 1:length(step_size_dual)
    [x_dual history_dual] = dual(data,step_size_dual(i));
    cost_dual(:,i) = history_dual.cost';
    feasibility_dual(:,i) = history_dual.violationLevel;
end

%differences
diff_primal = abs( cost_central*ones(size(cost_primal)) - cost_primal ) / abs(cost_central); 
diff_dual = abs( cost_central*ones(size(cost_dual)) - cost_dual ) / abs(cost_central);

%% plotting
Iterations = length(diff_primal(:,1));
set(0,'defaultlinelinewidth',3)
figure
semilogy(1:Iterations,diff_primal(:,1),'-',1:Iterations,diff_primal(:,2),'--',...
    1:Iterations,diff_primal(:,3),'-.')
xlabel('Iteration')
ylabel('Normal distance to optimal')
legend(['primal (' num2str(step_size_primal(1)) ')'],...
    ['primal (' num2str(step_size_primal(2)) ')'],...
    ['primal (' num2str(step_size_primal(3)) ')'])
set(gca,'FontSize',16)
grid on
% hold on
% plot(1:Iterations, 0.05*ones(size(1:Iterations)),'k--')


figure
semilogy(1:Iterations,diff_dual(:,1),'-',1:Iterations,diff_dual(:,2),'--',...
    1:Iterations,diff_dual(:,3),'-.')
xlabel('Iteration')
ylabel('Normal distance to optimal')
legend(['dual (' num2str(step_size_dual(1)) ')'],...
    ['dual (' num2str(step_size_dual(2)) ')'],...
    ['dual (' num2str(step_size_dual(3)) ')'])
set(gca,'FontSize',16)
grid on
% hold on
% plot(1:Iterations, 0.05*ones(size(1:Iterations)),'k--')



% Plotting infeasibility (not really relevant in this example)
% figure
% semilogy(1:Iterations,feasibility_primal(:,1),'-',1:Iterations,feasibility_primal(:,2),'-',...
%     1:Iterations,feasibility_dual(:,1),'--',1:Iterations,feasibility_dual(:,2),'--')
% xlabel('Iteration')
% ylabel('Distance to optimal')
% legend(['primal (' num2str(step_size_primal(1)) ')'],...
%     ['primal (' num2str(step_size_primal(2)) ')'],...
%     ['dual (' num2str(step_size_dual(1)) ')'],...
%     ['dual (' num2str(step_size_dual(2)) ')'])
% 
% set(gca,'FontSize',16)
