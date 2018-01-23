function [asymstruct, newVoc] = asymmetricize(symstruct, BC)
%ASYMMETRICIZE - Break a symmetrical solution in two halves and stabilize the
% asymmetrical model at pseudo-OC conditions applying Vapp equal to Voc
% taken from the symmetrical solution
%
% Syntax:  [sol, newVoc] = asymmetricize(ssol, BC)
%
% Inputs:
%   SYMSTRUCT - a symmetric struct as created by pindrift using the OC
%     parameter set to 1
%
% Outputs:
%
%
% Example:
%   [sol_i_light_OC, newVoc] = asymmetricize(ssol_i_light, 1)
%     take the first half of symmetrical solution at open circuit
%
% Other m-files required: pindrift
% Subfunctions: none
% MAT-files required: none
%
% See also pindrift.

% Author: Ilario Gelmetti, Ph.D. student, perovskite photovoltaics
% Institute of Chemical Research of Catalonia (ICIQ)
% Research Group Prof. Emilio Palomares
% email address: iochesonome@gmail.com  
% October 2017; Last revision: November 2017

%------------- BEGIN CODE --------------

p = symstruct.params;
p.OC = 0; % without setting OC to 0 BC gets ignored, OC 0 is needed for the asymmetric solution
p.BC = BC;
p.tpoints = 5; % rough, just for re-stabilization at Vapp

% get the Voc value in the middle of the symmetrical solution at the final time step
Voc = symstruct.Voc(end);
p.Vapp = Voc; % use potential value in the middle as new applied voltage, this is needed for BC 0

% set an initial time for stabilization tmax
if p.mui
    p.tmax = 2^(-log10(p.mui)) / 10 + 2^(-log10(p.mue_i));
else
    p.tmax = 2^(-log10(p.mue_i));
end

% halve the solution
centerIndex = ceil(length(symstruct.x) / 2); % get the index of the middle of the x mesh
sol_ic.sol = symstruct.sol(end, 1:centerIndex, :); % take the first spatial half of the matrix, at last time step
sol_ic.x = symstruct.x(1:centerIndex); % providing just sol to pindrift is not enough, a more complete structure is needed, including at least x mesh

% stabilize the divided solution
asymstruct = pindrift(sol_ic, p); % should already be stable...
newVoc = asymstruct.Efn(end) - asymstruct.Efp(1);
disp([mfilename ' - Symmetric solution voltage was ' num2str(Voc) '; asymmetrized solution voltage is ' num2str(newVoc)])

%------------- END OF CODE --------------
