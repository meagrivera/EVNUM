% static dual decomposition solution
function [x history] = dual(data, step_size, ITER)

%% Dual deocmposition parameters


%% Rasign variables
c=data.c;
R= data.R;
x_max=data.x_max;
cload=data.cload;
evload = data.evload;

%% Algorithm initialization
N= size(R,2); % Number of EVs
M= size(R,1); % Number of lines

%Define optimization variables
%price=ones(M,1);
x=data.xstart;
price=data.pricestart;

history.convergenge=0; % algorithm convergence
history.violation=0;  % algorithm violated contraints

% Maximal number of lines
% Lmax= max(sum(R)); % maximal number of lines used by an EV
% Smax= max(sum(R')); % maximal number of EVs

% step size                                                    STEP SIZE
%kappa= 1.74e-04;%2/(m^2*Lmax*Smax); % (for minimal multiply by 2)
% kappa= 1.6e-5;%2/(m^2*Lmax*Smax); % (for minimal multiply by 2)


%% Dual algorithm
tic
for k=1:ITER
    

    
% % Update prices for each line
        
        price=max(price - step_size * (c- R*x ), 0);
        history.price(:,k)= price;

% % Update rate for each EV
        % aggregate price for each EV
       
        % Sum of prices for EVs
        agrPrice= R'*price;
       for i=1:N
           if evload(i) ~= 0 
            x(i) = min(1/agrPrice(i), x_max );
            
        else
            x(i) = 0;
           end
        
       end
        
        history.x(:,k)= x;
        history.flows(:,k)= R*x + cload ; % flows through lines







end
history.time=toc;


