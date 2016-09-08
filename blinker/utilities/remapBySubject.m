function [] = remapBySubject(blinkIndir, blinkOutdir, blinkRemap)
%% Given a remap, reselect a channel for each file in blinkIndir
%
% Parameters:
%   blinkIndir    directory with blinker files for individual data
%   blinkOutdir   directory (not blinkIndir) to write new blinker files
%                 with the channel reselected by combination
%   blinkRemap    the remap structure computed from getRemapBySubject
%
% Notes: The blinker files for the individual data files contain 4 
% structures -- blinks, blinkFits, blinkProperties, and params.  These
% should have been run with the keepSignals option to true so that
% the remap function can work with all of the signals that pass the
% blink amplitute ratio test.
%

%% Find the list of input files
inList = dir(blinkIndir);
dirNames = {inList(:).name};
dirTypes = [inList(:).isdir];
fileNames = dirNames(~dirTypes);

%% Now create the new blinks file
subjects = {blinkRemap.subjectID};
for k = 1:length(fileNames)
    blinks = []; blinkFits = []; blinkProperties = []; params = []; %#ok<*NASGU>
    fprintf('Processing %s\n', fileNames{k});
    [thePath, theName, theExt] = fileparts(fileNames{k});
    inName = [blinkIndir filesep theName theExt];
    outName = [blinkOutdir filesep theName 'Combined.mat'];
    try
       blinks = []; blinkFits = []; blinkProperties = []; params = [];
       lTemp = load(inName);
       blinks = lTemp.blinks;
       blinkFits = lTemp.blinkFits;
       blinkProperties = lTemp.blinkProperties;
       params = lTemp.params;
 
    catch mex
        warning('----%s does not exist (%s)....\n', inName, mex.message);
        continue;
    end
    if ~exist('blinks', 'var')
        warning('----%s has no blinks structure', inName);
        continue;
    end
    theSubject = blinks.subjectID;
    pos = find(strcmpi(subjects, theSubject), 1, 'first');
    rmap = blinkRemap(pos);
    used = rmap.usedSignal;
    if ~ischar(used) || isnan(blinks.usedSignal)
        blinks.usedSignal = NaN; %#ok<*SAGROW>
        blinkProperties = [];
        blinkFits = [];
        blinks.status = ['Recombined failed old[' blinks.status ']'];
        saveFiles(outName);
        warning('---%s: %s', outName, blinks.status);
        continue;
    end
    rmapPos = find(strcmpi(rmap.signalLabels, used), 1, 'first');
    sData = blinks.signalData;
    myLabels = {sData.signalLabel};
    pos = find(strcmpi(myLabels, used), 1, 'first');
    if ~isempty(pos)
        sData = sData(pos);
        sData.signalType = 'RemappedBySubject';
        sData.bestMedian = rmap.bestMedians(rmapPos);
        sData.bestRobustStd = rmap.bestRobustStds(rmapPos);
        sData.goodRatio = rmap.goodRatios(rmapPos);
        sData.cutoff = rmap.cutoffs(rmapPos);

        if sData.signalNumber ~= abs(blinks.usedSignal)
            sData.blinkAmplitudeRatio = NaN;
            [blinkProperties, blinkFits] = ...
                extractBlinkProperties(sData, params); %#ok<*ASGLU>
            fprintf('---%s: changed from %d to %d\n', ...
                inName, blinks.usedSignal, sData.signalNumber);
        end
        blinks.signalData = sData;
        blinks.usedSignal = rmap.usedSign*sData.signalNumber;
    else
        blinks.usedSignal = NaN; %#ok<*SAGROW>
        blinkProperties = [];
        blinkFits = [];
        blinks.status = ['Recombined failed old[' blinks.status ']'];
        warning('---%s: %s', inName, blinks.status);
    end
    saveFiles(outName);
end

   function [] = saveFiles(fileName)
       save(fileName, 'blinks', 'blinkFits',  'blinkProperties', 'params', '-v7.3');
   end
end