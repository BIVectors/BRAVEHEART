%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% braveheart_gui.m -- BRAVEHEART GUI
% Copyright 2016-2025 Hans F. Stabenau and Jonathan W. Waks
% 
% Source code/executables: https://github.com/BIVectors/BRAVEHEART
% Contact: braveheart.ecg@gmail.com
% 
% BRAVEHEART is free software: you can redistribute it and/or modify it under the terms of the GNU 
% General Public License as published by the Free Software Foundation, either version 3 of the License, 
% or (at your option) any later version.
%
% BRAVEHEART is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
% without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
% See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License along with this program. 
% If not, see <https://www.gnu.org/licenses/>.
%
% This software is for research purposes only and is not intended to diagnose or treat any disease.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = braveheart_gui(varargin)
% braveheart_gui MATLAB code for braveheart_gui.fig
%      braveheart_gui, by itself, creates a new braveheart_gui or raises the existing
%      singleton*.
%
%      H = braveheart_gui returns the handle to a new braveheart_gui or the handle to
%      the existing singleton*.
%
%      braveheart_gui('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in braveheart_gui.M with the given input arguments.
%
%      braveheart_gui('Property','Value',...) creates a new braveheart_gui or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before braveheart_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to braveheart_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help braveheart_gui

% Last Modified by GUIDE v2.5 21-Apr-2025 22:25:21

% Update the current L&F for mac button issues...
% Windows will use the normal Windows theme
if ismac
    %originalLnF = javax.swing.UIManager.getLookAndFeel;  
    %newLnF = 'com.sun.java.swing.plaf.windows.WindowsLookAndFeel';
    newLnF = 'javax.swing.plaf.metal.MetalLookAndFeel';  % Makes buttons more consistent on mac
    javax.swing.UIManager.setLookAndFeel(newLnF);
end

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @braveheart_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @braveheart_gui_OutputFcn, ...
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


% --- Executes just before braveheart_gui is made visible.
function braveheart_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to braveheart_gui (see VARARGIN)

% Choose default command line output for braveheart_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Clear all axes
clear_axes(hObject,eventdata,handles);

% Supress warning about GUI
warning('off','MATLAB:hg:uicontrol:StringMustBeNonEmpty');

% Load BIDMC logo
axes(handles.logo_axis)
logo = imread ('logo_t.bmp'); 
imshow(logo);
    
% Disable update beat buttons
listbox_buttons_onoff('Off', hObject, eventdata, handles)

% Show tab1 (VCG) and hide other results tabs
set(handles.tab1,'visible','on')
set(handles.tab2,'visible','off')
set(handles.tab3,'visible','off')
set(handles.tab4,'visible','off')
set(handles.tab5,'visible','off')
    
% Load neural network for median beat annotation
load('MedianAnnoNet')
handles.MedianAnnoNet = MedianAnnoNet;
handles.meanTrain = meanTrain;
handles.stdTrain = stdTrain;
handles.standardizeFun = standardizeFun;
guidata(hObject, handles);  % Save to handles.
    
% Link face and vcg axes
hlink = linkprop([handles.vcg_axis, handles.face_axis],{'CameraPosition','CameraUpVector'});
handles.hlink = hlink;
guidata(hObject, handles);  % Save to handles.

% Load fiducial point presets from excel spreadsheed 'search_presets.csv'
% folder with the preset file will be in different location if running from .m file or from standalone .exe
% Add executable folder if running off shortcut
currentdir = getcurrentdir();

% Load fiducial point presets from csv 'search_presets.csv'
A = readcell(fullfile(currentdir,'search_presets.csv')); % read in data from .csv file
preset_names = A(2:size(A,1), 1);
preset_values = cell2mat(A(2:size(A,1), 2:size(A,2)));
set(handles.preset_fidpts, 'String', preset_names(1:length(preset_names(:,1)))); % load names of presets into dropdown

handles.preset_names =  preset_names(1:length(preset_names(:,1)));
handles.preset_values = preset_values;
guidata(hObject, handles);  % Save to handles.

% Load default Annoparams into GUI
aps = Annoparams();
push_guiparams(aps, hObject, eventdata, handles)

% Load ECG file format text presets from csv 'ecg_formats.csv'
A = read_format_csv(fullfile(currentdir,'ecg_formats.csv'));
handles.ecg_source_hash = A;
set(handles.ecg_source, 'String', A(:,1))
guidata(hObject, handles);  % Save to handles

% Load transformation matrix string presets from csv 'transform_mats.csv'
A = readcell(fullfile(currentdir,'transform_mats.csv'));
set(handles.transform_mat_dropdown, 'String', A);
guidata(hObject, handles);  % Save to handles

% Update GUI title bar/logo with version from AnnoResult
v = AnnoResult().version{1};
set(hObject, 'Name',sprintf('BRAVEHEART GUI v%s',v))
set(handles.version_txt,'String',sprintf('Version %s',v));

% Get current version of MATLAB to deal with graphics changes after R2025a
currentVersion = char(matlabRelease.Release);
currentVersion = str2double(currentVersion(2:5));

if currentVersion >= 2025
    % Fix GUI due to R2025 changes
    r2025_GUI(handles);
else
    % Adjust GUI appearance if on Mac and before R2025
    if ismac
        changeGUIfont(handles);
    end
end

% Show About Information regarding License etc 
% (automatically updates version number)
about_popup();

% UIWAIT makes braveheart_gui wait for user response (see UIRESUME)
% uiwait(handles.braveheart_gui);


% --- Outputs from this function are returned to the command line.
function varargout = braveheart_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function filename_txt_Callback(hObject, eventdata, handles)
% hObject    handle to filename_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filename_txt as text
%        str2double(get(hObject,'String')) returns contents of filename_txt as a double


% --- Executes during object creation, after setting all properties.
function filename_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filename_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_button.
function load_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Load button opens a file dialogue box and parses the filename
% appropriately.  It then calls reload_Callback which does all the actual
% ECG processing.  Once the filename is loaded in the file text box you do
% not have to use Load again unless you want to change the ECG file

% Open file dialog box
[filename_short, pathname] = uigetfile('*.*','Select ECG file');

if filename_short==0    % user pressed cancel
return
end

% pathname is the directory the file is in
% filename_short is the actual file name and extension
% filename is the  directory and filename/ext of ECG combined - displayed in GUI
filename = strcat(pathname, filename_short);

% Store filename and filename_short to handles for use in other callbacks
handles.filename = filename;               % Entire directory and file
handles.filename_short = filename_short;   % Just filename
handles.pathname = pathname;               % Just firectory
guidata(hObject, handles);                 % Save to handles.

% Set filename as the filename string in GUI
set(handles.filename_txt, 'String', filename); 
set(handles.save_dir_txt, 'String', pathname(1:end-1));

clear_axes(hObject, eventdata, handles);

% If 'Load Dir' checkbox checked will load directory file list
% Default to file 1/1
set(handles.file_num_txt,'String', '# 1 / 1');

if get(handles.load_dir_checkbox,'Value')

    % Load in all files from directory
    % Folder file stucture
    [~,~,ext] = fileparts(filename);

    file_list_struct = dir(fullfile(pathname, strcat('*',ext)));
    name_list_struct = {file_list_struct.name}';
    name_list_struct(ismember(name_list_struct, {'.', '..'})) = [];

    % Load ECGs from directory
    num_files = length(name_list_struct);
    file_list = cell(num_files, 1);
    for i = 1:num_files
        file_list{i} = char(fullfile(pathname,name_list_struct(i)));
    end

    % Want to alphebetize the file list so things are consistent over time
    file_list = sortrows(file_list);

    % file_list is now a column vector with cells for each filename of the
    % correct extension - note that some non ECG files may be in there too!

    % Need to find the index of the currently loaded ECG file
    ind = cellfun(@(s) ~isempty(strfind(filename, s)), file_list);
    ind = find(ind == 1);

    handles.file_index = ind;
    handles.file_list = file_list;
    guidata(hObject, handles);                 % Save to handles.

    % Update file number text box
    set(handles.file_num_txt,'String', sprintf('# %i / %i',ind,length(handles.file_list)));
    set(handles.file_num_txt,'FontSize', 8);
    if length(handles.file_list) <= 999
        set(handles.file_num_txt,'FontSize', 9);
    end
    if length(handles.file_list) >= 10000
        set(handles.file_num_txt,'FontSize', 7);
    end

    % Enable/disable prev/next ECG button based on index
    if handles.file_index == 1
        set(handles.load_prev_ecg_button,'Enable','off')
    else     
        set(handles.load_prev_ecg_button,'Enable','on')
    end

    if handles.file_index == length(handles.file_list)
        set(handles.load_next_ecg_button,'Enable','off')
    else     
        set(handles.load_next_ecg_button,'Enable','on')
    end

else
    % Disable next/prev file buttons if didn't load the list of files
    set(handles.load_prev_ecg_button,'Enable','off')
    set(handles.load_next_ecg_button,'Enable','off')     

    % Put single file in file_list since Reload uses this structure
    handles.file_index = 1;
    handles.file_list = char(fullfile(pathname,filename));
    guidata(hObject, handles);                 % Save to handles.
end

% Reload Callback
reload_Callback(hObject, eventdata, handles);
        


function freq_txt_Callback(hObject, eventdata, handles)
% hObject    handle to freq_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of freq_txt as text
%        str2double(get(hObject,'String')) returns contents of freq_txt as a double


% --- Executes during object creation, after setting all properties.
function freq_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freq_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function unitspermv_txt_Callback(hObject, eventdata, handles)
% hObject    handle to unitspermv_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of unitspermv_txt as text
%        str2double(get(hObject,'String')) returns contents of unitspermv_txt as a double


% --- Executes during object creation, after setting all properties.
function unitspermv_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to unitspermv_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function ecg_source_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ecg_source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ecg_source.
function ecg_source_Callback(hObject, eventdata, handles)
% hObject    handle to ecg_source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ecg_source contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ecg_source

% Update the expected frequency and filtering textboxies in GUI when change
% the ECG format dropdown

% Set ecg_string appropriately
strlist = get(handles.ecg_source, 'String');
handles.ecg_string = strlist{get(handles.ecg_source,'Value')};

% Obtain the format string (source_str) based on GUI dropbox
% source_str is passed into batch_calc/ECG12

[source_str, source_ext, source_freq] = ecg_source_string(handles.ecg_string,handles.ecg_source_hash);

handles.source_str = source_str;
handles.source_ext = source_ext;
guidata(hObject, handles);  % Save to handles.

% Default wavelet filtering levels based on format chosen
[~, wavelet_level_selection_val, wavelet_level_selection_lf_val] = ...
    ecg_source_gui(source_freq);

set(handles.wavelet_level_selection, 'Value', wavelet_level_selection_val);
set(handles.wavelet_level_selection_lf, 'Value', wavelet_level_selection_lf_val);


% --- Executes on button press in about_help_button.
function about_help_button_Callback(hObject, eventdata, handles)
% hObject    handle to about_help_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Load new custom popup
about_popup();


% --- Executes on button press in y_markers.
function y_markers_Callback(hObject, eventdata, handles)
% hObject    handle to y_markers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of y_markers


% --- Executes on button press in x_markers.
function x_markers_Callback(hObject, eventdata, handles)
% hObject    handle to x_markers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of x_markers


% --- Executes on button press in z_markers.
function z_markers_Callback(hObject, eventdata, handles)
% hObject    handle to z_markers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of z_markers


% --- Executes on button press in vm_markers.
function vm_markers_Callback(hObject, eventdata, handles)
% hObject    handle to vm_markers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of vm_markers


% --- Executes on button press in majorgrid_checkbox.
function majorgrid_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to majorgrid_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of majorgrid_checkbox


% --- Executes on button press in minorgrid_checkbox.
function minorgrid_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to minorgrid_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of minorgrid_checkbox


% --- Executes on button press in save_12lead_checkbox.
function save_12lead_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to save_12lead_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of save_12lead_checkbox

% --- Executes on button press in view_12lead_button.

% hObject    handle to view_12lead_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in view_12lead_button.
function view_12lead_button_Callback(hObject, eventdata, handles)
% hObject    handle to view_12lead_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ecg = handles.ecg;

filename = handles.filename_short;
save_folder = get(handles.save_dir_txt,'String');

grid_options = get(handles.grid_popup,'Value');

switch grid_options
    case 1
        minorgrid = 1;
        majorgrid = 1;
    case 2
        minorgrid = 0;
        majorgrid = 1;
    case 3
        minorgrid = 1;
        majorgrid = 0;
    case 4
        minorgrid = 0;
        majorgrid = 0;
end

% Get colors based on if in light/dark mode
[dm, dark_colors, light_colors] = check_darkmode(handles);

if dm == 1
    colors = dark_colors;
else
    colors = light_colors;
end

view_12lead_ecg(ecg, filename, save_folder, 0, 0, majorgrid, minorgrid, colors);



function qon_txt_Callback(hObject, eventdata, handles)
% hObject    handle to qon_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qon_txt as text
%        str2double(get(hObject,'String')) returns contents of qon_txt as a double


% --- Executes during object creation, after setting all properties.
function qon_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qon_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function qrs_txt_Callback(hObject, eventdata, handles)
% hObject    handle to qrs_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qrs_txt as text
%        str2double(get(hObject,'String')) returns contents of qrs_txt as a double


% --- Executes during object creation, after setting all properties.
function qrs_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qrs_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qoff_txt_Callback(hObject, eventdata, handles)
% hObject    handle to qoff_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qoff_txt as text
%        str2double(get(hObject,'String')) returns contents of qoff_txt as a double


% --- Executes during object creation, after setting all properties.
function qoff_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qoff_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tpeak_txt_Callback(hObject, eventdata, handles)
% hObject    handle to tpeak_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tpeak_txt as text
%        str2double(get(hObject,'String')) returns contents of tpeak_txt as a double


% --- Executes during object creation, after setting all properties.
function tpeak_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tpeak_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tend_txt_Callback(hObject, eventdata, handles)
% hObject    handle to tend_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tend_txt as text
%        str2double(get(hObject,'String')) returns contents of tend_txt as a double


% --- Executes during object creation, after setting all properties.
function tend_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tend_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxbpm_Callback(hObject, eventdata, handles)
% hObject    handle to maxbpm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxbpm as text
%        str2double(get(hObject,'String')) returns contents of maxbpm as a double


% --- Executes during object creation, after setting all properties.
function maxbpm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxbpm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rswidth_Callback(hObject, eventdata, handles)
% hObject    handle to rswidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rswidth as text
%        str2double(get(hObject,'String')) returns contents of rswidth as a double


% --- Executes during object creation, after setting all properties.
function rswidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rswidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ststart_Callback(hObject, eventdata, handles)
% hObject    handle to ststart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ststart as text
%        str2double(get(hObject,'String')) returns contents of ststart as a double


% --- Executes during object creation, after setting all properties.
function ststart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ststart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qrwidth_Callback(hObject, eventdata, handles)
% hObject    handle to qrwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qrwidth as text
%        str2double(get(hObject,'String')) returns contents of qrwidth as a double


% --- Executes during object creation, after setting all properties.
function qrwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qrwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function stend_Callback(hObject, eventdata, handles)
% hObject    handle to stend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stend as text
%        str2double(get(hObject,'String')) returns contents of stend as a double

% --- Executes during object creation, after setting all properties.


function stend_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in calculate.
function calculate_Callback(hObject, eventdata, handles)
% hObject    handle to calculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);  % load in handles variables

% Update success visibility
set(handles.success_txt,'Visible','Off')
    
% Clear the GUI values
clear_GEH_calculations_GUI(hObject, eventdata, handles);
clear_beat_listbox_GUI(hObject, eventdata, handles)

% Set filenames for output  
handles.csv_filename = handles.filename_short(1:end-4);

% Load VCG/ECG, QRS, and Annoparams
aps = pull_guiparams(hObject, eventdata, handles);  % Pull from GUI and update based on what is selected
handles.aps = aps;

% Load Qualparams
qps = Qualparams();

% To avoid endless outlier and PVC deletion issue due to more freedom with the GUI,
% need to NOT remomove outliers and PVCs via batch_calc, and instead call
% the PVC removal and outlier removal Callbacks that are part of the GUI.

% Save values for aps.pvc_removal and aps.outlier_removal
temp_pvc_removal = aps.pvc_removal;
temp_outlier_removal = aps.outlier_removal;

% Disable PVC and outlier removal for this run of batch_calc
aps.pvc_removal = 0;
aps.outlier_removal = 0;

if aps.debug
    figure(figure('name',' Annotation Fiducial Point Debug','numbertitle','off'));
    hold off;
    %plotind = min([15*handles.vcg.hz, 100000, length(handles.vcg.VM)]);
    plot(handles.vcg.VM, 'Color', '[ 0 0.8 0]');
    set(gcf, 'Position', [100, 800, 1400, 300])  % set figure size
    hold on;
end
 
% Run batch_calc
% This time dont recalc HR as this wont change
batchout = batch_calc(handles.ecg_raw, [], [], [], [], [], aps, qps, 0, "", []);

handles.beats = batchout.beats_final;
handles.quality = batchout.quality;
handles.correlation_test = batchout.correlation_test;
handles.median_vcg = batchout.medianvcg1;
handles.beatsig_vcg = batchout.beatsig_vcg;
handles.median_12L = batchout.median_12L;
handles.beatsig_12L = batchout.beatsig_12L;
handles.medianbeat = batchout.medianbeat;
handles.beat_stats = batchout.beat_stats;
handles.ecg_raw = batchout.ecg_raw;
handles.vcg_raw = batchout.vcg_raw;
handles.ecg = batchout.filtered_ecg;
handles.vcg = batchout.filtered_vcg;
handles.pacer_spikes = batchout.pacer_spikes;
handles.lead_ispaced = batchout.lead_ispaced;
handles.noise = batchout.noise;
handles.ecg_raw_postinterp = batchout.ecg_raw_postinterp;


% Get flags for processing different modules
vcg_calc_flag = get(handles.geh_option_checkbox,'Value');
lead_morph_flag = get(handles.lead_morphology_option_checkbox,'Value');
vcg_morph_flag = get(handles.vcg_morphology_option_checkbox,'Value');

% Create flags structure
flags = struct;
flags.vcg_calc_flag = vcg_calc_flag;
flags.lead_morph_flag = lead_morph_flag;
flags.vcg_morph_flag = vcg_morph_flag;


[handles.geh, handles.lead_morph, handles.vcg_morph] = module_output(handles.median_12L, handles.median_vcg, handles.medianbeat, aps, flags);


% Set PVC and outlier removal values back to what they were
% handles.aps is not affected by this.
aps.pvc_removal = temp_pvc_removal;
aps.outlier_removal = temp_outlier_removal;

% Update handles structure
guidata(hObject, handles);
    
% Finds outliers 
handles.beats = handles.beats.find_outliers(handles.vcg,aps);
guidata(hObject, handles);  % update handles
    
% Finds PVCs
handles.beats = handles.beats.find_pvcs(handles.vcg,handles.aps);
guidata(hObject, handles);  % update handles
  
% Runs calc_plot to update the GUI
calc_plot(handles.vcg, handles.beats, handles.aps, hObject, eventdata, handles);
guidata(hObject, handles);  % update handles

% disable rotation so can move lines to reannotate in selected beat viewer
    rotate3d off
       
% Excecute PVC removal automatically if checkbox clicked
if get(handles.auto_pvc_removal_checkbox, 'Value') == 1
    pvc_button_Callback(hObject, eventdata, handles);
    handles = guidata(hObject);
end

% Execute outlier removal automatically if checkbox clicked
if get(handles.auto_remove_outliers_checkbox, 'Value') == 1
     remove_outliers_button_Callback(hObject, eventdata, handles);
     handles = guidata(hObject);
end

    
% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Load default Annoparams 
aps = Annoparams();
    
% Push default Annoparams to update GUI dropdowns/checkboxes
push_guiparams(aps, hObject, eventdata, handles)

% Toggle fields that activate/deactivate based on checkboxes    
autocl_checkbox_Callback(hObject, eventdata, handles)

