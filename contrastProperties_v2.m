%% (c) Copyright 2023
%% mgr inż. Kamil Stachurski
%% kamil.stachurski@ifj.edu.pl

%% ANALIZE CONTRAST PROPERTIES

clear all;
close all;
fclose('all');

% -------------------------------------------------------------------------
% DATA (Before that, create Excel file)
data_path = '/Users/kamil/MATLAB-Drive/NCs/';
scan_name = '20230615_091324_GR23_testncs_01_Lactamid_POSS_Gd_POSS_Gd_in_1_2/';
savename = 'Lactamide HNS-Gd';
init_concentration = 2.98; % [mM]
rangeT1 = 'A9:V17';
rangeT2 = 'A9:V264';
do_relaxivity = 1;
% -------------------------------------------------------------------------
dataBaseT2 = importfile([data_path, scan_name, '/Test_T2.xlsx'], 1, rangeT2);
TE = dataBaseT2(:, 1); % [ms]
signalT2 = [dataBaseT2(:, 2) dataBaseT2(:, 5) dataBaseT2(:, 8) dataBaseT2(:, 11)... 
            dataBaseT2(:, 14) dataBaseT2(:, 17) dataBaseT2(:, 20)]; %Signal Column T2: 2 5 8 11 14 17 20

dataBaseT1 = importfile([data_path, scan_name, '/Test_T1.xlsx'], 1, rangeT1);
TR = dataBaseT1(:, 1); % [ms]
signalT1 = [dataBaseT1(:, 2) dataBaseT1(:, 5) dataBaseT1(:, 8) dataBaseT1(:, 11)... 
            dataBaseT1(:, 14) dataBaseT1(:, 17) dataBaseT1(:, 20)]; %Signal Column T1: 2 5 8 11 14 17 20

concentration = init_concentration .* [0 1/32 1/16 1/8 1/4 1/2 1]; % [mM]

color = {'r*', 'g*', 'b*', 'c*', 'm*', 'y*', 'k*'};
colorFit = {'r-', 'g-', 'b-', 'c-', 'm-', 'y-', 'k-'};
% -------------------------------------------------------------------------
% T1 RELAXATION
fT1 = figure();
T1values = [];
    for icnt = 1:numel(concentration)
        plot(TR, signalT1(:, icnt), color{icnt});
        hold on;
        [fitresultT1, gofT1] = createFitT1(TR, signalT1(:, icnt));
        T1values(icnt) = fitresultT1.T;
        plot(fitresultT1, colorFit{icnt});
        fprintf('T1 Relaxation results for %d \n', icnt);
        display(fitresultT1);
        display(gofT1);
    end
grid on;
grid minor;
xlabel('TR [ms]');
ylabel('Signal Intensity');
title(['T1 Relaxation of ' savename]);
lgd = legend('H2O', '', '0.093 mM', '', '0.186 mM', '', '0.373 mM', '', ...
             '0.745 mM', '', '1.49 mM', '', '2.98 mM', '');
% -------------------------------------------------------------------------
% T2 RELAXATION
fT2 = figure();
T2values = [];
    for icnt = 1:numel(concentration)
        plot(TE, signalT2(:, icnt), color{icnt});
        hold on;
        [fitresultT2, gofT2] = createFitT2(TE, signalT2(:, icnt));
        T2values(icnt) = fitresultT2.T;
        plot(fitresultT2, colorFit{icnt});
        fprintf('T2 Relaxation result for %d', icnt);
        display(fitresultT2);
        display(gofT2);
    end
grid on;
grid minor;
xlabel('TE [ms]');
ylabel('Signal Intensity');
title(['T2 Relaxation of ' savename]);
lgd = legend('H2O', '', '0.093 mM', '', '0.186 mM', '', '0.373 mM', '', ...
             '0.745 mM', '', '1.49 mM', '', '2.98 mM', '');
% -------------------------------------------------------------------------
% RELAXIVITIES
if do_relaxivity == 1
% R1
fR1 = figure();
R1values = (1./T1values).*1000; % [1/s]
plot(concentration, R1values, 'b*');
hold on;
[fitresultR1, gofR1] = createFitR(concentration, R1values);
r1 = fitresultR1.r;
plot(fitresultR1, 'b-');
fprintf('Molar Relaxivity r1 results: \n');
display(fitresultR1);
display(gofR1);
grid on;
grid minor;
xlabel('Concentration [mM]');
ylabel('Relaxation rate [1/s]');
title(['Molar relaxivity r1 of ' savename]);
% R2
fR2 = figure();
R2values = (1./T2values).*1000; % [1/s]
plot(concentration, R2values, 'r*');
hold on;
[fitresultR2, gofR2] = createFitR(concentration, R2values);
r2 = fitresultR2.r;
plot(fitresultR2, 'r-');
fprintf('Molar Relaxivity r2 results: \n');
display(fitresultR2);
display(gofR2);
grid on;
grid minor;
xlabel('Concentration [mM]');
ylabel('Relaxation rate [1/s]');
title(['Molar relaxivity r2 of ' savename]);
else
    return;
end









% -------------------------------------------------------------------------
%FUNCTIONS
function imported = importfile(filepath, sheet, range)
    % Use importfile(file.xlsx, 1, 'A1:C4')
    imported = xlsread(filepath, sheet, range);
end

    function [fitresult, gof] = createFitT1(X, Y)
    
        [xData, yData] = prepareCurveData(X, Y);
    
        % Options of fit
        ft = fittype('A*(1-exp(-x/T))', 'independent', 'x', 'dependent', 'y');
        opts = fitoptions('Method', 'NonlinearLeastSquares');
        opts.Display = 'Off';
        opts.StartPoint = [120 500];
    
        % Fit model to data
        [fitresult, gof] = fit(xData, yData, ft, opts);
    
    end

function [fitresult, gof] = createFitT2(X, Y)

    [xData, yData] = prepareCurveData(X, Y);

    % Options of fit
    ft = fittype('A*exp(-x/T)', 'independent', 'x', 'dependent', 'y');
    opts = fitoptions('Method', 'NonlinearLeastSquares');
    opts.Display = 'Off';
    opts.StartPoint = [0.823457828327293 0.694828622975817];

    % Fit model to data
    [fitresult, gof] = fit(xData, yData, ft, opts);

end

    function [fitresult, gof] = createFitR(X, Y)
        
        [xData, yData] = prepareCurveData(X, Y);

        ft = fittype('r*x+R', 'independent', 'x', 'dependent', 'y');
        opts = fitoptions('Method', 'NonlinearLeastSquares');
        opts.Display = 'Off';
        opts.StartPoint = [0.757740130578333 0.678735154857773];

        [fitresult, gof] = fit(xData, yData, ft, opts);

    end