%%
% ColonyCounter.
% Copyright (C) 2022 A. Bachmann, A. Dupont, J. Stegmaier
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
 
function clickEventHandler(~, ~)
    global settings;

    %% get the modifier keys
    %modifiers = get(gcf,'currentModifier');        %(Use an actual figure number if known)
    %shiftPressed = ismember('shift',modifiers);
    %ctrlPressed = ismember('control',modifiers);
    %altPressed = ismember('alt',modifiers);

    %% identify the click position and the button
    buttonPressed = get(gcf, 'SelectionType');
    clickPosition = get(gca, 'currentpoint');
    clickPosition = round([clickPosition(1,1), clickPosition(1,2)]);
    
    %% handle different add/delete/select/deselect scenarios
    if (settings.addDeleteMode == 0 || strcmp(buttonPressed, 'open') || min(clickPosition) <= 0)
        return;
    
    %% mode 1 allows to add/delete bacteria
    elseif (settings.addDeleteMode == 1)
        
        %% add/remove bacterium
        if (strcmp(buttonPressed, 'normal'))
            meanIntensity = settings.meanFilteredImage(clickPosition(2), clickPosition(1));
            settings.currentDetections = [settings.currentDetections; -1, mean(settings.currentDetections(:, settings.areaIndex)), clickPosition(1), clickPosition(2), 1, meanIntensity, 0, 0, 1];
            disp('Adding bacterium at the current curser location');
        elseif (strcmp(buttonPressed, 'alt'))
            %% identify closest bacterium
            closestIndex = knnsearch(settings.currentDetections(:,3:4), clickPosition, 'K', 1);

            settings.currentDetections(closestIndex, :) = [];
            disp(['Removing bacterium closest to the current curser location: ' num2str(clickPosition)]);
        end
        
        %% call find colonies to update the clusters
        findColonies;

    %% mode 2 allows to activate/deactivate colonies
    elseif (settings.addDeleteMode == 2)

        %% identify closest bacterium
        closestIndex = knnsearch(settings.currentDetections(:,3:4), clickPosition, 'K', 1);
        closestDetection = settings.currentDetections(closestIndex, :);
        closestColony = closestDetection(settings.groupIdIndex);
        
        if (closestColony == 0)
            disp('Closest cell does not belong to a colony! Skipping ... ');
            return;
        end
        
        if (strcmp(buttonPressed, 'normal'))
            settings.colonies(closestColony).isSelected = true;
            settings.globalStatsPerColony((settings.globalStatsPerColony(:,1) == closestColony), 6) = 1;
            selectedDetections = settings.currentDetections(:,settings.groupIdIndex) == closestColony;
            settings.currentDetections(selectedDetections, settings.colonyActiveIndex) = true;
            disp(['Activating colony ' num2str(closestColony)]);
        elseif (strcmp(buttonPressed, 'alt'))
            settings.colonies(closestColony).isSelected = false;
            settings.globalStatsPerColony((settings.globalStatsPerColony(:,1) == closestColony), 6) = 0;
            selectedDetections = settings.currentDetections(:,settings.groupIdIndex) == closestColony;
            settings.currentDetections(selectedDetections, settings.colonyActiveIndex) = false;
            disp(['Deactivating colony ' num2str(closestColony)]);
        end
    end
        
    %% update the visualization
    updateVisualization;
end