set(handles.preset_fidpts,'Value',1);
set(handles.ststart, 'Enable', 'on');
set(handles.stend, 'Enable', 'on');
set(handles.preset_fidpts, 'Enable', 'on');
set(handles.pacing_pkwidth_txt, 'Enable', 'on');
set(handles.pacing_thresh_txt, 'Enable', 'on');
set(handles.align_dropdown, 'Enable', 'on');
set(handles.tend_method_dropdown, 'Enable', 'on');
set(handles.autocl_checkbox, 'Enable', 'on');
% set(handles.cwt_pacing_remove_box, 'Enable', 'on');
% set(handles.spike_removal_old_checkbox, 'Enable', 'on');
% set(handles.all_auto_checkbox, 'Value', 1);
% set(handles.pacer_interpolation_button,'enable','on');
% set(handles.pacing_pkwidth_txt,'enable', 'on');
% set(handles.pacing_thresh_txt,'enable', 'on');
% set(handles.pacer_zpk_txtbox, 'enable', 'on');
% set(handles.pacer_zcut_txtbox, 'enable', 'on');
% set(handles.pacer_maxscale_txtbox, 'enable', 'on');
% set(handles.pacer_num_leads_txtbox, 'enable','on');

if aps.keep_pvc == 0
set(handles.pvc_button, 'String', 'Remove PVCs')
else
set(handles.pvc_button, 'String', 'Remove Native')
end

% Update handles structure
guidata(hObject, handles);

% Adjust spike removal fields being enabled or not
if get(handles.cwt_pacing_remove_box, 'Value') == 1
    set(handles.spike_removal_old_checkbox,'value',0);
    set(handles.pacer_interpolation_button,'enable','on');
    set(handles.pacing_pkwidth_txt,'enable', 'off');
    set(handles.pacing_thresh_txt,'enable', 'off');
    set(handles.pacer_zpk_txtbox, 'enable', 'on');
    set(handles.pacer_zcut_txtbox, 'enable', 'on');
    set(handles.pacer_maxscale_txtbox, 'enable', 'on');
    set(handles.pacer_num_leads_txtbox, 'enable','on');
else
    set(handles.pacer_interpolation_button,'enable','off');
    set(handles.pacing_pkwidth_txt,'enable', 'on');
    set(handles.pacing_thresh_txt,'enable', 'on');
    set(handles.pacer_zpk_txtbox, 'enable', 'off');
    set(handles.pacer_zcut_txtbox, 'enable', 'off');
    set(handles.pacer_maxscale_txtbox, 'enable', 'off');
    set(handles.pacer_num_leads_txtbox, 'enable','off');
end



% --- Executes on selection change in activebeats_list.
function activebeats_list_Callback(hObject, eventdata, handles)
% hObject    handle to activebeats_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns activebeats_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from activebeats_list


% Pulls the selected beat into the edit beat text box and then displays the 
% selected beat with current fiducial points

% Get colors based on if in light/dark mode
[dm, dark_colors, light_colors] = check_darkmode(handles);

if dm == 1
    colors = dark_colors;
else
    colors = light_colors;
end


handles = guidata(hObject);  % load handles variables

% Disable rotation so can move lines to reannotate in selected beat viewer
rotate3d off

vcg = handles.vcg;
beatsig_vcg = handles.beatsig_vcg;
beats = handles.beats;
aps = pull_guiparams(hObject, eventdata, handles); 

beatmatrix = beats.beatmatrix();

beatsigx = beatsig_vcg.X;
beatsigy = beatsig_vcg.Y;
beatsigz = beatsig_vcg.Z;
beatsigvm = beatsig_vcg.VM;

X = vcg.X;
Y = vcg.Y;
Z = vcg.Z;
VM = vcg.VM;

% Code to deal with green highlighting of beats:

% If a beat is already highlighted, delete the highlight to start
if handles.highlight_flag == 1 
    
   % Acitvates each of the 4 median beat axes and then deletes 
   % the handle/object for the highlighted beat 
   axes(handles.Xmedianbeat_axis)
   delete(handles.highlightx)

   axes(handles.Ymedianbeat_axis)
   delete(handles.highlighty)

   axes(handles.Zmedianbeat_axis)
   delete(handles.highlightz)

%    axes(handles.VMmedianbeat_axis)
%    delete(handles.highlightvm)

   % Acitvates each of the 4 median beat axes and then deletes 
   % the handle/object for the highlighted star marker 
   axes(handles.x_axis)
   delete(handles.beat_starx)

   axes(handles.y_axis)
   delete(handles.beat_stary)

   axes(handles.z_axis)
   delete(handles.beat_starz)

   axes(handles.vm_axis)
   delete(handles.beat_starvm)

   % Set highlight flag to 0
   handles.highlight_flag = 0;
end

% Converts numeric beatmatrix into a matrix of string values so can 
% import it into the listbox
str_matrix = num2str(beatmatrix);

% Get the index of the active beat
str_index = get(handles.activebeats_list,'Value');

% Moves the fiducial points of the selected beat into the selected beat
% text box
set(handles.edit_selectedbeat_textbox,'String',str_matrix(str_index,:))

% Obtain the fiducial points (Qon, Rpk, Qoff, Toff) for the selected beat
x1 = beatmatrix(str_index,1); %qon
rpeak = beatmatrix(str_index,2); %rpeak
x3 = beatmatrix(str_index,3); %qoff
x4 = beatmatrix(str_index,4); %toff

% Guesses for plotting if some data is missing to avoid errors
if isnan(x1); x1 = rpeak - aps.QRwidth*vcg.freq/1000; end
if isnan(x3); x3 = rpeak + aps.QRwidth*vcg.freq/1000; end
if isnan(x4)
    rravg = length(VM) / size(beatmatrix, 1);
    stend = aps.STend;
    st = rravg * stend/100;
    x4 = x3 + st;
end 

% Set Y axis limits based on the beat
y1 = min(VM(x1:x4))-0.1*(max(VM(x1:x4))-min(VM(x1:x4)));
y2 = max(VM(x1:x4))+0.1*(max(VM(x1:x4))-min(VM(x1:x4)));

% Clear selected beat axis
cla(handles.selectedbeat_axis) 

% Graph selected beat and fiducial points
axes(handles.selectedbeat_axis) 

plot(VM, 'color', colors.xyzecg)        % Plots entire VM signal - will re-window the beat later in function
set(gca,'YTick',[])
set(gca, 'color', colors.bgfigcolor);
set(gca, 'Xcolor', colors.txtcolor);
hold on

% Draw the fiducial point lines in the selected beat viewer
qon_line = line([x1 x1],[y2 y1], 'color', colors.vertlines,'linewidth',0.5, 'linestyle', '--'); %qon line
qoff_line = line([x3 x3],[y2 y1], 'color', colors.bluetxtcolor,'linewidth',0.5, 'linestyle', '--'); %qoff line
toff_line = line([x4 x4],[y2 y1], 'color', 'r','linewidth',0.5, 'linestyle', '--'); %toff line
rpeak_line = line([rpeak rpeak],[y2 y1], 'color', '[0 0.7 0]','linewidth',0.5, 'linestyle', '--'); %Rpeak line

% Make the lines draggable
draggable(qon_line,'h',[x1-50 x4+50],'endfcn',@update_drag_qon);
draggable(qoff_line,'h',[x1-50 x4+50],'endfcn',@update_drag_qoff);
draggable(toff_line,'h',[x1-50 x4+50],'endfcn',@update_drag_tend);
draggable(rpeak_line,'h',[x1-50 x4+50],'endfcn',@update_drag_rpeak);

% Pad 50 samples around qon/toff for the beat selected
xlim([x1-50 x4+50]) 
ylim([y1 y2])


% Now highlight the selected beat in the Full X, Y, Z, VM and median X, Y,
% Z, VM graphs

% Add green lead highlighting to median beat graphs 
axes(handles.Xmedianbeat_axis)
hold on
handles.highlightx = plot(beatsigx(str_index,:),'g', 'linewidth', 1.1');
hold off

axes(handles.Ymedianbeat_axis)
hold on
handles.highlighty = plot(beatsigy(str_index,:),'g', 'linewidth', 1.1');
hold off

axes(handles.Zmedianbeat_axis)
hold on
handles.highlightz = plot(beatsigz(str_index,:),'g', 'linewidth', 1.1');
hold off

% axes(handles.VMmedianbeat_axis)
% hold on
% handles.highlightvm = plot(beatsigvm(str_index,:),'g', 'linewidth', 1.1');
% hold off


% Add green star to X,Y,Z,VM axes (not median beats)
axes(handles.x_axis)
hold on
handles.beat_starx = plot(beatmatrix(str_index,2),X(beatmatrix(str_index,2)),'*','color','g','MarkerSize', 8);
hold off

axes(handles.y_axis)
hold on
handles.beat_stary = plot(beatmatrix(str_index,2),Y(beatmatrix(str_index,2)),'*','color','g','MarkerSize', 8);
hold off

axes(handles.z_axis)
hold on
handles.beat_starz = plot(beatmatrix(str_index,2),Z(beatmatrix(str_index,2)),'*','color','g','MarkerSize', 8);
hold off

axes(handles.vm_axis)
hold on
handles.beat_starvm = plot(beatmatrix(str_index,2),VM(beatmatrix(str_index,2)),'*','color','g','MarkerSize', 8);
hold off

% Activate flag noting highlighting is present
handles.highlight_flag = 1;

% Enable update select beat and other similar buttons
listbox_buttons_onoff('On', hObject, eventdata, handles)

guidata(hObject, handles);      % Updates handles



% Xcoord of Qon dragged lines
function new_line_xcoord = update_drag_qon(line)

drag_line_xdata = round(get(line,'XData'));
new_line_xcoord = drag_line_xdata(1);

hGui = findobj('Tag','BRAVEHEART_GUI');
 if ~isempty(hGui)
     handles = guidata(hGui);

 end

old_beat = str2num(get(handles.edit_selectedbeat_textbox,'String'));
old_beat(1) = new_line_xcoord;
set(handles.edit_selectedbeat_textbox,'String',num2str(old_beat));


% Xcoord of Qoff dragged lines
function new_line_xcoord = update_drag_qoff(line)

drag_line_xdata = round(get(line,'XData'));
new_line_xcoord = drag_line_xdata(1);

hGui = findobj('Tag','BRAVEHEART_GUI');
 if ~isempty(hGui)
     handles = guidata(hGui);

 end

old_beat = str2num(get(handles.edit_selectedbeat_textbox,'String'));
old_beat(3) = new_line_xcoord;
set(handles.edit_selectedbeat_textbox,'String',num2str(old_beat));



% Xcoord of Tend dragged lines
function new_line_xcoord = update_drag_tend(line)

drag_line_xdata = round(get(line,'XData'));
new_line_xcoord = drag_line_xdata(1);

hGui = findobj('Tag','BRAVEHEART_GUI');
 if ~isempty(hGui)
     handles = guidata(hGui);

 end

old_beat = str2num(get(handles.edit_selectedbeat_textbox,'String'));
old_beat(4) = new_line_xcoord;
set(handles.edit_selectedbeat_textbox,'String',num2str(old_beat));



% Xcoord of Rpeak dragged marker
function new_line_xcoord = update_drag_rpeak(line)

drag_line_xdata = round(get(line,'XData'));
new_line_xcoord = drag_line_xdata(2);

hGui = findobj('Tag','BRAVEHEART_GUI');
 if ~isempty(hGui)
     handles = guidata(hGui);

 end

old_beat = str2num(get(handles.edit_selectedbeat_textbox,'String'));
old_beat(2) = new_line_xcoord;
set(handles.edit_selectedbeat_textbox,'String',num2str(old_beat));



% --- Executes during object creation, after setting all properties.
function activebeats_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to activebeats_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in edit_selectbeat_button.
function edit_selectbeat_button_Callback(hObject, eventdata, handles)
% hObject    handle to edit_selectbeat_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in remove_selectbeat_button.
function remove_selectbeat_button_Callback(hObject, eventdata, handles)
% hObject    handle to remove_selectbeat_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Need to leave at least 1 beat to avoid errors
if length(handles.beats.Q) > 1
    
    % Disable update select beat and other similar buttons
    listbox_buttons_onoff('Off', hObject, eventdata, handles)

    delete_beat_GUI(hObject, eventdata, handles)
    handles = guidata(hObject);     % Take handles from the function and transfer to main program
    
    % Load VCG/ECG, QRS, and Annoparams
    aps = pull_guiparams(hObject, eventdata, handles);  % Pull from GUI and update based on what is selected
    handles.aps = aps;

    % Load Qualparams
    qps = Qualparams();

    % To avoid endless outlier and PVC deletion issue due to more freedom with the GUI,
    % need to NOT remomove outliers and PVCs via batch_calc, and instead call
    % the PVC removal and outlier removal Callbacks that are part of the GUI.

    % Save values for aps.pvc_removal and aps.outlier_removal
    temp_pvc_removal = aps.pvc_removal;
    temp_outlier_removal = aps.outlier_removal;

    % Disable PVC and outlier removal for this run of batch_calc
    aps.pvc_removal = 0;
    aps.outlier_removal = 0;

    batchout = batch_calc(handles.ecg_raw, handles.beats, [], [], [], [], aps, qps, 0, "", []);
   
    handles.beats = batchout.beats_final;
    handles.quality = batchout.quality;
    handles.correlation_test = batchout.correlation_test;
    handles.median_vcg = batchout.medianvcg1;
    handles.beatsig_vcg = batchout.beatsig_vcg;
    handles.median_12L = batchout.median_12L;
    handles.beatsig_12L = batchout.beatsig_12L;
    handles.medianbeat = batchout.medianbeat;
    handles.beat_stats = batchout.beat_stats;
    handles.noise = batchout.noise;
    
    % Get flags for processing different modules
    vcg_calc_flag = get(handles.geh_option_checkbox,'Value');
    lead_morph_flag = get(handles.lead_morphology_option_checkbox,'Value');
    vcg_morph_flag = get(handles.vcg_morphology_option_checkbox,'Value');
    
    % Create flags structure
    flags = struct;
    flags.vcg_calc_flag = vcg_calc_flag;
    flags.lead_morph_flag = lead_morph_flag;
    flags.vcg_morph_flag = vcg_morph_flag;
    
    
    [handles.geh, handles.lead_morph, handles.vcg_morph] = module_output(handles.median_12L, handles.median_vcg, handles.medianbeat, aps, flags);
        

    % Set PVC and outlier removal values back to what they were
    % handles.aps is not affected by this.
    aps.pvc_removal = temp_pvc_removal;
    aps.outlier_removal = temp_outlier_removal;    
        
    % Update handles structure
    guidata(hObject, handles);

    calc_plot(handles.vcg, handles.beats, handles.aps, hObject, eventdata, handles);
    guidata(hObject, handles);  % update handles

end

% disable rotation so can move lines to reannotate in selected beat viewer
rotate3d off


function edit_selectedbeat_textbox_Callback(hObject, eventdata, handles)
% hObject    handle to edit_selectedbeat_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_selectedbeat_textbox as text
%        str2double(get(hObject,'String')) returns contents of edit_selectedbeat_textbox as a double


% --- Executes during object creation, after setting all properties.
function edit_selectedbeat_textbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_selectedbeat_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in update_selectbeat_button.
function update_selectbeat_button_Callback(hObject, eventdata, handles)
% hObject    handle to update_selectbeat_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Disable update select beat and other similar buttons
listbox_buttons_onoff('Off', hObject, eventdata, handles)

update_select_beat_GUI(hObject, eventdata, handles)
handles = guidata(hObject);     % Take handles from the function and transfer to main program

% Load VCG/ECG, QRS, and Annoparams
aps = pull_guiparams(hObject, eventdata, handles);  % Pull from GUI and update based on what is selected
handles.aps = aps;

% Load Qualparams
qps = Qualparams();

% To avoid endless outlier and PVC deletion issue due to more freedom with the GUI,
% need to NOT remomove outliers and PVCs via batch_calc, and instead call
% the PVC removal and outlier removal Callbacks that are part of the GUI.

% Save values for aps.pvc_removal and aps.outlier_removal
temp_pvc_removal = aps.pvc_removal;
temp_outlier_removal = aps.outlier_removal;

% Disable PVC and outlier removal for this run of batch_calc
aps.pvc_removal = 0;
aps.outlier_removal = 0;

batchout = batch_calc(handles.ecg_raw, handles.beats, [], [], [], [], aps, qps, 0, "", []);

handles.beats = batchout.beats_final;
handles.quality = batchout.quality;
handles.correlation_test = batchout.correlation_test;
handles.median_vcg = batchout.medianvcg1;
handles.beatsig_vcg = batchout.beatsig_vcg;
handles.median_12L = batchout.median_12L;
handles.beatsig_12L = batchout.beatsig_12L;
handles.medianbeat = batchout.medianbeat;
handles.beat_stats = batchout.beat_stats;
handles.noise = batchout.noise;

% Get flags for processing different modules
vcg_calc_flag = get(handles.geh_option_checkbox,'Value');
lead_morph_flag = get(handles.lead_morphology_option_checkbox,'Value');
vcg_morph_flag = get(handles.vcg_morphology_option_checkbox,'Value');

% Create flags structure
flags = struct;
flags.vcg_calc_flag = vcg_calc_flag;
flags.lead_morph_flag = lead_morph_flag;
flags.vcg_morph_flag = vcg_morph_flag;


[handles.geh, handles.lead_morph, handles.vcg_morph] = module_output(handles.median_12L, handles.median_vcg, handles.medianbeat, aps, flags);


% Set PVC and outlier removal values back to what they were
% handles.aps is not affected by this.
aps.pvc_removal = temp_pvc_removal;
aps.outlier_removal = temp_outlier_removal;

% Update handles structure
guidata(hObject, handles);

calc_plot(handles.vcg, handles.beats, handles.aps, hObject, eventdata, handles);
guidata(hObject, handles);  % update handles

% Disable rotation so can move lines to reannotate in selected beat viewer  
 rotate3d off


% --- Executes on button press in add_newbeat_button.
function add_newbeat_button_Callback(hObject, eventdata, handles)
% hObject    handle to add_newbeat_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

add_beat_GUI(hObject, eventdata, handles)
handles = guidata(hObject);     % Take handles from the function and transfer to main program

% Load VCG/ECG, QRS, and Annoparams
aps = pull_guiparams(hObject, eventdata, handles);  % Pull from GUI and update based on what is selected
handles.aps = aps;

% Load Qualparams
qps = Qualparams();

% To avoid endless outlier and PVC deletion issue due to more freedom with the GUI,
% need to NOT remomove outliers and PVCs via batch_calc, and instead call
% the PVC removal and outlier removal Callbacks that are part of the GUI.

% Save values for aps.pvc_removal and aps.outlier_removal
temp_pvc_removal = aps.pvc_removal;
temp_outlier_removal = aps.outlier_removal;

% Disable PVC and outlier removal for this run of batch_calc
aps.pvc_removal = 0;
aps.outlier_removal = 0;

batchout = batch_calc(handles.ecg_raw, handles.beats, [], [], [], [], aps, qps, 0, "", []);

handles.beats = batchout.beats_final;
handles.quality = batchout.quality;
handles.correlation_test = batchout.correlation_test;
handles.median_vcg = batchout.medianvcg1;
handles.beatsig_vcg = batchout.beatsig_vcg;
handles.median_12L = batchout.median_12L;
handles.beatsig_12L = batchout.beatsig_12L;
handles.medianbeat = batchout.medianbeat;
handles.beat_stats = batchout.beat_stats;
handles.noise = batchout.noise;


% Get flags for processing different modules
vcg_calc_flag = get(handles.geh_option_checkbox,'Value');
lead_morph_flag = get(handles.lead_morphology_option_checkbox,'Value');
vcg_morph_flag = get(handles.vcg_morphology_option_checkbox,'Value');

% Create flags structure
flags = struct;
flags.vcg_calc_flag = vcg_calc_flag;
flags.lead_morph_flag = lead_morph_flag;
flags.vcg_morph_flag = vcg_morph_flag;


[handles.geh, handles.lead_morph, handles.vcg_morph] = module_output(handles.median_12L, handles.median_vcg, handles.medianbeat, aps, flags);


% Set PVC and outlier removal values back to what they were
% handles.aps is not affected by this.
aps.pvc_removal = temp_pvc_removal;
aps.outlier_removal = temp_outlier_removal;

% Update handles structure
guidata(hObject, handles);

calc_plot(handles.vcg, handles.beats, handles.aps, hObject, eventdata, handles);
guidata(hObject, handles);  % update handles

% disable rotation so can move lines to reannotate in selected beat viewer
rotate3d off
     
  

% --- Executes on button press in view_xyz_ecg.
function view_xyz_ecg_Callback(hObject, eventdata, handles)
% hObject    handle to view_xyz_ecg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vcg = handles.vcg;

filename = handles.filename_short;
save_folder = get(handles.save_dir_txt,'String');

grid_options = get(handles.grid_popup,'Value');

switch grid_options
    case 1
        minorgrid = 1;
        majorgrid = 1;
    case 2
        minorgrid = 0;
        majorgrid = 1;
    case 3
        minorgrid = 1;
        majorgrid = 0;
    case 4
        minorgrid = 0;
        majorgrid = 0;
end

% Get colors based on if in light/dark mode
[dm, dark_colors, light_colors] = check_darkmode(handles);

if dm == 1
    colors = dark_colors;
else
    colors = light_colors;
end

view_xyz_ecg(vcg, filename, save_folder, 0, 0, majorgrid, minorgrid, colors);


% --- Executes on button press in x_stats_button.
function x_stats_button_Callback(hObject, eventdata, handles)
% hObject    handle to x_stats_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[ ~, ~, ~, ~, ~, ~, ~] = xyz_stats(1, hObject, eventdata, handles);


% --- Executes on button press in y_stats_button.
function y_stats_button_Callback(hObject, eventdata, handles)
% hObject    handle to y_stats_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[ ~, ~, ~, ~, ~, ~, ~] = xyz_stats(2, hObject, eventdata, handles);


% --- Executes on button press in z_stats_button.
function z_stats_button_Callback(hObject, eventdata, handles)
% hObject    handle to z_stats_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[ ~, ~, ~, ~, ~, ~, ~]  = xyz_stats(3, hObject, eventdata, handles);


function excel_filename_Callback(hObject, eventdata, handles)
% hObject    handle to excel_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of excel_filename as text
%        str2double(get(hObject,'String')) returns contents of excel_filename as a double


% --- Executes during object creation, after setting all properties.
function excel_filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to excel_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function export_note_Callback(hObject, eventdata, handles)
% hObject    handle to export_note (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of export_note as text
%        str2double(get(hObject,'String')) returns contents of export_note as a double


% --- Executes during object creation, after setting all properties.
function export_note_CreateFcn(hObject, eventdata, handles)
% hObject    handle to export_note (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in wavelet_filter_box.
function wavelet_filter_box_Callback(hObject, eventdata, handles)
% hObject    handle to wavelet_filter_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of wavelet_filter_box

% Disable filtering dropdowns if filtering disabled
if get(hObject,'Value')
    set(handles.wavelet_type,'Enable','on');
    set(handles.wavelet_level_selection,'Enable','on');
else
    set(handles.wavelet_type,'Enable','off');
    set(handles.wavelet_level_selection,'Enable','off');  
end



% --- Executes on button press in noise_reduction_button.
function noise_reduction_button_Callback(hObject, eventdata, handles)
% hObject    handle to noise_reduction_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);  % load handles variables

ecg = handles.ecg;
ecg_raw = handles.ecg_raw;
aps = pull_guiparams(hObject, eventdata, handles);
filename = handles.filename;

noise_reduction_figure(ecg, ecg_raw, aps, filename, hObject, eventdata, handles)



% --- Executes on selection change in wavelet_level_selection.
function wavelet_level_selection_Callback(hObject, eventdata, handles)
% hObject    handle to wavelet_level_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns wavelet_level_selection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from wavelet_level_selection


% --- Executes during object creation, after setting all properties.
function wavelet_level_selection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wavelet_level_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in propagation_checkbox.
function propagation_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to propagation_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of propagation_checkbox


% --- Executes on button press in speed_checkbox.
function speed_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to speed_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of speed_checkbox


% --- Executes on button press in legend_checkbox.
function legend_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to legend_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of legend_checkbox


% --- Executes on button press in vector_checkbox.
function vector_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to vector_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of vector_checkbox


% --- Executes on button press in debug_anno.
function debug_anno_Callback(hObject, eventdata, handles)
% hObject    handle to debug_anno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of debug_anno


% --- Executes on button press in export_button.
function export_button_Callback(hObject, eventdata, handles)
% hObject    handle to export_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(handles.success_txt,'visible'),'off');
    
handles = guidata(hObject);
basename = handles.filename;
aps = pull_guiparams(hObject, eventdata, handles);
ecg = handles.ecg;
beats = handles.beats;
beat_stats = handles.beat_stats;
geh = handles.geh;
morph = handles.lead_morph;
vcg_morph = handles.vcg_morph;
source_str = handles.source_str;
corr = handles.correlation_test;
noise = handles.noise;
hr = handles.hr;
num_initial_beats = handles.num_initial_beats;
quality = handles.quality;
lead_ispaced = handles.lead_ispaced;

% Get file format (.csv vs .xlsx) from dropdown
fmt_val = get(handles.export_file_fmt_dropdown,'Value');
fmt_str = get(handles.export_file_fmt_dropdown,'String');
fmt = fmt_str(fmt_val);

% Add note to output
note = get(handles.export_note,'String');
if strcmp(note,"")
    note = '.';
end

i = 1;  % Deal with issue in how AnnoResult handles single ecgs outide of batch. HFS: don't change!
results{i} = AnnoResult(basename, note, source_str, aps, ecg, hr, num_initial_beats, beats, beat_stats, corr, noise, quality.prob_value, quality.missing_lead, lead_ispaced, geh, morph, vcg_morph);
	
save_folder = get(handles.save_dir_txt,'String');
filename = handles.filename;  % filename loaded

excelfilename_short = strcat(get(handles.excel_filename, 'String'),fmt);
excelfilename = fullfile(save_folder,excelfilename_short);

% Export to .xlsx
result = AnnoResult(results);
[h, a] = result.export_data();

% Append to existing file if file already exists
if isfile(excelfilename)
f = readcell(char(excelfilename),'DatetimeType', 'text');
missingind = cellfun(@(x) all(ismissing(x)), f); % took me a long time to figure that out!
f(missingind) = {''}; % you can't writecell() on a cell array with missing values; has to be empty array instead
f = [f ; a];
writecell(f,  char(excelfilename));    
set(handles.success_txt,'Visible','On')

else    
writecell( [h ; a], char(excelfilename));

set(handles.success_txt,'Visible','On')
    
end
end


function shift_box_Callback(hObject, eventdata, handles)
% hObject    handle to shift_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of shift_box as text
%        str2double(get(hObject,'String')) returns contents of shift_box as a double


% --- Executes during object creation, after setting all properties.
function shift_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shift_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in qon_shift_button.
function qon_shift_button_Callback(hObject, eventdata, handles)
% hObject    handle to qon_shift_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Now get shift before pass into shift_annotation and then shift_annotations_GUI    
shift = str2num(get(handles.shift_box,'String'));

% Need to pass in median VM signal to recalculate Tmax location if it changes
signal = handles.median_vcg.VM;

shift_annotations('Q', shift, signal, hObject, eventdata, handles)
%handles = guidata(hObject);  % load handles variables

   
% --- Executes on button press in qoff_shift_button.
function qoff_shift_button_Callback(hObject, eventdata, handles)
% hObject    handle to qoff_shift_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Now get shift before pass into shift_annotation and then shift_annotations_GUI    
shift = str2num(get(handles.shift_box,'String'));

% Need to pass in median VM signal to recalculate Tmax location if it changes
signal = handles.median_vcg.VM;

shift_annotations('S', shift, signal, hObject, eventdata, handles)
%handles = guidata(hObject);  % load handles variables


% --- Executes on button press in r_shift_button.
function r_shift_button_Callback(hObject, eventdata, handles)
% hObject    handle to r_shift_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in toff_shift_button.
function toff_shift_button_Callback(hObject, eventdata, handles)
% hObject    handle to toff_shift_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Now get shift before pass into shift_annotation and then shift_annotations_GUI    
shift = str2num(get(handles.shift_box,'String'));

% Need to pass in median VM signal to recalculate Tmax location if it changes
signal = handles.median_vcg.VM;

shift_annotations('Tend', shift, signal, hObject, eventdata, handles)
%handles = guidata(hObject);  % load handles variables

% --- Executes on button press in TendTangent.
function TendTangent_Callback(hObject, eventdata, handles)
% hObject    handle to TendTangent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TendTangent


% --- Executes on button press in TendBaseline.
function TendBaseline_Callback(hObject, eventdata, handles)
% hObject    handle to TendBaseline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TendBaseline


% --- Executes on button press in pop_out_vcg_button.
function pop_out_vcg_button_Callback(hObject, eventdata, handles)
% hObject    handle to pop_out_vcg_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

L = handles.vcg_axis;
h = figure('name','VCG','numbertitle','off');
copyobj([L legend(L)],h);
set(gca, 'Units', 'normalized', 'Position', [.1 .1 .7 .7] );
set(gcf, 'Position', [0, 0, 1000, 1000])  % set figure size

title(handles.filename_short(1:end-4),'fontsize',14,'Interpreter', 'none');
xlabel('X','FontWeight','bold','FontSize',14);
ylabel('Y','FontWeight','bold','FontSize',14);
zlabel('Z','FontWeight','bold','FontSize',14);

rotate3d on



% --- Executes on button press in rpeak_minus_button.
function qon_minus_button_Callback(hObject, eventdata, handles)
% hObject    handle to rpeak_minus_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);  % load handles variables

% If Median    
if get(handles.shift_median_checkbox, 'Value')

    % Now get shift before pass into shift_annotation and then shift_annotations_GUI    
    shift = -1;

    % Need to pass in median VM signal to recalculate Tmax location if it changes
    signal = handles.median_vcg.VM;

    shift_annotations('Q', shift, signal, hObject, eventdata, handles)

% Not Median
else

    edit_box = str2num(get(handles.edit_selectedbeat_textbox,'String'));
    
    if edit_box(1) > 1
        edit_box(1) = edit_box(1)-1;
    end
    
    set(handles.edit_selectedbeat_textbox,'String',num2str(edit_box));

end


% --- Executes on button press in qon_plus_button.
function qon_plus_button_Callback(hObject, eventdata, handles)
% hObject    handle to qon_plus_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);  % load handles variables

% If Median  
if get(handles.shift_median_checkbox, 'Value')

    % Now get shift before pass into shift_annotation and then shift_annotations_GUI    
    shift = 1;

    % Need to pass in median VM signal to recalculate Tmax location if it changes
    signal = handles.median_vcg.VM;

    shift_annotations('Q', shift, signal, hObject, eventdata, handles)

% Not Median    
else

    handles = guidata(hObject);  % load handles variables
    
    edit_box = str2num(get(handles.edit_selectedbeat_textbox,'String'));
    
    if edit_box(1) < length(handles.vcg.VM)
        edit_box(1) = edit_box(1)+1;
    end
    
    set(handles.edit_selectedbeat_textbox,'String',num2str(edit_box));

end

% --- Executes on button press in rpeak_plus_button.
function rpeak_plus_button_Callback(hObject, eventdata, handles)
% hObject    handle to rpeak_plus_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);  % load handles variables

edit_box = str2num(get(handles.edit_selectedbeat_textbox,'String'));

if edit_box(2) < length(handles.vcg.VM)
    edit_box(2) = edit_box(2)+1;
end

set(handles.edit_selectedbeat_textbox,'String',num2str(edit_box));


% --- Executes on button press in rpeak_plus_button.
function rpeak_minus_button_Callback(hObject, eventdata, handles)
% hObject    handle to rpeak_plus_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);  % load handles variables

