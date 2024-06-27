%% COLORMAP2
% Zel Hurewitz
% 3/29/2022
% 
% A new set of colormaps. Some are based on brewermap by Stephen Cobeldick
% as noted in the 'cmapstruct' function of the file.
% Options:
% Note: case-insensitive
% 'N', n: Number of colors. Alternatively, have the number be your second
% input (i.e. colormap2('copper',20) works)
% 'Diverging': Specifies if the colormap is diverging
% 'Range' or 'Data', range : input the data or the range of the color axis
% 'Axis', axis: specify the target axis
% 'Flip': flips the colormap
% 'Base' or 'Original': returns the built-in colormap base, overriding all other
% arguments
% 'Names': returns string array of the names of built-in colormaps
% 'Struct': returns struct of the built-in colormaps
% 'Plot': plots the built-in colormaps
% 
% Example usage:
% colormap2('redblue',64,'Range',[-20,10],'Axis',gca)
% colormap2('copper','Range',[-11,1])
% cmap= colormap2('bulb');
% colormap2('bulb',100,'diverging','Range',data)
% colormap2(cmap,100,'diverging','Range',data)
% colormap2('help')
% colormap2


function cmap= colormap2(mapname,varargin)
% Load all built-in colormaps
S= cmapstruct;


% Parse input

if nargin == 0 || ischar(mapname) && (contains(mapname,'help','IgnoreCase',true) || ...
        any(strcmpi(mapname,{'-h','--h'})))
    disphelp
    return
end

if ~isempty(varargin) && isnumeric(varargin{1}) && ~isempty(varargin{1})
    N= varargin{1};
else
    N= parseIn(varargin, 'N');
    if isempty(N)
        N= 256;
    end
end

DIVERGING= any(strcmpi(varargin,'diverging'));

RANGE= parseIn(varargin, 'range');
if isempty(RANGE)
    RANGE= parseIn(varargin, 'data');
end
if ~ischar(RANGE)
    RANGE= double(RANGE);
end

AXIS= parseIn(varargin, 'axis');

BASE= any(strcmpi(varargin,'base') | strcmpi(varargin,'original'));

FLIP= any(strcmpi(varargin,'flip'));


% Directly returns the struct containing the built-in colormaps
% Implemented for debugging reasons
if strcmpi(mapname,'struct')
    cmap= cmapstruct;
    return
end

% Directly returns the names of built-in colormaps
if any(strcmpi(mapname, {'name','names'}))
    cmap= string({S.name});
    return
end

if strcmpi(mapname,'plot')
    plotall
    return
end



%% Select Base Colormap

if isnumeric(mapname)
    cmap= mapname;
    
    if islogical(cmap) || any(cmap < 0,'all') 
        error('Colormap2: Input colormap must be positive numeric')
    end
    
    if any(cmap > 255,'all')
        error('Colormap2: Input cannot be greater than 255')
    end
    
    if any(cmap > 1,'all')
        warning on
        warning('Colormap2: Scaling input colormap to [0 1] (assuming max 255)')
        cmap= cmap/255;
    end
    
    if size(cmap,2) ~= 3 || size(cmap,1) < 2
        error('Colormap2: Must be Mx3 matrix, M> 1')
    end
    
else
    % Modify name in special cases which allow it
    mname= pad(mapname,6);
    if strcmpi(mname(1:6),'squirt')
        mapname= 'squirt';
    elseif strcmpi(mapname,'bluered')
        mapname= 'redblue';
        FLIP= true;
    end
    % Note: phase these out
    
    
    % Index within struct
    i= find(arrayfun(@(S) strcmpi(S.name,mapname),S),1);
    
    if isempty(i)
        error('Colormap2: Colormap not found')
    end
    
    % Extract base colormap
    cmap= S(i).cmap;
    
    if FLIP; cmap= flip(cmap); end
    
    if S(i).diverging; DIVERGING= true; end
    % Note: Have to be careful here not to override input which desires
    % diverging
    
    % Rescale to [0 1]
    cmap= cmap/255;
