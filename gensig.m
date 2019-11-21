%% Формирование самого сигнала
clc;clear;

% подключение библиотеки
addpath 'H:\SIG_MATLAB\WaveformDownloadAssistant_v2'


% подрубаем VISA
%io = agt_newconnection('tcpip','192.168.1.4');

fs = 50e6; % частота дискретизации
T = 1 / fs;

f1 = 1;  % 1 ~ частота сигнала равна частоте генератора
f2 = 12e6; % смещение на 12 МГц(вправо)


% импульс 0.4 мкс
pnt = 0.4e-6 / T;
t = [ 1 : pnt ] * T;
IQData =  exp( 1i * 2 * pi * f1 * t );


% пауза 11.6 мкс
pnt = 11.6e-6 / T;
t = [ 1 :  pnt ] * T;
IQData = [IQData,   0 * exp( 1i * 2 * pi * f2 * t )];


% импульс 0.4 мкс
pnt = 0.4e-6 / T;
t = [ 1 : pnt ] * T;
IQData =  [IQData, exp( 1i * 2 * pi * f2 * t )];


% пауза 2.6 мкс
pnt = 2.6e-6 / T;
t = [ 1 :  pnt ] * T;
IQData = [IQData,   0 * exp( 1i * 2 * pi * f2 * t )];

% импульс 0.4 мкс
pnt = 0.4e-6 / T;
t = [ 1 : pnt ] * T;
IQData =  [IQData, exp( 1i * 2 * pi * f2 * t )];


% пауза финал, добиваем до 2049 мкс
pnt = 2033.6e-6 / T;
t = [ 1 : pnt ] * T;
IQData = [IQData, 0 * exp( 1i * 2 * pi * f2 * t )];



% Отстраиваем на всякий случай, посмотреть, что вышло в итоге
figure() 
sig = imag(IQData) + real(IQData);
plot(sig)


%% Часть для сохраения сигнала в файл генератора. По сути просто переписана из библиотеки

% нормализация
maximum = max( [ real( IQData ) imag( IQData ) ] );
IQData = 0.7 * IQData / maximum;



% куда пишем
fd = fopen('C:\Users\User\Desktop\SIG_MATLAB_ONCE_T.WAVEFORM', 'w');
wave = [real(IQData);imag(IQData)];

tmp = 1;
modval = 2^16;
scale = 2^15-1;
scale = scale/tmp;
wave = round(wave * scale);
wave = uint16(mod(modval + wave, modval));




len = 1; % сколько раз повторяем сигнал


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


%% часть для загрузки через VISA

agt_sendcommand(io, 'SOURce:FREQuency 50000000');
agt_sendcommand(io, 'POWer -20');
[status, status_description]  = agt_waveformload(io, IQData, 'SIG_IMPULSE_MATLAB', fs,  'play','no_normscale', []);
agt_sendcommand( io, 'OUTPut:STATe ON' );
status % напоследок выводим статус загрузки