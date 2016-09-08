%% Test GUI

userData = getBlinkerDefaults(EEG);
title = 'Blinker parameters';
hObject = [];
defaultStruct = getBlinkerDefaults(EEG);
fNamesDefault = fieldnames(defaultStruct);
for k = 1:length(fNamesDefault)
    textColorStruct.(fNamesDefault{k}) = 'k';
end
% callbackdata = [];
% % [paramsOut, okay] = blinkerGUI(hObject, callbackdata, userData, EEG);
% 
% %     userData = getUserData();
%     %     [params, okay] = MasterGUI([],[],userData, EEG);
%     
%     geometry = {[1, 1.75,1], [1, 1.75,1], [1, 1.75,1], 1, [1.35,1,1.75,1], [1.35,1,1.75,1], ...
%         [1.35,1,1.75,1], 1, [1.35,1,1.75,1], [1.35,1,1.75,1], [1.35,1,1.75,1], 1, ...
%         [1.35,1,1.75,1], [1.35,1,1.75,1], [1.35,1,1.75,1], 1};
%     geomvert = [];
%     uilist={{'style', 'text', 'string', 'Channel labels', ...
%         'TooltipString', defaultStruct.channelLabels.description}...
%         {'style', 'edit', 'string', ...
%         defaultStruct.channelLabels.value, 'tag', ...
%         'channelLabels', 'ForegroundColor', ...

res = inputgui('geometry', { 1 1 }, 'uilist', ...
                        { { 'style' 'text' 'string' 'Enter a value' } ...
                          { 'style' 'edit' 'string' '' } });


  uilist={{'style', 'text', 'string', 'Channel labels', ...
        'TooltipString', defaultStruct.channelLabels.description}...
        {'style', 'edit', 'string', ...
        defaultStruct.channelLabels.value, 'tag', ...
        'channelLabels', 'ForegroundColor', ...
        textColorStruct.channelLabels}};
  geomvert = [];
   geometry = {[1, 1.75]};    
    [~, ~, ~, paramsOut] = ...
        inputgui('geometry', geometry, 'geomvert', geomvert, ...
        'uilist', uilist, 'title', title, 'helpcom', ...
        'pophelp(''pop_blinker'')');