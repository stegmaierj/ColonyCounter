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

%% get the global settings
global settings;

%% get the number of different groups
groupIndices = unique(settings.currentDetections(:,settings.groupIdIndex));

%% specify different random colors
settings.groupColors = lines(length(groupIndices)+1);
settings.groupColors(1,:) = [1,0,0];

%% ensure current slice is valid
settings.currentSlice = min(max(1, settings.currentSlice), size(settings.rawImage1,3));

%% filter the detections
settings.colormap = settings.colormapStrings{settings.colormapIndex};
figure(settings.mainFigure);
clf;
set(settings.mainFigure, 'Color', 'black');
set(gca, 'Units', 'normalized', 'Position', [0,0,1,1]);

%% visualize the maximum projection view
if (settings.maximumProjectionMode == true)
    set(settings.mainFigure, 'Name', 'Maximum Projection');
    
    %% plot the background images
    if (settings.viewMode == 1)
        imagesc(imadjust(settings.maxProjectionImage1, [settings.minIntensity, settings.maxIntensity], [], settings.gamma)); colormap(settings.colormap); hold on;
    elseif (settings.viewMode == 2)
        imagesc(imadjust(settings.maxProjectionImage2, [settings.minIntensity, settings.maxIntensity], [], settings.gamma)); colormap(settings.colormap); hold on;
    elseif (settings.viewMode == 3)
        boundaryImage = double(settings.segImageEdges == 0); %double(imgradient(settings.segImage) == 0 .* (settings.segImage > 0));
        enhancedMaxProj = imadjust(settings.maxProjectionImage1, [settings.minIntensity, settings.maxIntensity], [], settings.gamma);
        imagesc(cat(3, max(enhancedMaxProj, 255*(boundaryImage==0)), enhancedMaxProj .* boundaryImage, enhancedMaxProj .* boundaryImage)); hold on;
    elseif (settings.viewMode == 4)
        boundaryImage = double(settings.segImageEdges == 0);
        enhancedMaxProj = imadjust(settings.maxProjectionImage2, [settings.minIntensity, settings.maxIntensity], [], settings.gamma);
        imagesc(cat(3, max(enhancedMaxProj, 255*(boundaryImage==0)), enhancedMaxProj .* boundaryImage, enhancedMaxProj .* boundaryImage)); hold on;
    elseif (settings.viewMode == 5)
        maxProj1 = imadjust(settings.maxProjectionImage1, [settings.minIntensity, settings.maxIntensity], [], settings.gamma);
        maxProj2 = imadjust(settings.maxProjectionImage2, [settings.minIntensity, settings.maxIntensity], [], settings.gamma);
        imagesc(cat(3, maxProj1, maxProj1, maxProj1 .* (1-maxProj2))); colormap(settings.colormap); hold on;
    elseif (settings.viewMode == 6 || settings.viewMode == 7)
        maxProj2 = imadjust(settings.maxProjectionImage2, [settings.minIntensity, settings.maxIntensity], [], settings.gamma);
        imagesc(maxProj2); colormap(settings.colormap); hold on;
    end
    
    %% plot group association of the detections
    for i=groupIndices'
        
        %% skip plotting the detections if disabled
        if (settings.showDetections == false || settings.viewMode == 7)
            continue;
        end
        
        validIndices = find(settings.currentDetections(:,settings.groupIdIndex) == i);
        activeDetections = settings.currentDetections(:,settings.pedestalActiveIndex) > 0;
        
        %% plot detections of the red channel
        %plot(settings.currentDetections(validIndices,3), settings.currentDetections(validIndices,4), 'or', 'Color', settings.groupColors(i+1, :), 'MarkerSize', settings.markerSize);
        if (i == 0)
            if (settings.viewMode == 5 || settings.viewMode == 6)
                plot(settings.currentDetections(activeDetections,3), settings.currentDetections(activeDetections,4), '.g', 'MarkerSize', settings.markerSize);
                plot(settings.currentDetections(~activeDetections,3), settings.currentDetections(~activeDetections,4), '.r', 'MarkerSize', settings.markerSize);
            else
                plot(settings.currentDetections(validIndices,3), settings.currentDetections(validIndices,4), 'xr', 'Color', settings.groupColors(i+1, :), 'MarkerSize', 0.5*settings.markerSize);
            end
        else
            if (settings.viewMode == 5 || settings.viewMode == 6)
                plot(settings.currentDetections(activeDetections,3), settings.currentDetections(activeDetections,4), '.g', 'MarkerSize', settings.markerSize);
                plot(settings.currentDetections(~activeDetections,3), settings.currentDetections(~activeDetections,4), '.r', 'MarkerSize', settings.markerSize);
            else
                plot(settings.currentDetections(validIndices,3), settings.currentDetections(validIndices,4), '.r', 'Color', settings.groupColors(i+1, :), 'MarkerSize', settings.markerSize);
            end
            if (settings.showInfo == true)
                text('String', ['C' num2str(i) ' (#B: ' num2str(settings.colonies(i).numDetections) ', A: ' num2str(settings.colonies(i).area) ')'], 'FontSize', settings.fontSize, 'Color', settings.groupColors(i+1, :), 'Units', 'data', 'Position', settings.colonies(i).clusterCenter, 'Background', 'black', 'HorizontalAlignment', 'center');
            end
            
            if (settings.showBoundary == true && settings.colonies(i).isSelected == true)
                %plot(settings.currentDetections(settings.colonies(i).boundaryPoints, 3),settings.currentDetections(settings.colonies(i).boundaryPoints, 4),'r', 'Color', settings.groupColors(i+1, :))
                plot(settings.colonies(i).boundaryPoints(:,1), settings.colonies(i).boundaryPoints(:,2), 'r', 'Color', settings.groupColors(i+1, :), 'LineWidth', 2)
            end
        end
    end
    
    hold off;
