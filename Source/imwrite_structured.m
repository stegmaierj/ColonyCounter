  function [] = imwrite_structured(myimage, filename, layer, timepoint, switch_structured, useSmallDataType)
% function [] = imwrite_structured(myimage, filename, layer, timepoint, switch_structured, useSmallDataType)
%
% 
% 
%  The function imread_structured is part of the MATLAB toolbox Gait-CAD.
%  Copyright (C) 2012 [Ralf Mikut, Johannes Stegmaier, Rüdiger Alshut, Arif ul Maula Khan, Markus Reischl]
% 
% 
%  Last file change: 10-Sep-2012 14:55:00
% 
%  This program is free software; you can redistribute it and/or modify,
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation; either version 2 of the License, or any later version.
% 
%  This program is distributed in the hope that it will be useful, but
%  WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% 
%  You should have received a copy of the GNU General Public License along with this program;
%  if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA.
% 
%  You will find further information about Gait-CAD in the manual or in the following conference paper:
% 
%  STEGMAIER,J.;ALSHUT,R.;REISCHL,M.;MIKUT,R.: Information Fusion of Image Analysis, Video Object Tracking, and Data Mining of Biological Images using the Open Source MATLAB Toolbox Gait-CAD.
%  In:  Proc., DGBMT-Workshop Biosignal processing, Jena, 2012, pp. 109-111; 2012
%  Online available: http://www.degruyter.com/view/j/bmte.2012.57.issue-s1-B/bmt-2012-4073/bmt-2012-4073.xml
% 
%  Please refer to this paper, if you use Gait-CAD with the ImVid extension for your scientific work.
% 
%      define the default reading mode if not set
%
% The function imwrite_structured is part of the MATLAB toolbox SciXMiner. 
% Copyright (C) 2010  [Ralf Mikut, Tobias Loose, Ole Burmeister, Sebastian Braun, Andreas Bartschat, Johannes Stegmaier, Markus Reischl]


% Last file change: 15-Aug-2016 11:31:12
% 
% This program is free software; you can redistribute it and/or modify,
% it under the terms of the GNU General Public License as published by 
% the Free Software Foundation; either version 2 of the License, or any later version.
% 
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License along with this program;
% if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA.
% 
% You will find further information about SciXMiner in the manual or in the following conference paper:
% 
% 
% Please refer to this paper, if you use SciXMiner for your scientific work.

    if (nargin < 3)
       layer = 1;
    end

    if (nargin < 4)
       timepoint = 1;
    end

    if (nargin < 5)
       switch_structured = '';
    end
    
    if (nargin < 6)
        useSmallDataType = false;
    end
    
    if iscell(myimage) && length(myimage) == 1
       myimage = myimage{1};
    end;

    %% convert the image to 8Bit uint by default and swap x-y dimension
    [pathstr, name, ext] = fileparts(filename);
    if (strcmpi(ext, '.jpg') == 1 || strcmpi(ext, '.jpeg') == 1 || useSmallDataType == true)
        myimage = im2uint8( myimage );
    else
        myimage = im2uint16( myimage );
    end
    filename = regexprep(filename, 'btf', 'tif');

    %% handle the different write commands
    if (strcmp(switch_structured, 'slices') == 1)
        %% really write single slices instead of whole image at once?
        %% writing slices needs to access the bfsave function.
        bfsave(myimage, filename);
    elseif (strcmp(switch_structured, 'samples') == 1)
        myerror( 'Writing video files is not implemented yet!' );
    else
        if (size(myimage, 3) > 3)
            if (exist( filename, 'file') > 0)
                delete( filename );
            end
            bfsave( myimage, filename );
        else
            %% automatically handle layer and timepoint filename adjustments?
            imwrite( myimage, filename );
        end
    end
end