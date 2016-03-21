% static dual decomposition solution
function [x history] = dual(data, step_size)

%% Dual deocmposition parameters
ITER = 1e5;
TOL = 1e-6; % Tolerance for terminating algorithm


%% Rasign variables
c = data.c;
R = data.R;
x_max = data.x_max;
cload = data.cload;


%% Algorithm initialization
N = size(R,2); % Number of EVs
M = size(R,1); % Number of lines

%Define optimization variables
price = 0.1*ones(M,1);
x = 16* ones(N,1);

history.convergenge=0; % algorithm convergence
history.violation=0;  % algorithm violated contraints
history.convergence=0;


% Conergence step size
% Lmax = max(sum(R)); % maximal number of lines used by an EV
% Smax = max(sum(R')); % maximal number of EVs
% step_size = 1.74e-04;%2/(m^2*Lmax*Smax); % (for minimal multiply by 2)



%% Dual algorithm
tic
for k=1:ITER
    
    % Violation of contraints
    history.violationLevel(k) = norm(R*x-c,inf);
    if  any(R*x>c) > 1e-3 && k~=1
        history.violation=1;
    end
    
    
    
    % Update prices for each line
    history.price(:,k)= price;
    price=max(price - step_size * (c- R*x ), 0);
    
    
    % % Convergence
    if norm(history.price(:,k) - price)< sqrt(M) *TOL && ~history.convergence
        history.convergence=1;
        history.convergenceTime=toc;
        history.convergenceIter=k;
        if data.convergence
            break;
        end
    end
    
   
    
    % Update rate for each EV
    % Sum of prices for EVs
    agrPrice= R'*price;
    
    x = min(1./agrPrice, x_max );
    
    history.x(:,k)= x;
    history.cost(k) = -sum(log(x));
    history.flows(:,k)= R*x + cload ; % flows through lines
    
    
     % stop if distance to optimal small
    if data.stop_fopt
        distance = (abs(data.fopt-history.cost(k)))/ abs(data.fopt);
        if distance < 0.05 % convergence to 95% achieved
            break;
        end
    end
    
    
    
    
end
history.time=toc;


