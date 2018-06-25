function varargout = ITCFittingGUI(varargin)
% ITCFITTINGGUI MATLAB code for ITCFittingGUI.fig
%      ITCFITTINGGUI, by itself, creates a new ITCFITTINGGUI or raises the existing
%      singleton*.
%
%      H = ITCFITTINGGUI returns the handle to a new ITCFITTINGGUI or the handle to
%      the existing singleton*.
%
%      ITCFITTINGGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ITCFITTINGGUI.M with the given input arguments.
%
%      ITCFITTINGGUI('Property','Value',...) creates a new ITCFITTINGGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ITCFittingGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ITCFittingGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ITCFittingGUI

% Last Modified by GUIDE v2.5 16-Nov-2015 17:46:36

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ITCFittingGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ITCFittingGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ITCFittingGUI is made visible.
function ITCFittingGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ITCFittingGUI (see VARARGIN)

jFrame=get(handles.figure1,'javaframe');  
jicon=javax.swing.ImageIcon('match.png');
jFrame.setFigureIcon(jicon);

% Choose default command line output for ITCFittingGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ITCFittingGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ITCFittingGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile({'*.DAT';'*.*'},'File Selector');

fname=[pathname filename];
handles.filename=fname;
guidata(hObject,handles);

%% Read the input file
fileID = fopen(fname,'r');
dataArray = textscan(fileID, '%s%s%s%s%s%s%s%s%[^\n\r]' , 'Delimiter', ...
    '\t', 'HeaderLines' ,1, 'ReturnOnError', false);