edit_box = str2num(get(handles.edit_selectedbeat_textbox,'String'));

if edit_box(2) > 1
    edit_box(2) = edit_box(2)-1;
end

set(handles.edit_selectedbeat_textbox,'String',num2str(edit_box));



% --- Executes on button press in qoff_minus_button.
function qoff_minus_button_Callback(hObject, eventdata, handles)
% hObject    handle to qoff_minus_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);  % load handles variables

% If Median  
if get(handles.shift_median_checkbox, 'Value')

    % Now get shift before pass into shift_annotation and then shift_annotations_GUI    
    shift = -1;
    % Need to pass in median VM signal to recalculate Tmax location if it changes
    signal = handles.median_vcg.VM;

    shift_annotations('S', shift, signal, hObject, eventdata, handles)

% Not Median    
else

    edit_box = str2num(get(handles.edit_selectedbeat_textbox,'String'));
    
    if edit_box(3) > 1
        edit_box(3) = edit_box(3)-1;
    end
    
    set(handles.edit_selectedbeat_textbox,'String',num2str(edit_box));

end

% --- Executes on button press in qoff_plus_button.
function qoff_plus_button_Callback(hObject, eventdata, handles)
% hObject    handle to qoff_plus_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);  % load handles variables

% If Median  
if get(handles.shift_median_checkbox, 'Value')

    % Now get shift before pass into shift_annotation and then shift_annotations_GUI    
    shift = 1;

    % Need to pass in median VM signal to recalculate Tmax location if it changes
    signal = handles.median_vcg.VM;

    shift_annotations('S', shift, signal, hObject, eventdata, handles)

% Not Median    
else

    edit_box = str2num(get(handles.edit_selectedbeat_textbox,'String'));
    
    if edit_box(3) < length(handles.vcg.VM)
        edit_box(3) = edit_box(3)+1;
    end
    
    set(handles.edit_selectedbeat_textbox,'String',num2str(edit_box));

end

% --- Executes on button press in toff_minus_button.
function toff_minus_button_Callback(hObject, eventdata, handles)
% hObject    handle to toff_minus_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);  % load handles variables

% If Median  
if get(handles.shift_median_checkbox, 'Value')

    % Now get shift before pass into shift_annotation and then shift_annotations_GUI    
    shift = -1;
    % Need to pass in median VM signal to recalculate Tmax location if it changes
    signal = handles.median_vcg.VM;

    shift_annotations('Tend', shift, signal, hObject, eventdata, handles)

% Not Median    
else

    edit_box = str2num(get(handles.edit_selectedbeat_textbox,'String'));
    
    if edit_box(4) > 1
        edit_box(4) = edit_box(4)-1;
    end
    
    set(handles.edit_selectedbeat_textbox,'String',num2str(edit_box));

end


% --- Executes on button press in toff_plus_button.
function toff_plus_button_Callback(hObject, eventdata, handles)
% hObject    handle to toff_plus_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);  % load handles variables

% If Median  
if get(handles.shift_median_checkbox, 'Value')

    % Now get shift before pass into shift_annotation and then shift_annotations_GUI    
    shift = 1;

    % Need to pass in median VM signal to recalculate Tmax location if it changes
    signal = handles.median_vcg.VM;

    shift_annotations('Tend', shift, signal, hObject, eventdata, handles)

% Not Median    
else

    edit_box = str2num(get(handles.edit_selectedbeat_textbox,'String'));
    
    if edit_box(4) < length(handles.vcg.VM)
        edit_box(4) = edit_box(4)+1;
    end
    
    set(handles.edit_selectedbeat_textbox,'String',num2str(edit_box));

end

% --- Executes on button press in refresh_vcg_button.
function refresh_vcg_button_Callback(hObject, eventdata, handles)
% hObject    handle to refresh_vcg_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);  % load handles variables
geh = handles.geh;
median_vcg = handles.median_vcg;
medianbeat = handles.medianbeat;
aps = pull_guiparams(hObject, eventdata, handles);

plot_vcg_gui(geh, median_vcg, medianbeat, aps, hObject, eventdata, handles);
linkprop([handles.vcg_axis, handles.face_axis],'view');
linkprop([handles.vcg_axis, handles.face_axis],'CameraUpVector');


% --- Executes on button press in orientation_button.
function orientation_button_Callback(hObject, eventdata, handles)
% hObject    handle to orientation_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

open_ext_pdf('anglesfig.pdf', 'other');


% --- Executes on button press in frontal_view_button.
function frontal_view_button_Callback(hObject, eventdata, handles)
% hObject    handle to frontal_view_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

view(handles.vcg_axis, [0,-90]) % XY
%view(handles.face_axis,[0,-90]) % XY


% --- Executes on button press in trans_view_button.
function trans_view_button_Callback(hObject, eventdata, handles)
% hObject    handle to trans_view_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

view(handles.vcg_axis, [0,180]) % XZ
%view(handles.face_axis,[0,180]) % XZ



% --- Executes on button press in sag_view_button.
function sag_view_button_Callback(hObject, eventdata, handles)
% hObject    handle to sag_view_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.vcg_axis)
view(-270,0) % ZY
camroll(270)

% axes(handles.face_axis)
% view(-270,0) % ZY
% camroll(270)

% view(handles.vcg_axis, [-270,0]) % ZY
% camroll(270)
% view(handles.face_axis,[-270,0]) % ZY
% camroll(270)
% drawnow


% --- Executes on button press in axes_origin_checkbox.
function axes_origin_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to axes_origin_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of axes_origin_checkbox


% --- Executes on button press in view_ori_button.
function view_ori_button_Callback(hObject, eventdata, handles)
% hObject    handle to view_ori_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);  % load handles variables

% face_flag is 1 if face is showing, and 0 if not showing
face_flag = handles.face_flag;

face_figure(face_flag, hObject, eventdata, handles)
handles = guidata(hObject);     % Take handles from the function and transfer to main program to avoid bugs


    
% --- Executes on button press in orientation_fig_checkbox.
function orientation_fig_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to orientation_fig_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of orientation_fig_checkbox


% --- Executes on button press in full_vcg_button.
function full_vcg_button_Callback(hObject, eventdata, handles)
% hObject    handle to full_vcg_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Displays filtered VCG data without any beat removal (X,Y,Z leads)
vcg = handles.vcg;

figure('name','Raw VCG Data','numbertitle','off')

scatter3(vcg.X,vcg.Y,vcg.Z,10,'filled');
hold on
line(vcg.X,vcg.Y,vcg.Z)

xlabel('X','FontWeight','bold','FontSize',14);
ylabel('Y','FontWeight','bold','FontSize',14);
zlabel('Z','FontWeight','bold','FontSize',14);

title('Raw VCG Data');
set( gca, 'Units', 'normalized', 'Position', [.1 .1 .8 .8] );
set(gcf, 'Position', [200, 100, 900, 900])  % set figure size
%set (gca,'Zdir','reverse');
set (gca,'Ydir','reverse');



% --- Executes on mouse press over axes background.
function vcg_axis_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to vcg_axis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

linkprop([handles.vcg_axis, handles.face_axis],'view');
linkprop([handles.vcg_axis, handles.face_axis],'CameraUpVector');

function vcg_axis_DeleteFcn(hObject, eventdata, handles)
% try to fix that close program error



% --- Executes on button press in fid_param_help_button.
function fid_param_help_button_Callback(hObject, eventdata, handles)
% hObject    handle to fid_param_help_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

open_ext_pdf('braveheart_firstpass.pdf', 'other');


% --- Executes on button press in pushbutton46.
function pushbutton46_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in sqaxes_box.
function sqaxes_box_Callback(hObject, eventdata, handles)
% hObject    handle to sqaxes_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sqaxes_box


% --- Executes on button press in pvc_button.
function pvc_button_Callback(hObject, eventdata, handles)
% hObject    handle to pvc_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
pvc_rem = remove_pvcs_GUI(hObject, eventdata, handles);
handles = guidata(hObject);     % Take handles from the function and transfer to main program

% Need to prevent potential endless loop if new PVCs are detected after
% first run of PVC removal -> keeps removing new PVCs because batch_calc
% does its own PVC removal.  Can't just call batch_calc without
% remove_pvcs_GUI because of issues in terms of saving PVC locations for
% summary graph.  Therefore, to get around this potential loop, once the
% PVC has been dealt with with remove_pvcs_GUI, set aps.pvc_removal = 0,
% and at end of this function turn it back to whatever it was before

% Get Annoparam values as currently stored/checked off in GUI
aps = pull_guiparams(hObject, eventdata, handles);

% Load Qualparams
qps = Qualparams();

% Set pvc_removal = 0 for passing into batch_calc
aps.pvc_removal = 0;
aps.outlier_removal = 0;

if pvc_rem == 1         % Only update things if actually did outlier removal

batchout = batch_calc(handles.ecg_raw, handles.beats, [], [], [], [], aps, qps, 0, "", []);
    
