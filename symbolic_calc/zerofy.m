% Performs thresholding to convert tiny numbers to 0.
function ret = zerofy(A,tol)
if (nargin < 2)
  tol = 1E-7;
end;
ret = A.*(abs(A) > tol);
