%This script visualizes the grid
clear all
%% VAriables
ForPaper = 1; % (1) plots for paper (0) plots not for paper
Details = 1   % (1) for line and node definitions  




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
Ampacity= [56    80    83   110   210   305   210   405   560   180]'; % From similar cables in Power Factory
CableNamesPF={ 'NYY 4x6   1.00 kV';... % Cable names in Power Factory
    'PVC-SWA-AL 3x25   1.00 kV';...
    'PVC-SWA-CU 3x16   1.00 kV';...
    'PILC-AL 3x35  11.00 kV';...
    'PILC-AL 1x70   1.00 kV';...
    'PILC-AL 1x120   1.00 kV';...
    'PILC-AL 1x300   1.00 kV';...
    'PILC-AL 1x185   1.00 kV';...
    'PILC-AL 1x70   1.00 kV'
    'PILC-CU 3x50   1.00 kV'};
LineCodes=[LineCodes table(Ampacity,CableNamesPF)];


% put information of lines together
LineCodes.Properties.VariableNames{'Name'} = 'LineCode';
T = table([1:size(LineCodes,1)]','VariableNames',{'LineCodeIndex'});
LineCodes = [LineCodes T];
Lines = join(Lines, LineCodes,'key','LineCode');

% Deifine information of loads
Loads.Properties.VariableNames{'Bus'}='Busname';
Loads = join( Loads, Buscoords,'key', 'Busname' ) ;

% Load profiles
profile={};
time={};
for i=1:size(Loads,1)
    
    T = readtable(['../European_LV_CSV/Load_Profiles/Load_profile_' num2str(i) '.csv'] );
    profile{i,1} = T{:,'mult'};
    time{i,1} = T{:,'time'};
end

Loads=[Loads table(time) table(profile)];
    
    

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

% Construc helping graph G2 only with paths to loads
tree = shortestpathtree(G1,Loads{:,'Busname'},1); % directed graphs to load to load
G2= graph(tree.Edges, tree.Nodes);
indexTerminal = find(degree(G2)==1);
indexJunction = find(degree(G2)>2);
indexRouting = find(degree(G2)==2);
indexNewNodes= [indexTerminal; indexJunction];

% New simple Graph with less nodes (verify visually )
snew= [1  25 27 27 25 32 36 36 32 59 66 66 59  101 155 155 171 188 188 171 196 196 241 241 101 114 127 127 145 261 261 145 283 283 114 247 247 263 263 280 373 373 391 530 530 391 505 505 578 578 594 594 615 615 666 786 786 854 854 666 686 690 690 686 691 691 707 891 891 707 718 739 739 718 745 763 763 745 794 884 884 794 868 868 280 310 336 336 310 325 325 332 332 453 453 475 484 484 475 508 544 544 508 559 651 651 559 587 587];
tnew= [25 27 70 34 32 36 47 83 59 66 73 74 101 155 178 171 188 208 264 196 225 241 248 249 114 127 289 145 261 314 276 283 327 320 247 387 263 342 280 373 458 391 530 556 539 505 522 578 785 594 614 615 688 666 786 817 854 861 860 686 690 701 778 691 702 707 891 896 900 718 739 813 755 745 763 835 780 794 884 906 898 868 899 886 310 336 349 388 325 337 332 406 453 629 475 484 563 502 508 544 611 562 559 651 676 682 587 619 639];

%Verify all loads are accountted for
for i= 1: size(Loads,1)
   
    test = find(tnew==Loads{i,'Busname'});
    if isempty(test)
        fprintf('\n\t The load in Table Loads with index %i is not accounted for\n',i);
    end
    
end


% Determine ampacity of simplified Graph (may need to fix terminal edges)
for i=1:length(tnew)

    idxLine= find(Lines.Bus2== tnew(i));
    if length(idxLine)>1
        spritf('\t something wrong')
    end
    newAmpacity(i)= Lines.Ampacity(idxLine(1));
end




% Calculate impedances of simple Graph
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


% Create simplified Graph
EdgeTableNew = table([snew' tnew'], newWeigths, newLineNames', newAmpacity' , 'VariableNames', {'EndNodes' 'Admittance' 'Name' 'Ampacity'} );
NodeTableNew = Buscoords;
Gsimple=graph(EdgeTableNew,NodeTableNew);

% Remove nodes for plot
Gplot = rmnode(Gsimple,find(degree(Gsimple)==0)); 

% Determine Load Index for Gplot
indexLoad=[];
for i=1:length(Gplot.Nodes{:,1})
    
    if any(Gplot.Nodes{i,1}==Loads{:,'Busname'})
    indexLoad=[indexLoad i];
        
    end
    
end


%% Plots

% Plot for inspection
figure
%p=plot(G1,'LineWidth',2, 'EdgeLabel',G1.Edges.Ampacity);
p=plot(G1,'LineWidth',2);
%title('Original IEEE European LV Test Feeder: (green=loads, red=junctions)')
axis([min(Buscoords{:,'x'})-10 max(Buscoords{:,'x'})+10 min(Buscoords{:,'y'}')-10 max(Buscoords{:,'y'}')+10])
p.XData=Buscoords{:,'x'}';
p.YData=Buscoords{:,'y'}';

% % Highlight and name terminal and junction buses
labelnode(p,indexTerminal, G1.Nodes.Busname(indexTerminal));
labelnode(p,indexJunction, G1.Nodes.Busname(indexJunction));
highlight(p,indexTerminal,'MarkerSize',10 ,'NodeColor','g')
highlight(p,1,'MarkerSize',8 ,'NodeColor','r', 'Marker','s')
highlight(p,indexJunction,'MarkerSize',10 ,'NodeColor','r')
labelnode(p,1,'Transformer')


% Plot for paper
figure
psimple=plot(Gplot,'LineWidth',2,'MarkerSize', 5);
axis([min(Buscoords{:,'x'})-10 max(Buscoords{:,'x'})+10 min(Buscoords{:,'y'}')-10 max(Buscoords{:,'y'}')+10]);
psimple.XData=Gplot.Nodes.x;
psimple.YData=Gplot.Nodes.y;

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


%% Extract test grid parameters

% calculate routing matrix
R=zeros( size(Gplot.Edges,1), length(indexLoad) ); 

for i=1:length(indexLoad)
    
    pathToLoad = shortestpath(Gplot,1,indexLoad(i));
    
    indexEdges= findedge(Gplot,pathToLoad(1:end-1),pathToLoad(2:end)) ;
    
    R(indexEdges,i)=ones(size(indexEdges));
        
end

%% Calculate EVNUM parameters 

% Define ampacity of lines
cinit= Gplot.Edges.Ampacity;


% Define load
profiles= cell2mat(Loads{:,'profile'}');
profilesAmp= profiles/0.23;
sumProfilesAmp= sum(profilesAmp');
indxmax= find(sumProfilesAmp==max(sumProfilesAmp));
indxmin= find(sumProfilesAmp==min(sumProfilesAmp));


xload= profilesAmp';
xloadmin= profilesAmp(indxmin,:)';
xloadmax= profilesAmp(indxmax,:)';


cmax = cinit - R * xloadmax;
cmin = cinit - R * xloadmin;


%% Calculte power flow parameters

% Admittanc ematrix - calculatred based on incidence matrix 
I=full( incidence(Gplot))';
Bline=diag(Gplot.Edges.Admittance);

Y= I'*Bline* I; 






  