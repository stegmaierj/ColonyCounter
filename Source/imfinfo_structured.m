function image_info = imfinfo_structured(filename)
% function image_info = imfinfo_structured(filename)
%
%  The function imfinfo_structured is part of the MATLAB toolbox Gait-CAD.
%  Copyright (C) 2012 [Ralf Mikut, Johannes Stegmaier, Rüdiger Alshut, Arif ul Maula Khan, Markus Reischl]
% 
% 
%  Last file change: 11-Jul-2012 16:45:07
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
%  Online available: https://sourceforge.net/projects/gait-cad/files/mikut08biosig_gaitcad.pdf/download
% 
%  Please refer to this paper, if you use Gait-CAD for your scientific work.
% 
% 
%     
%      get the filename of the 3D image and check if file exists
%
% The function imfinfo_structured is part of the MATLAB toolbox SciXMiner. 
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

    if (exist(filename, 'file') == 0)
        myerror( ['No file info available. The file ' filename ' does not exist!'] );
        return;
    end
    
    %% use matlab function if the image is not a 3D data type
    try
        image_info = imfinfo(filename);
        
        numZSlices = size(image_info, 1);
        if (numZSlices > 1)
            image_info = image_info(1);
            image_info.Depth = numZSlices;
        else
            image_info.Depth = 1;
        end
        
        %% set spacing to default. Can be changed manually using a plugin
        image_info.Spacing = [1,1];
    
    %% use bioformats loci if matlab function is unable to extract the info
    catch
        
        %% initialize the reader
        r = bfGetReader(filename, 0);
        
        %% fill the image_info structure
        %% available fields are listed here: http://fiji.sc/javadoc/loci/formats/ReaderWrapper.html
        pixelType = r.getPixelType();
        bytesPerPixel = loci.formats.FormatTools.getBytesPerPixel(pixelType);
        
        image_info.Filename = filename;
        image_info.FileModDate = '';
        image_info.Format = 'btf'
        image_info.FormatVersion = ''
        image_info.Width = r.getSizeX();
        image_info.Height = r.getSizeY();
        image_info.Depth = r.getSizeZ();        
        image_info.BitDepth = bytesPerPixel*8;
        if (r.isRGB() == true)
            image_info.ColorType = 'truecolor';
        else
            image_info.ColorType = 'grayscale';
        end
        image_info.FormatSignature = '';
        image_info.NumberOfSamples = r.getImageCount();
        image_info.FileSize = (image_info.NumberOfSamples * image_info.Height * image_info.Width) * bytesPerPixel;
        image_info.CodingMethod = ''; %% Find out which values are available
        image_info.CodingProcess = ''; %% Find out which values are available
        image_info.Comment = {};
        image_info.Spacing = [1,1,1];   %% set spacing to default. Can be changed manually using a plugin
    end
end