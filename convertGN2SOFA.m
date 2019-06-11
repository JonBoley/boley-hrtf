%% convert GN HRTF (*.mat) to SOFA file format

% % https://github.com/sofacoustics/API_MO
% addpath('C:\Users\jboley\Documents\development\github\sofa\API_MO');
% SOFAstart;

newFs = 44100; % sampling rate (samples per second)

%% load MAT file
GNfile = 'BoleyHRTFs';
GNfn = [GNfile '.mat'];
disp(['Loading: ' GNfn]);
GN=load(GNfn);

%% Define parameters
% Data compression (0..uncompressed, 9..most compressed)
compression=1; % results in a nice compression within a reasonable processing time

%% Get an empy conventions structure
Obj = SOFAgetConventions('SimpleFreeFieldHRIR');

%% Define positions
azimuth1 = 0:10:360;    % azimuth angles
elevation1 = 0;               % elevation angles
elevation = repmat(elevation1',length(azimuth1),1);
ida = round(0.5:1/length(elevation1):length(azimuth1)+0.5-1/length(elevation1));
azimuth = azimuth1(ida);

%% Fill data with data
M=length(azimuth1)*length(elevation1);
Obj.Data.IR = NaN(M,2,size(resample(GN.Yhrtf(1).data,newFs,GN.fs),1)); % data.IR must be [M R N]
Obj.Data.SamplingRate = newFs;

ii=1;
for aa=1:length(azimuth1)
	for ee=1:length(elevation1)
		Obj.Data.IR(ii,1,:) = resample(GN.Yhrtf(ii).data(:,1),newFs,GN.fs);
		Obj.Data.IR(ii,2,:) = resample(GN.Yhrtf(ii).data(:,2),newFs,GN.fs);
		[azi,ele]=hor2sph(azimuth(ii),elevation(ii));
      % SimpleFreeFieldHRIR 0.2
        % 		Obj.ListenerRotation(ii,:)=[azi ele 0];
      % SimpleFreeFieldHRIR 0.3
        Obj.SourcePosition(ii,:) = [azi ele 1];
		ii=ii+1;
	end
end

%% Update dimensions
Obj=SOFAupdateDimensions(Obj);

%% Fill with attributes
Obj.GLOBAL_ListenerShortName = GNfile;
Obj.GLOBAL_History = 'Converted from the GN file format';

%% Fill the mandatory variables
  % SimpleFreeFieldHRIR 0.2
    % Obj.ListenerPosition = [1 0 0];
    % Obj.ListenerView = [-1 0 0];
    % Obj.ListenerUp = [0 0 1];
% SimpleFreeFieldHRIR 0.3 and 0.4
Obj.ListenerPosition = [0 0 0];
Obj.ListenerView = [1 0 0];
Obj.ListenerUp = [0 0 1];

%% convert
Obj.GLOBAL_DatabaseName = 'GN';
Obj.GLOBAL_ApplicationName = 'GN HRTF converted with SOFA API';
Obj.GLOBAL_ApplicationVersion = SOFAgetVersion('API');

%% save SOFA file
SOFAfn = [GNfile '.sofa'];
disp(['Saving:  ' SOFAfn])
SOFAsave(SOFAfn, Obj, compression); 

