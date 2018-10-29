clear all


%% Laden des gesamten ordners, Einlesen aller Excel Dateien 

liste_ref =dir('C:\Users\Toyota Herrmann\Google Drive\Toyota\Motorrad\*.xls');   
files_ref = {liste_ref.name}';




%% Datenimport 
end_row_f = length(xlsread(files_ref{1},'Accelerometer', 'A:A'))+1;
time_f = xlsread(files_ref{1}, 'Accelerometer',['A2:A', num2str(end_row_f)]);
xf = xlsread(files_ref{1}, 'Accelerometer',['C2:C', num2str(end_row_f)])/9.81;
yf = -xlsread(files_ref{1}, 'Accelerometer',['B2:B', num2str(end_row_f)])/9.81;
zf = xlsread(files_ref{1}, 'Accelerometer',['D2:D', num2str(end_row_f)])/9.81;



end_row_g = length(xlsread(files_ref{1},'Gyroscope', 'A:A'))+1;  
time_g = xlsread(files_ref{1}, 'Gyroscope',['A2:A', num2str(end_row_g)]);
xg = xlsread(files_ref{1}, 'Gyroscope',['C2:C', num2str(end_row_g)])*180/pi;
yg = -xlsread(files_ref{1}, 'Gyroscope',['B2:B', num2str(end_row_g)])*180/pi;
zg = xlsread(files_ref{1}, 'Gyroscope',['D2:D', num2str(end_row_g)])*180/pi;




% end_row_gps = length(xlsread(files_ref{1},'Location', 'A:A'))+1;  
% time_g = xlsread(files_ref{1}, 'Location',['A2:A', num2str(end_row_gps)]);
% lon = xlsread(files_ref{1}, 'Location',['C2:C', num2str(end_row_gps)]);
% lat = -xlsread(files_ref{1}, 'Location',['B2:B', num2str(end_row_gps)]);
% vel = xlsread(files_ref{1}, 'Location',['E2:D', num2str(end_row_gps)]);
% 
% 
% 
% % geoshow(lon,lat)


%% Filter

% Filter Accelerometer
st = 30;                                 % Fensterbreite              
c = 1/st * ones(st, 1);
d = 1;

xf = filtfilt(c, d, xf);      
yf = filtfilt(c, d, yf);       
zf = filtfilt(c, d, zf);



% Filter Gyro
st = 8;                                 % Fensterbreite                      
c = 1/st * ones(st, 1);
d = 1;

xg = filtfilt(c, d, xg);
yg = filtfilt(c, d, yg);
zg = filtfilt(c, d, zg);





%% Accelerometer
% Bestimmen des Rollwinkels beim Starten der Maschine als Referenzwert

for i = 1:end_row_f -1;                  %Neigungswerte über ACC Sensor
    
    rw_acc(i) = asin (yf(i)/zf(i));
    rw_acc(i) = rw_acc(i)*180/pi;
    
end;

rw_acc = rw_acc'; 

rw0 = mean (rw_acc([1:100],1));            % Nullwert durch erste Sekunde der ACC Sensoren

rw00 = rw0;                                % Winkel bei Start der Aufnahme



%% Gyro
% Integrieren der Gyrobeschleunigungen für Winkeländerung

data_xg = [time_g xg];                   % Zusammenführen von xg und time_g

for i = 1:end_row_g-2;
    
    data_xg(i,3) = (data_xg(i+1,1)-data_xg(i,1)) * data_xg(i,2);
    
end;


data_xg(1,4) = rw0;                       % Zur Fehlervermeidung durch ungleiche Spaltenlänge
for i = 1:end_row_g-2;
    
    data_xg (i+1,4) = data_xg (i,4) + data_xg (i+1,3);
    
end;


rw_gyro (1,1) = rw0;
rw_gyro ([2:end_row_g],1) =  data_xg(:,4); 



%% Anpassen der Vektorlängen rw_acc und rw_gyro 

