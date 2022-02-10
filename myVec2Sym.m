function symfx = myVec2Sym(fx)
% Convert the vector into symbolic form polynomial.
% Input:
%   fx: [1 0 1 1] denote 1+x^2+x^3.
% Output:
%   symfx: x^3+x^2+1.
syms x;
symfx = 0*x;
for i = 1:length(fx)
     symfx = symfx + x^(i-1)*fx(i);
end
end