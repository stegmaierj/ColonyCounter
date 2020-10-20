%%
 % BacteriaCountingGUI.
 % Copyright (C) 2019 J. Stegmaier
 %
 % Licensed under the Apache License, Version 2.0 (the "License");
 % you may not use this file except in compliance with the License.
 % You may obtain a copy of the Liceense at
 % 
 %     http://www.apache.org/licenses/LICENSE-2.0
 % 
 % Unless required by applicable law or agreed to in writing, software
 % distributed under the License is distributed on an "AS IS" BASIS,
 % WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 % See the License for the specific language governing permissions and
 % limitations under the License.
 %
 % Please refer to the documentation for more information about the software
 % as well as for installation instructions.
 %
 % If you use this application for your work, please cite the repository and one
 % of the following publications:
 %
 % TBA
 %
 %%

%% initialize the global settings variable
close all;
if (exist('settings', 'var'))
    clearvars -except settings;
else
    clearvars;
end
global settings;

%% add path to the tiff handling scripts
addpath('ThirdParty/');
addpath('ThirdParty/saveastiff_4.3/');
addpath('ThirdParty/DBSCANClustering/');

answer = questdlg('Would you like to load an existing project?', 'Load existing project?', 'Yes', 'No', 'No');
if (strcmp(answer, 'Yes'))
    [fileName, pathName] = uigetfile('*.mat', 'Select the project file of a previous labeling session ...');
    load([pathName fileName]);
