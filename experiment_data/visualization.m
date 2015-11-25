%This script visualizes the grid
clear all
%% Define files to read
linesFile='../European_LV_CSV/Lines.csv';
lineCodeFile= '../European_LV_CSV/LineCodes.csv';
BuscoordsFile='../European_LV_CSV/Buscoords.csv';



%% Get data
Lines = readtable(linesFile,'HeaderLines',1,'Format','%s%u%u%s%f%s%s');
LineCodes = readtable (lineCodeFile, 'HeaderLines',1,'Format','%s%u%f%f%f%f%f%f%s');
BuscoordsFile = readtable(BuscoordsFile, 'HeaderLines',1,'Format', '%u%f%f');


%% Graph construction
%Define edges
LineCodesArray=table2array(LineCodes(:,1));
for i=2:size(Lines,1) % start from second row
    %define weight
 LineCode = table2array( Lines(i,end) );
 LineLength = table2cell(Lines(i,5));
 LineLength = LineLength{:}/1000; % transfer from [m] to [km]
 
 index= find(LineCodesArray{:}== LineCode);
 
 
 LineWeigth(i,1)= LineLength * (LineCodes(index,3) + LineCodes(index,4)*i ); 
end

