%%
% ColonyCounter.
% Copyright (C) 2021 A. Bachmann, A. Dupont, J. Stegmaier
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
 
%% select the root folder
rootFolder = uigetdir('', 'Select the root folder of the image (expects subfolders named DAPI, GFP and Phalloidin)');

%% parse input files
dapiFolder = [rootFolder filesep 'DAPI' filesep];
gfpFolder = [rootFolder filesep 'GFP' filesep];
phalloidinFolder = [rootFolder filesep 'Phalloidin' filesep];
dapiFiles = dir([dapiFolder '*.tif']);
gfpFiles = dir([gfpFolder '*.tif']);
phalloidinFiles = dir([phalloidinFolder '*.tif']);

%% initialize the result images
dapiImage = [];
gfpImage = [];
phalloidinImage = [];

disp(sprintf('Computing maximum intensity projections for input folder: %s', rootFolder));

%% loop through all images and compute the maximum intensity projections
for i=1:length(dapiFiles)
    
    currentDAPIImage = imread([dapiFolder dapiFiles(i).name]);
    currentGFPImage = imread([gfpFolder gfpFiles(i).name]);
    currentPhalloidinImage = imread([phalloidinFolder phalloidinFiles(i).name]);
    
    %% convert to grayscale if rgb images are present
    if (size(currentDAPIImage, 3) > 1)
        currentDAPIImage = rgb2gray(currentDAPIImage);
        currentGFPImage = rgb2gray(currentGFPImage);
        currentPhalloidinImage = rgb2gray(currentPhalloidinImage);
    end
    
    %% perform the maximum projection
    if (i==1)
        dapiImage = currentDAPIImage;
        gfpImage = currentGFPImage;
        phalloidinImage = currentPhalloidinImage;
    else
        dapiImage = max(dapiImage, currentDAPIImage);
        gfpImage = max(gfpImage, currentGFPImage);
        phalloidinImage = max(phalloidinImage, currentPhalloidinImage);
    end
    
    disp(sprintf('Finished image %i / %i', i, length(dapiFiles)));
end

%% get the fileparts
[folder, file, ext] = fileparts(rootFolder);

%% save result images
disp(sprintf('Saving result images to %s', rootFolder));

%% write the images to disk
imwrite(dapiImage, [rootFolder filesep file '_DAPI_MaxProj.tif']);
imwrite(gfpImage, [rootFolder filesep file '_GFP_MaxProj.tif']);
imwrite(phalloidinImage, [rootFolder filesep file '_Phalloidin_MaxProj.tif']);

disp('Done.');