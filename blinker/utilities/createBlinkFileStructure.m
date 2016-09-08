function s = createBlinkFileStructure()
% Return an empty structure describing how to generate blink files
s  = struct('fileName', NaN, ...
            'blinkFileName', NaN, ...
            'subjectID', NaN, ...
            'experiment', NaN, ...
            'uniqueName', NaN, ...
            'task', NaN, ...
            'startDate', NaN', ...
            'startTime', NaN);