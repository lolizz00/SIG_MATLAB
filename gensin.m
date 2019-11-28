%% генерация синусоиды в pcm файл

clc; clear;

fs = 5e3; % частота дискретизации
T = 1 / fs;

f = 12e2 ;  %  частота сигнала

% синус
pnt = 2e1 / T;
t = [ 1 : pnt ] * T;
IQData =  exp( 1i * 2 * pi * f * t );

%IQData = IQData +  exp( 1i * 2 * pi * 10e2 * t );
 

% Отстраиваем на всякий случай, посмотреть, что вышло в итоге
%figure() 
%sig = imag(IQData) + real(IQData);
%plot(sig)

% нормализация
maximum = max( [ real( IQData ) imag( IQData ) ] );
IQData = 0.7 * IQData / maximum;

fd = fopen('H:\NEW_ETH_IQ\data\data0.pcm', 'w');
wave = [real(IQData);imag(IQData)];

tmp = 1;
modval = 2^16;
scale = 2^15-1;
scale = scale/tmp;
wave = round(wave * scale);
wave = uint16(mod(modval + wave, modval));



disp('Add random')
randmax = 1000;
for i  = 1:length(wave)
    wave(1, i) =  wave(1, i) + randi([-randmax, randmax], 1, 1);
    wave(2, i) =  wave(2, i) + randi([-randmax, randmax], 1, 1);
end

    
disp('File write begin')

for i  = 1:length(wave)
    fwrite(fd, wave(1, i), 'uint16','ieee-le');
    fwrite(fd, wave(2, i), 'uint16','ieee-le');
end

fclose(fd);
disp('File write OK')