else
    set(settings.mainFigure, 'Name', ['Current Slice: ' num2str(settings.currentSlice) '/' num2str(size(settings.rawImage,3))]);
    
    %% plot the background images
    imagesc(imadjust(settings.rawImage(:,:,settings.currentSlice), [settings.minIntensity, settings.maxIntensity], [], settings.gamma)); colormap(settings.colormap); hold on;
    
    %% plot detections of the red channel
    validDetectionsNear = find(settings.currentDetections(:,5) <= settings.currentSlice+2 & settings.currentDetections(:,5) >= settings.currentSlice-2);
    validDetectionsCurrentSlice = find(settings.currentDetections(:,5) == settings.currentSlice);
    
    %% plot group association of the detections
    for i=0:4
        validDetectionsNear = find(settings.currentDetections(:,settings.groupIdIndex) == i & settings.currentDetections(:,5) <= settings.currentSlice+2 & settings.currentDetections(:,5) >= settings.currentSlice-2);
        validIndices = find(settings.currentDetections(:,settings.groupIdIndex) == i & settings.currentDetections(:,5) == settings.currentSlice);
        
        %% plot detections of the red channel
        plot(settings.currentDetections(validDetectionsNear,3), settings.currentDetections(validDetectionsNear,4), '.r', 'Color', settings.groupColors(i+1, :), 'MarkerSize', settings.markerSize);
        plot(settings.currentDetections(validIndices,3), settings.currentDetections(validIndices,4), 'or', 'Color', settings.groupColors(i+1, :), 'MarkerSize', settings.markerSize);
    end
end

%% show the group ids and counts
if (settings.showParameterPanel == true)
    textColors = {'white', 'red'};
    text('String', ['Epsilon: ' num2str(settings.epsilon)], 'FontSize', settings.fontSize, 'Color', textColors{(settings.selectedParameter == 0)+1}, 'Units', 'normalized', 'Position', [0.01 0.98], 'Background', 'black');
    text('String', ['MinPoints: ' num2str(settings.minPoints)], 'FontSize', settings.fontSize, 'Color', textColors{(settings.selectedParameter == 1)+1}, 'Units', 'normalized', 'Position', [0.01 0.94], 'Background', 'black');
    text('String', ['BdryShape: ' num2str(settings.boundaryShape)], 'FontSize', settings.fontSize, 'Color', textColors{(settings.selectedParameter == 2)+1}, 'Units', 'normalized', 'Position', [0.01 0.90], 'Background', 'black');
    text('String', ['PedestalThreshold: ' num2str(settings.pedestalThreshold)], 'FontSize', settings.fontSize, 'Color', textColors{(settings.selectedParameter == 3)+1}, 'Units', 'normalized', 'Position', [0.01 0.86], 'Background', 'black');

    addDeleteMode = {'None', 'Bacteria', 'Colonies'};
    text('String', ['Add/Delete Mode: ' addDeleteMode{settings.addDeleteMode+1}], 'FontSize', settings.fontSize, 'Color', 'white', 'Units', 'normalized', 'Position', [0.01 0.82], 'Background', 'black');
end

%% if enabled, use correct aspect ratio
if (settings.axesEqual == true)
    axis equal;
else
    axis tight;
end
axis off;

%% apply zoom
set(gca, 'XLim', settings.xLim);
set(gca, 'YLim', settings.yLim);
settings.dirtyFlag = false;