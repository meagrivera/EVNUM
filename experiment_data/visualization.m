%This script visualizes the grid
clear all
%% Define files to read
LinesFile='../European_LV_CSV/Lines.csv';
LineCodeFile= '../European_LV_CSV/LineCodes.csv';
BuscoordsFile='../European_LV_CSV/Buscoords.csv';
LoadsFile= '../European_LV_CSV/Loads.csv';

%% Get data
Lines = readtable(LinesFile,'HeaderLines',1,'Format','%s%f%f%s%f%s%s');
LineCodes = readtable (LineCodeFile, 'HeaderLines',1,'Format','%s%u%f%f%f%f%f%f%s');
Buscoords = readtable(BuscoordsFile, 'HeaderLines',1,'Format', '%f%f%f');
Loads = readtable(LoadsFile, 'HeaderLines',2, 'Format', '%s%f%f%s%f%f%s%f%f%s');
%LoadShapes= readtable(LoadShapesFile, 'HeaderLines',1, 'Format', '%s%f%f%s%s');

%Add Ampacity to lines
Ampacity= [56    83    83   110   210   305   210   405   560   180]'; % From similar cables in Power Factory
CableNamesPF={ 'NYY 4x6   1.00 kV';... % Cable names in Power Factory
    'PVC-SWA-AL 3x25   1.00 kV';...
    'PVC-SWA-CU 3x16   1.00 kV';...
    'PILC-AL 3x35  11.00 kV';...
    'PILC-AL 1x70   1.00 kV';...
    'PILC-AL 1x120   1.00 kV';...
    'PILC-AL 1x70   1.00 kV';...
    'PILC-AL 1x185   1.00 kV';...
    'PILC-AL 1x300   1.00 kV';...
    'PILC-CU 3x50   1.00 kV'};
LineCodes=[LineCodes table(Ampacity,CableNamesPF)];


% Define single lines table
LineCodes.Properties.VariableNames{'Name'} = 'LineCode';
T = table([1:size(LineCodes,1)]','VariableNames',{'LineCodeIndex'});
LineCodes = [LineCodes T];
Lines = join(Lines, LineCodes,'key','LineCode');

% Deifine Loads Table
Loads.Properties.VariableNames{'Bus'}='Busname';
Loads = join( Loads, Buscoords,'key', 'Busname' ) ;


    
    

%% Define graph

%Edges start and terminal
s = Lines{:,2};
t = Lines{:,3};

%node labels
nLabels = Buscoords{:,'Busname'}';
eLabels = Lines{:,'Name'};
weigths = Lines{:,'Length'} .* 1e-3 .*  complex(Lines{:,'R1'}, Lines{:,'X1'});   %tranform length to [km]

% Contruct original graph
EdgeTable = table([s t], weigths , eLabels, Lines{:,'Ampacity'}, 'VariableNames', {'EndNodes' 'Admittance' 'Name' 'Ampacity'} );
NodeTable = Buscoords;
G=graph(EdgeTable,NodeTable);



%% Plot
figure
p=plot(G,'LineWidth',2);
p.XData=Buscoords{:,'x'}';
p.YData=Buscoords{:,'y'}';



% Highlights
highlight(p,Loads{:,'Busname'},'MarkerSize',6 ,'NodeColor','k', 'Marker','v') 
highlight(p,1,'MarkerSize',8 ,'NodeColor','r', 'Marker','s')
labelnode(p,1,'Transformer')
labelnode(p,Loads{:,'Busname'}, Loads{:,'Name'} )

% style
axis([min(Buscoords{:,'x'})-10 max(Buscoords{:,'x'})+10 min(Buscoords{:,'y'}')-10 max(Buscoords{:,'y'}')+10])
axis off
set(gca,'position',[0 0 1 1],'units','normalized')

 