handles.beats = batchout.beats_final;
handles.quality = batchout.quality;
handles.correlation_test = batchout.correlation_test;
handles.median_vcg = batchout.medianvcg1;
handles.beatsig_vcg = batchout.beatsig_vcg;
handles.median_12L = batchout.median_12L;
handles.beatsig_12L = batchout.beatsig_12L;
handles.medianbeat = batchout.medianbeat;
handles.beat_stats = batchout.beat_stats;
handles.noise = batchout.noise;

 % Get flags for processing different modules
vcg_calc_flag = get(handles.geh_option_checkbox,'Value');
lead_morph_flag = get(handles.lead_morphology_option_checkbox,'Value');
vcg_morph_flag = get(handles.vcg_morphology_option_checkbox,'Value');

% Create flags structure
flags = struct;
flags.vcg_calc_flag = vcg_calc_flag;
flags.lead_morph_flag = lead_morph_flag;
flags.vcg_morph_flag = vcg_morph_flag;


[handles.geh, handles.lead_morph, handles.vcg_morph] = module_output(handles.median_12L, handles.median_vcg, handles.medianbeat, aps, flags);


    % Update handles structure
    guidata(hObject, handles);

    calc_plot(handles.vcg, handles.beats, handles.aps, hObject, eventdata, handles);
    guidata(hObject, handles);  % update handles
end

% Dont need to set aps.pvc_removal back, because the value assigned to
% handles is not changed, and the variable aps only exists in this callback

% disable rotation curcor
rotate3d off


% --- Executes on button press in pushbutton48.
function pushbutton48_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton48 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function pvc_thresh_txt_Callback(hObject, eventdata, handles)
% hObject    handle to pvc_thresh_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pvc_thresh_txt as text
%        str2double(get(hObject,'String')) returns contents of pvc_thresh_txt as a double


% --- Executes during object creation, after setting all properties.
function pvc_thresh_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pvc_thresh_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in camera_button.
function camera_button_Callback(hObject, eventdata, handles)
% hObject    handle to camera_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.vcg_axis)
cameratoolbar('Toggle')


% --- Executes on button press in sync_orbit_button.
function sync_orbit_button_Callback(hObject, eventdata, handles)
% hObject    handle to sync_orbit_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 


% --- Executes on button press in save3dfig_button.
function save3dfig_button_Callback(hObject, eventdata, handles)
% hObject    handle to save3dfig_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


filename = handles.filename_short;
save_folder = get(handles.save_dir_txt,'String');
filename_short = strcat(filename(1:end-4),'_3dvcg.png');
full_filename = fullfile(save_folder,filename_short);
fig_filename = fullfile(save_folder,strcat(filename(1:end-4),'_3dvcg.fig'));

L = handles.vcg_axis;
h = figure('name','VCG','numbertitle','off');
copyobj([L legend(L)],h);
set(gca, 'Units', 'normalized', 'Position', [.1 .1 .7 .7] );
set(gcf, 'Position', [0, 0, 1000, 1000])  % set figure size

title(handles.filename_short(1:end-4),'fontsize',14,'Interpreter', 'none');
xlabel('X','FontWeight','bold','FontSize',14);
ylabel('Y','FontWeight','bold','FontSize',14);
zlabel('Z','FontWeight','bold','FontSize',14);

print(gcf,'-dpng',full_filename,'-r600');   

saveas(h, fig_filename,'fig');
close(h);



function save_dir_txt_Callback(hObject, eventdata, handles)
% hObject    handle to save_dir_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of save_dir_txt as text
%        str2double(get(hObject,'String')) returns contents of save_dir_txt as a double



% --- Executes during object creation, after setting all properties.
function save_dir_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_dir_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in select_export_dir_button.
function select_export_dir_button_Callback(hObject, eventdata, handles)
% hObject    handle to select_export_dir_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);
save_folder = uigetdir();

% Dont change if save_folder = 0 (pressed cancel)
if save_folder ~= 0
    handles.save_folder = save_folder;
    guidata(hObject, handles);
    set(handles.save_dir_txt,'String',save_folder);
end


function edit29_Callback(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit29 as text
%        str2double(get(hObject,'String')) returns contents of edit29 as a double


% --- Executes during object creation, after setting all properties.
function edit29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in export_csv_button.
function export_csv_button_Callback(hObject, eventdata, handles)
% hObject    handle to export_csv_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

csv_filename_short = strcat(handles.csv_filename,'.anno');
csv_filename = fullfile(get(handles.save_dir_txt,'String'),csv_filename_short);

% Load beats and Annoparams from handles.
    beats = handles.beats;
    aps = pull_guiparams(hObject, eventdata, handles);

% Save file
    if get(handles.fidpt_export_checkbox,'Value') == 1
        aps.to_file(beats,csv_filename);
    else
        aps.to_file(csv_filename);
    end


% --- Executes on button press in animate_vcg_button.
function animate_vcg_button_Callback(hObject, eventdata, handles)
% hObject    handle to animate_vcg_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);  % load handles variables
median_vcg = handles.median_vcg;
aps = pull_guiparams(hObject, eventdata, handles); 
origin_flag = aps.origin_flag;

medianX = median_vcg.X;
medianY = median_vcg.Y;
medianZ = median_vcg.Z;

axes_flag = get(handles.sqaxes_box,'Value');
step = str2num(get(handles.step_txt, 'String'));

save_anim_flag = 0;

filename = handles.filename_short;
save_folder = get(handles.save_dir_txt,'String');
filename_short = strcat(filename(1:end-4),'_movie.mov');
animfig_filename_full = fullfile(save_folder,filename_short);

title_filename = handles.filename_short;

plot_animated_VCG(medianX, medianY, medianZ, axes_flag, step, save_anim_flag, animfig_filename_full, title_filename, origin_flag);



function step_txt_Callback(hObject, eventdata, handles)
% hObject    handle to step_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of step_txt as text
%        str2double(get(hObject,'String')) returns contents of step_txt as a double


% --- Executes during object creation, after setting all properties.
function step_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to step_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in median_filter_box.
function median_filter_box_Callback(hObject, eventdata, handles)
% hObject    handle to median_filter_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of median_filter_box


% --- Executes on button press in median_offset_measure.
function median_offset_measure_Callback(hObject, eventdata, handles)
% hObject    handle to median_offset_measure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'aps')
    handles.aps = Annoparams();
    handles.aps = pull_guiparams(hObject, eventdata, handles); 
    guidata(hObject, handles);  % update handles
end

median_offset_measure_GUI(hObject, eventdata, handles, handles.aps)


% --- Executes on button press in import_fidpts_button.
function import_fidpts_button_Callback(hObject, eventdata, handles)
% hObject    handle to import_fidpts_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Fix issue with highlighting caused by reanno median
handles.median_anno_press_flag = 0;    

% Update success visibility
set(handles.success_txt,'Visible','Off')

% Clear the GUI values/result labels
clear_GEH_calculations_GUI(hObject, eventdata, handles);
clear_beat_listbox_GUI(hObject, eventdata, handles)

% Initialize flag for drawing highlted beats on median plots        
handles.highlight_flag = 0;  

% Initialize face flag for VCG face 
face_flag = 0;
handles.face_flag = face_flag;
guidata(hObject, handles);  % update handles

% Load file
[csvfilename_short, csvpathname] = uigetfile('*.anno','Select .anno file');

if csvfilename_short==0
    % user pressed cancel
return
end

filename = strcat(csvpathname, csvfilename_short);

% Load Annoparams +/- fiducial points from .csv file
[aps, beats] = Annoparams(filename);

% Load Qualparams
qps = Qualparams();

% If aps.wavelet_level_highpass is > max level, will throw an error
% This code will add explanation to GUI given error handeling is within
% ECG12.m independent of GUI
if aps.wavelet_level_highpass > floor(log2(length(handles.ecg_raw.I)))
     set(handles.lf_fmin_txt,'String','Error - wavelet level > max');
end
    
% Since beats are already manually set, don't need PVC/outlier removal    
aps.outlier_removal = 0;
aps.pvc_removal = 0;
handles.aps = aps;
set(handles.all_auto_checkbox,'Value',0);

% Update handles structure
guidata(hObject, handles);
      
if isempty(beats)  
    % If no beats there are no beats to import, 
    % so update annoparams and break out of function
    % Push Annoparams to update GUI dropdowns/checkboxes
    push_guiparams(aps, hObject, eventdata, handles)
    return; 
end    

% Push Annoparams to update GUI dropdowns/checkboxes
push_guiparams(aps, hObject, eventdata, handles)

% Update beats and beatmatrix into handles based on the imported data    
handles.beats = beats;
beatmatrix = beats.beatmatrix();
handles.beatmatrix = beatmatrix;
guidata(hObject,handles);  % update handles

% Calculate using batch_calc and overbeats
batchout = batch_calc(handles.ecg_raw, beats, [], [], [], [], aps, qps, 0, "", []);

handles.beats = batchout.beats_final;
handles.quality = batchout.quality;
handles.correlation_test = batchout.correlation_test;
handles.median_vcg = batchout.medianvcg1;
handles.beatsig_vcg = batchout.beatsig_vcg;
handles.median_12L = batchout.median_12L;
handles.beatsig_12L = batchout.beatsig_12L;
handles.medianbeat = batchout.medianbeat;
handles.beat_stats = batchout.beat_stats;
handles.ecg_raw = batchout.ecg_raw;
handles.vcg_raw = batchout.vcg_raw;
handles.ecg = batchout.filtered_ecg;
handles.vcg = batchout.filtered_vcg;
handles.pacer_spikes = batchout.pacer_spikes;
handles.lead_ispaced = batchout.lead_ispaced;
handles.noise = batchout.noise;
handles.ecg_raw_postinterp = batchout.ecg_raw_postinterp;


% Get flags for processing different modules
vcg_calc_flag = get(handles.geh_option_checkbox,'Value');
lead_morph_flag = get(handles.lead_morphology_option_checkbox,'Value');
vcg_morph_flag = get(handles.vcg_morphology_option_checkbox,'Value');

% Create flags structure
flags = struct;
flags.vcg_calc_flag = vcg_calc_flag;
flags.lead_morph_flag = lead_morph_flag;
flags.vcg_morph_flag = vcg_morph_flag;


[handles.geh, handles.lead_morph, handles.vcg_morph] = module_output(handles.median_12L, handles.median_vcg, handles.medianbeat, aps, flags);


% Update handles structure
guidata(hObject, handles);

% Runs calc_plot to update the GUI
calc_plot(handles.vcg, handles.beats, handles.aps, hObject, eventdata, handles);
guidata(hObject, handles);  % update handles

% disable rotation so can move lines to reannotate in selected beat viewer
 rotate3d off
   


% --- Executes on button press in tab1_button.
function tab1_button_Callback(hObject, eventdata, handles)
% hObject    handle to tab1_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.tab1,'visible','on')
set(handles.tab2,'visible','off')
set(handles.tab3,'visible','off')
set(handles.tab4,'visible','off')
set(handles.tab5,'visible','off')


% --- Executes on button press in tab2_button.
function tab2_button_Callback(hObject, eventdata, handles)
% hObject    handle to tab2_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


calc_tab_pos = getpixelposition(handles.tab1);

setpixelposition(handles.tab2,calc_tab_pos);
set(handles.tab1,'visible','off');
set(handles.tab2,'visible','on');
set(handles.tab3,'visible','off');
set(handles.tab4,'visible','off');
set(handles.tab5,'visible','off')

% --- Executes on button press in pushbutton65.
function pushbutton65_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton65 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in speed_graph_button.
function speed_graph_button_Callback(hObject, eventdata, handles)
% hObject    handle to speed_graph_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% clear speed_axis
cla(handles.speed_axis);

% Get colors based on if in light/dark mode
[dm, dark_colors, light_colors] = check_darkmode(handles);

if dm == 1
    colors = dark_colors;
else
    colors = light_colors;
end

save_flag = get(handles.save_speedfig_checkbox,'Value');
accel_flag = get(handles.accel_box,'Value');
legend_flag = get(handles.speed_legend_checkbox,'Value');

filename = handles.filename_short;
save_folder = get(handles.save_dir_txt,'String');
filename_short = strcat(filename(1:end-4),'_speed.png');
speed_filename = fullfile(save_folder,filename_short);

popout = 0;

speed_graph_gui(hObject, eventdata, handles, speed_filename, save_flag, 0, str2num(get(handles.speed_blank_txt, 'String')), ...
    str2num(get(handles.speed_t_blank_txt, 'String')), accel_flag, legend_flag, colors, popout);


% --- Executes on button press in tab3_button.
function tab3_button_Callback(hObject, eventdata, handles)
% hObject    handle to tab3_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

calc_tab_pos = getpixelposition(handles.tab1);

setpixelposition(handles.tab3,calc_tab_pos);
set(handles.tab1,'visible','off')
set(handles.tab2,'visible','off')
set(handles.tab3,'visible','on')
set(handles.tab4,'visible','off')
set(handles.tab5,'visible','off')



% --- Executes on button press in tab4_button.
function tab4_button_Callback(hObject, eventdata, handles)
% hObject    handle to tab4_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

calc_tab_pos = getpixelposition(handles.tab1);

setpixelposition(handles.tab4,calc_tab_pos);
set(handles.tab1,'visible','off')
set(handles.tab2,'visible','off')
set(handles.tab3,'visible','off')
set(handles.tab4,'visible','on')
set(handles.tab5,'visible','off')


% --- Executes on button press in tab5_button.
function tab5_button_Callback(hObject, eventdata, handles)
% hObject    handle to tab5_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

calc_tab_pos = getpixelposition(handles.tab1);

setpixelposition(handles.tab5,calc_tab_pos);
set(handles.tab1,'visible','off')
set(handles.tab2,'visible','off')
set(handles.tab3,'visible','off')
set(handles.tab4,'visible','off')
set(handles.tab5,'visible','on')



% --- Executes on button press in save_speedfig_checkbox.
function save_speedfig_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to save_speedfig_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of save_speedfig_checkbox


% --- Executes on button press in custom_dcm_checkbox.
function custom_dcm_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to custom_dcm_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of custom_dcm_checkbox



function v2_mag_txt_Callback(hObject, eventdata, handles)
% hObject    handle to v2_mag_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of v2_mag_txt as text
%        str2double(get(hObject,'String')) returns contents of v2_mag_txt as a double


% --- Executes during object creation, after setting all properties.
function v2_mag_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to v2_mag_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function v2_az_txt_Callback(hObject, eventdata, handles)
% hObject    handle to v2_az_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of v2_az_txt as text
%        str2double(get(hObject,'String')) returns contents of v2_az_txt as a double


% --- Executes during object creation, after setting all properties.
function v2_az_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to v2_az_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function v2_el_txt_Callback(hObject, eventdata, handles)
% hObject    handle to v2_el_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of v2_el_txt as text
%        str2double(get(hObject,'String')) returns contents of v2_el_txt as a double


% --- Executes during object creation, after setting all properties.
function v2_el_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to v2_el_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function v1_mag_txt_Callback(hObject, eventdata, handles)
% hObject    handle to v1_mag_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of v1_mag_txt as text
%        str2double(get(hObject,'String')) returns contents of v1_mag_txt as a double


% --- Executes during object creation, after setting all properties.
function v1_mag_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to v1_mag_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function v1_az_txt_Callback(hObject, eventdata, handles)
% hObject    handle to v1_az_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of v1_az_txt as text
%        str2double(get(hObject,'String')) returns contents of v1_az_txt as a double


% --- Executes during object creation, after setting all properties.
function v1_az_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to v1_az_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function v1_el_txt_Callback(hObject, eventdata, handles)
% hObject    handle to v1_el_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of v1_el_txt as text
%        str2double(get(hObject,'String')) returns contents of v1_el_txt as a double


% --- Executes during object creation, after setting all properties.
function v1_el_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to v1_el_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in wavelet_type.
function wavelet_type_Callback(hObject, eventdata, handles)
% hObject    handle to wavelet_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns wavelet_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from wavelet_type


% --- Executes during object creation, after setting all properties.
function wavelet_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wavelet_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when braveheart_gui is resized.
function BRAVEHEART_GUI_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to braveheart_gui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function age_txt_Callback(hObject, eventdata, handles)
% hObject    handle to age_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of age_txt as text
%        str2double(get(hObject,'String')) returns contents of age_txt as a double


% --- Executes during object creation, after setting all properties.
function age_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to age_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton77.
function pushbutton77_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton77 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

open_ext_pdf('braveheart_userguide.pdf', 'userguide');


% --- Executes on selection change in preset_fidpts.
function preset_fidpts_Callback(hObject, eventdata, handles)
% hObject    handle to preset_fidpts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns preset_fidpts contents as cell array
%        contents{get(hObject,'Value')} returns selected item from preset_fidpts


pr_num = get(handles.preset_fidpts,'Value'); % get which preset is selected in dropdown
preset_values =  handles.preset_values; % load in preset values

% fractions of RR-interval
set(handles.stend, 'String', preset_values(pr_num,6));
set(handles.ststart, 'String', preset_values(pr_num,5));
set(handles.rswidth, 'String', preset_values(pr_num,4));
set(handles.qrwidth, 'String', preset_values(pr_num,3));
set(handles.maxbpm, 'String', preset_values(pr_num,2));
set(handles.pkthresh, 'String', preset_values(pr_num,1));

% Update handles structure
guidata(hObject, handles);
   


% --- Executes during object creation, after setting all properties.
function preset_fidpts_CreateFcn(hObject, eventdata, handles)
% hObject    handle to preset_fidpts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in equation_button.
function equation_button_Callback(hObject, eventdata, handles)
% hObject    handle to equation_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

open_ext_pdf('braveheart_equations.pdf', 'other');


% --- Executes on button press in wavelet_filter_box_lf.
function wavelet_filter_box_lf_Callback(hObject, eventdata, handles)
% hObject    handle to wavelet_filter_box_lf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of wavelet_filter_box_lf

% Disable filtering dropdowns if filtering disabled
if get(hObject,'Value')
    set(handles.wavelet_type_lf,'Enable','on');
    set(handles.wavelet_level_selection_lf,'Enable','on');
else
    set(handles.wavelet_type_lf,'Enable','off');
    set(handles.wavelet_level_selection_lf,'Enable','off');  
end



% --- Executes on selection change in wavelet_level_selection_lf.
function wavelet_level_selection_lf_Callback(hObject, eventdata, handles)
% hObject    handle to wavelet_level_selection_lf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns wavelet_level_selection_lf contents as cell array
%        contents{get(hObject,'Value')} returns selected item from wavelet_level_selection_lf



% --- Executes during object creation, after setting all properties.
function wavelet_level_selection_lf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wavelet_level_selection_lf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in wavelet_type_lf.
function wavelet_type_lf_Callback(hObject, eventdata, handles)
% hObject    handle to wavelet_type_lf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns wavelet_type_lf contents as cell array
%        contents{get(hObject,'Value')} returns selected item from wavelet_type_lf


% --- Executes during object creation, after setting all properties.
function wavelet_type_lf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wavelet_type_lf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function logo_axis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to logo_axis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate logo_axis


% --- Executes on button press in export_medianbeat_waveform_button.
function export_medianbeat_waveform_button_Callback(hObject, eventdata, handles)
% hObject    handle to export_medianbeat_waveform_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Save median signals and median fiducial points
save_folder = get(handles.save_dir_txt,'String');
mb_export_file_mat = strcat(handles.filename_short(1:end-4),'_medians.mat');
mb_export_file_csv = strcat(handles.filename_short(1:end-4),'_medians.csv');

medians = struct('vm',handles.median_vcg.VM, 'x',handles.median_vcg.X, 'y',handles.median_vcg.Y, 'z',handles.median_vcg.Z, ...
    'I',handles.median_12L.I, 'II',handles.median_12L.II, 'III',handles.median_12L.III,...
    'avR',handles.median_12L.avR, 'avF',handles.median_12L.avF, 'avL',handles.median_12L.avL,...
    'V1',handles.median_12L.V1, 'V2',handles.median_12L.V2, 'V3',handles.median_12L.V3,...
    'V4',handles.median_12L.V4, 'V5',handles.median_12L.V5, 'V6',handles.median_12L.V6,...
    'Q', handles.medianbeat.Q, 'S', handles.medianbeat.S, 'Tend', handles.medianbeat.Tend);

median12L_csv = [handles.median_12L.I handles.median_12L.II handles.median_12L.III ...
    handles.median_12L.avR handles.median_12L.avF handles.median_12L.avL ...
    handles.median_12L.V1 handles.median_12L.V2 handles.median_12L.V3 ...
    handles.median_12L.V4 handles.median_12L.V5 handles.median_12L.V6 ...
    handles.median_vcg.X handles.median_vcg.Y handles.median_vcg.Z handles.median_vcg.VM];

