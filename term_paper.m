% reference  https://github.com/sevagh/Real-Time-HPSS
% data set taken from https://soundseparation.songquito.com/

clc;
clear all;
close all;


[mix,fs] = audioread("v_drum.wav");

%sound(mix,fs)

spectrogram(mix,1024,512,1024,fs,"yaxis")
title("Harmonic-Percussive Audio")

% HPSS Using Binary Mask

win = sqrt(hann(1024,"periodic"));
% figure;
% plot(win)

overlapLength = floor(numel(win)/2);
fftLength = 2^nextpow2(numel(win) + 1);
y = stft(mix, ...
        "Window",win, ...
        "OverlapLength",overlapLength, ...
        "FFTLength",fftLength, ...
        "Centered",true);
figure;
n1=0:length(y)-1;
plot(n1,abs(y))
title('STFT of music source mixture signal')
xlabel('frequency')
ylabel('amplitude')

halfIdx = 1:ceil(size(y,1)/2);

yhalf = y(halfIdx,:);
ymag = abs(yhalf);

timeFilterLength = 0.2;
timeFilterLengthInSamples = timeFilterLength/((numel(win) - overlapLength)/fs);
ymagharm = movmedian(ymag,timeFilterLengthInSamples,2);

figure;
n1=0:length(ymagharm)-1;
plot(n1,abs(ymagharm))
title('median of STFT signal(single sided)')
xlabel('frequency')
ylabel('amplitude')



figure;
surf(flipud(log10(ymagharm.^2)),"EdgeColor","none")
title("Harmonic Enhanced Audio")
view([0,90])
axis tight

% 

frequencyFilterLength = 500;
frequencyFilterLengthInSamples = frequencyFilterLength/(fs/fftLength);
ymagperc = movmedian(ymag,frequencyFilterLengthInSamples,1);


figure;
surf(flipud(log10(ymagperc.^2)),"EdgeColor","none")
title("Percussive Enhanced Audio")
view([0,90])
axis tight

%

totalMagnitudePerBin = ymagharm + ymagperc;

harmonicMask = ymagharm > (totalMagnitudePerBin*0.5);
percussiveMask = ymagperc > (totalMagnitudePerBin*0.5);


yharm = harmonicMask.*yhalf;
yperc = percussiveMask.*yhalf;

yharm = cat(1,yharm,flipud(conj(yharm)));
yperc = cat(1,yperc,flipud(conj(yperc)));


h = istft(yharm, ...
    "Window",win, ...
    "OverlapLength",overlapLength, ...
    "FFTLength",fftLength, ...
    "ConjugateSymmetric",true);
p = istft(yperc, ...
    "Window",win, ...
    "OverlapLength",overlapLength, ...
    "FFTLength",fftLength, ...
    "ConjugateSymmetric",true);
 


%sound(h,fs)
figure;
spectrogram(h,1024,512,1024,fs,"yaxis")
title("Recovered Harmonic Audio")



%sound(p,fs)
figure;
spectrogram(p,1024,512,1024,fs,"yaxis")
title("Recovered Percussive Audio")





%sound(h + p,fs)
% 
% figure;
% spectrogram(h + p,1024,512,1024,fs,"yaxis")
% title("Recovered Harmonic + Percussive Audio")













