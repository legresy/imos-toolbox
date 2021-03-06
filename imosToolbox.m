function imosToolbox(auto, varargin)
%IMOSTOOLBOX Starts the IMOS toolbox.
%
% This function is the entry point for the IMOS toolbox.
%
% Inputs:
%   auto     - optional String parameter - if 'auto', the toolbox is executed
%              automatically, with no user interaction. Any other string will
%              result in the toolbox being executed normally.
%   varargin - In 'auto' mode, any other parameters passed in are passed 
%              through to the autoIMOSToolbox function - see the
%              documentation for that function for details.
%
% Author: Paul McCarthy <paul.mccarthy@csiro.au>
% Contributor: Gordon Keith <gordon.keith@csiro.au>
%    -now adds any .jar found in Java directory to the path so that any driver
%    can be used to connect to a deployment database for example.
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

if nargin == 0, auto = 'manual'; end

% Set current toolbox version
toolboxVersion = ['2.5 beta (testing purpose only) - ' computer];

% we must dynamically add the ddb.jar java library to the classpath
% as well as any other .jar library and jdbc drivers
path = '';
if ~isdeployed, [path, ~, ~] = fileparts(which('imosToolbox.m')); end
if isempty(path), path = pwd; end
jars = fsearch('.jar', fullfile(path, 'Java'), 'files');
for j = 1 : length(jars)
    javaaddpath(jars{j});
end

switch auto
  
  case 'auto', autoIMOSToolbox(toolboxVersion, varargin{:});
  otherwise,   flowManager(toolboxVersion);
end
