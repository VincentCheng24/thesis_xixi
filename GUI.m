function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 28-Mar-2019 21:17:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
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


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% --- Executes on button press in start.


%%

function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


kt = xlsread('kpi_tech.xlsx', 'C16:P27');
cof = xlsread('tech_tech.xlsx','A14:L25');
const = xlsread('constraints.xlsx', 'E2:F13');

target_oee = str2double(get(handles.target_oee, 'String'));
target_ctm = str2double(get(handles.target_ctm, 'String'));
target_qua = str2double(get(handles.target_qua, 'String'));
time_const = str2double(get(handles.time_const, 'String'));
invest_const = str2double(get(handles.invest_const, 'String'));

weight_oee = str2double(get(handles.weight_oee, 'String'));
weight_ctm = str2double(get(handles.weight_ctm, 'String'));
weight_qua = str2double(get(handles.weight_qua, 'String'));

labor_cost = str2double(get(handles.labor_cost, 'String'));
cost_of_capital = str2double(get(handles.cost_of_capital, 'String'));
worker_availability = str2double(get(handles.worker_availability, 'String'));
staff_turnover = str2double(get(handles.staff_turnover, 'String'));
transport_costs = str2double(get(handles.transport_costs, 'String'));
material_costs = str2double(get(handles.material_costs, 'String'));
labor_productivity = str2double(get(handles.labor_productivity, 'String'));

load('loc_fac.mat');

location_factor = (loc_fac(2, cost_of_capital))/(loc_fac(1, labor_cost) * loc_fac(3, worker_availability)...
                                                * loc_fac(4, staff_turnover) * loc_fac(5, transport_costs) ...
                                                * loc_fac(6, material_costs) * loc_fac(7, labor_productivity));

result = clc_results(kt, cof, const, location_factor, target_oee, target_ctm, target_qua, time_const, invest_const);
% disp(handles.result_4)
result(:,8) = -result(:,8);
result_norm = normalize(result(:,6:8), 1, 'range');
sum = weight_oee * result_norm(:,1) + weight_ctm * result_norm(:,2) +  weight_qua * result_norm(:,3);

% result(:,6:8) = normalize(result(:,6:8), 1, 'range');
% sum = weight_oee * result(:,6) + weight_ctm * result(:,7) +  weight_qua * result(:,8);

result = [result, sum];
result = sortrows(result, 9, 'descend');

handles.result = result;
% data = handles.result(:, 6:8);
draw_3d(result_norm)
set(handles.uitable2, 'Data', handles.result);


% --- Executes on button press in clear.
function clear_Callback(hObject, eventdata, handles)
% hObject    handle to clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


set(handles.target_oee, 'String', 'Target OEE')
set(handles.target_ctm, 'String', 'Target CTM')
set(handles.target_qua, 'String', 'Target QUA')
set(handles.time_const, 'String', 'Time Const')
set(handles.invest_const, 'String', 'Invest Const')
set(handles.weight_oee, 'String', 'Weight OEE')
set(handles.weight_ctm, 'String', 'Weight CTM')
set(handles.weight_qua, 'String', 'Weight QUA')
set(handles.uitable2, 'Data', {});

set(handles.labor_cost, 'String', 'Labor Costs');
set(handles.cost_of_capital, 'String', 'Cost of Capital');
set(handles.worker_availability, 'String', 'Worker Availability');
set(handles.staff_turnover, 'String', 'Staff Turnover');
set(handles.transport_costs, 'String', 'Transport Costs');
set(handles.material_costs, 'String', 'Material Costs');
set(handles.labor_productivity, 'String', 'Labor Productivity');

clc; clear all


% --- Executes on button press in test.
function test_Callback(hObject, eventdata, handles)
% hObject    handle to test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.target_oee, 'String', '0')
set(handles.target_ctm, 'String', '0')
set(handles.target_qua, 'String', '0')
set(handles.time_const, 'String', '10000')
set(handles.invest_const, 'String', '1000000')
set(handles.weight_oee, 'String', '0.3')
set(handles.weight_ctm, 'String', '0.3')
set(handles.weight_qua, 'String', '0.4')
set(handles.uitable2, 'Data', {});

set(handles.labor_cost, 'String', '1');
set(handles.cost_of_capital, 'String', '2');
set(handles.worker_availability, 'String', '1');
set(handles.staff_turnover, 'String', '1');
set(handles.transport_costs, 'String', '2');
set(handles.material_costs, 'String', '1');
set(handles.labor_productivity, 'String', '3');


