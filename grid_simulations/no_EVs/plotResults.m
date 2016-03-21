% plotResults.m 
% Plottign the results for the EU LV grid without EVs main plot 
% c: Jose Rivera (j.rivera@tum.de)
clear all

%% Grid data
% Trafo rating
TrafoRating= 0.8; % in MVA

% Define path
BuscoordsFile = '../../European_LV_CSV/Buscoords.csv';
LinesFile = '../../European_LV_CSV/Lines.csv';
LineCodeFile= '../../European_LV_CSV/LineCodes.csv';
LoadsFile = '../../European_LV_CSV/Loads.csv';

% Read 
Buscoords = readtable(BuscoordsFile, 'HeaderLines',1,'Format', '%f%f%f');
Lines = readtable(LinesFile,'HeaderLines',1,'Format','%s%f%f%s%f%s%s');
LineCodes = readtable (LineCodeFile, 'HeaderLines',1,'Format','%s%u%f%f%f%f%f%f%s');
Loads = readtable(LoadsFile, 'HeaderLines',2, 'Format', '%s%f%f%s%f%f%s%f%f%s');

%Add Ampacity to lines
Ampacity= [56    83    83   110   210   560   210   405   560   180]'; % From similar cables in Power Factory
CableNamesPF={ 'NYY 4x6   1.00 kV';... % Cable names in Power Factory
    'PVC-SWA-AL 3x25   1.00 kV';...
    'PVC-SWA-CU 3x16   1.00 kV';...
    'PILC-AL 3x35  11.00 kV';...
    'PILC-AL 1x70   1.00 kV';...
    'PILC-AL 1x300   1.00 kV';...
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

% Define load phase index
T = table({'A'; 'B'; 'C'}, [1:3]' , 'VariableNames', {'phases' 'phasesIndex'} );
Loads = join(Loads, T,'key','phases');


%% Simulation results 
% Peak files
PeakV = 'Result_no_EVs/output_voltage_peak.csv';
PeakI = 'Result_no_EVs/output_current_peak.csv';
% Transformer files
TrafoPower = 'Result_no_EVs/Transformer_output_power.csv';
 

% Parse voltage
peak_node_voltages = csvread(PeakV,910,1);
peak_node_voltages = peak_node_voltages(:,[1 3 5]);
for i=1:size(peak_node_voltages,1)
temp(i) = peak_node_voltages(i,Loads.phasesIndex(i)) /240.1777;  
end
peak_node_voltages=temp;


% Parse current
peak_line_currents = csvread(PeakI,2,1);
peak_line_currents = peak_line_currents(3:end,[1 3 5]);
peak_line_currents = max(peak_line_currents')'./Lines.Ampacity(:) ;

% Parse power
trafo_power=  csvread(TrafoPower,9,1);
trafo_power= sqrt(trafo_power(:,1).^2 + trafo_power(:,2).^2 ) ./ 1e6; % result in MVA


%% plots

% Lines Current/ampacity
figure
bar(peak_line_currents)
hold on
plot(1:length(peak_line_currents), ones(size(peak_line_currents)), 'k--')
axis([1 length(peak_line_currents) 0 1.5])
xlabel('Line number')
ylabel('Current / Ampacity')
grid on


% Loads Voltages
figure
bar(peak_node_voltages,'BaseValue',1)
hold on
plot(1:length(peak_node_voltages), 1.1* ones(size(peak_node_voltages)), 'k--')
plot(1:length(peak_node_voltages), 0.9* ones(size(peak_node_voltages)), 'k--')
axis([1 length(peak_node_voltages) 0.8 1.2])
xlabel('Load number')
ylabel('Voltage (p.u.)')
grid on

% Transformer power
figure
plot(1:length(trafo_power), trafo_power)
hold on
plot(1:length(trafo_power), 0.8 * ones(1,length(trafo_power)), 'k--')
xlabel('Time(minute)')
ylabel('Power (MVA)')
grid on




