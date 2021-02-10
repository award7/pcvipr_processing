function [vParaboloid] = paraboloid_fit(vTimeFrame, BWcrossectionRG, r)
% code for paraboloid fitting for a velocity profile in a given two
% dimensional slice


y = -r:1:r;          
x = -r:1:r;
[X,Y] = meshgrid(x,y);
f1 = (X.^2+Y.^2).*BWcrossectionRG;
f2 = X.*BWcrossectionRG;
f3 = Y.*BWcrossectionRG;
f4 = ones(size(X)).*BWcrossectionRG;         
A = [f1(:),f2(:),f3(:),f4(:)];
y = vTimeFrame(:);
coeffs = A\y;
vParaboloid = coeffs(1)*f1+coeffs(2)*f2+coeffs(3)*f3+coeffs(4)*f4;



end

