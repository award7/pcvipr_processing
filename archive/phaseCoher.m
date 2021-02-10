% Phase coherence function.
%
% INPUT:    velocity matrix v(res,res,res,3)
%           method, can be 'dev', 'lpc1' or 'lpc2'
% OUTPUT:   phase coherence matrix C(res,res,res)
%           method used
%
% Author: Erik Spaak

function [C, method] = phaseCoher(vel, method)

global res

%
% Phase coherence

v_xCroped = vel(2:res-1, 2:res-1, 2:res-1,1);
v_yCroped = vel(2:res-1, 2:res-1, 2:res-1,2);
v_zCroped = vel(2:res-1, 2:res-1, 2:res-1,3);

C = zeros(res,res,res);
counter= 0;

if strcmp(method, 'dev')

% CM_dev as implemented by Schmidt

    for i = -1:1
        for j = -1:1
            for k = -1:1

                 v_xPad = padarray(v_xCroped, [i+1 j+1 k+1], 'pre');
                 v_xPad = padarray(v_xPad, [-i+1 -j+1 -k+1], 'post');

                 v_yPad = padarray(v_yCroped, [i+1 j+1 k+1], 'pre');
                 v_yPad = padarray(v_yPad, [-i+1 -j+1 -k+1], 'post');

                 v_zPad = padarray(v_zCroped, [i+1 j+1 k+1], 'pre');
                 v_zPad = padarray(v_zPad, [-i+1 -j+1 -k+1], 'post');

                 C = C + 1/27 * acos((vel(:,:,:,1).*v_xPad + vel(:,:,:,2).*v_yPad + vel(:,:,:,3).*v_zPad)...
                     ./ sqrt(vel(:,:,:,1).^2+vel(:,:,:,2).^2+vel(:,:,:,3).^2) ./ sqrt(v_xPad.^2+v_yPad.^2+v_zPad.^2));
                 
    %            C = C + 1/27 * ((x.*xPad + y.*yPad + z.*zPad) ./ sqrt(x.^2+y.^2+z.^2) ./ sqrt(xPad.^2+yPad.^2+zPad.^2));

                 counter = counter + 1;
                 disp(['Phase coherence calc. ' num2str(counter) ' of 27'])
                 
            end
        end
    end
    
C = real(C);
edges = pi;
C(1,:,:) = edges; C(res,:,:) = edges; C(:,1,:) = edges; C(:,res,:) = edges; C(:,:,1) = edges; C(:,:,res) = edges;
    
end


if strcmp(method, 'lpc2')

% CM_lpc(2) as implemented by Chung

    for m = 1:9

                 % first order            % second order
        padder = [1 0 0; 0 1 0; 0 0 1;    1 1 0; 1 -1 0; 0 1 1; 0 1 -1; 1 0 1; -1 0 1];

        v_xPad = padarray(v_xCroped, [1 1 1] + padder(m,:), 'pre');
        v_xPad = padarray(v_xPad, [1 1 1] - padder(m,:), 'post');

        v_yPad = padarray(v_yCroped, [1 1 1] + padder(m,:), 'pre');
        v_yPad = padarray(v_yPad, [1 1 1] - padder(m,:), 'post');

        v_zPad = padarray(v_zCroped, [1 1 1] + padder(m,:), 'pre');
        v_zPad = padarray(v_zPad, [1 1 1] - padder(m,:), 'post');

        C = C + vel(:,:,:,1).*v_xPad + vel(:,:,:,2).*v_yPad + vel(:,:,:,3).*v_zPad;
        %C = C + vel(:,:,:,1).*v_xPad + vel(:,:,:,2).*v_yPad + vel(:,:,:,3).*v_zPad ...
        %    ./ sqrt(vel(:,:,:,1).^2+vel(:,:,:,2).^2+vel(:,:,:,3).^2) ./ sqrt(v_xPad.^2+v_yPad.^2+v_zPad.^2);

        disp(['Phase coherence calc. ' num2str(m) ' of 9'])

    end

C = C/max(max(max(C)));
    
end


if strcmp(method, 'lpc1')

% CM_lpc(1) as implemented by Chung

    for m = 1:3

        padder = [1 0 0; 0 1 0; 0 0 1]; % first order

        v_xPad = padarray(v_xCroped, [1 1 1] + padder(m,:), 'pre');
        v_xPad = padarray(v_xPad, [1 1 1] - padder(m,:), 'post');

        v_yPad = padarray(v_yCroped, [1 1 1] + padder(m,:), 'pre');
        v_yPad = padarray(v_yPad, [1 1 1] - padder(m,:), 'post');

        v_zPad = padarray(v_zCroped, [1 1 1] + padder(m,:), 'pre');
        v_zPad = padarray(v_zPad, [1 1 1] - padder(m,:), 'post');

        C = C + vel(:,:,:,1).*v_xPad + vel(:,:,:,2).*v_yPad + vel(:,:,:,3).*v_zPad;

        disp(['Phase coherence calc. ' num2str(m) ' of 3'])

    end

disp('done')    
    
C = C/max(max(max(C)));
    
end

