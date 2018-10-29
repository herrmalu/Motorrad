
% Load data from json. You need the Json Toolbox, found here:
% https://uk.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files


function [data] = json2mat()


liste = dir('*.json'); 
files = {liste.name}';

for k = 1:numel(files);
try
    
data = loadjson(char([files{k}]));

catch

continue
end
end

end