fclose(fileID);
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));
for col=[1,2,3,4,5,6,7,8]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(thousandsRegExp, ',', 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {0}; % Replace non-numeric cells

% Allocate imported array to column variable names
injv = cell2mat(raw(:, 2));
xt = cell2mat(raw(:, 3));
mt = cell2mat(raw(:, 4));
xmt = cell2mat(raw(:, 5));
ndh = cell2mat(raw(:, 6));

clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me R;

axes(handles.axes1);
plot(xmt,ndh,'bo');



function v0_Callback(hObject, eventdata, handles)
% hObject    handle to v0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of v0 as text
%        str2double(get(hObject,'String')) returns contents of v0 as a double


% --- Executes during object creation, after setting all properties.
function v0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to v0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function temp_Callback(hObject, eventdata, handles)
% hObject    handle to temp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of temp as text
%        str2double(get(hObject,'String')) returns contents of temp as a double


% --- Executes during object creation, after setting all properties.
function temp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to temp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function discard_Callback(hObject, eventdata, handles)
% hObject    handle to discard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of discard as text
%        str2double(get(hObject,'String')) returns contents of discard as a double


% --- Executes during object creation, after setting all properties.
function discard_CreateFcn(hObject, eventdata, handles)
% hObject    handle to discard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ska_Callback(hObject, eventdata, handles)
% hObject    handle to ska (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ska as text
%        str2double(get(hObject,'String')) returns contents of ska as a double


% --- Executes during object creation, after setting all properties.
function ska_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ska (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sn_Callback(hObject, eventdata, handles)
% hObject    handle to sn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sn as text
%        str2double(get(hObject,'String')) returns contents of sn as a double


% --- Executes during object creation, after setting all properties.
function sn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

zero_final_obj=get(handles.basezero,'SelectedObject');
base_offset_obj=get(handles.baseoffset,'SelectedObject');
fit_method_obj=get(handles.fitmethod,'SelectedObject');

zero_final_s=get(zero_final_obj,'String');
switch zero_final_s
    case 'Yes' 
        zero_final='y';
    case 'No'
        zero_final='n';
end

base_offset_s=get(base_offset_obj,'String');
switch base_offset_s
    case 'Yes' 
        base_offset='y';
    case 'No'
        base_offset='n';
end

v0=str2num(get(handles.v0,'String'));
syc=str2num(get(handles.syc,'String'));
temp=str2num(get(handles.temp,'String'));
discard=str2num(get(handles.discard,'String'));
ska=str2num(get(handles.ska,'String'));
sn=str2num(get(handles.sn,'String'));

% Call appropiate fitting method
fit_method_s=get(fit_method_obj,'String');
fname=handles.filename;
switch fit_method_s
    case 'Levenberg-Marquardt' 
        if base_offset == 'y'
            [outf,p1,p2]=ITCFit(fname,v0,syc,temp,discard,ska,sn,zero_final);
        elseif base_offset == 'n'
            [outf,p1,p2]=ITCFit2(fname,v0,syc,temp,discard,ska,sn,zero_final);
        end
    case 'Non-Linear Fit'
        if base_offset == 'y'
            [outf,p1,p2]=ITCFitnlin(fname,v0,syc,temp,discard,ska,sn,zero_final);
        elseif base_offset == 'n'
            [outf,p1,p2]=ITCFitnlin2(fname,v0,syc,temp,discard,ska,sn,zero_final);
        end
end
axes(handles.axes1);
cla;
plot(p1(:,1),p1(:,2),'-','Color',[0.8 0.8 0.8],'LineWidth',3); % Plot the line
hold on;
plot(p2(:,1),p2(:,2),'ko'); % plot the points of style ptype

handles.p1=p1;
handles.p2=p2;
guidata(hObject,handles);

set(handles.kd, 'String', num2str(outf(1)*1e6));
set(handles.ekd, 'String', num2str(outf(2)*1e6));
set(handles.n, 'String', num2str(outf(5)));
set(handles.en, 'String', num2str(outf(6)));
set(handles.dh, 'String', num2str(outf(7)*1e-3));
set(handles.edh, 'String', num2str(outf(8)*1e-3));

set(handles.savefig, 'Visible', 'On');
set(handles.savefig, 'Visible', 'On');
set(handles.readts, 'Visible', 'On');
set(handles.starttrunc, 'Visible', 'On');
set(handles.plotts, 'Visible', 'On');
% set(handles.savefinalfig, 'Visible', 'On');
set(handles.trunct, 'Visible', 'On');
set(handles.windowt, 'Visible', 'On');
set(handles.stepsizet, 'Visible', 'On');
set(handles.window, 'Visible', 'On');
set(handles.stepsize, 'Visible', 'On');


function syc_Callback(hObject, eventdata, handles)
% hObject    handle to syc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of syc as text
%        str2double(get(hObject,'String')) returns contents of syc as a double


% --- Executes during object creation, after setting all properties.
function syc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to syc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in savefig.
function savefig_Callback(hObject, eventdata, handles)
% hObject    handle to savefig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% F=getimage(handles.axes1); %select axes in GUI
% figure(); %new figure
% image(F.cdata); %show selected axes in new figure
% saveas(gcf, 'path', 'fig'); %save figure
% close(gcf); %and close it

[file,path] = uiputfile('*.eps','Save Figure FileName');
filenoext=file(1:end-4);
fh = figure;
copyobj(handles.axes1, fh);
set(gcf,'Units','inches');
xlabel('Molar Ratio');
set(gca,'Position',[9.87499999999999 3.8095238095238 88.8125 25]);
saveas(fh, [path filenoext '.fig'] ,'fig');
saveas(fh, [path file],'eps2c');
close(fh);

T=str2num(get(handles.temp,'String'));
dS=-(-1.9858775*(273.15+T)*log(1/str2num(get(handles.kd,'String')))-str2num(get(handles.dh,'String')))/(273.15+T); %dS = -(dG-dH)/T; dG = -RTln(Ka);
dS=dS*1e3;

fid = fopen( [filenoext '_fit.txt'], 'w' );
fprintf( fid, 'Delta_H: %10.5f ± %10.5f \t [kcal/mol] \n', str2num(get(handles.dh,'String')), str2num(get(handles.edh,'String')));
fprintf( fid, 'n      : %10.2f ± %10.2f \t \n', str2num(get(handles.n,'String')), str2num(get(handles.en,'String')));
fprintf( fid, 'Kd     : %10.5f ± %10.5f \t [ x10^-6 M (uM) ]\n', str2num(get(handles.kd,'String')), str2num(get(handles.ekd,'String')));
fprintf( fid, 'dS     : %10.5f \t [cal/mol/K]\n', dS);
fclose(fid);


% --- Executes on button press in resetdata.
function resetdata_Callback(hObject, eventdata, handles)
% hObject    handle to resetdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fname=handles.filename;
fileID = fopen(fname,'r');
dataArray = textscan(fileID, '%s%s%s%s%s%s%s%s%[^\n\r]' , 'Delimiter', ...
    '\t', 'HeaderLines' ,1, 'ReturnOnError', false);
fclose(fileID);
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));
for col=[1,2,3,4,5,6,7,8]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(thousandsRegExp, ',', 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {0}; % Replace non-numeric cells

% Allocate imported array to column variable names
injv = cell2mat(raw(:, 2));
xt = cell2mat(raw(:, 3));
mt = cell2mat(raw(:, 4));
xmt = cell2mat(raw(:, 5));
ndh = cell2mat(raw(:, 6));

clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me R;

axes(handles.axes1);
cla;
plot(xmt,ndh,'bo');

set(handles.kd, 'String','');
set(handles.ekd, 'String', '');
set(handles.n, 'String', '');
set(handles.en, 'String', '');
set(handles.dh, 'String', '');
set(handles.edh, 'String', '');
set(handles.savefig, 'Visible', 'Off');
set(handles.readts, 'Visible', 'Off');
set(handles.starttrunc, 'Visible', 'Off');
set(handles.plotts, 'Visible', 'Off');
set(handles.savefinalfig, 'Visible', 'Off');
set(handles.trunct, 'Visible', 'Off');
set(handles.windowt, 'Visible', 'Off');
set(handles.stepsizet, 'Visible', 'Off');
set(handles.window, 'Visible', 'Off');
set(handles.stepsize, 'Visible', 'Off');


% --- Executes on button press in readts.
function readts_Callback(hObject, eventdata, handles)
% hObject    handle to readts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uigetfile({'*.DAT';'*.*'},'File Selector');;
tsdata=importdata([path file]);
handles.tsdatafname=tsdata.data;
guidata(hObject,handles);


% --- Executes on button press in plotts.
function plotts_Callback(hObject, eventdata, handles)
% hObject    handle to plotts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tsdata=handles.tsdatafname;
starttrunc=str2num(get(handles.starttrunc,'String'));
window=str2num(get(handles.window,'String'));
stepsize=str2num(get(handles.stepsize,'String'));
tsdata(1:starttrunc-1,:)=[];
figure;
xdata=tsdata(:,1);
ydata=tsdata(:,2);
newydata=msbackadj(xdata,ydata,'WindowSize',window,'StepSize',stepsize);
handles.tsxdata=xdata;
handles.tsydata=newydata;
guidata(hObject,handles);
plot(xdata,newydata,'k-');
xlabel('time');
ylabel('Cp');
set(handles.savefinalfig, 'Visible', 'On');

% --- Executes on button press in printplots.
function printplots_Callback(hObject, eventdata, handles)
% hObject    handle to printplots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function starttrunc_Callback(hObject, eventdata, handles)
% hObject    handle to starttrunc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of starttrunc as text
%        str2double(get(hObject,'String')) returns contents of starttrunc as a double


% --- Executes during object creation, after setting all properties.
function starttrunc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to starttrunc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function window_Callback(hObject, eventdata, handles)
% hObject    handle to window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of window as text
%        str2double(get(hObject,'String')) returns contents of window as a double


% --- Executes during object creation, after setting all properties.
function window_CreateFcn(hObject, eventdata, handles)
% hObject    handle to window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stepsize_Callback(hObject, eventdata, handles)
% hObject    handle to stepsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stepsize as text
%        str2double(get(hObject,'String')) returns contents of stepsize as a double


% --- Executes during object creation, after setting all properties.
function stepsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stepsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in savefinalfig.
function savefinalfig_Callback(hObject, eventdata, handles)
% hObject    handle to savefinalfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fh=figure;
%fh.Units = 'inches';
set(fh,'Position',[452.3333   37.6667  468.0000  580.0000]);
subplot1 = subplot(2,1,1,'Parent',fh);
hold(subplot1,'on');
plot(handles.tsxdata,handles.tsydata,'k-');
xlabel('time');
ylabel('Cp');
box(subplot1,'on');
% Create axes
axes2 = axes('Parent',fh,...
    'Position',[0.13 0.11 0.775 0.396896494252873]);
hold(axes2,'on');
p1=handles.p1;
p2=handles.p2;
plot(p1(:,1),p1(:,2),'-','Color',[0.8 0.8 0.8],'LineWidth',3); % Plot the line
hold on;
plot(p2(:,1),p2(:,2),'ko'); % plot the points of style ptype
xlim(get(handles.axes1,'XLim'));
ylim(get(handles.axes1,'YLim'));
xlabel('Molar Ratio');
box(axes2,'on');

[file,path] = uiputfile('*.eps','Save Final Figure FileName');
filenoext=file(1:end-4);
if isempty(filenoext)
    filenoext='FinalFigure';
end
saveas(fh, [path filenoext '.fig'] ,'fig');
saveas(fh, [path file],'eps2c');
close(fh);

T=str2num(get(handles.temp,'String'));
dS=-(-1.9858775*(273.15+T)*log(1/str2num(get(handles.kd,'String')))-str2num(get(handles.dh,'String')))/(273.15+T); %dS = -(dG-dH)/T; dG = -RTln(Ka);
dS=dS*1e3;

fid = fopen( [filenoext '_fit.txt'], 'w' );
fprintf( fid, 'Delta_H: %10.5f ± %10.5f \t [kcal/mol] \n', str2num(get(handles.dh,'String')), str2num(get(handles.edh,'String')));
fprintf( fid, 'n      : %10.2f ± %10.2f \t \n', str2num(get(handles.n,'String')), str2num(get(handles.en,'String')));
fprintf( fid, 'Kd     : %10.5f ± %10.5f \t [ x10^-6 M (uM) ]\n', str2num(get(handles.kd,'String')), str2num(get(handles.ekd,'String')));
fprintf( fid, 'dS     : %10.5f \t [cal/mol/K]\n', dS);
fclose(fid);
