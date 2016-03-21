% Prepare data for EV NUM paper
% author: Jose Rivera (2016)

clear all

%% Definition variable
base_voltage = 230;  %416/sqrt(3); % THe base voltage of the loads 

%% Define files to read
linesFile='../European_LV_CSV/Lines.csv';
lineCodeFile= '../European_LV_CSV/LineCodes.csv';
BuscoordsFile='../European_LV_CSV/Buscoords.csv';

LoadsFile= '../European_LV_CSV/Loads.csv';
LoadShapesFile= '../European_LV_CSV/LoadShapes.csv';
%% Getting data
Lines = readtable(linesFile,'HeaderLines',1,'Format','%s%f%f%s%f%s%s');
LineCodes = readtable (lineCodeFile, 'HeaderLines',1,'Format','%s%u%f%f%f%f%f%f%s');
Buscoords = readtable(BuscoordsFile, 'HeaderLines',1,'Format', '%f%f%f');
Loads = readtable(LoadsFile, 'HeaderLines',2, 'Format', '%s%f%f%s%f%f%s%f%f%s');
LoadShapes= readtable(LoadShapesFile, 'HeaderLines',1, 'Format', '%s%f%f%s%s');

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


%% Ordering data
% Add line code information to lines table
LineCodes.Properties.VariableNames{'Name'} = 'LineCode';
Lines = join(Lines, LineCodes,'key','LineCode');

%% Constructing graph 
s = Lines{:,2};
t = Lines{:,3};
G = graph(s,t);


%% Contruct routing matrix (TO ADD VOLTAGE CONSIDERATION)
R=zeros( size(G.Edges,1), height(Loads) ); 

for i=1:height(Loads)
    
    pathToLoad = shortestpath(G,1,Loads{i,'Bus'});
    
    indexEdges= findedge(G,pathToLoad(1:end-1),pathToLoad(2:end)) ;
    
    R(indexEdges,i)=ones(size(indexEdges));
        
end

%% Construct load parameters (TO ADD VOLTAGE CONSIDERATION)
cinit= Lines.Ampacity;

% Read original load profiles
num_loads = 55;
loads = zeros(60*24,num_loads);

for i=1:num_loads
    FileName = ['../European_LV_CSV/Load_Profiles/Load_profile_' num2str(i) '.csv'];
    T = readtable(FileName,'HeaderLines',0,'Format','%s%f');
    loads(:,i) = table2array(T(:,2));
end

xload = loads ./ base_voltage;

cload = R * xload'; 
c = repmat(cinit,1,size(xload,1)) - cload;

%% save data
save('grid.mat','R','cinit', 'cload', 'c')






