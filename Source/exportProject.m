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
 
global settings;

imageSuffix{1} = '_GFP+Detections.png';
imageSuffix{2} = '_Phalloidin+Detections.png';
imageSuffix{3} = '_GFP+Segmentation.png';
imageSuffix{4} = 'Phalloidin+Segmentation.png';
imageSuffix{5} = '_GFPOverlay+PedestalClassification.png';
imageSuffix{6} = '_Phalloidin+PedestalClassification.png';
imageSuffix{7} = '_ColonyStats.png';
imageSuffix{8} = '_ColonyStats.csv';
imageSuffix{9} = '_Project.mat';

[folder, file, ext] = fileparts(settings.csvFile);
folder = strrep(folder, '/item_0003_ExtractLocalExtremaFilter', '');
file = strrep(file, '_ExtractLocalExtremaFilter_KeyPoints', '');
resultFolder = [folder filesep file filesep];
if (~exist(resultFolder, 'dir'))
    mkdir(resultFolder);
end

for v=1:7
    if (v < 7)
        settings.viewMode = v;
        updateVisualization;
        currentImage = frame2im(getframe(settings.mainFigure));
    else
        if (~isfield(settings, 'globalStatsPerColony'))
            disp('Not generating result plots for the colony statistics - run boundary detection first!');
            continue; 
        end
        ShowColonyStats();
        fh = figure(2);
        currentImage = frame2im(getframe(fh));
    end
    resultFileName = [resultFolder file imageSuffix{v}];
    imwrite(currentImage, resultFileName);
end

%% write the colony stats if they were already extracted
if (isfield(settings, 'globalStatsPerColony'))
    resultFileName = [resultFolder file imageSuffix{8}];
    dlmwrite(resultFileName, settings.globalStatsPerColony, ';');
    prepend2file(settings.globalStatsPerColonySpecifiers, resultFileName, 1);
else
    disp('Not generating result plots for the colony statistics - run boundary detection first!');
end

tempFigure1 = settings.mainFigure;
tempFigure2 = settings.statsFigure;
settings.mainFigure = 0;
settings.statsFigure = 0;

resultFileName = [resultFolder file imageSuffix{9}];
save(resultFileName, '-mat', 'settings');

settings.mainFigure = tempFigure1;
settings.statsFigure = tempFigure2;
figure(settings.mainFigure);

disp(['Successfully saved colony statistics to: ' resultFileName]);