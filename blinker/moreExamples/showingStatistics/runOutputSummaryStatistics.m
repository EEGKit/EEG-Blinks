%% Outp
%% Load the NCTU directory
% summaryDir = 'O:\ARL_Data\NCTU\NCTUBlinksNewRefactored';
% summaryFile = 'NCTU_LKAllMastNewBothSummary.mat';

%% Load the Shooter directory
% summaryDir = 'O:\ARL_Data\Shooter\ShooterBlinksNewRefactored';
% summaryFile = 'ShooterAllMastNewBothCombinedSummary.mat';

%% Load the BCIT directory
% summaryDir = 'O:\ARL_Data\BCITBlinksNewRefactored';
% summaryFile = 'BCITLevel0AllUnrefNewBothBlinksSummary.mat';

%% Load the BCI2000 directory
summaryFile = 'BCI2000AllMastNewBothCombinedSummary.mat';
summaryDir = 'O:\ARL_Data\BCI2000\BCI2000BlinksNewRefactored';

%% Load the summary file
load([summaryDir filesep summaryFile]);

%% Overall counts
fprintf('Total datasets: %d\n', length(fileMask));
fprintf('Excluded datasets: %d\n', sum(~fileMask));
fprintf('Nan datasets: %d\n', sum(fileMask & nanMask));

%% Output the channel counts
keysGood = keys(mapGood);
keysMarginal = keys(mapMarginal);
fprintf('Good datasets:\n')
totalGood = 0;
for k = 1:length(keysGood)
    fprintf('\tSignal %s: %d datasets\n', keysGood{k}, mapGood(keysGood{k}));
    totalGood = totalGood + mapGood(keysGood{k});
end
fprintf('Total good datasets = %d\n', totalGood);
totalMarginal = 0;
fprintf('Marginal datasets:\n')
for k = 1:length(keysMarginal)
    fprintf('\tSignal %s: %d datasets\n', keysMarginal{k}, mapMarginal(keysMarginal{k}));
    totalMarginal = totalMarginal + mapMarginal(keysMarginal{k});
end
fprintf('Total marginal datasets = %d\n', totalMarginal);

%% Output the total channel counts
fprintf('Total channel counts\n');
channelLabels = union(keysGood, keysMarginal);
channelCounts = zeros(size(channelLabels));
for k = 1:length(channelLabels)
    if isKey(mapGood, channelLabels{k})
        channelCounts(k) = channelCounts(k) + mapGood(channelLabels{k});
    end
    if isKey(mapMarginal, channelLabels{k})
        channelCounts(k) = channelCounts(k) + mapMarginal(channelLabels{k});
    end
end
[sortCounts, sortOrder] = sort(channelCounts);
channelLabels = channelLabels(sortOrder);
for k = 1:length(channelLabels)
   fprintf('\tSignal %s: %d datasets\n', channelLabels{k}, sortCounts(k));
end

%% Display the count of nan datasets
fprintf('Original number of datasets %d\n', length(blinkSummary));
srates = cellfun(@double, {blinkSummary.srate});
nanComponents = isnan(srates);
fprintf('Number of NaN datasets: %g [percentage %g]\n', ...
    sum(nanComponents),  100*sum(nanComponents)/length(blinkSummary));
blinkSummary(nanComponents) = [];
numDatasets = length(blinkSummary);
fprintf('Total number of datasets %d\n', numDatasets);
signalNumbers = cellfun(@double, {blinkSummary.usedNumber});
nanComponents = isnan(signalNumbers);

%% Display the count of marginal datasets
marginalComponents = strcmpi({blinkSummary.status}, 'marginal');
fprintf('Number of marginal datasets: %g [Percentage %g]\n', ...
    sum(marginalComponents), 100*sum(marginalComponents)/numDatasets);

marginalIndices = find(marginalComponents);
for k = 1:sum(marginalComponents)
    pos = marginalIndices(k);
    fprintf('%d: %s (ratio %g) %s\n', pos, blinkSummary(pos).usedLabel, ...
        blinkSummary(pos).goodRatio, blinkSummary(pos).uniqueName);
end

totalBlinksMarginal = 0;
totalBlinksGood = 0;
goodBlinksMarginal = 0;
goodBlinksGood = 0;
totalSecondsGood = 0;
totalSecondsMarginal = 0;
for k = 1:length(blinkSummary)
    if isnan(blinkSummary(k).usedNumber) 
        continue;
    end
    if marginalComponents(k)
        totalBlinksMarginal = totalBlinksMarginal + blinkSummary(k).numberBlinks;
        goodBlinksMarginal = goodBlinksMarginal + blinkSummary(k).numberGoodBlinks;
        totalSecondsMarginal = totalSecondsMarginal + blinkSummary(k).seconds;
    else
        totalBlinksGood = totalBlinksGood + blinkSummary(k).numberBlinks;
        goodBlinksGood = goodBlinksGood  + blinkSummary(k).numberGoodBlinks;
        totalSecondsGood  = totalSecondsGood  + blinkSummary(k).seconds;
    end
end

%% Print total values
fprintf('Total blinks good datasets: %d\n', totalBlinksGood);
fprintf('Total good blinks good datasets: %d\n', goodBlinksGood);
fprintf('Total seconds good datasets: %d\n', totalSecondsGood);
totalMinutesGood = totalSecondsGood/60;
fprintf('Minutes good datasets: %g\n', totalMinutesGood);
fprintf('Blinks/minute good datasets: %g\n', totalBlinksGood/totalMinutesGood);

%% Print marginal values
fprintf('Total blinks marginal datasets: %d\n', totalBlinksMarginal);
fprintf('Total good blinks good datasets: %d\n', goodBlinksMarginal);
fprintf('Total seconds marginal datasets: %d\n', totalSecondsMarginal);
totalMinutesMarginal = totalSecondsMarginal/60;
fprintf('Minutes marginal datasets: %g\n', totalMinutesMarginal);
fprintf('Blinks/minute marginal datasets: %g\n', totalBlinksMarginal/totalMinutesMarginal);

%% Print overall values
totalBlinks = totalBlinksGood + totalBlinksMarginal;
totalGoodBlinks = goodBlinksGood + goodBlinksMarginal;
totalSeconds = totalSecondsGood + totalSecondsMarginal;
fprintf('Total blinks: %d\n', totalBlinks);
fprintf('Total good blinks: %d\n', totalGoodBlinks);
fprintf('Total seconds: %d\n', totalSeconds);
totalMinutes = totalSeconds/60;
fprintf('Minutes datasets: %g\n', totalMinutes);
fprintf('Blinks/minute datasets: %g\n', totalBlinks/totalMinutes);

%% Print the overall averages 