else
    %% open the input image
    [fileName, pathName] = uigetfile('*GFP*.tif', 'Select the maximum intensity projection of the GFP channel you want to process ...');
    settings.rawImageFile1 = [pathName filesep fileName]; 
    settings.rawImageFile1 = strrep(settings.rawImageFile1, '\', '/');
    settings.rawImageFile2 = strrep(settings.rawImageFile1, 'GFP', 'Phalloidin');
    settings.outputFolder = uigetdir('', 'Select the output folder to store the results to ...');%'D:/Projects/2019/EPEC_BachmannUKA/Processing/';
    settings.outputFolder = strrep(settings.outputFolder, '\', '/');
    settings.outputFolder = [settings.outputFolder '/'];
    [path, name, ext] = fileparts(settings.rawImageFile1);

    %% perform instance segmentation using XPIWIT (seeded watershed)
    if (ispc)
        cd XPIWIT\Windows\
    elseif (ismac)
        cd XPIWIT/MacOSX/
    elseif (isunix)
        cd XPIWIT/Ubuntu/
    end

    %% specify the XPIWIT command
    XPIWITCommand1 = ['./XPIWIT.sh ' ...
        '--output "' settings.outputFolder '" ' ...
        '--input "0, ' settings.rawImageFile1 ', 2, float" ' ...
        '--xml "../DetectionPipelineWithSegmentation.xml" ' ...
        '--seed 0 --lockfile off --subfolder "filterid, filtername" --outputformat "imagename, filtername" --end'];

    %% replace slashes by backslashes for windows systems
    if (ispc == true)
        XPIWITCommand1 = strrep(XPIWITCommand1, './XPIWIT.sh', 'XPIWIT.exe');
        XPIWITCommand1 = strrep(XPIWITCommand1, '\', '/');
    end
    system(XPIWITCommand1);
    cd ../../;

    %% specify file names for the segmentation and the csv files
    settings.segmentationFile = [settings.outputFolder 'item_0013_ParallelSeededWatershedSegmentation/' name '_ParallelSeededWatershedSegmentation_Out1.tif'];
    settings.csvFile = [settings.outputFolder 'item_0003_ExtractLocalExtremaFilter/' name '_ExtractLocalExtremaFilter_KeyPoints.csv'];
    if (~exist(settings.segmentationFile, 'file') || ~exist(settings.csvFile, 'file'))
        disp('ERROR: Failed to load the segmentation image or the csv file containing the detections.');
    end

    %% load the raw image with the appropriate loader
    if (contains(settings.rawImageFile1, '.ome.'))
        settings.rawImage1 = imread_structured(settings.rawImageFile1);
        settings.rawImage2 = imread_structured(settings.rawImageFile2);
    else
        settings.rawImage1 = loadtiff(settings.rawImageFile1);
        settings.rawImage2 = loadtiff(settings.rawImageFile2);
    end
    settings.rawImage1 = double(settings.rawImage1);
    settings.rawImage1 = settings.rawImage1 / 255;
    settings.maxProjectionImage1 = max(settings.rawImage1, [], 3);
    settings.rawImage2 = double(settings.rawImage2);
    settings.rawImage2 = settings.rawImage2 / 255;
    settings.maxProjectionImage2 = max(settings.rawImage2, [], 3);

    %% load the segmentation file
    settings.segImage = loadtiff(settings.segmentationFile);
    settings.segImageEdges = uint16(imgradient(settings.segImage) > 0) .* settings.segImage;
    settings.segImageRegionProps = regionprops(settings.segImage, settings.rawImage2, 'Area', 'Centroid', 'PixelIdxList', 'MinIntensity', 'MaxIntensity', 'MeanIntensity');
    settings.segImageEdgesRegionProps = regionprops(settings.segImageEdges, 'Area', 'Centroid', 'PixelIdxList');

    %% load the csv files
    settings.areaIndex = 2;
    settings.currentDetections = zeros(length(settings.segImageRegionProps), 9);
    settings.meanIntensityIndex = size(settings.currentDetections, 2)-3;
    settings.groupIdIndex = size(settings.currentDetections, 2)-2;
    settings.pedestalActiveIndex = size(settings.currentDetections, 2)-1;
    settings.colonyActiveIndex = size(settings.currentDetections, 2);

    for i=1:length(settings.segImageRegionProps)
        settings.currentDetections(i, :) = [i, settings.segImageRegionProps(i).Area, round(settings.segImageRegionProps(i).Centroid), 1, settings.segImageRegionProps(i).MeanIntensity, 0, 0, 1];
    end
    settings.meanFilteredImage = imfilter(settings.maxProjectionImage2, fspecial('average', round(sqrt(mean(settings.currentDetections(:, settings.areaIndex))))));

    %% initialize the settings
    settings.maximumProjectionMode = true;
    settings.viewMode = 1;
    settings.currentSlice = 1;
    settings.colormapIndex = 1;
    settings.selectedGroup = 1;
    settings.markerSize = 10;
    settings.gamma = 1;
    settings.minIntensity = min(settings.rawImage1(:));
    settings.maxIntensity = max(settings.rawImage1(:));
    settings.axesEqual = true;
    settings.fontSize = 14;
    settings.thresholdMode = 1;
    settings.colormapStrings = {'gray', 'parula', 'jet'};
    settings.dirtyFlag = true;
    settings.pedestalThreshold = 0.29;
    settings.boundaryShape = 0.5;
    settings.minPoints = 3;
    settings.epsilon = 21;
    settings.selectedParameter = 1;
    settings.addDeleteMode = 0;
    settings.showInfo = false;
    settings.showBoundary = false;
    settings.showDetections = true;
    settings.showParameterPanel = true;
end

%% specify the figure boundaries
settings.xLim = [0, size(settings.rawImage1,2)];
settings.yLim = [0, size(settings.rawImage1,1)];

%% open the main figure
settings.mainFigure = figure(1);
settings.statsFigure = figure(2);
set(settings.mainFigure, 'units','normalized','outerposition',[0 0 1 1]);
set(settings.statsFigure, 'units','normalized','outerposition',[0 0 1 1]);

%% mouse, keyboard events and window title
set(settings.mainFigure, 'WindowButtonDownFcn', @clickEventHandler);
set(settings.mainFigure, 'WindowScrollWheelFcn', @scrollEventHandler);
set(settings.mainFigure, 'KeyReleaseFcn', @keyReleaseEventHandler);
set(settings.mainFigure, 'CloseRequestFcn', @closeRequestHandler);

%% update the visualization
updateVisualization;