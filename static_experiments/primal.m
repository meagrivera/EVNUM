%static primal decomposition
function [x history] = primal(data,step_size)

%% Primal deocmposition parameters
ITER = 1e4;
TOL = 1e-6; % Tolerance for terminating algorithm

history.ITER = ITER;
history.TOL = TOL;

%% Rasign variables
c = data.c;
R = data.R;
x_max = data.x_max;
cload = data.cload;

%% Algorithm
%Initialize
N = size(R,2); % Number of EVs
M = size(R,1); % Number of lines


x = 16 * ones(N,1); % EV charging rate
marginal_benefit = 1e10* ones(N,1); % Optimization
b = 0* ones(N,1);


history.convergence = 0; % algorithm convergence
history.violation = 0;  % algorithm violated contraints

%% primal algorithm

tic
for k=1:ITER
    
    % Violation of contraints
    history.violationLevel(k) = norm(R*x-c,inf);
    if  any(R*x>c) > 1e-3 && k~=1
        history.violation=1;
    end
    
    
    % History of all
    history.x(:,k) = x;
    history.cost(k) = -sum(log(x));
    history.marginal_benefit(:,k)= marginal_benefit;
    history.flows(:,k)= R*x  + cload;
    history.b(:,k)= b;
    
    %%%PROTECTION DEVICE
    %Update line assigment
    b = b - step_size * (-marginal_benefit);
    % projection on local budget
    for l=1:M
        if R(l,:)*b>c(l)
            b = b+(c(l)-R(l,:)*b)*R(l,:)'/norm(R(l,:))^2;
        end
    end
    
    
    % convergence criteria
    if norm(history.b(:,k) - b)< sqrt(N)* TOL && ~history.convergence
        history.convergence = 1;
        history.convergenceTime = toc;
        history.convergenceIter = k; 
        if data.convergence
            break;
        end
    end
    
    if data.stop_fopt
        distance = (abs(data.fopt-history.cost(k)))/ abs(data.fopt);
        if distance < 0.05 % convergence to 95% achieved
            break;
        end
    end
    
    
    
    %%%EV CHARGER
    % % update each user (each user sends marginal cost)
    for i = 1:N
        % user optimization result
        x(i) = min(b(i),x_max);
        
        % calculate marginal cost
        if x(i) < b(i)
            marginal_benefit(i)=0;
        else
            marginal_benefit(i)=1/x(i);
            if x(i) == 0
                marginal_benefit(i)=1e10;
            end
        end
        
    end
    
    
    
end
history.time=toc;



