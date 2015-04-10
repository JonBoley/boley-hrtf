function hrtf2json(matFileName,jsFileName)
% HRTF2JSON

newFs = 44100; % resample if necessary

if nargin<1
    matFileName = 'BoleyHRTFs.mat';
    if ~exist(matFileName,'file')
        [FileName,PathName] = uigetfile('*.mat');
        if isempty(PathName)
            error('No HRTF file specified');
        else
            matFileName = fullfile(PathName,FileName);
        end
    end
end

if nargin<2
    jsFileName = 'boley_hrtfs.js';
end

% format of JSON file:
% {
% 	"name": "Jon Boley",
% 	"date": "2014-06-23",
% 	"description": "Head Related Transfer Functions",
% 	"samplingRate_Hz": 44100,
%   "HRTFs": {
%     {
%     "azimuth_deg": 0,
%     "elevation_deg": 0,
%     "distance_m": 1,
%     "HRIR_left": [ 0.00021427, -0.0038777, ...],
%     "HRIR_right": [ 0.00021427, -0.0038777, ...],
%     },
%     {
%     "azimuth_deg": 10,
%     "elevation_deg": 0,
%     "distance_m": 1,
%     "HRIR_left": [ 0.00021427, -0.0038777, ...],
%     "HRIR_right": [ 0.00021427, -0.0038777, ...],
%     },
%   {
% }

hrtfVarName = 'Yhrtf';
HRTF = load(matFileName,hrtfVarName,'fs');

% normalize
for ii=1:numel(HRTF.(hrtfVarName))
    foo(ii)=max(max(HRTF.(hrtfVarName)(ii).data));
end
normFactor = max(abs(foo));

angles = linspace(0,360,numel(HRTF.(hrtfVarName)));
angles = angles(1:end-1); % first & last are the same
numAngles = length(angles);


fileID = fopen(jsFileName,'w');
fprintf(fileID,'var data = \n');
fprintf(fileID,'{\n');
fprintf(fileID,'  "name": "Jon Boley",\n');
fprintf(fileID,'  "date": "2014-06-23",\n');
fprintf(fileID,'  "description": "Semi-Anechoic Head Related Transfer Functions",\n');
fprintf(fileID,'  "samplingRate_Hz": %d,\n',newFs);

fprintf(fileID,'  "HRTFs": [\n');



%%%%%%%%%%%%%%%%%
distance = 1;
elevation = 0;
for azimuthIndex=1:numAngles
    azimuth=angles(azimuthIndex);
    
    samples = HRTF.(hrtfVarName)(azimuthIndex).data;
    samples = resample(samples,newFs,HRTF.fs)/normFactor;
    numSamples = length(samples);
    
    fprintf(fileID,'    {\n');
    fprintf(fileID,'    ''azimuth_deg'': %d,\n',azimuth);
    fprintf(fileID,'    ''elevation_deg'': %d,\n',elevation);
    fprintf(fileID,'    ''distance_m'': %d,\n',distance);
    
    fprintf(fileID,'    ''HRIR_left'': [');
    for jj=1:numSamples
        fprintf(fileID,' %1.8f',samples(jj,1));
        if jj<numSamples
            fprintf(fileID,',');
        end
    end
    fprintf(fileID,'      ],\n'); % end of HRIR_left
    
    fprintf(fileID,'    ''HRIR_right'': [');
    for jj=1:numSamples
        fprintf(fileID,' %1.8f',samples(jj,2));
        if jj<numSamples
            fprintf(fileID,',');
        end
    end
    fprintf(fileID,'      ]\n'); % end of HRIR_right
    
    fprintf(fileID,'    }'); % end of this azimuth
    if azimuthIndex<numAngles
        fprintf(fileID,',');
    end
    fprintf(fileID,'\n');
end
fprintf(fileID,'  ]\n'); % end of HRTFs

fprintf(fileID,'};\n');
fclose(fileID);
