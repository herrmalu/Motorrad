

%% Plotten 


% Accelerometer
subplot(3,1,1) 
plot(time, xf, 'color', 'blue'); hold on
plot(time, yf, 'color', 'green'); hold on
plot(time, zf, 'color', 'red'); hold on

grid minor;
xlim([0, time(length(time))])
% ylim([min_ges, max_ges])
xlabel('time [s]', 'fontsize', 22)
ylabel('acceleration [g]', 'fontsize', 22)

h11_legend = legend('x-channel', 'y-channel', 'z-channel'); hold on
set(h11_legend, 'Fontsize', 20);




% Rollangle
subplot(3,1,2) 
plot(time, rwf, 'color', 'blue'); hold on

grid minor;
xlim([0, time(length(time))])
% ylim([min_ges, max_ges])
xlabel('time [s]', 'fontsize', 22)
ylabel('Rollangle [°]', 'fontsize', 22)

h11_legend = legend('x-channel', 'y-channel', 'z-channel'); hold on
set(h11_legend, 'Fontsize', 20);



end_row = length(xlsread(files_ref{1},'Gyroscope', 'A:A'))+1;  
time = xlsread(files_ref{1}, 'Gyroscope',['A2:A', num2str(end_row)]);
xg = -xlsread(files_ref{1}, 'Gyroscope',['C2:C', num2str(end_row)])*180/pi;
yg = xlsread(files_ref{1}, 'Gyroscope',['B2:B', num2str(end_row)])*180/pi;
zg = xlsread(files_ref{1}, 'Gyroscope',['D2:D', num2str(end_row)])*180/pi;


st = 8;         % Fensterbreite                      
c = 1/st * ones(st, 1);
d = 1;

xg = filtfilt(c, d, xg);      
yg = filtfilt(c, d, yg);       
zg = filtfilt(c, d, zg);

subplot(3,1,3)
plot(time, xg, 'color', 'blue'); hold on
plot(time, yg, 'color', 'green'); hold on
plot(time, zg, 'color', 'red'); hold on

grid minor;
xlim([0, time(length(time))])
% ylim([min_ges, max_ges])
xlabel('time [s]', 'fontsize', 22)
ylabel('yaw rate [°/s]', 'fontsize', 22)

h11_legend = legend('x-channel', 'y-channel', 'z-channel'); hold on
set(h11_legend, 'Fontsize', 20);






%% textbox University/time

date = datestr(clock);
annotation('textbox', [0.125 0.01 0.5 0.025],...
 'String',{['Date of print:',' ', date ,'       ', 'Toyota Institute for Next Gen Mobility Services - Tim Berger']},...
 'FontSize',18,...
 'EdgeColor','none',...
 'LineWidth',0.1);