function [x CostCtrl sol]=centralized(data)

%% required values 
R = data.R;
c = data.c;
x_max = data.x_max;


%% Centralized optimization (YALMIP)
N = size(R,2); % Number of EVs
M = size(R,1); % Number of lines

%opt variable
xhat=sdpvar(N,1);
%cost
cost=0;
for i=1:N
    cost=cost -log(xhat(i));
end

%contraint
constraints=[R*xhat<=c, zeros(N,1)<=xhat <= x_max*ones(N,1)];

%optimizer
ops = sdpsettings('verbose',0);
sol=solvesdp(constraints,cost,ops);


if sol.problem == 0
 x = double(xhat);
 CostCtrl = double(cost);    
else
 display('Hmm, something went wrong!');
 sol.info
 yalmiperror(sol.problem)
end

