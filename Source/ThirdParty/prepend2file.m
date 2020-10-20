function prepend2file( string, filename, newline )
%% Copyright notice: 
%% Code was copied from the following blog entry: https://de.mathworks.com/matlabcentral/answers/98758-how-can-i-prepend-text-to-a-file-using-matlab

tempFile = tempname;
fw = fopen( tempFile, 'wb' );
if nargin < 3
newline = false;
end
if newline
fwrite( fw, sprintf('%s\n', string ) );
else
fwrite( fw, string );
end

fclose( fw );
appendFiles( filename, tempFile );
copyfile( tempFile, filename );
delete(tempFile);

% append readFile to writtenFile
function status = appendFiles( readFile, writtenFile )
fr = fopen( readFile, 'rb' );
fw = fopen( writtenFile, 'ab' );

while feof( fr ) == 0
tline = fgetl( fr );
fwrite( fw, sprintf('%s\n',tline ) );
end
fclose(fr);
fclose(fw);