save(fullfile(save_folder,mb_export_file_mat),'medians');
csvwrite(fullfile(save_folder,mb_export_file_csv), median12L_csv); 


% --- Executes on button press in export_xyz_waveform_button.
function export_xyz_waveform_button_Callback(hObject, eventdata, handles)
% hObject    handle to export_xyz_waveform_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

save_folder = get(handles.save_dir_txt,'String');
vcg = handles.vcg;

xyz_beats_export_matfilename = fullfile(save_folder,strcat(handles.filename_short(1:end-4), '_xyz_beats.mat'));
xyz_beats_export_csvfilename = fullfile(save_folder,strcat(handles.filename_short(1:end-4), '_xyz_beats.csv'));

xyz_beats = [vcg.X vcg.Y vcg.Z vcg.VM];

save(xyz_beats_export_matfilename, 'xyz_beats');
csvwrite(xyz_beats_export_csvfilename, xyz_beats); 



function pkthresh_Callback(hObject, eventdata, handles)
% hObject    handle to pkthresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pkthresh as text
%        str2double(get(hObject,'String')) returns contents of pkthresh as a double


% --- Executes during object creation, after setting all properties.
function pkthresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pkthresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in reload.
function reload_Callback(hObject, eventdata, handles)
% hObject    handle to reload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% load frequency from txt box in GUI and store in handles

% Don't do anything if there is no previously loaded file
if ~isempty(get(handles.filename_txt, 'String'))

% Clear axes
clear_axes(hObject, eventdata, handles);
    
% Take the file from the filename_txt textbox -- allows manual editing 
filename = get(handles.filename_txt, 'String');

% Store filename and filename_short to handles for use in other callbacks
handles.filename = filename;               % Entire directory and file
[pathname, fname,ext] = fileparts(filename);

