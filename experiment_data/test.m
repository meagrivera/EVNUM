% testing the U = Z I idea

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

%% The line configurations

% Z_2c__007 = [
% 	 6.389080+0.159325j 0.000000+0.000000j 0.000000+0.000000i;...
%      0.000000+0.000000j 6.389080+0.159325j 0.000000+0.000000j;...
% 	 0.000000+0.000000j 0.000000+0.000000j 6.389080+0.159325j]
% 
% 
% Z_2c__0225 = [
% 	 2.022940+0.136794j 0.000000+0.000000j	  0.000000+0.000000j;...
% 	 0.000000+0.000000j 2.022940+0.136794j 0.000000+0.000000j;...
% 	 0.000000+0.000000j 0.000000+0.000000j 2.022940+0.136794j]
% 
% Z_2c_16 = [
% 	 1.877563+0.141622j 0.026822+0.000000j 0.026822+0.000000j;...
% 	 0.026822+0.000000j	 1.877563+0.141622j	 z23 0.026822+0.000000j;...
% 	 0.026822+0.000000j 0.026822+0.000000j 1.877563+0.141622j]
% 
% object line_configuration {
% 	 name _35_SAC_XSC;
% 	 z11 1.338971+0.148059j;
% 	 z12 -0.057936+0.000000j;
% 	 z13 -0.057936+0.000000j;
% 	 z21 -0.057936+0.000000j;
% 	 z22 1.338971+0.148059j;
% 	 z23 -0.057936+0.000000j;
% 	 z31 -0.057936+0.000000j;
% 	 z32 -0.057936+0.000000j;
% 	 z33 1.338971+0.148059j;
% }
% 
% object line_configuration {
% 	 name _4c__06;
% 	 z11 1.351309+0.129284j;
% 	 z12 0.596529+0.008583j;
% 	 z13 0.596529+0.008583j;
% 	 z21 0.596529+0.008583j;
% 	 z22 1.351309+0.129284j;
% 	 z23 0.596529+0.008583j;
% 	 z31 0.596529+0.008583j;
% 	 z32 0.596529+0.008583j;
% 	 z33 1.351309+0.129284j;
% }
% 
% object line_configuration {
% 	 name _4c__1;
% 	 z11 0.808425+0.120700j;
% 	 z12 0.367466+0.003219j;
% 	 z13 0.367466+0.003219j;
% 	 z21 0.367466+0.003219j;
% 	 z22 0.808425+0.120700j;
% 	 z23 0.367466+0.003219j;
% 	 z31 0.367466+0.003219j;
% 	 z32 0.367466+0.003219j;
% 	 z33 0.808425+0.120700j;
% }
% 
% object line_configuration {
% 	 name _4c__35;
% 	 z11 0.266614+0.113190j;
% 	 z12 0.123383+0.004560j;
% 	 z13 0.123383+0.004560j;
% 	 z21 0.123383+0.004560j;
% 	 z22 0.266614+0.113190j;
% 	 z23 0.123383+0.004560j;
% 	 z31 0.123383+0.004560j;
% 	 z32 0.123383+0.004560j;
% 	 z33 0.266614+0.113190j;
% }
% 
% object line_configuration {
% 	 name _4c_185;
% 	 z11 0.489239+0.114800j;
% 	 z12 0.222089+0.005364j;
% 	 z13 0.222089+0.005364j;
% 	 z21 0.222089+0.005364j;
% 	 z22 0.489239+0.114800j;
% 	 z23 0.222089+0.005364j;
% 	 z31 0.222089+0.005364j;
% 	 z32 0.222089+0.005364j;
% 	 z33 0.489239+0.114800j;
% }
% 
% object line_configuration {
% 	 name _4c_70;
% 	 z11 1.285863+0.120700j;
% 	 z12 0.568097+0.006437j;
% 	 z13 0.568097+0.006437j;
% 	 z21 0.568097+0.006437j;
% 	 z22 1.285863+0.120700j;
% 	 z23 0.568097+0.006437j;
% 	 z31 0.568097+0.006437j;
% 	 z32 0.568097+0.006437j;
% 	 z33 1.285863+0.120700j;
% }
% 
% Z_4c_95_SAC_XC=
% 	 0.776775+0.129284j	 0.258567+0.010192j	 0.258567+0.010192j;...
% 	 0.258567+0.010192j	 0.776775+0.129284j	 0.258567+0.010192j;...
% 	 0.258567+0.010192j	 0.258567+0.010192j	 0.776775+0.129284j ];
% 



%%  Constructing Impedance matrix Z

%Define line admittances 
impedances= Lines{:,'Length'} .* 1e-3 .*  complex(Lines{:,'R1'}, Lines{:,'X1'});
admitances= 1./impedances; 
Lines= [Lines table(admitances)];


% create simple grid graph 
s = Lines{:,2};
t = Lines{:,3};
G = graph(s,t);

% Admittance and Impedance matrix - calculatred based on incidence matrix 
I=full( incidence(G));
Bline=diag(abs(Lines.admitances));
Y= I*Bline * I'; 

% Admittance matrix (Y is singular, add delta to make invertible)
Ynew= Y+ eye(size(Y))*1e-9;
Z= inv(Ynew);