function target_oee_Callback(hObject, eventdata, handles)
% hObject    handle to target_oee (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of target_oee as text
%        str2double(get(hObject,'String')) returns contents of target_oee as a double


% --- Executes during object creation, after setting all properties.
function target_oee_CreateFcn(hObject, eventdata, handles)
% hObject    handle to target_oee (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function target_ctm_Callback(hObject, eventdata, handles)
% hObject    handle to target_ctm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of target_ctm as text
%        str2double(get(hObject,'String')) returns contents of target_ctm as a double


% --- Executes during object creation, after setting all properties.
function target_ctm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to target_ctm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function target_qua_Callback(hObject, eventdata, handles)
% hObject    handle to target_qua (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of target_qua as text
%        str2double(get(hObject,'String')) returns contents of target_qua as a double


% --- Executes during object creation, after setting all properties.
function target_qua_CreateFcn(hObject, eventdata, handles)
% hObject    handle to target_qua (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function time_const_Callback(hObject, eventdata, handles)
% hObject    handle to time_const (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time_const as text
%        str2double(get(hObject,'String')) returns contents of time_const as a double


% --- Executes during object creation, after setting all properties.
function time_const_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_const (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function invest_const_Callback(hObject, eventdata, handles)
% hObject    handle to invest_const (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of invest_const as text
%        str2double(get(hObject,'String')) returns contents of invest_const as a double


% --- Executes during object creation, after setting all properties.
function invest_const_CreateFcn(hObject, eventdata, handles)
% hObject    handle to invest_const (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function weight_oee_Callback(hObject, eventdata, handles)
% hObject    handle to weight_oee (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of weight_oee as text
%        str2double(get(hObject,'String')) returns contents of weight_oee as a double


% --- Executes during object creation, after setting all properties.
function weight_oee_CreateFcn(hObject, eventdata, handles)
% hObject    handle to weight_oee (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function weight_ctm_Callback(hObject, eventdata, handles)
% hObject    handle to weight_ctm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of weight_ctm as text
%        str2double(get(hObject,'String')) returns contents of weight_ctm as a double


% --- Executes during object creation, after setting all properties.
function weight_ctm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to weight_ctm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function weight_qua_Callback(hObject, eventdata, handles)
% hObject    handle to weight_qua (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of weight_qua as text
%        str2double(get(hObject,'String')) returns contents of weight_qua as a double


% --- Executes during object creation, after setting all properties.
function weight_qua_CreateFcn(hObject, eventdata, handles)
% hObject    handle to weight_qua (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function labor_cost_Callback(hObject, eventdata, handles)
% hObject    handle to labor_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of labor_cost as text
%        str2double(get(hObject,'String')) returns contents of labor_cost as a double


% --- Executes during object creation, after setting all properties.
function labor_cost_CreateFcn(hObject, eventdata, handles)
% hObject    handle to labor_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cost_of_capital_Callback(hObject, eventdata, handles)
% hObject    handle to cost_of_capital (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cost_of_capital as text
%        str2double(get(hObject,'String')) returns contents of cost_of_capital as a double


% --- Executes during object creation, after setting all properties.
function cost_of_capital_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cost_of_capital (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function worker_availability_Callback(hObject, eventdata, handles)
% hObject    handle to worker_availability (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of worker_availability as text
%        str2double(get(hObject,'String')) returns contents of worker_availability as a double


% --- Executes during object creation, after setting all properties.
function worker_availability_CreateFcn(hObject, eventdata, handles)
% hObject    handle to worker_availability (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function staff_turnover_Callback(hObject, eventdata, handles)
% hObject    handle to staff_turnover (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of staff_turnover as text
%        str2double(get(hObject,'String')) returns contents of staff_turnover as a double


% --- Executes during object creation, after setting all properties.
function staff_turnover_CreateFcn(hObject, eventdata, handles)
% hObject    handle to staff_turnover (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function transport_costs_Callback(hObject, eventdata, handles)
% hObject    handle to transport_costs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of transport_costs as text
%        str2double(get(hObject,'String')) returns contents of transport_costs as a double


% --- Executes during object creation, after setting all properties.
function transport_costs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to transport_costs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function material_costs_Callback(hObject, eventdata, handles)
% hObject    handle to material_costs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of material_costs as text
%        str2double(get(hObject,'String')) returns contents of material_costs as a double


% --- Executes during object creation, after setting all properties.
function material_costs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to material_costs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function labor_productivity_Callback(hObject, eventdata, handles)
% hObject    handle to labor_productivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of labor_productivity as text
%        str2double(get(hObject,'String')) returns contents of labor_productivity as a double


% --- Executes during object creation, after setting all properties.
function labor_productivity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to labor_productivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