handles.pathname = strcat(pathname,'\');
handles.filename_short = strcat(fname,ext);

guidata(hObject, handles);                 % Save to handles.

% Update directory text in GUI if needed
set(handles.save_dir_txt, 'String', handles.pathname(1:end-1));
    

% Have option for 'Safe Mode' to simply filter the ECG and then allow you
% to look at it - helpful if there are errors on loading.  'Safe Mode' will
% not calculate anything - just allows ECG visualization
safemode = get(handles.safemode_checkbox,'Value');    
    

% Start diary for logging and remove old error log if exists
diary off
if get(handles.errorlog_checkbox, 'Value')
    
    diaryfile = fullfile(getcurrentdir(),strcat('braveheart_error_log_', ...
        datestr(now,'mm-dd-yyyy','local'),'_',datestr(now,'hhMMss','local'),'.txt'));
      
    % OS
    os = computer;
    
    % Pull AnnoParams so have them in error log
    A = pull_guiparams(hObject, eventdata, handles);
    Afn = fieldnames(A);

    % Write filename and date/time to diary
    fid = fopen(diaryfile, 'wt', 'native', 'UTF-8');
    if fid ~= -1
        fprintf(fid, 'FILE: %s \n', get(handles.filename_txt, 'String'));
        fprintf(fid, 'DATE/TIME: %s_%s \n', datestr(now,'mm-dd-yyyy','local'),datestr(now,'hh:MM:ss','local'));
        fprintf(fid, 'OPERATING SYSTEM: %s \n\n', os);
        fprintf(fid, 'AnnoParams: \n', os);
        
        for i = 1:length(Afn)
            fprintf(fid, '%s  %s \n', Afn{i}, string(A.(Afn{i})));
        end
           
        fprintf(fid, '\n\n', os);
        fclose(fid);
    else
        error('Cannot create error log file');
    end
    
    diary(diaryfile)
    diary on 
end
 

% Deep clean handles on reload, but leave UI and NNet elements.  Values
% should be overwritten as the ECG is processed, but if some error occurs
% this makes sure that handles is in its original state (UI elements only)
% once you reload an ECG.  
reset_handles(hObject, eventdata, handles);
handles = guidata(hObject);     % Take handles from the function and transfer to main program to avoid bugs

% Fix issue with highlighting caused by reanno median
handles.median_anno_press_flag = 0;            
    
% Set ecg_string appropriately
strlist = get(handles.ecg_source, 'String');
handles.ecg_string = strlist{get(handles.ecg_source,'Value')};

% Obtain the format string (source_str) based on GUI dropbox
% source_str is passed into batch_calc/ECG12

[source_str, source_ext, ~] = ecg_source_string(handles.ecg_string,handles.ecg_source_hash);
handles.source_str = source_str;
handles.source_ext = source_ext;
guidata(hObject, handles);  % Save to handles.

% Obtain age/sex/race from xml if available
% If age/sex/race cannot be found in the xml
% Versions prior to 1.2.1 would set missing age = 50 and missing race =
% white, but since version 1.2.1 only include demographic data that is
% present.  If data is missing display as missing, and normal calculations
% will use the margins assuming the missing data is the mean from the
% normals manuscript.  see https://onlinelibrary.wiley.com/doi/10.1111/jce.16062
% BMI was basically never found in any of the XML files we reviewed, so
% will not abstract it and if missing will assume it is the population mean
% for calculations as noted above.  Can manually add BMI to the GUI textbox
% to get more accurate normal ranges.
M = xml_demographics(handles.filename, handles.source_str);
age = M.Age;
sex = M.Sex;
race = M.Race;

% Update GUI utilities values
set(handles.age_txt, 'String', age);

% Sex
if strcmpi(sex, 'f') || strcmpi(sex, 'female')
    set(handles.gender_dropdown, 'Value', 1);
elseif strcmpi(sex, 'm') || strcmpi(sex, 'male')
    set(handles.gender_dropdown, 'Value', 2); 
elseif strcmp(sex, 'N/A')
    set(handles.gender_dropdown, 'Value', 4);
else
    % Not listed as male or female but not missing
    % We did not have enough non-binary patients to include in normal value
    % regression, so list as "O" in dropdown and will assume gender is
    % missing for normal value regression calculations as noted above
    set(handles.gender_dropdown, 'Value', 3)
end

% Race
if strcmpi(race, "white") || strcmpi(race, "caucasian")
    set(handles.race_dropdown, 'Value', 1);
elseif strcmp(race, 'N/A') || strcmpi(race, "unknown") || strcmpi(race, "unk") ...
        || strcmpi(race, "u") || strcmpi(race, "undefined") || strcmpi(race, "und")
    % Unknown
    set(handles.race_dropdown, 'Value', 3);
else
    set(handles.race_dropdown, 'Value', 2);
end

% Does not support BMI yet -- can add in future but most ECGs dont have BMI
% recorded in metadata 
    set(handles.bmi_txt, 'String', 'N/A');

guidata(hObject, handles);  % Save to handles.
    
% Clear the GUI values/result labels
clear_GEH_calculations_GUI(hObject, eventdata, handles);
clear_beat_listbox_GUI(hObject, eventdata, handles)

% Initialize flag for drawing highlted beats on median plots        
handles.highlight_flag = 0;  

% Initialize face flag for VCG face 
face_flag = 0;
handles.face_flag = face_flag;
guidata(hObject, handles);  % update handles

% Generate Annoparams Class with default values and then pull values from
% GUI based on what options are checked
aps = Annoparams();
aps = pull_guiparams(hObject, eventdata, handles); 

% Load Qualparams
qps = Qualparams();

% If loading with safemode = 1, drop pkthresh down to 10% to avoid missing
% peaks if get a big noise spike and disable interpolation
if safemode  
    aps.pkthresh = 10;  
    aps.interpolate = 0;
    aps.spike_removal = 0;
    aps.cwt_spike_removal = 0;
end

    
% Set outlier and PVC removal flags using Annoparams class (will be set
% back to 1 later if wanted -- need to keep outliers and PVCs in for
% accurate HR calculation on first pass annotation
aps.outlier_removal = 0;
aps.pvc_removal = 0;
aps.debug = 0;
  
% Loads ECG by calling ECG12 class
filename = handles.filename;
source_str = handles.source_str;

ecg_raw = ECG12(filename, source_str);      % Loads raw data
handles.ecg_raw = ecg_raw;
          
% Extract frequency and sample_time from ecg class
freq = ecg_raw.hz;
handles.freq = freq;

sample_time = ecg_raw.sample_time();
handles.sample_time = sample_time;

% Deal with integers vs values with decimals to avoid excess extra 0s

if mod(sample_time,1) == 0
    set(handles.sample_time_txt, 'String', sprintf('%i ms',sample_time));  % Add to GUI
else
    set(handles.sample_time_txt, 'String', sprintf('%1.3f ms',sample_time));  % Add to GUI
end

set(handles.freq_txt, 'String', sprintf('%i Hz',freq));  % Add to GUI and updates the frequency if there is a non-standard frequency in the file format

% Number of samples in the file     
num_samples = length(ecg_raw.I); 
handles.num_samples = num_samples;

set(handles.num_samples_txt, 'String', num_samples);
set(handles.duration_txt, 'String', sprintf('%0.1f s',num_samples*sample_time/1000));    
    
% Generate raw VM lead for R peak detection
vcg_raw = VCG(ecg_raw, aps);
handles.vcg_raw = vcg_raw;

% Initial pass through to find peaks in VM signal
QRS = vcg_raw.peaks(aps);
NQRS = length(QRS);
    
% ekgfreq has use for some of the filtering later
ekgfreq = NQRS / num_samples;
handles.ekgfreq=ekgfreq;

% Calculate max RR interval (for auto HPF level selection)
maxRR = 2*max(diff(QRS)*sample_time);
maxRR_hr = 60000/maxRR;
handles.maxRR_hr = maxRR_hr;
    
% Filter ECG based on flags as checked above
% If aps.wavelet_level_highpass is > max level, will throw an error
% This code will add explanation to GUI given error handeling is within
% ECG12.m independent of GUI
if aps.wavelet_level_highpass > floor(log2(length(ecg_raw.I)))
     set(handles.lf_fmin_txt,'String','Error - wavelet level > max');
end

% Actual filtering
[ecg, highpass_lvl_min] = ecg_raw.filter(maxRR_hr, aps);
handles.ecg = ecg;
    
% Calculate filtering frequencies and update GUI
if aps.highpass == 1            
    wavelet_lf_string_format = "Level: %i / Frequency: %.2f Hz";
    wavelet_lf_string_1 = highpass_lvl_min;
    wavelet_lf_string_2 = round((freq/2)/(2^highpass_lvl_min),2);
    handles.wavelet_hpf = (freq/2)/(2^highpass_lvl_min);
    wavelet_lf_string = sprintf(wavelet_lf_string_format, wavelet_lf_string_1,wavelet_lf_string_2);
    set(handles.lf_fmin_txt,'String',wavelet_lf_string);  % frequency cutoff for low freq wavelet filter
else
    set(handles.lf_fmin_txt,'String','N/A');  % blank if not using wavelet LF filter
    handles.wavelet_hpf = 0;
end

if aps.lowpass == 1
    wavelet_hf_string_format = "%.2f Hz";  
    wavelet_hf_string = sprintf(wavelet_hf_string_format, round((freq/2)/(2^aps.wavelet_level_lowpass),2)); 
    handles.wavelet_lpf = (freq/2)/(2^aps.wavelet_level_lowpass);
    set(handles.hf_freq_txt,'String',wavelet_hf_string);  % frequency cutoff for low freq wavelet filter
else
    set(handles.hf_freq_txt,'String','N/A');  % blank if not using wavelet HF filter
    handles.wavelet_lpf = 0;
end    

if safemode    
    % Stop here after update handles
    guidata(hObject, handles);

else

% Call batch_calc to load in the signals - ignore other output for now
% batch_calc now does bascially everything needed to calculate the VCGs,
% filtering, baseline correction, pacemaker spike removal, GEH, and other outputs, etc.
% For GUI only need to calculate the HR on this first pass, as after this
% the beats may be altered and wont get an accurate HR calculation

batchout = batch_calc(handles.ecg_raw, [], [], [], [], [], aps, qps, 0, "", []);

handles.hr = batchout.hr_orig;
handles.num_initial_beats = batchout.NQRS_orig;
handles.vcg = batchout.filtered_vcg;

% For pacer spike visualiation
handles.ecg_raw_postinterp = batchout.ecg_raw_postinterp;

% Saving these signals for use in interopolation figure without needing to
% press calculate first

handles.ecg = batchout.filtered_ecg;
handles.pacer_spikes = batchout.pacer_spikes;
handles.lead_ispaced = batchout.lead_ispaced;

% Update GUI to show if pacing detected

% Get colors based on if in light/dark mode
[dm, dark_colors, light_colors] = check_darkmode(handles);

if dm == 1
    colors = dark_colors;
else
    colors = light_colors;
end

% If sum of lead_ispaced is > value set in Annoparams pacer_spike_num, pacing was found
if ~isempty(handles.lead_ispaced) && sum(cell2mat(struct2cell(handles.lead_ispaced(:)))) >= 0

    set(handles.num_paced_leads_detected_txtbox,'String', num2str(sum(cell2mat(struct2cell(handles.lead_ispaced(:))))));

    if sum(cell2mat(struct2cell(handles.lead_ispaced(:)))) == 0
        set(handles.num_paced_leads_detected_txtbox,'String', '');
    end

    if sum(cell2mat(struct2cell(handles.lead_ispaced(:)))) >= aps.pacer_spike_num
        set(handles.gui_pacing_indicator,'BackgroundColor','yellow');
        set(handles.gui_pacing_indicator,'String',char(hex2dec('2301')));
        set(handles.gui_pacing_indicator,'FontWeight','bold');
        set(handles.gui_pacing_indicator,'ForegroundColor','black');
        set(handles.gui_pacing_indicator,'FontSize',13);
    
    elseif sum(cell2mat(struct2cell(handles.lead_ispaced(:)))) < aps.pacer_spike_num ...
            && sum(cell2mat(struct2cell(handles.lead_ispaced(:)))) > 0
        set(handles.gui_pacing_indicator,'BackgroundColor','white');
        set(handles.gui_pacing_indicator,'String',char(hex2dec('2301')));
        set(handles.gui_pacing_indicator,'FontWeight','bold');
        set(handles.gui_pacing_indicator,'ForegroundColor','#aaaaaa');
        set(handles.gui_pacing_indicator,'FontSize',13);

    else
        set(handles.gui_pacing_indicator,'BackgroundColor',colors.bgcolor);
        set(handles.gui_pacing_indicator,'String',' ');
    end

else
        set(handles.gui_pacing_indicator,'BackgroundColor',colors.bgcolor);
        set(handles.gui_pacing_indicator,'String',' ');
        set(handles.num_paced_leads_detected_txtbox,'String', '');

end

% Update handles structure
guidata(hObject, handles);
    
% Update HR in GUI
set(handles.hr_txt,'String',round(handles.hr));

% Post-12 lead filtering ECG transformation:
% Baseline correction for X, Y, Z (since linear transformation, can do this
% on X, Y, Z and not on the original 12-leads -- less error this way since
% only doing the correction on 3 leads as opposed to 12

% Calculate the baseline shifts in the filtered 12 lead ECG using 12 lead
% Baseline correction to use with calculating baseline offsets
if aps.baseline_correct_flag
    [~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, baseline_L1, baseline_L2, baseline_L3, baseline_avR, baseline_avF,...
        baseline_avL, baseline_V1, baseline_V2, baseline_V3, baseline_V4, baseline_V5, baseline_V6] = ...
        baseline_shift_hfs(ecg.I, ecg.II, ecg.III, ecg.avR, ecg.avF, ecg.avL, ecg.V1, ecg.V2, ecg.V3, ecg.V4, ecg.V5, ecg.V6, ecg.hz, QRS);
    
    vcg_shift = VCG(ecg, aps);      % Have to do it this way for GUI because batch_calc deals with the baseline offset and filtering together
                                    % and otherwise would have to have batch_calc output all of these values too just for this part.
        
    [~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, baseline_X, baseline_Y, baseline_Z, ~, ~, ~, ~, ~, ~] = ...
    baseline_shift_hfs(ecg.I, ecg.II, ecg.III, vcg_shift.X, vcg_shift.Y, vcg_shift.Z, ecg.V1, ecg.V2, ecg.V3, ecg.V4, ecg.V5, ecg.V6, vcg_shift.hz, QRS);
            
    % Save baseline shifts from prior calculations to baseline_shift structure
    handles.baseline_shift = struct('I',baseline_L1,'II',baseline_L2,'III',baseline_L3,...
        'avR',baseline_avR, 'avF',baseline_avF, 'avL',baseline_avL, ...
        'V1',baseline_V1, 'V2',baseline_V2, 'V3',baseline_V3, ...
        'V4',baseline_V4, 'V5',baseline_V5, 'V6',baseline_V6, ...
        'X',baseline_X, 'Y',baseline_Y, 'Z',baseline_Z);
    
%     % Baseline correct the 12L ECG (needed for GUI prior to pressing calculate)
%     [sL1, sL2, sL3, savR, savF, savL, sV1, sV2, sV3, sV4, sV5, sV6, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~] = ...
%     baseline_shift_hfs(ecg.I, ecg.II, ecg.III, ecg.avR, ecg.avF, ecg.avL, ...
%     ecg.V1, ecg.V2, ecg.V3, ecg.V4, ecg.V5, ecg.V6, ecg.hz, QRS);
%     
%     handles.ecg = ECG12(ecg.hz,'',sL1, sL2, sL3, savR, savF, savL, sV1, sV2, sV3, sV4, sV5, sV6);

else

    % Save baseline shifts from prior calculations to baseline_shift structure
    handles.baseline_shift = struct('I',0,'II',0,'III',0,...
        'avR',0, 'avF',0, 'avL',0, ...
        'V1',0, 'V2',0, 'V3',0, ...
        'V4',0, 'V5',0, 'V6',0, ...
        'X',0, 'Y',0, 'Z',0);
end

% update handles    
    guidata(hObject,handles);
    
% Do pacer spike removal for the GUI - gets done later as part of
% calculations, so wont save things here, but will just do for display
% purposes
% if aps.spike_removal
%     [vcg_noppm, ~] = handles.vcg.remove_pacer_spikes(QRS, aps);
%     QRS = vcg_noppm.peaks(aps);
% else
%     QRS = handles.vcg.peaks(aps);
% end   

QRS = batchout.beats_final.QRS;

% display the filtered, shifted etc X, Y, Z 10 second leads in GUI
    display_leads(handles.vcg.X, handles.vcg.Y, handles.vcg.Z, handles.vcg.VM, QRS, hObject,eventdata,handles);

end
    
end


% --- Executes on button press in vtbox.
function vtbox_Callback(hObject, eventdata, handles)
% hObject    handle to vtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of vtbox

if get(hObject, 'Value') == 1.0

    set(handles.qrwidth, 'Enable', 'off');
    set(handles.rswidth, 'Enable', 'off');
    set(handles.ststart, 'Enable', 'off');
    set(handles.stend, 'Enable', 'off');
    set(handles.preset_fidpts, 'Enable', 'off');
    set(handles.autocl_value_txtbox, 'Enable', 'off');
    set(handles.pacing_pkwidth_txt, 'Enable', 'off');
    set(handles.pacing_thresh_txt, 'Enable', 'off');
    set(handles.align_dropdown, 'Enable', 'off');
    set(handles.tend_method_dropdown, 'Enable', 'off');
    set(handles.autocl_checkbox, 'Enable', 'off');
    set(handles.cwt_pacing_remove_box, 'Enable', 'off');

else

    if get(handles.autocl_checkbox, 'Value');
        set(handles.qrwidth, 'Enable', 'off');
        set(handles.rswidth, 'Enable', 'off');
        set(handles.autocl_value_txtbox, 'Enable', 'on');
    else
        set(handles.qrwidth, 'Enable', 'on');
        set(handles.rswidth, 'Enable', 'on');  
        set(handles.autocl_value_txtbox, 'Enable', 'off');
    end
    
    set(handles.ststart, 'Enable', 'on');
    set(handles.stend, 'Enable', 'on');
    set(handles.preset_fidpts, 'Enable', 'on');
    set(handles.pacing_pkwidth_txt, 'Enable', 'on');
    set(handles.pacing_thresh_txt, 'Enable', 'on');
    set(handles.align_dropdown, 'Enable', 'on');
    set(handles.tend_method_dropdown, 'Enable', 'on');
    set(handles.autocl_checkbox, 'Enable', 'on');
    set(handles.cwt_pacing_remove_box, 'Enable', 'on');
   
end



function speed_blank_txt_Callback(hObject, eventdata, handles)
% hObject    handle to speed_blank_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of speed_blank_txt as text
%        str2double(get(hObject,'String')) returns contents of speed_blank_txt as a double


% --- Executes during object creation, after setting all properties.
function speed_blank_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to speed_blank_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in refresh_speed_button.
function refresh_speed_button_Callback(hObject, eventdata, handles)
% hObject    handle to refresh_speed_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Recalculates variables and updates the speed graph
calculate_Callback(hObject, eventdata, handles)
speed_graph_button_Callback(hObject, eventdata, handles)
 

% --- Executes on button press in accel_box.
function accel_box_Callback(hObject, eventdata, handles)
% hObject    handle to accel_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of accel_box


% --- Executes on button press in batch_load_button.
function batch_load_button_Callback(hObject, eventdata, handles)
% hObject    handle to batch_load_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% NOTE: nothing in batch loops other than data in the GUI itself is stored in handles

% Disable debug to avoid issues
set(handles.debug_anno,'Value',0);

% Clean up any errant progress bars
all_waitbars = findall(0,'type','figure','tag','TMWWaitbar');
delete(all_waitbars);

% Obtain parameters for the batch run:

% ECG format string and file extension
strlist = get(handles.ecg_source, 'String');
ecg_string = strlist{get(handles.ecg_source,'Value')};
[source_str, source_ext, ~] = ecg_source_string(ecg_string,handles.ecg_source_hash);

% Output file extension (.csv or .xlsx)
output_ext_list = get(handles.export_file_fmt_dropdown, 'String');
output_ext_index = get(handles.export_file_fmt_dropdown, 'Value');
output_ext = char(output_ext_list(output_ext_index));

% Note added to output
output_note = get(handles.export_note,'String');
if isempty(output_note)
    output_note = 'batchGUI'; 
end

% Parallel computing
parallel_proc = get(handles.parallel_batch_button, 'Value');

% Enable/Disable progress bar
progressbar = 1;

% Types of data to save
save_figures = get(handles.batch_save_figs_button, 'Value');
save_annotations = get(handles.batch_save_anno_button, 'Value');
save_data = get(handles.batch_save_data_button, 'Value');

% Get flags for processing different modules
vcg_calc_flag = get(handles.geh_option_checkbox,'Value');
lead_morph_flag = get(handles.lead_morphology_option_checkbox,'Value');
vcg_morph_flag = get(handles.vcg_morphology_option_checkbox,'Value');

% Pull Annoparams from GUI selections
batch_aps = pull_guiparams(hObject, eventdata, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Now call braveheart_batch() function
braveheart_batch('', source_str, output_ext, output_note, parallel_proc, progressbar, ...
    save_figures, save_data, save_annotations, ...
    vcg_calc_flag, lead_morph_flag, vcg_morph_flag, batch_aps, 'disable');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on selection change in zero_ref_list.
function zero_ref_list_Callback(hObject, eventdata, handles)
% hObject    handle to zero_ref_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns zero_ref_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from zero_ref_list


% --- Executes during object creation, after setting all properties.
function zero_ref_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zero_ref_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in vcg_origin_list.
function vcg_origin_list_Callback(hObject, eventdata, handles)
% hObject    handle to vcg_origin_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns vcg_origin_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from vcg_origin_list


% --- Executes during object creation, after setting all properties.
function vcg_origin_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vcg_origin_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in launch_ecgsplit_button.
function launch_ecgsplit_button_Callback(hObject, eventdata, handles)
% hObject    handle to launch_ecgsplit_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Splits into 2 ECGs of the same format into UNFORMATTED.TXT format
% source_str = handles.source_str;      % For now just use 'unformatted.txt'
% source_ext = handles.source_ext;      % Working on MUSE format splitting
source_str = 'unformatted';             
source_ext = '.txt';
ecg = handles.ecg_raw;
[d,n,~] = fileparts(handles.filename);
file = fullfile(d,n);

% Get sample to split based on dialogue box
prompt = {'Enter Sample Where ECG Will Be Cut:'};
dlgtitle = 'Cut Sample';
dims = [1 40];
cutpt = inputdlg(prompt,dlgtitle,dims);

% Check if pressed cancel
if isempty(cutpt)
   return; 
end

cutpt = str2num(cell2mat(cutpt));

% Don't do anything if input number outside of 1:length(ecg)

if cutpt > 1 && cutpt < ecg.length()-1
    [ecg1,ecg2] = ecg.split(cutpt);

    % Split ECGs need to be written in bidmc .txt format
    ecg1.write(strcat(file,'_split_1',source_ext),source_str);
    ecg2.write(strcat(file,'_split_2',source_ext),source_str);
    
    msgbox({sprintf('ECG Split Complete!\nOutput Directory %s',d)});
else
    msgbox({sprintf('Cut Point Out Of Bounds')});
end


% --- Executes on button press in outlier_button.
function outlier_button_Callback(hObject, eventdata, handles)
% hObject    handle to outlier_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'beats')
    vcg = handles.vcg;
    beats = handles.beats;
    aps = pull_guiparams(hObject, eventdata, handles);
    cutpt = aps.modz_cutoff;

    outlier_figure(vcg, beats, cutpt, hObject, eventdata, handles)
end



% --- Executes on button press in prev_beat_button.
function prev_beat_button_Callback(hObject, eventdata, handles)
% hObject    handle to prev_beat_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

init_index = get(handles.activebeats_list,'Value');

if init_index > 1
    new_index = init_index - 1;
else
    new_index = init_index;
end

set(handles.activebeats_list, 'Value', new_index)

activebeats_list_Callback(hObject, eventdata, handles)


% --- Executes on button press in next_beat_button.
function next_beat_button_Callback(hObject, eventdata, handles)
% hObject    handle to next_beat_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

str_matrix = num2str(handles.beats.beatmatrix());
max_index = size(str_matrix,1);

init_index = get(handles.activebeats_list,'Value');

if init_index < max_index
    new_index = init_index + 1;
else
    new_index = init_index;
end

set(handles.activebeats_list, 'Value', new_index)

activebeats_list_Callback(hObject, eventdata, handles)


% --- Executes on button press in rpk_shift_button.
function rpk_shift_button_Callback(hObject, eventdata, handles)
% hObject    handle to rpk_shift_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

shift = str2num(get(handles.shift_box,'String'));

% Need to pass in median VM signal to recalculate Tmax location if it changes
signal = handles.median_vcg.VM;

shift_annotations('R', shift, signal, hObject, eventdata, handles)

% --- Executes on button press in remove_outliers_button.
function remove_outliers_button_Callback(hObject, eventdata, handles)
% hObject    handle to remove_outliers_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

outlier_rem = remove_outliers_GUI(hObject, eventdata, handles);
handles = guidata(hObject);     % Take handles from the function and transfer to main program

% Need to prevent potential endless loop if new outliers are detected after
% first run of outlier removal -> keeps removing new outliers because batch_calc
% does its own outlier removal.  Can't just call batch_calc without
% remove_outliers_GUI because of issues in terms of saving outlier locations for
% summary graph.  Therefore, to get around this potential loop, once the
% outliers have been dealt with with remove_outliers_GUI, set aps.outlier_removal = 0,
% and at end of this function turn it back to whatever it was before

% Get Annoparam values as currently stored/checked off in GUI
aps = pull_guiparams(hObject, eventdata, handles);

% Load Qualparams
qps = Qualparams();

% Set pvc_removal = 0 for passing into batch_calc
aps.outlier_removal = 0;
aps.pvc_removal = 0;

if outlier_rem == 1         % Only update things if actually did outlier removal
batchout = batch_calc(handles.ecg_raw, handles.beats, [], [], [], [], handles.aps, qps, 0, "", []);
 
handles.beats = batchout.beats_final;
handles.quality = batchout.quality;
handles.correlation_test = batchout.correlation_test;
handles.median_vcg = batchout.medianvcg1;
handles.beatsig_vcg = batchout.beatsig_vcg;
handles.median_12L = batchout.median_12L;
handles.beatsig_12L = batchout.beatsig_12L;
handles.medianbeat = batchout.medianbeat;
handles.beat_stats = batchout.beat_stats;

    
% Get flags for processing different modules
vcg_calc_flag = get(handles.geh_option_checkbox,'Value');
lead_morph_flag = get(handles.lead_morphology_option_checkbox,'Value');
vcg_morph_flag = get(handles.vcg_morphology_option_checkbox,'Value');

% Create flags structure
flags = struct;
flags.vcg_calc_flag = vcg_calc_flag;
flags.lead_morph_flag = lead_morph_flag;
flags.vcg_morph_flag = vcg_morph_flag;


[handles.geh, handles.lead_morph, handles.vcg_morph] = module_output(handles.median_12L, handles.median_vcg, handles.medianbeat, aps, flags);

    % Update handles structure
    guidata(hObject, handles);

    calc_plot(handles.vcg, handles.beats, handles.aps, hObject, eventdata, handles);
    guidata(hObject, handles);  % update handles

end

% Dont need to set aps.outlier_removal back, because the value assigned to
% handles is not changed, and the variable aps only exists in this callback

% disable rotation curcor
rotate3d off


% --- Executes on button press in reannotate_flag.
function reannotate_flag_Callback(hObject, eventdata, handles)
% hObject    handle to reannotate_flag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of reannotate_flag

    

% --- Executes on button press in crosscorr_button.
function crosscorr_button_Callback(hObject, eventdata, handles)
% hObject    handle to crosscorr_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Displays cross correlation and RMSE value matrix for all beats

aps = pull_guiparams(hObject, eventdata, handles); 
beats = handles.beats;
vcg = handles.vcg;

pvc_data_visualization(beats, aps, vcg, hObject, eventdata, handles)

handles = guidata(hObject);


% --- Executes on button press in keepnative_button.
function keepnative_button_Callback(hObject, eventdata, handles)
% hObject    handle to keepnative_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of keepnative_button

set(handles.pvc_button, 'String', 'Remove PVCs')



% --- Executes on button press in keeppvc_button.
function keeppvc_button_Callback(hObject, eventdata, handles)
% hObject    handle to keeppvc_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of keeppvc_button

set(handles.pvc_button, 'String', 'Remove Native')


% --- Executes on button press in quality_button.
function quality_button_Callback(hObject, eventdata, handles)
% hObject    handle to quality_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% batch_calc calculates quality class object
% This is where it is visualized in GUI

if isfield(handles,'quality')
    quality = handles.quality;
    quality_figure(quality, hObject, eventdata, handles);
end



% --- Executes on button press in batch_save_figs_button.
function batch_save_figs_button_Callback(hObject, eventdata, handles)
% hObject    handle to batch_save_figs_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of batch_save_figs_button


% --- Executes on button press in baseline_correct_checkbox.
function baseline_correct_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to baseline_correct_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of baseline_correct_checkbox


% --- Executes on button press in sensitivity_analysis_button.
function sensitivity_analysis_button_Callback(hObject, eventdata, handles)
% hObject    handle to sensitivity_analysis_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

aps = pull_guiparams(hObject, eventdata, handles);
median_vcg = handles.median_vcg;
medianbeat = handles.medianbeat;
ecg = handles.ecg;

save_folder = get(handles.save_dir_txt,'String');
filename = fullfile(save_folder,strcat(handles.filename_short(1:end-4), '_sensitivity_analysis.csv'));

% Variability to test
step = round(str2num(get(handles.sensitivity_step_txt,'String'))/(1000/ecg.hz));    
    
geh_sensitivity(filename,median_vcg, medianbeat, aps, step);

msgbox({sprintf('Sensitivity Analysis Complete')});

    

% --- Executes on button press in pushbutton102.
function pushbutton102_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton102 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function sensitivity_step_txt_Callback(hObject, eventdata, handles)
% hObject    handle to sensitivity_step_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sensitivity_step_txt as text
%        str2double(get(hObject,'String')) returns contents of sensitivity_step_txt as a double


% --- Executes during object creation, after setting all properties.
function sensitivity_step_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sensitivity_step_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function autocl_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to autocl_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autocl_checkbox

if get(hObject, 'Value') == 1.0
    set(handles.qrwidth, 'Enable', 'off');
    set(handles.rswidth, 'Enable', 'off');
    set(handles.autocl_value_txtbox, 'Enable', 'on');
else
    set(handles.qrwidth, 'Enable', 'on');
    set(handles.rswidth, 'Enable', 'on');
    set(handles.autocl_value_txtbox, 'Enable', 'off');
end



function autocl_value_txtbox_Callback(hObject, eventdata, handles)
% hObject    handle to autocl_value_txtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of autocl_value_txtbox as text
%        str2double(get(hObject,'String')) returns contents of autocl_value_txtbox as a double


% --- Executes during object creation, after setting all properties.
function autocl_value_txtbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to autocl_value_txtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in auto_remove_outliers_checkbox.
function auto_remove_outliers_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to auto_remove_outliers_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of auto_remove_outliers_checkbox

if get(hObject, 'Value') == 0.0
    set(handles.all_auto_checkbox, 'Value', 0);
end

% --- Executes on button press in auto_pvc_removal_checkbox.
function auto_pvc_removal_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to auto_pvc_removal_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of auto_pvc_removal_checkbox

if get(hObject, 'Value') == 0.0
    set(handles.all_auto_checkbox, 'Value', 0);
end


% --- Executes on button press in cwt_pacing_remove_box.
function cwt_pacing_remove_box_Callback(hObject, eventdata, handles)
% hObject    handle to cwt_pacing_remove_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cwt_pacing_remove_box

if get(hObject,'Value') == 0
    set(handles.interpolate_spikes_ckbox,'value',0);
    set(handles.pacer_interpolation_button,'enable','off');
    set(handles.pacing_pkwidth_txt,'enable', 'on');
    set(handles.pacing_thresh_txt,'enable', 'on');
    set(handles.pacer_zpk_txtbox, 'enable', 'on');
    set(handles.pacer_zcut_txtbox, 'enable', 'on');
    set(handles.pacer_maxscale_txtbox, 'enable', 'on');
    set(handles.pacer_num_leads_txtbox, 'enable','on');
else
    set(handles.pacer_interpolation_button,'enable','on');
    set(handles.spike_removal_old_checkbox,'value',0);
    set(handles.pacing_pkwidth_txt,'enable', 'off');
    set(handles.pacing_thresh_txt,'enable', 'off');
    set(handles.pacer_zpk_txtbox, 'enable', 'on');
    set(handles.pacer_zcut_txtbox, 'enable', 'on');
    set(handles.pacer_maxscale_txtbox, 'enable', 'on');
    set(handles.pacer_num_leads_txtbox, 'enable','on');
end


% --- Executes on selection change in tend_method_dropdown.
function tend_method_dropdown_Callback(hObject, eventdata, handles)
% hObject    handle to tend_method_dropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns tend_method_dropdown contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tend_method_dropdown


% --- Executes during object creation, after setting all properties.
function tend_method_dropdown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tend_method_dropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pacing_thresh_txt_Callback(hObject, eventdata, handles)
% hObject    handle to pacing_thresh_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pacing_thresh_txt as text
%        str2double(get(hObject,'String')) returns contents of pacing_thresh_txt as a double


% --- Executes during object creation, after setting all properties.
function pacing_thresh_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pacing_thresh_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pacing_pkwidth_txt_Callback(hObject, eventdata, handles)
% hObject    handle to pacing_pkwidth_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pacing_pkwidth_txt as text
%        str2double(get(hObject,'String')) returns contents of pacing_pkwidth_txt as a double


% --- Executes during object creation, after setting all properties.
function pacing_pkwidth_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pacing_pkwidth_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in align_dropdown.
function align_dropdown_Callback(hObject, eventdata, handles)
% hObject    handle to align_dropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns align_dropdown contents as cell array
%        contents{get(hObject,'Value')} returns selected item from align_dropdown


% --- Executes during object creation, after setting all properties.
function align_dropdown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to align_dropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in summary_ecg_button.
function summary_ecg_button_Callback(hObject, eventdata, handles)
% hObject    handle to summary_ecg_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Only does anything if a median_vcg has been created
if isfield(handles,'median_vcg')

    filename = handles.filename_short;
    save_folder = get(handles.save_dir_txt,'String');

    vcg = handles.vcg;
    median_vcg = handles.median_vcg;
    beats = handles.beats;
    medianbeat = handles.medianbeat;

%     if isfield(handles,'qrs_pvcs')
%         pvc_index = handles.qrs_pvcs;
%     else
%         pvc_index = [];
%     end
% 
%     if isfield(handles,'qrs_outliers')
%         outlier_index = handles.qrs_outliers;
%     else 
%         outlier_index = [];
%     end
% 
    % cross correlation for printing on figure
    correlation_test = handles.correlation_test;

    % Quality probability for printing on figure
    prob = handles.quality.prob_value;

    % Get colors based on if in light/dark mode
    [dm, dark_colors, light_colors] = check_darkmode(handles);
    
    if dm == 1
        colors = dark_colors;
    else
        colors = light_colors;
    end

    summary_figure(vcg, beats, median_vcg, medianbeat, correlation_test, prob, save_folder, filename, colors)
    

end

% --- Executes on button press in all_auto_checkbox.
function all_auto_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to all_auto_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of all_auto_checkbox


if get(hObject, 'Value') == 1.0
    set(handles.auto_remove_outliers_checkbox, 'Value', 1);
    set(handles.auto_pvc_removal_checkbox, 'Value', 1);
else
    set(handles.auto_remove_outliers_checkbox, 'Value', 0);
    set(handles.auto_pvc_removal_checkbox, 'Value', 0);
end


% --- Executes on selection change in transform_mat_dropdown.
function transform_mat_dropdown_Callback(hObject, eventdata, handles)
% hObject    handle to transform_mat_dropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)_

% Hints: contents = cellstr(get(hObject,'String')) returns transform_mat_dropdown contents as cell array
%        contents{get(hObject,'Value')} returns selected item from transform_mat_dropdown


% --- Executes during object creation, after setting all properties.
function transform_mat_dropdown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to transform_mat_dropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in fidpt_export_checkbox.
function fidpt_export_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to fidpt_export_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fidpt_export_checkbox


% --- Executes on button press in export_mat_data_button.
function export_mat_data_button_Callback(hObject, eventdata, handles)
% hObject    handle to export_mat_data_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

save_folder = get(handles.save_dir_txt,'String');

% Load all data
ecg_raw = handles.ecg_raw;
vcg_raw = handles.vcg_raw;
ecg = handles.ecg;
vcg = handles.vcg;

pacer_spikes = handles.pacer_spikes;
lead_ispaced = handles.lead_ispaced;
ecg_raw_postinterp = handles.ecg_raw_postinterp;

beats = handles.beats;
beat_stats = handles.beat_stats;
medianbeat = handles.medianbeat;

median_vcg = handles.median_vcg;
beatsig_vcg = handles.beatsig_vcg;

median_12L =  handles.median_12L;
beatsig_12L = handles.beatsig_12L;

geh = handles.geh;
lead_morph = handles.lead_morph;
vcg_morph = handles.vcg_morph;

export_filename = fullfile(save_folder,strcat(handles.filename_short(1:end-4), '_data.mat'));

ecg_filename = handles.filename;

aps = handles.aps;

% Misc additions
basename = handles.filename;
source_str = handles.source_str;
corr = handles.correlation_test;
noise = handles.noise;
hr = handles.hr;
num_initial_beats = handles.num_initial_beats;
quality = handles.quality;

% Create an AnnoResult class object
i = 1;  % Deal with issue in how AnnoResult handles single ecgs outide of batch. HFS: don't change!
results{i} = AnnoResult(basename, '', source_str, aps, ecg, hr, num_initial_beats, beats, ...
    beat_stats, corr, noise, quality.prob_value, quality.missing_lead, lead_ispaced, geh, ...
    lead_morph, vcg_morph);
	
% Choose the relevant parts of AnnoResult to avoid duplication
% of data in output files.  Will copy results{i} which is the
% AnnoResult data into a new variable 'ar' for manipulation

warning('off', 'MATLAB:structOnObject');        % Turn off warning as this is intentional
ar = struct(results{i});
warning('on', 'MATLAB:structOnObject');
% Remove the data that is already in other parts of the output
% file so we can see just the remaining misc data
ar = rmfield(ar, {'geh', 'vcg_morph', 'lead_morph', 'ap', 'beat_stats', 'beats', 'filename'});

% Reformat so can export without errors
ar_fields = fieldnames(ar);
for cc = 1:length(ar_fields)
    ff = ar_fields{cc};
    if iscell(ar.(ff)) && numel(ar.(ff)) == 1
            ar.(ff) = ar.(ff){1};
    end
    if isempty(ar.(ff))
            ar.(ff) = [];  % Convert empty string to []
    end
end

data = struct( ...
    'filename',ecg_filename, ...
    'annoparams', aps, ...
    'ecg_raw', ecg_raw, ...
    'ecg_filtered', ecg, ...
    'vcg_raw', vcg_raw, ...
    'vcg_filtered', vcg, ...
    'ecg_raw_postinterp', ecg_raw_postinterp, ...
    'pacer_spikes', pacer_spikes, ...
    'lead_ispaced', lead_ispaced, ...
    'beats', beats, ...
    'beat_stats', beat_stats, ...
    'vcg_calc', geh, ...
    'median_vcg', median_vcg, ...
    'median_12L', median_12L, ...
    'medianbeat', medianbeat, ...
    'beats_median_vcg', beatsig_vcg, ...
    'beats_median_12L', beatsig_12L, ...
    'lead_morph', lead_morph, ...
    'vcg_morph', vcg_morph, ...
    'quality', quality, ...
    'misc', ar);

save(export_filename,'data');



% --- Executes on button press in shift_median_checkbox.
function shift_median_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to shift_median_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of shift_median_checkbox

% If checkbox checked
if get(hObject,'Value')

    % Disable R peak point changes
    set(handles.rpeak_plus_button, 'Enable', 'off');
    set(handles.rpeak_minus_button, 'Enable', 'off');
    set(handles.rpk_shift_button, 'Enable', 'off');

% If not checked
else

    % Enable R peak point changes for non median beats
    set(handles.rpeak_plus_button, 'Enable', 'on');
    set(handles.rpeak_minus_button, 'Enable', 'on');
    set(handles.rpk_shift_button, 'Enable', 'on');

end


% --- Executes on button press in polar_fig_button.
function polar_fig_button_Callback(hObject, eventdata, handles)
% hObject    handle to polar_fig_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

filename = handles.filename_short;
save_folder = get(handles.save_dir_txt,'String');

[age, male, white, bmi] = pull_gui_demographics(hObject, eventdata, handles);

% Get nurmal ranges based on the demographics
nval = NormalVals(age, male, white, bmi, handles.hr);

% Get colors based on if in light/dark mode
[dm, dark_colors, light_colors] = check_darkmode(handles);

if dm == 1
    colors = dark_colors;
else
    colors = light_colors;
end

% Generate polar figure with normal values included
polar_figures(handles.geh, nval, save_folder, filename, colors)



function shift_annotations(pt, shift, signal, hObject, eventdata, handles)
  
shift_annotations_GUI(pt, shift, signal, hObject, eventdata, handles)
handles = guidata(hObject);     % Take handles from the function and transfer to main program

% Don't remove PVCs and outliers when shift - makes it too complicated -
% will need to do manually to avoid having things auto deleted if you move
% fiducial points without wanting to delete a beat

% Load VCG/ECG, QRS, and Annoparams
aps = pull_guiparams(hObject, eventdata, handles);  % Pull from GUI and update based on what is selected
handles.aps = aps;

% Load Qualparams
qps = Qualparams();

aps.pvc_removal = 0;
aps.outlier_removal = 0;


% IF MEDIAN    
if get(handles.shift_median_checkbox, 'Value')
   
    % Get flags for processing different modules
    vcg_calc_flag = get(handles.geh_option_checkbox,'Value');
    lead_morph_flag = get(handles.lead_morphology_option_checkbox,'Value');
    vcg_morph_flag = get(handles.vcg_morphology_option_checkbox,'Value');

    % Create flags structure
    flags = struct;
    flags.vcg_calc_flag = vcg_calc_flag;
    flags.lead_morph_flag = lead_morph_flag;
    flags.vcg_morph_flag = vcg_morph_flag;
 
    handles.correlation_test = median_fit(handles.beatsig_vcg, handles.medianbeat);
  
    [handles.geh, handles.lead_morph, handles.vcg_morph] = module_output(handles.median_12L, handles.median_vcg, handles.medianbeat, aps, flags);
       
    guidata(hObject, handles);  % update handles    
    
    handles.quality = Quality(handles.median_vcg, handles.ecg_raw, handles.beats, handles.medianbeat, ...
            handles.hr, handles.num_initial_beats, handles.correlation_test, handles.noise, aps, qps); % maxRR isnt being used now....set to zero
        
    guidata(hObject, handles);  % update handles
        
    calc_plot(handles.vcg, handles.beats, handles.aps, hObject, eventdata, handles)   

    guidata(hObject, handles);  % update handles    
 
    
else   % IF NOT MEDIAN

batchout = batch_calc(handles.ecg_raw, handles.beats, [], [], [], [], aps, qps, 0, "", []);

handles.beats = batchout.beats_final;
handles.quality = batchout.quality;
handles.correlation_test = batchout.correlation_test;
handles.median_vcg = batchout.medianvcg1;
handles.beatsig_vcg = batchout.beatsig_vcg;
handles.median_12L = batchout.median_12L;
handles.beatsig_12L = batchout.beatsig_12L;
handles.medianbeat = batchout.medianbeat;
handles.beat_stats = batchout.beat_stats;
    
% Get flags for processing different modules
vcg_calc_flag = get(handles.geh_option_checkbox,'Value');
lead_morph_flag = get(handles.lead_morphology_option_checkbox,'Value');
vcg_morph_flag = get(handles.vcg_morphology_option_checkbox,'Value');

% Create flags structure
flags = struct;
flags.vcg_calc_flag = vcg_calc_flag;
flags.lead_morph_flag = lead_morph_flag;
flags.vcg_morph_flag = vcg_morph_flag;


[handles.geh, handles.lead_morph, handles.vcg_morph] = module_output(handles.median_12L, handles.median_vcg, handles.medianbeat, aps, flags);

    % Update handles structure
    guidata(hObject, handles);
    
    calc_plot(handles.vcg, handles.beats, handles.aps, hObject, eventdata, handles);
    guidata(hObject, handles);  % update handles

end
    
% Disable rotation so can move lines to reannotate in selected beat viewer
    rotate3d off 
    

% --- Executes on selection change in medianreanno_popup.
function medianreanno_popup_Callback(hObject, eventdata, handles)
% hObject    handle to medianreanno_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns medianreanno_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from medianreanno_popup

% Only run this code if have a median VCG processed.  Otherwise just change
% the text so annoparams can deal with it

if isfield(handles, 'median_vcg')

% Update success visibility
    set(handles.success_txt,'Visible','Off')
    
    % Pull aps from GUI given choice of median annotater (NNet vs Std)
    aps = pull_guiparams(hObject, eventdata, handles); 

    % Load Qualparams
    qps = Qualparams();
    
    % Don't need to do any PVC/outlier removal in this case because just
    % adjusting median annotations
    aps.pvc_removal = 0;
    aps.outlier_removal = 0;
    
    %Other is a structure that makes it simpler to pass special situations
    %into batch_calc
    
    other.hr = handles.hr;
    other.NQRS_orig = handles.num_initial_beats;
    
    
   batchout = batch_calc(handles.ecg_raw, handles.beats, handles.medianbeat, handles.median_vcg, handles.median_12L, handles.beatsig_vcg, ...
      aps, qps, 0, "", other);

handles.quality = batchout.quality;
handles.correlation_test = batchout.correlation_test;
handles.medianbeat = batchout.medianbeat;

  
% Get flags for processing different modules
vcg_calc_flag = get(handles.geh_option_checkbox,'Value');
lead_morph_flag = get(handles.lead_morphology_option_checkbox,'Value');
vcg_morph_flag = get(handles.vcg_morphology_option_checkbox,'Value');

% Create flags structure
flags = struct;
flags.vcg_calc_flag = vcg_calc_flag;
flags.lead_morph_flag = lead_morph_flag;
flags.vcg_morph_flag = vcg_morph_flag;


[handles.geh, handles.lead_morph, handles.vcg_morph] = module_output(handles.median_12L, handles.median_vcg, handles.medianbeat, aps, flags);
  
    % Update handles structure
    guidata(hObject, handles);

    calc_plot(handles.vcg, handles.beats, handles.aps, hObject, eventdata, handles);
    guidata(hObject, handles);  % update handles

% disable rotation so can move lines to reannotate in selected beat viewer
rotate3d off
     
end


% --- Executes during object creation, after setting all properties.
function medianreanno_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to medianreanno_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rot_l_button.
function rot_l_button_Callback(hObject, eventdata, handles)
% hObject    handle to rot_l_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.face_axis);
camorbit(10,0,'coordsys') 

% --- Executes on button press in rot_r_button.
function rot_r_button_Callback(hObject, eventdata, handles)
% hObject    handle to rot_r_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.face_axis);
camorbit(-10,0,'coordsys') 