end


%% Interpolate

if ~isempty(RANGE) && isnumeric(RANGE)
    % Take the min and max if "range" is actually data
    if numel(RANGE) < 2
        error('Colormap2: Range must contain 2 or more values')
        
    elseif numel(RANGE) > 2
        RANGE= [min(RANGE,[],'all','omitnan') max(RANGE,[],'all','omitnan')];
        
    elseif any(isnan(RANGE) | isinf(RANGE),'all')
        RANGE2= crange(AXIS);
        
        if isnan(RANGE(1)) || isinf(RANGE(1))
            RANGE(1)= RANGE2(1);
        end
        if isnan(RANGE(2)) || isinf(RANGE(2))
            RANGE(2)= RANGE2(2);
        end
    end
    
else
    RANGE= crange(AXIS);
    if DIVERGING
        RANGE(1)= -RANGE(2);
    end
    RANGE= sort(RANGE);
end

if DIVERGING
    % Rescale by maximum of absolute value
    absrangemax= max(abs(RANGE));
    
    % Interpolation values
    % Rescale from [-1 1] to [0 1]
    z= linspace(RANGE(1)/absrangemax,RANGE(2)/absrangemax,N)*.5+ .5;
else
    z= linspace(0,1,N);
end

% Interpolate the colormap
if ~BASE
    cmap= interp1(linspace(0,1,size(cmap,1)),cmap,z);
end


%% Set Colormap

% If no output is desired, set colormap in axis
if nargout == 0
    if ~isempty(AXIS)
        colormap(AXIS,cmap)
        clim(AXIS,RANGE);
    else
        colormap(cmap)
        clim(RANGE);
    end
    
    clear cmap
end



end



%% Utility Functions

% Color range in axis
function RANGE= crange(AXIS)
if ~isempty(AXIS)
    RANGE= get(AXIS,'CLim');
else
    RANGE= get(gca,'CLim');
end
if RANGE(1) == RANGE(2)
    RANGE= [-1 1]+ RANGE(1);
end
end


% Parse Input

function value= parseIn(VARARGIN,key)
value= [];
I= find(strcmpi(VARARGIN,key));
if ~isempty(I) && length(VARARGIN) >= I+1
    value= VARARGIN{I+1};
end
end


% Display Help

function disphelp
disp('Colormap2')
disp('Zel Hurewitz')
disp('Mar 2022')
disp([newline 'Input:'])
disp('mapname: name of a built-in map OR your own colormap (size Ncolor x 3, range [0,1])')

disp([newline 'Optional Input: '])
disp("'Names': Returns names of built-in colormaps instead")
disp("'N': number of colors in output colormap, default 256. ")
disp("    Alternatively, have the number be your second input (i.e. colormap2('copper',20))")
disp("'Diverging': Specifies if the colormap is diverging")
disp("'Range' or 'Data': input the desired range of the color axis or the data itself")
disp("'Axis': specify the target axis")
disp("'Flip': flips the base colormap")

disp([newline 'Example Use:'])
disp("colormap2('redblue',64,'Range',[-20,10],'Axis',gca)")
disp("colormap2(cmap,100,'diverging','Data',data)")
disp("cmap= colormap2('fire');")

disp([newline 'Built-in Colormaps:'])
S= cmapstruct;
disp(join(string({S.name}),', '))
end


% Plot All Built-in Colormaps

function plotall
S= colormap2('struct');
names= {S.name};
Nc= numel(S);
N= 256;

CIM= zeros(N,Nc,3);
for i= 1:Nc
    cmap= colormap2(S(i).name,N);
    CIM(:,i,:)= reshape(cmap,N,1,3);
end

image(CIM)
set(gca,'FontSize',16,'YDir','normal')
yticklabels({})
xticks(1:Nc)
xticklabels(names)
title('Built-In Colormaps')
end




%% Built-In Colormaps

function S= cmapstruct

S= struct();

