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

% Last Modified by GUIDE v2.5 27-Apr-2019 22:20:09

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


kt = xlsread('master_data.xlsx','kpi_tech','C4:P15');
cof = xlsread('master_data.xlsx','tech_tech','C4:N15');
const = xlsread('master_data.xlsx','constraints','F5:G16');

target_oee = str2double(get(handles.target_oee, 'String'));
target_ctm = str2double(get(handles.target_ctm, 'String'));
target_qua = str2double(get(handles.target_qua, 'String'));
time_const = str2double(get(handles.time_const, 'String'));
invest_const = str2double(get(handles.invest_const, 'String'));
max_num_tech = str2double(get(handles.max_num_tech, 'String'));

weight_oee = str2double(get(handles.weight_oee, 'String'));
weight_ctm = str2double(get(handles.weight_ctm, 'String'));
weight_qua = str2double(get(handles.weight_qua, 'String'));

labor_cost = get(handles.popupmenu2, 'Value') - 1;
cost_of_capital = get(handles.popupmenu3, 'Value') - 1;
worker_availability = get(handles.popupmenu4, 'Value') - 1;
staff_turnover = get(handles.popupmenu5, 'Value') - 1;
transport_costs = get(handles.popupmenu6, 'Value') - 1;
material_costs = get(handles.popupmenu7, 'Value') - 1;
labor_productivity = get(handles.popupmenu8, 'Value') - 1;

if get(handles.robust,'Value') == 0 
    robust = false;
else
    robust = true;
end

% load('loc_fac.mat');
lf_level = xlsread('master_data.xlsx','lf_level','C5:E11');


location_factor = (lf_level(2, cost_of_capital))/(lf_level(1, labor_cost) * lf_level(3, worker_availability)...
                                                * lf_level(4, staff_turnover) * lf_level(5, transport_costs) ...
                                                * lf_level(6, material_costs) * lf_level(7, labor_productivity));
K = max_num_tech;
handles.K = K;
[result, time_costs, invest_costs] = clc_results(K, kt, cof, const, location_factor, target_oee, target_ctm, target_qua, time_const, invest_const, robust);
% disp(handles.result_4)
result_norm = normalize(result(:,K+2:K+4), 1, 'range');
sum = weight_oee * result_norm(:,1) + weight_ctm * result_norm(:,2) +  weight_qua * result_norm(:,3);
draw_3d(result_norm)


unit_cost = normalize(sum ./ invest_costs, 1, 'range');
unit_time = normalize(sum ./ time_costs, 1, 'range');

result = [result, sum, unit_cost, unit_time];

result = sortrows(result, K+5, 'descend');
handles.result = result;
set_ui_table(K, handles)

% Update handles structure 
guidata (hObject, handles);


function set_ui_table(K, handles)
    % set UI tables

    ColumnName = {'Tech Orders', 'Num Techs','OEE', 'Customer Satisfaction', 'Quality Cost', 'Weighted Value', 'Unit Cost', 'Unit Time'};
    ColumnFormat = {'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char'};

    tech_order = handles.result(:, 1:K);
    tech_order_strs = cell(size(tech_order, 1), 1);

    for j = 1:size(tech_order, 1)
        a = tech_order(j,:);
        order_str = sprintf('%d', a(1));
        for i = 2:size(a, 2)
            if  a(i) == 0
                break
            end
            order_str = strcat(order_str, '->', sprintf('%d', a(i)));
        end
        tech_order_strs{j} = order_str;
    end

    data = handles.result(:, K+1:end);
    datacell = [tech_order_strs, num2cell(data)];
    set(handles.uitable2, 'Data', datacell, 'ColumnName', ColumnName, ...
        'RowName','numbered', 'ColumnWidth','auto', 'ColumnFormat', ColumnFormat);

    disp('well done')


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
set(handles.max_num_tech, 'String', 'Max Num Techs')
set(handles.weight_oee, 'String', 'Weight OEE')
set(handles.weight_ctm, 'String', 'Weight CTM')
set(handles.weight_qua, 'String', 'Weight QUA')
set(handles.uitable2, 'Data', {}, 'ColumnName', {}, 'RowName', {});

set(handles.popupmenu2, 'Value', 1);
set(handles.popupmenu3, 'Value', 1);
set(handles.popupmenu4, 'Value', 1);
set(handles.popupmenu5, 'Value', 1);
set(handles.popupmenu6, 'Value', 1);
set(handles.popupmenu7, 'Value', 1);
set(handles.popupmenu8, 'Value', 1);

clc; clear all;


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
set(handles.max_num_tech, 'String', '4')
set(handles.weight_oee, 'String', '0.3')
set(handles.weight_ctm, 'String', '0.3')
set(handles.weight_qua, 'String', '0.4')
set(handles.uitable2, 'Data', {});

set(handles.popupmenu2, 'Value', 2);
set(handles.popupmenu3, 'Value', 3);
set(handles.popupmenu4, 'Value', 2);
set(handles.popupmenu5, 'Value', 3);
set(handles.popupmenu6, 'Value', 2);
set(handles.popupmenu7, 'Value', 3);
set(handles.popupmenu8, 'Value', 4);


% --- Executes on button press in sort_by_unit_cost.
function sort_by_unit_cost_Callback(hObject, eventdata, handles)
% hObject    handle to sort_by_unit_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.result = sortrows(handles.result, handles.K+6, 'descend');
set_ui_table(handles.K, handles)

% Update handles structure 
guidata (hObject, handles);


% --- Executes on button press in sort_by_unit_time.
function sort_by_unit_time_Callback(hObject, eventdata, handles)
% hObject    handle to sort_by_unit_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.result = sortrows(handles.result, handles.K+7, 'descend');
set_ui_table(handles.K, handles)

% Update handles structure 
guidata (hObject, handles);













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


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5


% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu6


% --- Executes during object creation, after setting all properties.
function popupmenu6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu7.
function popupmenu7_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu7


% --- Executes during object creation, after setting all properties.
function popupmenu7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu8.
function popupmenu8_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu8


% --- Executes during object creation, after setting all properties.
function popupmenu8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function max_num_tech_Callback(hObject, eventdata, handles)
% hObject    handle to max_num_tech (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max_num_tech as text
%        str2double(get(hObject,'String')) returns contents of max_num_tech as a double


% --- Executes during object creation, after setting all properties.
function max_num_tech_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_num_tech (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu10.
function popupmenu10_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu10 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu10


% --- Executes during object creation, after setting all properties.
function popupmenu10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu11.
function popupmenu11_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu11 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu11


% --- Executes during object creation, after setting all properties.
function popupmenu11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu12.
function popupmenu12_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu12 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu12


% --- Executes during object creation, after setting all properties.
function popupmenu12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in robust.
function robust_Callback(hObject, eventdata, handles)
% hObject    handle to robust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of robust