% --- Executes on button press in rot_d_button.
function rot_d_button_Callback(hObject, eventdata, handles)
% hObject    handle to rot_d_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.face_axis);
camorbit(0,10,'coordsys') 

% --- Executes on button press in rot_u_button.
function rot_u_button_Callback(hObject, eventdata, handles)
% hObject    handle to rot_u_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.face_axis);
camorbit(0,-10,'coordsys') 

% --- Executes on button press in rot_l2_button.
function rot_l2_button_Callback(hObject, eventdata, handles)
% hObject    handle to rot_l2_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.face_axis);
camroll(10)

% --- Executes on button press in rot_r2_button.
function rot_r2_button_Callback(hObject, eventdata, handles)
% hObject    handle to rot_r2_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.face_axis);
camroll(-10)


% --- Executes on button press in pushbutton139.
function pushbutton139_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton139 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function septal_txt_Callback(hObject, eventdata, handles)
% hObject    handle to septal_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of septal_txt as text
%        str2double(get(hObject,'String')) returns contents of septal_txt as a double


% --- Executes during object creation, after setting all properties.
function septal_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to septal_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in septal_button.
function septal_button_Callback(hObject, eventdata, handles)
% hObject    handle to septal_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Update success visibility
%     set(handles.success_txt,'Visible','Off')
%     
% % Load VCG, QRS, and Annoparams
%     aps = pull_guiparams(hObject, eventdata, handles); 
%     vcg = handles.vcg;
%     ecg = handles.ecg;
%     beats = handles.beats;
%     median_vcg = handles.median_vcg;
%     beatsig_vcg  = handles.beatsig_vcg ;
%     
% % Annotate median VM lead and save annotations to medianbeats
% % Pass in vcg with pacer spikes as QRS locations will ignore pacer spikes
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%% CALCULATE/PLOT BLOCK    
% if aps.debug
%     figure(figure('name','Initial Forces Fiducial Point Debug','numbertitle','off'));
%     hold off;
%     plotind = min([15*vcg.hz, 100000, length(median_vcg.VM)]);
%     plot(median_vcg.VM(1:plotind), 'Color', '[ 0 0.8 0]');
%     hold on;
% end
% [geh, med_intervals, medianbeat]...
%      = calc_plot_septum(median_vcg, beatsig_vcg , aps, hObject, eventdata, handles);
% 
% % Add to handles
%     handles.median_vcg = median_vcg;
%     handles.medianbeat = medianbeat;
%     handles.beatsig_vcg = beatsig_vcg;
%     handles.geh = geh;
%     handles.med_intervals = med_intervals;
%     
% %     % Save uncropped signals and annotations for later use in plotting
% %     handles.wide_medianvcg = wide_medianvcg;
% %     handles.wide_beatsig = wide_beatsig;
% %     handles.wide_annotations = wide_annotations;
%     
%     guidata(hObject, handles);  % update handles
% %%% END CALCULATE/PLOT BLOCK    
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      


% --- Executes on button press in speedgraph_popout_button.
function speedgraph_popout_button_Callback(hObject, eventdata, handles)
% hObject    handle to speedgraph_popout_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

save_flag = get(handles.save_speedfig_checkbox,'Value');
accel_flag = get(handles.accel_box,'Value');
legend_flag = get(handles.speed_legend_checkbox,'Value');

filename = handles.filename_short;
save_folder = get(handles.save_dir_txt,'String');
filename_short = strcat(filename(1:end-4),'_speed.png');
speed_filename = fullfile(save_folder,filename_short);

popout = 1;

speed_graph_gui(hObject, eventdata, handles, speed_filename, save_flag, 0, str2num(get(handles.speed_blank_txt, 'String')), str2num(get(handles.speed_t_blank_txt, 'String')), accel_flag, legend_flag, popout);



% --- Executes on button press in norm_values_buton.
function norm_values_buton_Callback(hObject, eventdata, handles)
% hObject    handle to norm_values_buton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%winopen('normal_values.pdf');



% --- Executes on button press in lead_morph_button.
function lead_morph_button_Callback(hObject, eventdata, handles)
% hObject    handle to lead_morph_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'lead_morph')

    filename = handles.filename_short;
    save_folder = get(handles.save_dir_txt,'String');
    median_12L = handles.median_12L;
    median_vcg = handles.median_vcg;
    medianbeat = handles.medianbeat;
    lead_morph = handles.lead_morph;
    geh = handles.geh;
    save = 0;
    
    % Get colors based on if in light/dark mode
    [dm, dark_colors, light_colors] = check_darkmode(handles);
    
    if dm == 1
        colors = dark_colors;
    else
        colors = light_colors;
    end

    view_lead_morph_fig(median_12L, median_vcg, medianbeat, lead_morph, geh, save, filename, save_folder, colors)

end


% --- Executes on button press in view_median_ecg_button.
function view_median_ecg_button_Callback(hObject, eventdata, handles)
% hObject    handle to view_median_ecg_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ecg = handles.median_12L;
vcg = handles.median_vcg;

filename = handles.filename_short;
save_folder = get(handles.save_dir_txt,'String');

grid_options = get(handles.grid_popup,'Value');

switch grid_options
    case 1
        minorgrid = 1;
        majorgrid = 1;
    case 2
        minorgrid = 0;
        majorgrid = 1;
    case 3
        minorgrid = 1;
        majorgrid = 0;
    case 4
        minorgrid = 0;
        majorgrid = 0;
end

    % Get colors based on if in light/dark mode
    [dm, dark_colors, light_colors] = check_darkmode(handles);
    
    if dm == 1
        colors = dark_colors;
    else
        colors = light_colors;
    end


view_median12lead_ecg(ecg, vcg, filename, save_folder, 0, 0, majorgrid, minorgrid, colors);


% --- Executes on button press in parallel_batch_button.
function parallel_batch_button_Callback(hObject, eventdata, handles)
% hObject    handle to parallel_batch_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of parallel_batch_button


% --- Executes on button press in darkmode_button.
function darkmode_button_Callback(hObject, eventdata, handles)
% hObject    handle to darkmode_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Switch dark mode and light mode and change text of button
[is_dark, ~, ~] = check_darkmode(handles);

if is_dark == 0
    set(handles.darkmode_button, 'String', 'Light Mode');
else
    set(handles.darkmode_button, 'String', 'Dark Mode');
end

darkmode(handles);




% --- Executes on button press in batch_save_data_button.
function batch_save_data_button_Callback(hObject, eventdata, handles)
% hObject    handle to batch_save_data_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of batch_save_data_button


% --- Executes on button press in batch_save_anno_button.
function batch_save_anno_button_Callback(hObject, eventdata, handles)
% hObject    handle to batch_save_anno_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of batch_save_anno_button


% --- Executes on selection change in export_file_fmt_dropdown.
function export_file_fmt_dropdown_Callback(hObject, eventdata, handles)
% hObject    handle to export_file_fmt_dropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns export_file_fmt_dropdown contents as cell array
%        contents{get(hObject,'Value')} returns selected item from export_file_fmt_dropdown

contents = cellstr(get(hObject,'String'));
set(handles.export_button,'String',strcat('Export Data',{' ('},contents{get(hObject,'Value')},')'));


% --- Executes during object creation, after setting all properties.
function export_file_fmt_dropdown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to export_file_fmt_dropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function rmse_thresh_txt_Callback(hObject, eventdata, handles)
% hObject    handle to rmse_thresh_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rmse_thresh_txt as text
%        str2double(get(hObject,'String')) returns contents of rmse_thresh_txt as a double


% --- Executes during object creation, after setting all properties.
function rmse_thresh_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rmse_thresh_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in safemode_checkbox.
function safemode_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to safemode_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of safemode_checkbox

if get(hObject,'Value') == 1
    set(handles.calculate,'Enable','off')
else
    set(handles.calculate,'Enable','on')
end


% --- Executes on button press in view_vcgloops_button.
function view_vcgloops_button_Callback(hObject, eventdata, handles)
% hObject    handle to view_vcgloops_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vcg = handles.median_vcg;
medianbeat = handles.medianbeat;

filename = handles.filename_short;
save_folder = get(handles.save_dir_txt,'String');

% Get colors based on if in light/dark mode
[dm, dark_colors, light_colors] = check_darkmode(handles);

if dm == 1
    colors = dark_colors;
else
    colors = light_colors;
end

view_vcgloops(vcg, medianbeat, filename, save_folder, 0, colors)



function zscore_thresh_txt_Callback(hObject, eventdata, handles)
% hObject    handle to zscore_thresh_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zscore_thresh_txt as text
%        str2double(get(hObject,'String')) returns contents of zscore_thresh_txt as a double


% --- Executes during object creation, after setting all properties.
function zscore_thresh_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zscore_thresh_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in threshold_fig_button.
function threshold_fig_button_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_fig_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

aps = pull_guiparams(hObject, eventdata, handles);
threshold_figure_gui(handles.vcg, aps);


% --- Executes on button press in pushbutton150.
function pushbutton150_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton150 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in lead_morphology_option_checkbox.
function lead_morphology_option_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to lead_morphology_option_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of lead_morphology_option_checkbox


% --- Executes on button press in vcg_morphology_option_checkbox.
function vcg_morphology_option_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to vcg_morphology_option_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of vcg_morphology_option_checkbox


% --- Executes on button press in geh_option_checkbox.
function geh_option_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to geh_option_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of geh_option_checkbox


% --- Executes on button press in qrsloop_vcg_morph_button.
function qrsloop_vcg_morph_button_Callback(hObject, eventdata, handles)
% hObject    handle to qrsloop_vcg_morph_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vcg = handles.median_vcg;
fidpts = handles.medianbeat.beatmatrix();

x = vcg.X(fidpts(1):fidpts(3));
y = vcg.Y(fidpts(1):fidpts(3));
z = vcg.Z(fidpts(1):fidpts(3));

x2 = vcg.X(fidpts(3):fidpts(4));
y2 = vcg.Y(fidpts(3):fidpts(4));
z2 = vcg.Z(fidpts(3):fidpts(4));

% Get colors based on if in light/dark mode
[dm, dark_colors, light_colors] = check_darkmode(handles);

if dm == 1
    colors = dark_colors;
else
    colors = light_colors;
end

vcg_loop_fig_GUI(x, y, z, x2, y2, z2, 'qrs', colors, hObject, eventdata, handles)

rotate3d on


% --- Executes on button press in tloop_vcg_morph_button.
function tloop_vcg_morph_button_Callback(hObject, eventdata, handles)
% hObject    handle to tloop_vcg_morph_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vcg = handles.median_vcg;
fidpts = handles.medianbeat.beatmatrix();

x = vcg.X(fidpts(3):fidpts(4));
y = vcg.Y(fidpts(3):fidpts(4));
z = vcg.Z(fidpts(3):fidpts(4));

x2 = vcg.X(fidpts(1):fidpts(3));
y2 = vcg.Y(fidpts(1):fidpts(3));
z2 = vcg.Z(fidpts(1):fidpts(3));

% Get colors based on if in light/dark mode
[dm, dark_colors, light_colors] = check_darkmode(handles);

if dm == 1
    colors = dark_colors;
else
    colors = light_colors;
end

vcg_loop_fig_GUI(x, y, z, x2, y2, z2, 't', colors, hObject, eventdata, handles)

rotate3d on


