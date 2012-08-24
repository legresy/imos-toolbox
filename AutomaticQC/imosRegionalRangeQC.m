function [data, flags, log] = imosRegionalRangeQC ( sample_data, data, k, type, auto )
%IMOSREGIONALRANGEQC Flags data which is out of the variable's valid regional range.
%
% Iterates through the given data, and returns flags for any samples which
% do not fall within the regionalRangeMin and regionalRangeMax fields for the given
% mooring site and variable in imosRegionalRangeQC.txt.
%
% Inputs:
%   sample_data - struct containing the entire data set and dimension data.
%
%   data        - the vector of data to check.
%
%   k           - Index into the sample_data.variables vector.
%
%   type        - dimensions/variables type to check in sample_data.
%
%   auto        - logical, run QC in batch mode
%
% Outputs:
%   data        - same as input.
%
%   flags       - Vector the same length as data, with flags for corresponding
%                 data which is out of range.
%
%   log         - Empty cell array.
%
% Author:       Guillaume Galibert <guillaume.galibert@utas.edu.au>
%

%
% Copyright (c) 2009, eMarine Information Infrastructure (eMII) and Integrated 
% Marine Observing System (IMOS).
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are met:
% 
%     * Redistributions of source code must retain the above copyright notice, 
%       this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright 
%       notice, this list of conditions and the following disclaimer in the 
%       documentation and/or other materials provided with the distribution.
%     * Neither the name of the eMII/IMOS nor the names of its contributors 
%       may be used to endorse or promote products derived from this software 
%       without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.
%

error(nargchk(4, 5, nargin));
if ~isstruct(sample_data),        error('sample_data must be a struct'); end
if ~isvector(data),               error('data must be a vector');        end
if ~isscalar(k) || ~isnumeric(k), error('k must be a numeric scalar');   end
if ~ischar(type),                 error('type must be a string');        end

% auto logical in input to enable running under batch processing
if nargin<5, auto=false; end

log   = {};
flags   = [];

if ~strcmp(type, 'variables'), return; end

% let's handle the case we have multiple same param distinguished by "_1",
% "_2", etc...
paramName = sample_data.(type){k}.name;
iLastUnderscore = strfind(paramName, '_');
if iLastUnderscore > 0
    iLastUnderscore = iLastUnderscore(end);
    if length(paramName) > iLastUnderscore
        if ~isnan(str2double(paramName(iLastUnderscore+1:end)))
            paramName = paramName(1:iLastUnderscore-1);
        end
    end
end

% get details from this site
%     site = sample_data.meta.site_name; % source = ddb
%     if strcmpi(site, 'UNKNOWN'), site = sample_data.site_code; end % source = global_attributes file
site = sample_data.site_code;
site = imosSites(site);

% test if site information exists
if isempty(site)
    fprintf('%s\n', ['Warning : ' 'No site information found to '...
        'perform regional range QC test']);
else
    % read values from imosRegionalRangeQC properties file
    [regionalMin, regionalMax, isSite] = getImosRegionalRange(site.name, paramName);
    
    if ~isSite
        fprintf('%s\n', ['Warning : ' 'File imosRegionalRangeQC.txt is not documented '...
        'for site ' site.name]);
    else
        if ~isnan(regionalMin)
            % get the flag values with which we flag good and out of range data
            qcSet     = str2double(readProperty('toolbox.qc_set'));
            rangeFlag = imosQCFlag('bad', qcSet, 'flag');
            rawFlag   = imosQCFlag('raw',   qcSet, 'flag');
            goodFlag  = imosQCFlag('good',  qcSet, 'flag');
            
            lenData = length(data);
            
            % initialise all flags to non QC'd
            flags = ones(lenData, 1)*rawFlag;
            
            if regionalMax ~= regionalMin
                % initialise all flags to bad
                flags = ones(lenData, 1)*rangeFlag;
                
                iPassed = data <= regionalMax;
                iPassed = iPassed & data >= regionalMin;
                
                % add flags for in range values
                flags(iPassed) = goodFlag;
                flags(iPassed) = goodFlag;
            end
        end
    end
end

end