fs = 2.2e6;

fid = fopen("iq_samples.bin", "r");
[data, count] = fread(fid, Inf, "int8");
i = data(1:2:end);
q = data(2:2:end);
iq = complex(i, q);

[Fxx, f] = pwelch(iq, [], 0, [], fs, "shift");
figure; subplot(2,1,1);
plot(f/1e3, 10*log10(Fxx));
xlabel("F[kHz]"); ylabel("dB/Hz");
xlim([-1100 1100]); title("before shift");

t = 0:length(iq)-1;
iq .*= exp(j*2*pi*700e3/fs*t');

[Fxx, f] = pwelch(iq, [], 0, [], fs, "shift");
subplot(2,1,2);
plot(f/1e3, 10*log10(Fxx));
xlabel("F[kHz]"); ylabel("dB/Hz");
xlim([-1100 1100]); title("after shift");


h = fir2(200, [0 75e3/fs, 100e3/fs, 1], [1, 1, 0, 0]);
iq = filter(h, 1, iq);

iq = decimate(iq, 10);
iqn = [iq; 0];
iqn(1) = [];
phase_diff = iqn.*conj(iq);
demod_sig = angle(phase_diff);

demod_sig = resample(demod_sig, 12, 55);

player = audioplayer(demod_sig, 48e3);
play(player);
