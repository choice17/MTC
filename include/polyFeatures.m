function [X_poly] = polyFeatures(X, p, cross)
%POLYFEATURES Maps X (2D vector) into the p-th power
%   [X_poly] = POLYFEATURES(X, p) takes a data matrix X (size m x n) and
%   maps each example into its polynomial features where
%   X_poly(i, :) = [X(i) X(i).^2 X(i).^3 ...  X(i).^p];
%   return X_poly matrix in dimension m x n*p
%   cross option only valid for 3 features temporary 

[m,n] = size(X);

if nargin<3
    cross = false;
end


% You need to return the following variables correctly.

X_poly = zeros(m, n*p);

% ====================== YOUR CODE HERE ======================
% Instructions: Given a vector X, return a matrix X_poly where the p-th 
%               column of X contains the values of X to the p-th power.
%
% 

for i =1:p    
 X_poly(:,1+n*(i-1):n*i) = X.^i; 
end

%{
if cross == true && n==3
  X_cross = [X(:,1).*X(:,2) X(:,1).*X(:,3) X(:,2).*X(:,3) ...
            X(:,1).*X(:,2).*X(:,3)  X(:,1).*(X(:,3).^2) X(:,2).*(X(:,3).^2) ];
  X_poly = [X_poly X_cross];
end
%}

if cross == true && n==3
  X_cross = [X(:,1).*X(:,2) X(:,1).^2.*X(:,2) X(:,1).*(X(:,2).^2) (X(:,1).^2).*(X(:,2).^2)];
  X_poly = [X_poly X_cross];
end

% =========================================================================

end