i= 1;
S(i).name= 'charm';
S(i).cmap= [246   237   198
    222   175   108
    193   103    54
    160    55    25
    113    24     8];

% i= i+1;
% S(i).name= 'bulb';
% S(i).cmap= [30   140   150
%     95   210   180
%     145   235   175
%     160   225   130
%     150   195    80
%     115   155     0];

i= i+1;
S(i).name= 'squirt';
S(i).cmap= [19    91   120
    67   153   180
   130   196   217
   192   225   236
   236   241   237
   242   227   206
   227   195   157
   188   136    86
   125    65    11];
S(i).diverging= true;

i= i+1;
S(i).name= 'redblue';
S(i).cmap= [103     0    31
    178    24    43
    214    96    77
    244   165   130
    253   219   199
    247   247   247
    209   229   240
    146   197   222
    67   147   195
    33   102   172
    5    48    97]; % Source: brewermap (Stephen Cobeldick)
S(i).diverging= true;

i= i+1;
S(i).name= 'pikachu';
S(i).cmap= [71    11     0
   149    82     0
   212   176    28
   240   229    93
   255   255   236];

i= i+1;
S(i).name= 'copper';
S(i).cmap= [47    15     3
   119    46    11
   176    88    37
   214   131    75
   239   182   126
   251   234   182];

% i= i+1;
% S(i).name= 'earth';
% S(i).cmap= [60    30    20
%     70    70    20
%     85   130    45
%     110   180   110
%     135   220   205];

i= i+1;
S(i).name= 'fire';
S(i).cmap= [ 20     0     0
    100     4     0
   150    20     1
   190    41     8
   220    80    23
   230   135    47
   250   187    78
   255   229   121
   255   255   185
   255 255 255];
% S(i).cmap= [ 30     0     0 % Old version
%     77     4     0
%    113    20     1
%    148    41     8
%    175    80    23
%    203   135    47
%    223   187    78
%    240   229   121
%    248   255   185];

i= i+1;
S(i).name= 'vir';
S(i).cmap= [25    10    76
    25    66    94
    46   132   108
    75   176    98
   122   208   105
   191   227   126
   243   228   136];

i= i+1;
S(i).name= 'magenta';
S(i).cmap= [28     0    47
    39     0    91
    49     4   140
    76    16   182
   113    35   214
   158    58   234
   206    78   244];

% i= i+1;
% S(i).name= 'bluebrown';
% S(i).cmap= [0    42    85
%     53   106   171
%    134   170   222
%    204   226   246
%    240   251   245
%    238   243   205
%    217   208   129
%    171   146    55
%     86    56     0];
% S(i).diverging= true;

i= i+1;
S(i).name= 'royal';
S(i).cmap= [0     0   109
    56    17   144
   130    61   184
   198   137   222
   254   239   255];

i= i+1;
S(i).name= 'seafoam';
S(i).cmap= [14    14    56
    23    58    88
    37   109   122
    54   154   141
    79   186   156
   115   217   176
   161   246   208];



i= i+1;
S(i).name= 'forest';
S(i).cmap= [9    18    17
    28    57    37
    47   100    50
    84   145    56
   135   189    50
   186   245    18];

i= i+1;
S(i).name= 'deeps';
S(i).cmap= [10    10    56
    23    23   104
    40    58   138
    62   106   168
    89   148   197
   129   194   224
   185   234   248];

i= i+1;
S(i).name= 'sunset';
S(i).cmap= [23     7    63
    92    20   102
   141    40    90
   176    68    76
   204   112    97
   227   160   127
   243   223   156];

i= i+1;
S(i).name= 'phase';
S(i).cmap= [35    11    71
    12    21    80
    27    79   108
    47   141    47
   170   189    75
   216   171   104
   211   123   107
   170    72    96
    91    25    98
    35    11    71];
S(i).cyclical= true;


for i= 1:length(S)
    if isempty(S(i).diverging)
        S(i).diverging= false;
    end
    if isempty(S(i).cyclical)
        S(i).cyclical= false;
    end
end

end



