  function [myimage, myimfinfo] = imread_structured(filelist, slice, timepoint, switch_structured)
% function [myimage, myimfinfo] = imread_structured(filelist, slice, timepoint, switch_structured)
%
% 
% function [myimage myimfinfo] = imread_structured(filelist, slice, timepoint, switch_structured)
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
%  define the default reading mode if not set
%
% The function imread_structured is part of the MATLAB toolbox SciXMiner. 
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

if (nargin < 2)
   slice = 1;
end

if (nargin < 3)
   timepoint = 1;
end

if (nargin < 4)
   switch_structured = '';
end

%% handle different input image types
if (strcmp(switch_structured, 'slices') == 1)
   
   %% get the filename of the 3D image and check if file exists
   if iscell(filelist)
      filename = filelist{1};
   else
      filename = filelist;
   end;
   
   if (exist(filename, 'file') == 0)
      myerror( ['The file ' filename ' does not exist!'] );
      return;
   else
       myimfinfo = imfinfo_structured( filename );
   end
   
   % load the Bio-Formats library into the MATLAB environment
   status = bfCheckJavaPath(true);
   assert(status, ['Missing Bio-Formats library. Either add loci_tools.jar '...
                   'to the static Java path or add it to the Matlab path.']);
   
   % initialize logging
   loci.common.DebugTools.enableLogging('INFO');

   %% initialize the reader
   r = bfGetReader(filename, 0);
   metadataList = r.getMetadata();
   
   %% check how many images are in the stack
   numImages = r.getImageCount();
   if (numImages < slice)
      myerror( 'The amount of slices in the file is fewer than the requested layer.' );
      return;
   end
   myimage = im2double(bfGetPlane(r, slice));
   
   %% read sample from a 2D video
elseif (strcmp(switch_structured, 'samples') == 1)
   %% not implemented yet
   disp( num2str(timepoint) );
   
   %% read layer from a separate file
else
   %% check if file list is long enough for the desired slice
   if iscell(filelist) && (length(filelist) < slice)
      myerror( 'The requested slice exceeds the amount of filenames in the file list!' );
      return;
   end
   
   %% get the filename of the desired layer and check if file exists
   if iscell(filelist)
      filename = filelist{slice};
   else
      if slice == 1
         filename = filelist;
      else
         myerror( 'The requested slice exceeds the amount of filenames in the file list!' );
      end;
   end;
   
   %% check if the file exists. if it exists read the image information
   if (exist(filename, 'file') == 0)
      myerror( ['The file ' filename ' does not exist!'] );
      return;
   else
       myimfinfo = imfinfo_structured( filename );
   end
   
   %% load complete ND image depending on the type specified in myimfinfo
   if (myimfinfo.Depth > 1)
       volume = bfOpen3DVolume(filename);
       if (isa(volume{1,1}{1}, 'int32'))
           myimage = double(volume{1,1}{1});
           myimage = myimage / max(myimage(:));
       else
           myimage = im2double( volume{1,1}{1} );
       end
   else
       myimage = im2double( imread(filename) );
   end
end