% --- Executes on button press in vcg_morph_fig_legend_checkbox.
function vcg_morph_fig_legend_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to vcg_morph_fig_legend_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of vcg_morph_fig_legend_checkbox


% --- Executes on button press in vcg_morph_fig_axis_checkbox.
function vcg_morph_fig_axis_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to vcg_morph_fig_axis_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of vcg_morph_fig_axis_checkbox


% --- Executes on button press in vcg_morph_fig_hidebasis_checkbox.
function vcg_morph_fig_hidebasis_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to vcg_morph_fig_hidebasis_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of vcg_morph_fig_hidebasis_checkbox


% --- Executes on button press in v1_v2_angle_button.
function v1_v2_angle_button_Callback(hObject, eventdata, handles)
% hObject    handle to v1_v2_angle_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

v1_mag = str2num(get(handles.v1_mag_txt,'String'));
v1_az = str2num(get(handles.v1_az_txt,'String'));
v1_el = str2num(get(handles.v1_el_txt,'String'));

v2_mag = str2num(get(handles.v2_mag_txt,'String'));
v2_az = str2num(get(handles.v2_az_txt,'String'));
v2_el = str2num(get(handles.v2_el_txt,'String'));

[v1_x, v1_y, v1_z] = azel2xyz(v1_mag, v1_az, v1_el);
[v2_x, v2_y, v2_z] = azel2xyz(v2_mag, v2_az, v2_el);


set(handles.v1_x_txt, 'String', round(v1_x,3));
set(handles.v1_y_txt, 'String', round(v1_y,3));
set(handles.v1_z_txt, 'String', round(v1_z,3));

set(handles.v2_x_txt, 'String', round(v2_x,3));
set(handles.v2_y_txt, 'String', round(v2_y,3));
set(handles.v2_z_txt, 'String', round(v2_z,3));

vector1 = [v1_x, v1_y, v1_z];
vector2 = [v2_x, v2_y, v2_z];

v1_v2_angle = rad2deg(atan2(norm(cross(vector1,vector2)),dot(vector1,vector2)));

set(handles.v1_v2_angle_txt, 'String', round(v1_v2_angle,2));


% --- Executes on button press in check_version_button.
function check_version_button_Callback(hObject, eventdata, handles)
% hObject    handle to check_version_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

web('https://github.com/BIVectors/BRAVEHEART');


% --- Executes on button press in convert_format_button.
function convert_format_button_Callback(hObject, eventdata, handles)
% hObject    handle to convert_format_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Choose if single file conversion or conversion of full directory
answer = questdlg('Convert ECG Format:', ...
	'Convert ECG Format:', ...
	'This File','Directory of Files','This File');
% Handle response
switch answer
    case 'This File'
        P = 1;
    case 'Directory of Files'
        P = 2;
    otherwise
        return;
end

% list = handles.ecg_source.String';   % If have ability to save for ALL formats

% If only have code to save for select formats, need to manually populate list

% list = {'BIDMC .txt', 'Prucka .txt', 'MUSE .xml', 'Unformatted .txt'};
% 
% [indx,~] = listdlg('PromptString',{'Select New Format:',' ', 'Note: Converting between', 'formats with different', 'amplitude resolutions can', 'result in converted signals', 'not being equivalent'},'ListString',list,'SelectionMode','single');
% 
% if isempty(indx)
%     return;
% end
% 
% [new_fmt, new_ext, ~] = ecg_source_string(list{indx},handles.ecg_source_hash);

% For now can only convert to 'unformatted' ECG format.
% In future will add more formats

if P == 1   % single file
    ecg_raw = handles.ecg_raw;
    filename = handles.filename(1:end-4);
    ecg_raw.write(strcat(filename,'.txt'), 'unformatted');

else        % Directory of files

    % ECG format string and file extension
    strlist = get(handles.ecg_source, 'String');
    ecg_string = strlist{get(handles.ecg_source,'Value')};
    [source_str, source_ext, ~] = ecg_source_string(ecg_string,handles.ecg_source_hash);

    % Call batch_convert with blank folder (so prompts user to choose) and progbar = 1
    [num_files, err] = batch_convert('', source_str, source_ext, 1)

    % Show complete
    mb = msgbox(sprintf('%i ECGs Converted with %i Errors', num_files-err, err),'Complete');

end % end if else for single/directory


% --- Executes on button press in vcg_morph_popout_button.
function vcg_morph_popout_button_Callback(hObject, eventdata, handles)
% hObject    handle to vcg_morph_popout_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

L = handles.vcg_morph_axis;
h = figure('name','VCG Morphology','numbertitle','off');
copyobj([L legend(L)],h);
set(gca, 'Units', 'normalized', 'Position', [.1 .1 .7 .7] );
set(gcf, 'Position', [200, 100, 1200, 1200])  % set figure size

title(handles.filename_short(1:end-4),'fontsize',14,'Interpreter', 'none');
xlabel('X','FontWeight','bold','FontSize',14);
ylabel('Y','FontWeight','bold','FontSize',14);
zlabel('Z','FontWeight','bold','FontSize',14);

rotate3d on


% --- Executes on button press in usermanual_button.
function usermanual_button_Callback(hObject, eventdata, handles)
% hObject    handle to usermanual_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

open_ext_pdf('braveheart_userguide.pdf', 'userguide');


% --- Executes on button press in errorlog_checkbox.
function errorlog_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to errorlog_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of errorlog_checkbox


function bmi_txt_Callback(hObject, eventdata, handles)
% hObject    handle to bmi_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bmi_txt as text
%        str2double(get(hObject,'String')) returns contents of bmi_txt as a double


% --- Executes during object creation, after setting all properties.
function bmi_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bmi_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in load_prev_ecg_button.
function load_prev_ecg_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_prev_ecg_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.file_index - 1 > 0 && ~isempty(handles.file_list)
handles.file_index = handles.file_index - 1;
new_file = string(handles.file_list{handles.file_index});

handles.filename = new_file;
[~,f,e] = fileparts(new_file);
handles.filename_short = strcat(f,e);

guidata(hObject, handles);  % Save to handles

% Update file number text box
set(handles.file_num_txt,'String', sprintf('# %i / %i',handles.file_index,length(handles.file_list)));
set(handles.file_num_txt,'FontSize', 8);
    if length(handles.file_list) <= 999
        set(handles.file_num_txt,'FontSize', 9);
    end
    if length(handles.file_list) >= 10000
        set(handles.file_num_txt,'FontSize', 7);
    end

% Change path text box to new file
set(handles.filename_txt,'String',new_file);

% Enable/disable prev/next ECG button based on index
if handles.file_index == 1
    set(handles.load_prev_ecg_button,'Enable','off')
else     
    set(handles.load_prev_ecg_button,'Enable','on')
end

if handles.file_index == length(handles.file_list)
	set(handles.load_next_ecg_button,'Enable','off')
else     
    set(handles.load_next_ecg_button,'Enable','on')
end

% Reload Callback
reload_Callback(hObject, eventdata, handles);
end



% --- Executes on button press in load_next_ecg_button.
function load_next_ecg_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_next_ecg_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if handles.file_index + 1 <= length(handles.file_list) && ~isempty(handles.file_list)
handles.file_index = handles.file_index + 1;
new_file = string(handles.file_list{handles.file_index});

handles.filename = new_file;
[~,f,e] = fileparts(new_file);
handles.filename_short = strcat(f,e);

guidata(hObject, handles);  % Save to handles

% Change path text box to new file
set(handles.filename_txt,'String',new_file);

% Update file number text box
set(handles.file_num_txt,'String', sprintf('# %i / %i',handles.file_index,length(handles.file_list)));
set(handles.file_num_txt,'FontSize', 8);
    if length(handles.file_list) <= 999
        set(handles.file_num_txt,'FontSize', 9);
    end
    if length(handles.file_list) >= 10000
        set(handles.file_num_txt,'FontSize', 7);
    end

% Enable/disable prev/next ECG button based on index
if handles.file_index == 1
    set(handles.load_prev_ecg_button,'Enable','off')
else     
    set(handles.load_prev_ecg_button,'Enable','on')
end

if handles.file_index == length(handles.file_list)
	set(handles.load_next_ecg_button,'Enable','off')
else     
    set(handles.load_next_ecg_button,'Enable','on')
end

% Reload Callback
reload_Callback(hObject, eventdata, handles);
end


% --- Executes on button press in checkbox83.
function checkbox83_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox83 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox83


% --- Executes on button press in normal_values_ckbox.
function normal_values_ckbox_Callback(hObject, eventdata, handles)
% hObject    handle to normal_values_ckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of normal_values_ckbox


% --- Executes on button press in normal_range_button.
function normal_range_button_Callback(hObject, eventdata, handles)
% hObject    handle to normal_range_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

filename = handles.filename_short;
save_folder = get(handles.save_dir_txt,'String');

[age, male, white, bmi] = pull_gui_demographics(hObject, eventdata, handles);

nml = NormalVals(age, male, white, bmi, handles.hr);

geh = handles.geh;
 
% Get colors based on if in light/dark mode
[dm, dark_colors, light_colors] = check_darkmode(handles);

if dm == 1
    colors = dark_colors;
else
    colors = light_colors;
end

normal_range_figure(geh, age, male, white, bmi, handles.hr, nml, save_folder, filename, colors);


% --- Executes on selection change in popupmenu16.
function popupmenu16_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu16 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu16


% --- Executes during object creation, after setting all properties.
function popupmenu16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in grid_popup.
function grid_popup_Callback(hObject, eventdata, handles)
% hObject    handle to grid_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns grid_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from grid_popup


% --- Executes during object creation, after setting all properties.
function grid_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to grid_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_dir_checkbox.
function load_dir_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to load_dir_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of load_dir_checkbox


% --- Executes on button press in variables_button.
function variables_button_Callback(hObject, eventdata, handles)
% hObject    handle to variables_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

open_ext_pdf('braveheart_variables.pdf', 'other');



function speed_t_blank_txt_Callback(hObject, eventdata, handles)
% hObject    handle to speed_t_blank_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of speed_t_blank_txt as text
%        str2double(get(hObject,'String')) returns contents of speed_t_blank_txt as a double


% --- Executes during object creation, after setting all properties.
function speed_t_blank_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to speed_t_blank_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in speed_legend_checkbox.
function speed_legend_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to speed_legend_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of speed_legend_checkbox


% --- Executes on button press in read_xml_metadata_button.
function read_xml_metadata_button_Callback(hObject, eventdata, handles)
% hObject    handle to read_xml_metadata_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

M = xml_demographics(handles.filename, handles.source_str);

% Convert structure into table data
Mtable = struct2table(M, 'AsArray',1);
rnames = Mtable.Properties.VariableNames;
Mtable = rows2vars(Mtable);
Mtable.Properties.RowNames = rnames;
Mtable.OriginalVariableNames = [];
Mtable.Properties.VariableNames = {'XML Data'};

% Display figure in GUI
fig = uifigure('name','ECG Data Summary','Position',[500,500, 390 280]);
uit = uitable(fig,"Data",Mtable,"Position",[10 10 380 270]);
s = uistyle('HorizontalAlignment','left');
addStyle(uit,s);
uit.ColumnWidth = 'auto';



% --- Executes on button press in open_ecg_file_button.
function open_ecg_file_button_Callback(hObject, eventdata, handles)
% hObject    handle to open_ecg_file_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Open ECG file with system viewer
open_ext_file(handles.filename);


% --- Executes on selection change in gender_dropdown.
function gender_dropdown_Callback(hObject, eventdata, handles)
% hObject    handle to gender_dropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns gender_dropdown contents as cell array
%        contents{get(hObject,'Value')} returns selected item from gender_dropdown


% --- Executes during object creation, after setting all properties.
function gender_dropdown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gender_dropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in race_dropdown.
function race_dropdown_Callback(hObject, eventdata, handles)
% hObject    handle to race_dropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns race_dropdown contents as cell array
%        contents{get(hObject,'Value')} returns selected item from race_dropdown


% --- Executes during object creation, after setting all properties.
function race_dropdown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to race_dropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on BRAVEHEART_GUI or any of its controls.
function BRAVEHEART_GUI_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to BRAVEHEART_GUI (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

switch eventdata.Key

    case 'f1'           % Open user guide
        usermanual_button_Callback(hObject, eventdata, handles);
    
    case 'rightarrow'   % Next ECG -- CTRL+arrow
        % Only do anything if the button is enabled
        if strcmp(eventdata.Modifier,'control')
            if strcmp(handles.load_next_ecg_button.Enable, 'on')
                load_next_ecg_button_Callback(hObject, eventdata, handles);
            end
        end

    case 'leftarrow'    % Prev ECG -- CTRL+arrow
        % Only do anything if the button is enabled
        if strcmp(eventdata.Modifier,'control')
            if strcmp(handles.load_prev_ecg_button.Enable, 'on')
                load_prev_ecg_button_Callback(hObject, eventdata, handles);
            end
        end
    
    case 'e'           % Calculate -- uses CTRL+e (not using CRL+c due to system copy function)
        if strcmp(eventdata.Modifier,'control') 
            calculate_Callback(hObject, eventdata, handles);
        end
    
    case 's'           % Export to file -- uses CTRL+s
        if strcmp(eventdata.Modifier,'control') 
            export_button_Callback(hObject, eventdata, handles);
        end

    case 'l'            % Load button -- uses CTRL+l
        if strcmp(eventdata.Modifier,'control') 
            load_button_Callback(hObject, eventdata, handles);
        end

    case 'r'            % Reload button -- uses CTRL+r
        if strcmp(eventdata.Modifier,'control') 
            reload_Callback(hObject, eventdata, handles);
        end

    case 'b'            % Batch button -- uses CTRL+b
        if strcmp(eventdata.Modifier,'control') 
            batch_load_button_Callback(hObject, eventdata, handles);
        end

    case 'downarrow'    % Next beat -- uses CTRL+DOWN        
        if strcmp(eventdata.Modifier,'control') & strcmp(handles.next_beat_button.Enable, 'on')
            next_beat_button_Callback(hObject, eventdata, handles);
        end

    case 'uparrow'      % Previous beat -- uses CTRL+UP
        if strcmp(eventdata.Modifier,'control') & strcmp(handles.prev_beat_button.Enable, 'on')
            prev_beat_button_Callback(hObject, eventdata, handles);
        end

    case 'd'            % Delete selected beat -- uses CTRL+d
        if strcmp(eventdata.Modifier,'control') & strcmp(handles.remove_selectbeat_button.Enable, 'on')
            remove_selectbeat_button_Callback(hObject, eventdata, handles);
        end

    case 'a'            % Enable/Disable 'All Auto' checkbox -- uses CTRL+a
            if strcmp(eventdata.Modifier,'control')
                if get(handles.all_auto_checkbox, 'Value') == 0
                    set(handles.auto_remove_outliers_checkbox, 'Value', 1);
                    set(handles.auto_pvc_removal_checkbox, 'Value', 1);
                    set(handles.all_auto_checkbox, 'Value', 1);
                else
                    set(handles.auto_remove_outliers_checkbox, 'Value', 0);
                    set(handles.auto_pvc_removal_checkbox, 'Value', 0);
                    set(handles.all_auto_checkbox, 'Value', 0);
                end
            end
end




% --- Executes on button press in pkfilter_checkbox.
function pkfilter_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to pkfilter_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pkfilter_checkbox


% --- Executes on button press in pushbutton167.
function pushbutton167_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton167 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in interpolate_spikes_ckbox.
function interpolate_spikes_ckbox_Callback(hObject, eventdata, handles)
% hObject    handle to interpolate_spikes_ckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of interpolate_spikes_ckbox




function pacer_zcut_txtbox_Callback(hObject, eventdata, handles)
% hObject    handle to pacer_zcut_txtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pacer_zcut_txtbox as text
%        str2double(get(hObject,'String')) returns contents of pacer_zcut_txtbox as a double


% --- Executes during object creation, after setting all properties.
function pacer_zcut_txtbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pacer_zcut_txtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pacer_zpk_txtbox_Callback(hObject, eventdata, handles)
% hObject    handle to pacer_zpk_txtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pacer_zpk_txtbox as text
%        str2double(get(hObject,'String')) returns contents of pacer_zpk_txtbox as a double


% --- Executes during object creation, after setting all properties.
function pacer_zpk_txtbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pacer_zpk_txtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pacer_maxscale_txtbox_Callback(hObject, eventdata, handles)
% hObject    handle to pacer_maxscale_txtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pacer_maxscale_txtbox as text
%        str2double(get(hObject,'String')) returns contents of pacer_maxscale_txtbox as a double


% --- Executes during object creation, after setting all properties.
function pacer_maxscale_txtbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pacer_maxscale_txtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pacer_interpolation_button.
function pacer_interpolation_button_Callback(hObject, eventdata, handles)
% hObject    handle to pacer_interpolation_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);

aps = Annoparams();
aps = pull_guiparams(hObject, eventdata, handles); 

if aps.cwt_spike_removal == 1

prespike = handles.ecg_raw;
postspike = handles.ecg_raw_postinterp;

pacer_spikes = handles.pacer_spikes;
lead_ispaced = handles.lead_ispaced;

ecgfn = fieldnames(prespike);
ecgfn(1:2) = [];

% Only show the interpolation figure if actually interpolated
if aps.interpolate == 1

figure
set(gcf, 'Position', [100, 100, 1500, 1000])  % set figure size
tiledlayout(6,2,'TileSpacing','tight','Padding','tight')
sgtitle('Pacing Spike Interpolation','fontsize',12,'fontweight','bold')

for i = 1:length(ecgfn)
nexttile
hold on

if lead_ispaced.(ecgfn{i}) == 1
    title(sprintf('%s - Pacing Detected',string(ecgfn{i})),'Color','red')
else
    title(sprintf('%s - Pacing Not Detected',string(ecgfn{i})),'Color','black')
end
p1 = plot(prespike.(ecgfn{i}),'linewidth',1.5,'Color','red');

p2 = plot(postspike.(ecgfn{i}),'linewidth',1.5,'Color','black');

% plot interpolated signal in green
    if ~isempty(pacer_spikes)
        idx = find(~isnan(pacer_spikes.(ecgfn{i})));
        only_interp = nan(1,length(prespike.(ecgfn{i})));
        only_interp(idx) = postspike.(ecgfn{i})(idx);
        p3 = plot(only_interp,'LineWidth',1.5,'color','g');
    else
        tmp = nan(1,length(prespike.(ecgfn{i})));
        p3 = plot(tmp,'LineWidth',1.5,'color','g');
    end

    if i == 2
        legend([p1 p2 p3],{'Removed Spikes','Final Signal','Interpolation'},'Location','eastoutside','FontSize',10)
    end

end

end


    % Z score data using debug
    [~,~,~] = find_and_interpolate_pacing_spikes_12L(prespike, aps, 1);

end



function pacer_num_leads_txtbox_Callback(hObject, eventdata, handles)
% hObject    handle to pacer_num_leads_txtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pacer_num_leads_txtbox as text
%        str2double(get(hObject,'String')) returns contents of pacer_num_leads_txtbox as a double


% --- Executes during object creation, after setting all properties.
function pacer_num_leads_txtbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pacer_num_leads_txtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in spike_removal_old_checkbox.
function spike_removal_old_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to spike_removal_old_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of spike_removal_old_checkbox


if get(hObject,'Value') == 1
    set(handles.cwt_pacing_remove_box,'value',0);
    set(handles.interpolate_spikes_ckbox,'value',0);
    set(handles.pacer_interpolation_button,'enable','off');
    set(handles.pacing_pkwidth_txt,'enable', 'on');
    set(handles.pacing_thresh_txt,'enable', 'on');
    set(handles.pacer_zpk_txtbox, 'enable', 'off');
    set(handles.pacer_zcut_txtbox, 'enable', 'off');
    set(handles.pacer_maxscale_txtbox, 'enable', 'off');
    set(handles.pacer_num_leads_txtbox, 'enable','off');
else
    set(handles.pacer_interpolation_button,'enable','on');
    set(handles.spike_removal_old_checkbox,'value',0);
    set(handles.pacing_pkwidth_txt,'enable', 'on');
    set(handles.pacing_thresh_txt,'enable', 'on');
    set(handles.pacer_zpk_txtbox, 'enable', 'on');
    set(handles.pacer_zcut_txtbox, 'enable', 'on');
    set(handles.pacer_maxscale_txtbox, 'enable', 'on');
    set(handles.pacer_num_leads_txtbox, 'enable','on');
end
