%% 
clc;clear;

addpath 'H:\SIG_MATLAB\WaveformDownloadAssistant_v2'


%io = agt_newconnection('tcpip','192.168.1.4');

fs = 50e6;
T = 1 / fs;


f1 = 1;  % 1458
f2 = 12e6; % 1470 


% импульс 0.4  #1
pnt = 0.4e-6 / T;
t = [ 1 : pnt ] * T;
IQData =  exp( 1i * 2 * pi * f1 * t );


% пауза 11.6 
pnt = 11.6e-6 / T;
t = [ 1 :  pnt ] * T;
IQData = [IQData,   0 * exp( 1i * 2 * pi * f2 * t )];


% импульс 0.4 #2
pnt = 0.4e-6 / T;
t = [ 1 : pnt ] * T;
IQData =  [IQData, exp( 1i * 2 * pi * f2 * t )];


% пауза 2.6 
pnt = 2.6e-6 / T;
t = [ 1 :  pnt ] * T;
IQData = [IQData,   0 * exp( 1i * 2 * pi * f2 * t )];

% импульс 0.4 #3
pnt = 0.4e-6 / T;
t = [ 1 : pnt ] * T;
IQData =  [IQData, exp( 1i * 2 * pi * f2 * t )];




% пауза финал
pnt = 2033.6e-6 / T;
t = [ 1 : pnt ] * T;
IQData = [IQData, 0 * exp( 1i * 2 * pi * f2 * t )];



figure() 
sig = imag(IQData) + real(IQData);
plot(sig)



maximum = max( [ real( IQData ) imag( IQData ) ] );
IQData = 0.7 * IQData / maximum;



% save
fd = fopen('C:\Users\User\Desktop\SIG_MATLAB_ONCE_T.WAVEFORM', 'w');
wave = [real(IQData);imag(IQData)];

tmp = 1;
modval = 2^16;
scale = 2^15-1;
scale = scale/tmp;
wave = round(wave * scale);
wave = uint16(mod(modval + wave, modval));


% 100ms
%len = 49;

% 1000ms
%len = 490;


% 1
len = 1;


disp('File write begin')

for j =1:len
    disp(j)
    for i  = 1:length(wave)
        fwrite(fd, wave(1, i), 'uint16','ieee-be');
        fwrite(fd, wave(2, i), 'uint16','ieee-be');
    end
end

fclose(fd);

disp('File write OK')

return

agt_sendcommand(io, 'SOURce:FREQuency 50000000');
agt_sendcommand(io, 'POWer -20');
[status, status_description]  = agt_waveformload(io, IQData, 'SIG_IMPULSE_MATLAB', fs,  'play','no_normscale', []);
agt_sendcommand( io, 'OUTPut:STATe ON' );
status