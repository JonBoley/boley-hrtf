load('BoleyHRTFs.mat','Yhrtf','fs');
angles = 0:10:350;
numAngles = length(angles);

% save to wav file
numChans = numel(Yhrtf)*size(Yhrtf(1).data,2);
y = zeros(size(Yhrtf(1).data,1),numel(Yhrtf)*size(Yhrtf(1).data,2));
index = 1;
for ii=1:numel(Yhrtf)
    y(:,index:index+1) = Yhrtf(ii).data;
    index = index + 2;
end
y = y / max(max(abs(y)));
audiowrite('BoleyHRTFs.wav',y,fs,'Comment','Head-Related Transfer Functions [L-0°,R-0°,L-10°,R-10°,...,L-360°,R-360°]');

% plot ILD
ILD = zeros(1,numAngles);
for ii=1:numAngles
    ILD(ii) = 20*log10(rms(Yhrtf(ii).data(:,1))) - ...
        20*log10(rms(Yhrtf(ii).data(:,2)));
end
ILD = ILD-ILD(1);

h = polar(angles/180*pi,abs(ILD));
set(h,'linewidth',2);
view(90,-90);