length_diff = abs(length(rw_acc) - length(rw_gyro));

 if length(rw_acc) > length(rw_gyro);
     
     rw_acc     = rw_acc([length_diff+1:length(rw_acc)]);
     
 elseif length(rw_acc) < length(rw_gyro);
     
     rw_gyro    = rw_gyro([1:length(rw_gyro) - length_diff]);
     
 end;
 
 
 
%plot(rw_gyro)


%% Fusion

f = 1;
rollwinkel(1,1) = rw0;

for i = 2:length(rw_gyro)-1;

rollwinkel(i,1) =  (f * (data_xg (i,4))) + ((1-f)* rw_acc (i,1));

end;

%rollwinkel = rollwinkel (t-1) + (k * gyro winkel) + (1-k) * acc winkel



%plot(rollwinkel);


%% Lotdurchläufe

for i = 1:length(rollwinkel)-1;
    
    if rollwinkel(i,1) > 0 && rollwinkel(i+1,1) < 0;
        
        zero(i+1,1) = 1 ;
        
    elseif rollwinkel(i,1) < 0 && rollwinkel(i+1,1) > 0;
        
        zero (i+1,1) = 1;
        
    else;    
        
        zero(i+1,1) = 0;
    end;
    
end;

zero_original = zero;                               % Referenzwert für Endwerterweiterung (line.153)

zero = [zero;0];
zero = find(zero ==1);                              % Zeilen in denen RW = 0
zero = [1; zero; length(zero_original)];            % Vektor um eine Reihe verschieben und um Endwert erweitern




%% Verschachteln
% Rollwinkelbestimmung in den Intervallen zwischen den Lotdurchgängen

k = 2

for k = 2 : length(zero)
    
       
      
       
%   % Accelerometer
             
            start = zero(k-1,1);
            finish = length(zero_original);
            
            for i = start : finish;                             % Neigungswerte über ACC Sensor

                rw_acc(i,1) = asin (yf(i,1)/zf(i,1));
                rw_acc(i,1) = rw_acc(i,1)*180/pi;

            end;
            
%% sequenzielles rw0 berechnen
             
            if k == 2;
                         rw0 = mean(rw_acc([start:start+50],1));         %rw0 durch erste  halbe Sekunde der ACC 

            else;
                         rw0 = mean(rw_acc([start-40:start+40],1));

            end;


       
%% Gyro
            
            for i = start : finish - 1;

                data_xg(i+1,3) = (data_xg(i+1,1) - data_xg(i,1)) * data_xg(i,2);

            end;


            
            
                
            for i = start : finish - 1;

                
                  % Anpassung von Sequenzstart auf rw0 um drift zu verhindern
                    if k == 2;            
                        data_xg(1,4) = rw00;                       
                    else
                        data_xg(start,4) = rw0;
                    end
                    
                    
                data_xg (i+1,4) = data_xg (i,4) + data_xg (i+1,3);        
            
            end;


            rw_gyro ([start : finish],1) =  data_xg(start : finish ,4); 
            rw_gyro (1,1) = rw00;

    



%             f = 0.8;
%             
%             for i = start : finish;
% 
%             rollwinkel(i,1) =  (f * (data_xg (i,4)+ rw0)) + ((1-f)* rw_acc (i,1));
% 
%             end;

            rollwinkel(1,1) = rw00;
            
       
            
            zero_durchlaufend = zero_original;
            
            for i = start : length(rollwinkel)-1;

                    if rollwinkel(i,1) > 0 && rollwinkel(i+1,1) < 0;

                        zero_durchlaufend(i+1,1) = 1 ;

                    elseif rollwinkel(i,1) < 0 && rollwinkel(i+1,1) > 0;

                        zero_durchlaufend (i+1,1) = 1;

                    else    

                        zero_durchlaufend(i+1,1) = 0;
                    end;

            end;


            zero = [zero_durchlaufend;0];
            zero = find(zero ==1);                              % Zeilen in denen RW = 0
            zero = [1; zero; length(zero_original)];            % Vektor um eine Reihe verschieben und um Endwert erweitern



            
            
            
            
            
   
end;


