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
 
if (~ishandle(settings.statsFigure))
    settings.statsFigure = figure(2);
    set(settings.statsFigure, 'units','normalized','outerposition',[0 0 1 1]);
end
 
figure(settings.statsFigure); clf;
set(gcf, 'color', 'white');
colordef white; %#ok<COLORDEF>
subplot(2,3,1);

%% only compute stats for the active colonies
activeColonies = ones(length(settings.globalStatsPerColony), 1);
deselectedBacteriaCount = 0;
for i=1:length(settings.colonies)
   activeColonies(i) = settings.colonies(i).isSelected;
   
   if (activeColonies(i) == 0)
       deselectedBacteriaCount = deselectedBacteriaCount + sum(settings.currentDetections(:,settings.groupIdIndex) == i);
   end   
end
activeColonies = activeColonies > 0;

%% histogram of colony size (1, 2-5, 6-10, 11-15 bacteria per colony)
binValues = zeros(5,1);
binValues(1) = sum(settings.globalStatsPerColony(activeColonies,2) < 2) + sum(settings.currentDetections(:,settings.groupIdIndex) == 0) + deselectedBacteriaCount;
binValues(2) = sum(settings.globalStatsPerColony(activeColonies,2) >= 2 & settings.globalStatsPerColony(activeColonies,2) < 6);
binValues(3) = sum(settings.globalStatsPerColony(activeColonies,2) >= 6 & settings.globalStatsPerColony(activeColonies,2) < 11);
binValues(4) = sum(settings.globalStatsPerColony(activeColonies,2) >= 11 & settings.globalStatsPerColony(activeColonies,2) < 16);
binValues(5) = sum(settings.globalStatsPerColony(activeColonies,2) >= 16);

bar(1:5, binValues);
%histogram(settings.globalStatsPerColony(:,2), [0, 2, 6, 11, inf]);
title('Histogram of Colony Size');
xlabel('Colony Size (Bacteria per Colony)');
set(gca, 'XTick', [1,2,3,4,5], 'XTickLabel', {'1', '2-5', '6-10', '11-15', '>15'});
axis([0, 6, 0, max(binValues)+1]);
ylabel('Occurrence Frequency');

subplot(2,3,2);
boxplot(settings.globalStatsPerColony(activeColonies,2));
title(['Number of Bacteria per Colony (\mu = ' num2str(mean(settings.globalStatsPerColony(activeColonies,2))) ' \pm ' num2str(std(settings.globalStatsPerColony(activeColonies,2))) ')'] );
ylabel('#Bacteria per Colony');

subplot(2,3,3);
boxplot(settings.globalStatsPerColony(activeColonies,3));
title(['Number of Bacteria with Pedestals per Colony (\mu = ' num2str(mean(settings.globalStatsPerColony(activeColonies,3))) ' \pm ' num2str(std(settings.globalStatsPerColony(activeColonies,3))) ')'] );
ylabel('#Bacteria with Pedestals per Colony')


subplot(2,3,4);
pedestalActiveColonies = sum(settings.globalStatsPerColony(activeColonies,7) & settings.globalStatsPerColony(activeColonies,6));
pedestalInactiveColonies = sum(activeColonies) - pedestalActiveColonies;
bar([1,2], [pedestalActiveColonies, pedestalInactiveColonies]);

text(1, pedestalActiveColonies, num2str(pedestalActiveColonies), 'HorizontalAlignment','center', 'VerticalAlignment','bottom');
text(2, pedestalInactiveColonies, num2str(pedestalInactiveColonies), 'HorizontalAlignment','center', 'VerticalAlignment','bottom');

set(gca, 'XTick', [1,2], 'XTickLabel', {sprintf('Act. Pedestals >=%.2f%%', 100 * settings.pedestalActiveColonyThreshold), sprintf('Act. Pedestals <%.2f%%', 100 * settings.pedestalActiveColonyThreshold)})
ylabel('Number of Colonies')
title(sprintf('Number of Colonies with More/Less Than %.2f%% Active Pedestals', 100 * settings.pedestalActiveColonyThreshold));

subplot(2,3,5);
boxplot(settings.globalStatsPerColony(activeColonies,4));
title(['Fraction of Pedestal Active Bacteria per Colony (\mu = ' num2str(mean(settings.globalStatsPerColony(activeColonies,4))) ' \pm ' num2str(std(settings.globalStatsPerColony(activeColonies,4))) ')']);
ylabel('Pedestal Active Bacteria per Colony (%)');

subplot(2,3,6);
boxplot(settings.globalStatsPerColony(activeColonies,5));
title(['Density (\mu = ' num2str(mean(settings.globalStatsPerColony(activeColonies,5))) ' \pm ' num2str(std(settings.globalStatsPerColony(activeColonies,5))) ')']);
ylabel('#Bacteria per Area');