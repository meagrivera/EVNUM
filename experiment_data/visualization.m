%This script visualizes the grid
clear all
%% Define files to read
linesFile='../European_LV_CSV/Lines.csv';
lineCodeFile= '../European_LV_CSV/LineCodes.csv';
BuscoordsFile='../European_LV_CSV/Buscoords.csv';



%% Get data
Lines = readtable(linesFile,'HeaderLines',1,'Format','%s%f%f%s%f%s%s');
LineCodes = readtable (lineCodeFile, 'HeaderLines',1,'Format','%s%u%f%f%f%f%f%f%s');
Buscoords = readtable(BuscoordsFile, 'HeaderLines',1,'Format', '%f%f%f');

% put information of lines together
LineCodes.Properties.VariableNames{'Name'} = 'LineCode';
T =table([1:size(LineCodes,1)]','VariableNames',{'LineCodeIndex'})
LineCodes=[LineCodes T];
Lines=join(Lines, LineCodes,'key','LineCode');
%% Graph construction

%Edges start and terminal
s = Lines{:,2};
t = Lines{:,3};

%node labels
nLabels = Buscoords{:,'Busname'}';
eLabels = Lines{:,'LineCode'};
weigths = Lines{:,'Length'} .* complex(Lines{:,'R1'}, Lines{:,'X1'});

weigthsAbs= abs(weigths);


% Plot network
G = graph(s,t, weigthsAbs);
LWidths = 10*Lines{:,'LineCodeIndex'}/max(Lines{:,'LineCodeIndex'});
p=plot(G,'LineWidth', LWidths );
%p=plot(G,'EdgeLabel',Lines{:,'LineCode'}, 'LineWidth', LWidths );
p.XData=Buscoords{:,'x'}';
p.YData=Buscoords{:,'y'}';




%Define edges
LineCodesArray=LineCodes{:,1};
for i=1:size(Lines,1) % start from second row
    %define weight
 LineCode = Lines{i,end};
 LineLength = Lines{i,5}/1000; % tranform [m] to [KM]

 
 for index=1:length(LineCodesArray)
 if isequal(LineCodesArray(index), LineCode);
     break
 end
 end
 
 R = LineCodes{index,3};
 X = LineCodes{index,4};
 
 
 
 LinesImpedance(i,1)= LineLength * complex( R, X );
 LinesType(i,:)= index; 
end

%s =  cell2mat( table2cell( Lines(:,2) ) );
%t =  cell2mat( table2cell( Lines(:,3) ) );
weigths = LinesImpedance;
code = Lines(:,1);

names= Buscoords{:,1};
