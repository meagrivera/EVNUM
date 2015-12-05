%This script visualizes the grid
clear all
%% VAriables
ForPaper = 1; % (1) plots for paper (0) plots not for paper

%Define Ampacity of line types 



%% Define files to read
linesFile='../European_LV_CSV/Lines.csv';
lineCodeFile= '../European_LV_CSV/LineCodes.csv';
BuscoordsFile='../European_LV_CSV/Buscoords.csv';

LoadsFile= '../European_LV_CSV/Loads.csv';
LoadShapesFile= '../European_LV_CSV/LoadShapes.csv';
%% Get data
Lines = readtable(linesFile,'HeaderLines',1,'Format','%s%f%f%s%f%s%s');
LineCodes = readtable (lineCodeFile, 'HeaderLines',1,'Format','%s%u%f%f%f%f%f%f%s');
Buscoords = readtable(BuscoordsFile, 'HeaderLines',1,'Format', '%f%f%f');
Loads = readtable(LoadsFile, 'HeaderLines',2, 'Format', '%s%f%f%s%f%f%s%f%f%s');
LoadShapes= readtable(LoadShapesFile, 'HeaderLines',1, 'Format', '%s%f%f%s%s');

%Add Ampacity to lines
Ampacity= [56;    80;    83;   110;   210;   305;   305;   405;   560;  560]; % From similar cables in Power Factory
CableNamesPF={ 'NYY 4x6   1.00 kV';... % Cable names in Power Factory
    'PVC-SWA-AL 3x25   1.00 kV';...
    'PVC-SWA-CU 3x16   1.00 kV';...
    'PILC-AL 3x35  11.00 kV';...
    'PILC-AL 1x70   1.00 kV';...
    'PILC-AL 1x120   1.00 kV';...
    'PILC-AL 1x300   1.00 kV';...
    'PILC-AL 1x185   1.00 kV';...
    'PILC-AL 1x70   1.00 kV'
    'unknown still waiting on gregorio'};
LineCodes=[LineCodes table(Ampacity,CableNamesPF)];


