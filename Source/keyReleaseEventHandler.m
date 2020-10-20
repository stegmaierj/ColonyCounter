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
 
%% the key event handler
function keyReleaseEventHandler(~,evt)
    global settings;

    settings.xLim = get(gca, 'XLim');
    settings.yLim = get(gca, 'YLim');

    %% switch between the images of the loaded series
    if (strcmp(evt.Key, 'rightarrow'))
        settings.currentSlice = min(size(settings.rawImage,3), settings.currentSlice+1);
        updateVisualization;
    elseif (strcmp(evt.Key, 'leftarrow'))
        settings.currentSlice = max(1, settings.currentSlice-1);
        updateVisualization;
        %% not implemented yet, maybe use for contrast or scrolling
    elseif (strcmp(evt.Character, '+'))
        settings.gamma(1) = min(5, settings.gamma(1)+0.1);
        updateVisualization;
    elseif (strcmp(evt.Character, '-'))
        settings.gamma(1) = max(0, settings.gamma(1) - 0.1);
        updateVisualization;
        
    elseif (strcmp(evt.Key, 'uparrow'))
        if (settings.selectedParameter == 0)
           settings.epsilon = settings.epsilon + 1;
        elseif (settings.selectedParameter == 1)
            settings.minPoints = settings.minPoints + 1;
        elseif (settings.selectedParameter == 2)
            settings.boundaryShape = min(1, settings.boundaryShape + 0.1);
        elseif (settings.selectedParameter == 3)
            settings.pedestalThreshold = min(1, settings.pedestalThreshold + 0.01);
        end
        findColonies;
        updateVisualization;
    elseif (strcmp(evt.Key, 'downarrow'))
        if (settings.selectedParameter == 0)
           settings.epsilon = max(0, settings.epsilon - 1);
        elseif (settings.selectedParameter == 1)
            settings.minPoints = max(1, settings.minPoints - 1);
        elseif (settings.selectedParameter == 2)
            settings.boundaryShape = max(0, settings.boundaryShape - 0.1);
        elseif (settings.selectedParameter == 3)
            settings.pedestalThreshold = max(0, settings.pedestalThreshold - 0.01);
        end
        findColonies;
        updateVisualization; 
	elseif (strcmp(evt.Key, 'p'))
        settings.selectedParameter = mod(settings.selectedParameter+1, 4);
        updateVisualization;
    
    %% toggle add/delete/deselect mode
    elseif (strcmp(evt.Character, 'a'))
        settings.addDeleteMode = mod(settings.addDeleteMode+1, 3);
        updateVisualization;
        
    %% add a new detection if in slice-mode
    elseif (strcmp(evt.Character, 'v'))
        settings.axesEqual = ~settings.axesEqual;
        updateVisualization;
%         if (settings.maximumProjectionMode == true)
%             errordlg('Adding and deleting detections only works in slice mode!');
%         else
%             [x, y] = ginputc(1, 'Color', 'r', 'LineWidth', 1);
%             settings.currentDetections(end+1,:) = [size(settings.currentDetections,1), 1, x, y, settings.currentSlice, settings.selectedGroup];
%             updateVisualization;
%         end
        
    elseif (strcmp(evt.Character, 'm'))
        ShowColonyStats();
        
    %% export the results
    elseif (strcmp(evt.Character, 'e'))
        exportProject();
        
    elseif (strcmp(evt.Character, 'i'))        
        settings.showInfo = ~settings.showInfo;
        updateVisualization;
        
    elseif (strcmp(evt.Character, 'b'))
        settings.showBoundary = ~settings.showBoundary;
        findColonies;     
        updateVisualization;
        
    elseif (strcmp(evt.Character, 'd'))
        settings.showDetections = ~settings.showDetections;
        updateVisualization;
        
    %% select a region of interest and assign the current group to contained detections
    elseif (strcmp(evt.Character, 's'))
        
        
	%% toggle the color map
    elseif (strcmp(evt.Character, 'c'))
        settings.colormapIndex = mod(settings.colormapIndex+1, 3)+1;
        updateVisualization;
        
    %% reset the current group selection
    elseif (strcmp(evt.Character, 'r'))
        answer = questdlg('Really reset parameters to the default settings (no undo available!)?');
        if (strcmp(answer, 'Yes'))
            settings.currentDetections(:,settings.groupIdIndex) = 0;
            settings.pedestalThreshold = 0.38;
            settings.boundaryShape = 1;
            settings.minPoints = 6;
            settings.epsilon = 33;
            settings.selectedParameter = 1;
            settings.showInfo = false;
            settings.showBoundary = false;
            updateVisualization;
        end
        
    %% reset the zoom
    elseif (strcmp(evt.Character, 'o'))
        settings.xLim = [1, size(settings.rawImage1,2)];
        settings.yLim = [1, size(settings.rawImage1,1)];
        axis tight;
        updateVisualization;

    %% show the help dialog
    elseif (strcmp(evt.Character, 'h'))    
        showHelp;
        
	%% set group 1 for selection
    elseif (strcmp(evt.Character, '1'))
        settings.viewMode = 1;
        updateVisualization;
    
    %% set group 2 for selection
    elseif (strcmp(evt.Character, '2'))
        settings.viewMode = 2;
        updateVisualization;
    
	%% set group 3 for selection
    elseif (strcmp(evt.Character, '3'))
        settings.viewMode = 3;
        updateVisualization;

    %% set group 4 for selection
    elseif (strcmp(evt.Character, '4'))
        settings.viewMode = 4;
        updateVisualization;
    
	%% set group unassigned for selection
    elseif (strcmp(evt.Character, '5'))
        settings.viewMode = 5;
        updateVisualization;
%% set group unassigned for selection
    elseif (strcmp(evt.Character, '6'))
        settings.viewMode = 6;
        updateVisualization;
    end
end