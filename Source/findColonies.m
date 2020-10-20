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

%% set the pedestal flag depending on the current threshold
settings.currentDetections(:, settings.pedestalActiveIndex) = settings.currentDetections(:, settings.meanIntensityIndex) >= settings.pedestalThreshold; 

%% skip rest of the script if boundaries are disabled (for faster threshold adaptation)
if (settings.showBoundary == false)
    return;
end

%% perform clustering using the current parameters
[clusterIndices] = dbscan(settings.currentDetections(:,3:4), settings.epsilon, settings.minPoints);
clusterIndices(clusterIndices < 0) = 0;

%% assign the cluster indices to the detections
settings.currentDetections(:,settings.groupIdIndex) = clusterIndices;

%% iterate over the clusters and analyze the boundaries
groupIndices = unique(settings.currentDetections(:,settings.groupIdIndex));
settings.colonies = struct();
settings.globalStatsPerColony = zeros(length(groupIndices)-1, 6);
settings.globalStatsPerColonySpecifiers = 'ColonyID; NumBacteria; NumBacteriaWithPedestal; FractionOfBacteriaWithPedestal; Density; IsSelected';

for i = groupIndices'
    if (i == 0)
        continue;
    end
    
    %% find the IDs of the detections/segments currently associated with the colony
    validIndices = find(settings.currentDetections(:,settings.groupIdIndex) == i);
    
    %% extract colony boundary either using the centroids or the boundary pixels
    seedBoundary = false;
    if (seedBoundary == true)
        [boundaryIndices, ~] = boundary(settings.currentDetections(validIndices, 3),settings.currentDetections(validIndices, 4), settings.boundaryShape);
        settings.colonies(i).boundaryPoints = [settings.currentDetections(validIndices(boundaryIndices), 3),settings.currentDetections(validIndices(boundaryIndices), 4)];
    else
        %% compute the number of edge pixels
        numEdgePixels = 0;
        for j=validIndices'
            if (settings.currentDetections(j, 1) > 0)
                currentOriginalIndex = settings.currentDetections(j, 1);
                numEdgePixels = numEdgePixels + length(settings.segImageEdgesRegionProps(currentOriginalIndex).PixelIdxList);
            else
                numEdgePixels = numEdgePixels + 1;
            end
        end

        %% combine the edge pixels of the different bacteria
        currentEdgePixels = zeros(numEdgePixels, 2);
        currentInsertPosition = 1;
        for j=validIndices'
            if (settings.currentDetections(j, 1) > 0)
                currentOriginalIndex = settings.currentDetections(j, 1);
                [ypos, xpos] = ind2sub(size(settings.segImage), settings.segImageEdgesRegionProps(currentOriginalIndex).PixelIdxList);
                currentEdgePixels(currentInsertPosition:(currentInsertPosition+length(ypos)-1), :) = [xpos, ypos];
                currentInsertPosition = currentInsertPosition+length(ypos);
            else
                meanRadius = sqrt(mean(settings.currentDetections(:,settings.areaIndex)) / pi);
                for k=[-1,1]
                    for l=[-1,1]
                        currentEdgePixels(currentInsertPosition, :) = round(settings.currentDetections(j, 3:4) + meanRadius*[k,l]);
                        currentInsertPosition = currentInsertPosition+1;
                    end
                end
            end
        end
        
        %% compute the boundary of the current group
        [boundaryIndices, ~] = boundary(currentEdgePixels(:,1), currentEdgePixels(:,2), settings.boundaryShape);
        settings.colonies(i).boundaryPoints = [currentEdgePixels(boundaryIndices,1), currentEdgePixels(boundaryIndices,2)];
    end
    
    %% compute the area based on the segmentation of each bacterium
    area = 0;
    numActive = 0;
    numBacteria = length(validIndices);
    for j=validIndices'
        area = area + settings.currentDetections(j, settings.areaIndex);
        
        %% check if mean intensity of the current bacteria exceeds the pedestal threshold
        isActive = settings.currentDetections(j, settings.meanIntensityIndex) >= settings.pedestalThreshold;
        settings.currentDetections(j, settings.pedestalActiveIndex) = isActive;
        if (isActive == true)
            numActive = numActive + 1;
        end
    end
    settings.colonies(i).area = area;
    settings.colonies(i).density = length(validIndices) / area;
    settings.colonies(i).positivePedestalFraction = 100 * numActive / numBacteria;
    
    %% extract the parameters to characterize the colonies
    settings.colonies(i).clusterCenter = mean(settings.currentDetections(validIndices, 3:4), 1);
    settings.colonies(i).numDetections = numBacteria;
    settings.colonies(i).validIndices = validIndices;
    settings.colonies(i).area = area;
    if (median(settings.currentDetections(validIndices, settings.colonyActiveIndex)) > 0)
        settings.colonies(i).isSelected = true;
        settings.currentDetections(validIndices, settings.colonyActiveIndex) = true;
    else
        settings.colonies(i).isSelected = false;
        settings.currentDetections(validIndices, settings.colonyActiveIndex) = false;
    end
    
    settings.globalStatsPerColony(i, :) = [i, numBacteria, numActive, settings.colonies(i).positivePedestalFraction, settings.colonies(i).density, settings.colonies(i).isSelected];
end