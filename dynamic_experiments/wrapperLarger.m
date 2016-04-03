%Dynamic case
clear all



%%  
SAVE=1; % save yes 1 / no 0
PLOT= 1; % plot yes 1 / no 0

caseName='caseReal'; % case of load change 
method='dual';   % cmethod for control primal/dual
time = 3600*2; % simulation time [sec]
slotDur= 0.02; % time slot duration [sec] 
alpha=1;            % primal step size
kappa=8.68e-5;         % dual step size

%%
data = load(caseName);
numberChanges= size(data.c,2);
ITER=time/numberChanges/slotDur; % Number of iterations without change

N= size(data.R,2); % Number of EVs
M= size(data.R,1); % Number of EVs
history.x=0* ones(N,1);
history.flows=0* ones(M,1);

history.price= 1* ones(M,1);


history.lambda=0* ones(N,1); % marginal cost (Primal)
history.t=0* ones(N,1);     % preallocation (Primal)

for i=1:numberChanges
    
   fprintf('\n \t ON iteration %i of %i',i,numberChanges)
    dataChange=data;
    dataChange.c=data.c(:,i);
    dataChange.cload=data.cload(:,i);
   
    
    switch method
        
        case 'primal'
            
            name=['results/' method '_' caseName '_' num2str(alpha) '.mat'];
            dataChange.tstart=history.t(:,end);
            
            [x historyTemp]=primal(dataChange,alpha,ITER);
            
            history.lambda=[history.lambda historyTemp.lambda];
            history.t= [history.t historyTemp.t];
            
        case 'dual'
             name=['results/' method '_' caseName '_' num2str(kappa) '.mat'];
            
            dataChange.xstart=history.x(:,end);
            dataChange.pricestart=history.price(:,end);
            [x historyTemp]=dual(dataChange,kappa,ITER);
            
            history.price=[history.price historyTemp.price];
        otherwise
            
            fprintf('\n Error: No valid method selection (primal / dual)')
    end
    
    
     history.x= [history.x historyTemp.x ];
     history.flows= [history.flows historyTemp.flows];

   
    
    
    
    
end

%%
if SAVE

    

save(name)
end
%% plotting save results (for plottign just load saved results)
k=numberChanges*ITER;


if PLOT
     set(0,'defaultlinelinewidth',3)
     FONTSIZE=14;
    figure
    
   %
    
    subplot(311)
    set(gca,'FontSize',FONTSIZE)
     plot(0:k,data.cinit(1)*ones(k+1,1)*data.VOLTAGE , 0:k,history.flows(1,:)*data.VOLTAGE)
     ylabel('Transformer (KVA)')
     xlabel('Iteration')
     
     subplot(312)
     set(gca,'FontSize',FONTSIZE)
     plot(0:k, data.cinit(5)*ones(k+1,1),0:k,history.flows(5,:))
     ylabel('Line 5 (A)')
     xlabel('Iteration')
     
     subplot(313)
     set(gca,'FontSize',FONTSIZE)
     plot(0:k, data.cinit(9)*ones(k+1,1),0:k,history.flows(9,:))
     ylabel('Line 9 (A)')
xlabel('Iteration')
%legend('\alpha1=1','\kappa=1e-4','Maximal loading')
legend('Budget-based','Incentive-based','Maximal loading')
     
end



