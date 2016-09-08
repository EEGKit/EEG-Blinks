% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input:
%       blinkComp:  The independent component (IC) of eye-related
%                    activations derived from EEG.  This component should
%                    be "upright" 
%
%       srate:       the sample rate at which the EEG data was taken
%       stdTreshold  number of standard deviations above threshold for blink
% Output:
%       blinkPositions   2 x n array with start and end frames of blinks
%
% Notes:
%   This function uses EEGLAB functions, so EEGLAB must be running
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function blinkPositions = getBlinkPositions(blinkComp, srate, stdThreshold)
%% Constants:
minEventLen = 0.05; % events less than 50 ms are discarded
minEventSep = 0.05; % events less than 50 ms apart are discarded

mu = mean(blinkComp); 
robustStdDev = 1.4826*mad(blinkComp);
minBlink = minEventLen * srate;              % minimum blink frames
threshold = mu + stdThreshold * robustStdDev;      % actual threshold

% The return structure.  Initially there is room for an event at every time
% tick, to be trimmed later
blinkPositions = zeros(2, length(blinkComp));  % t_up, t_dn, max, start, end

% Find Events
numBlinks = 0;
inBlink = false;                  % flag indicating during blink
for index = 1:length(blinkComp);   
    % If amplitude exceeds threshold and not currently detecting a blink
    if (~inBlink && blinkComp(index) > threshold)
        % record index as a possible start
        start = index;
        inBlink = true;
    end
    
    % if previous point was in a blink and signal retreats below threshold
    % and duration greater than discard threshold
    if (inBlink && blinkComp(index) < threshold)
        % check to make sure this is not caused by noise
       if (index - start > minBlink)
           numBlinks = numBlinks + 1;
           blinkPositions(1, numBlinks) = start;  % t_up
           blinkPositions(2, numBlinks) = index;  % t_dn
       end
       inBlink = false;
    end   
end

%% Trim blink events to remove zeros
blinkPositions = blinkPositions(:,1:numBlinks);

%% Now remove blinks that aren't separated 
positionMask = true(numBlinks, 1);
startBlinks = blinkPositions(1, :);
endBlinks = blinkPositions(2, :);
x = (startBlinks(2:end) - endBlinks(1:end-1))/srate;
y = find(x <= 0.05);
positionMask(y) = false;
positionMask(y+1) = false;
blinkPositions = blinkPositions(:, positionMask);