% put information of lines together
LineCodes.Properties.VariableNames{'Name'} = 'LineCode';
T = table([1:size(LineCodes,1)]','VariableNames',{'LineCodeIndex'});
LineCodes = [LineCodes T];
Lines = join(Lines, LineCodes,'key','LineCode');

% Deifine information of loads
Loads.Properties.VariableNames{'Bus'}='Busname';
Loads = join( Loads, Buscoords,'key', 'Busname' ) ;


%% Regularize IEEE European LV Test Feeder data for EVNUM

%Edges start and terminal
s = Lines{:,2};
t = Lines{:,3};

%node labels
nLabels = Buscoords{:,'Busname'}';
eLabels = Lines{:,'Name'};
weigths = Lines{:,'Length'} .* 1e-3 .*  complex(Lines{:,'R1'}, Lines{:,'X1'});   %tranform length to [km]

weigthsAbs= abs(weigths);



% Contruct original graph
EdgeTable = table([s t], weigths , eLabels, Lines{:,'Ampacity'}, 'VariableNames', {'EndNodes' 'Admittance' 'Name' 'Ampacity'} );
NodeTable = Buscoords;
G1=graph(EdgeTable,NodeTable);

% Construc graph only with paths to loads
tree = shortestpathtree(G1,Loads{:,'Busname'},1); % paths to load
G2= graph(tree.Edges, tree.Nodes);
indexTerminal = find(degree(G2)==1);
indexJunction = find(degree(G2)>2);
indexRouting = find(degree(G2)==2);
indexNewNodes= [indexTerminal; indexJunction];

% build new Graph with less nodes (use option ForPaper=0 to verify visually )
snew= [1  25 27 27 25 32 36 36 32 59 66 66 59  101 155 155 171 188 188 171 196 196 241 241 101 114 127 127 145 261 261 145 283 283 114 247 247 263 263 280 373 373 391 530 530 391 505 505 578 578 594 594 615 615 666 786 786 854 854 666 686 690 690 686 691 691 707 891 891 707 718 739 739 718 745 763 763 745 794 884 884 794 868 868 280 310 336 336 310 325 325 332 332 453 453 475 484 484 475 508 544 544 508 559 651 651 559 587 587];
tnew= [25 27 70 34 32 36 47 83 59 66 73 74 101 155 178 171 188 208 264 196 225 241 248 249 114 127 289 145 261 314 276 283 327 320 247 387 263 342 280 373 458 391 530 556 539 505 522 578 785 594 614 615 688 666 786 817 854 861 860 686 690 701 778 691 702 707 891 896 900 718 739 813 755 745 763 835 780 794 884 906 898 868 899 886 310 336 349 388 325 337 332 406 453 629 475 484 563 502 508 544 611 562 559 651 676 682 587 619 639];

% Determine ampacity (may need to fix this by hand)
for i=1:length(tnew)

    idxLine= find(Lines.Bus2== tnew(i));
    if length(idxLine)>1
        spritf('something wong')
    end
    newAmpacity(i)= Lines.Ampacity(idxLine(1));
end

%Verify all loads are accountted for
for i= 1: size(Loads,1)
   
    test = find(tnew==Loads{i,'Busname'});
    if isempty(test)
        fprintf('\n\t The load in Table Loads with index %i is not accounted for\n',i);
    end
    
end


% Calculate impedance of lines
Greal = graph(s,t, real(weigths) );
Gimag = graph (s, t, imag(weigths));

newR= distances(Greal);
newR= diag( newR( snew,tnew ) );

newX= distances( Gimag );
newX= diag( newX( snew,tnew ) );

newWeigths = complex( newR, newX );
for i=1:length(newWeigths)
    newLineNames{i}= ['c_' num2str(i)];
    
end
%newAmpacity= 

% Create simplified graph
EdgeTableNew = table([snew' tnew'], newWeigths, newLineNames', newAmpacity' , 'VariableNames', {'EndNodes' 'Admittance' 'Name' 'Ampacity'} );
NodeTableNew = Buscoords;
Gsimple=graph(EdgeTableNew,NodeTableNew);

Gplot = rmnode(Gsimple,find(degree(Gsimple)==0)); % remove nodes for plot
% determine Load Index
indexLoad=[];
for i=1:length(Gplot.Nodes{:,1})
    
    if any(Gplot.Nodes{i,1}==Loads{:,'Busname'})
    indexLoad=[indexLoad i];
        
    end
    
end


%% Plot
figure
if ForPaper== 1
    
     %ptest=plot(Gplot,'LineWidth',2,'MarkerSize', 5,'EdgeLabel',Gplot.Edges.Ampacity);
     %layout(ptest,'layered','Direction','right','Sources',[1])
     %highlight(ptest,,'MarkerSize',5 ,'NodeColor','k', 'Marker','v')

     psimple=plot(Gplot,'LineWidth',2,'MarkerSize', 5)
          axis([min(Buscoords{:,'x'})-10 max(Buscoords{:,'x'})+10 min(Buscoords{:,'y'}')-10 max(Buscoords{:,'y'}')+10])
     psimple.XData=Gplot.Nodes.x;
     psimple.YData=Gplot.Nodes.y;
  %  highlight(ptest,indexJunction,'MarkerSize',10 ,'NodeColor','r')
%     p2=plot(G2,'LineWidth',2,'Marker','none');
%     p2.XData=Buscoords{G2.Nodes.Busname ,'x'}';
%     p2.YData=Buscoords{G2.Nodes.Busname ,'y'}';
%     
    hold on
    
    p=plot(G1,'LineStyle','--');
    axis off
    set(gca,'position',[0 0 1 1],'units','normalized')
    
    
    axis([min(Buscoords{:,'x'})-10 max(Buscoords{:,'x'})+10 min(Buscoords{:,'y'}')-10 max(Buscoords{:,'y'}')+10])
    p.XData=Buscoords{:,'x'}';
    p.YData=Buscoords{:,'y'}';
    p.Marker = 'none'; % no marker on connection nodes
    highlight(p,Loads{:,'Busname'},'MarkerSize',5 ,'NodeColor','k', 'Marker','v') % highlight Loads
    highlight(p,1,'MarkerSize',8 ,'NodeColor','r', 'Marker','s')
    labelnode(p,1,'Transformer')
    labelnode(p,Loads{:,'Busname'}, Loads{:,'Name'} )

    legend('Simplified','Original')
    
else
    figure
    p=plot(G1,'LineWidth',2, 'EdgeLabel',G1.Edges.Ampacity);
    %p=plot(G1,'LineWidth',2);
    title('Original IEEE European LV Test Feeder')
    axis([min(Buscoords{:,'x'})-10 max(Buscoords{:,'x'})+10 min(Buscoords{:,'y'}')-10 max(Buscoords{:,'y'}')+10])
    p.XData=Buscoords{:,'x'}';
    p.YData=Buscoords{:,'y'}';
    
    % Highlight and name terminal and junction buses
    labelnode(p,indexTerminal, G1.Nodes.Busname(indexTerminal));
    labelnode(p,indexJunction, G1.Nodes.Busname(indexJunction));
    highlight(p,indexTerminal,'MarkerSize',10 ,'NodeColor','g')
    highlight(p,1,'MarkerSize',8 ,'NodeColor','r', 'Marker','s')
    highlight(p,indexJunction,'MarkerSize',10 ,'NodeColor','r')
    labelnode(p,1,'Transformer')
    %labelnode(p,Loads{:,'Busname'}, Loads{:,'Name'} )
  
    
    
%     
%     
%     highlight(p,indexRouting,'MarkerSize',10 ,'NodeColor','b')
    
    
end







