function [xParticular, xNullspace, nFree] = mySolveEquation(A, b)
% solve equation: Ax = b over gf(2)
% 

[mRow, nCol] = size(A);

% get the augmented matrix 
augMatrix = nan(mRow, nCol+1);
augMatrix(:,1:nCol) = A;
augMatrix(:,end) = b;
% perform guass-jordan elimination
[matrixRowEchelon, indexColPivot, rankOfMatrix] = ...
    getEchelonMatrix(augMatrix);
if ismember(nCol+1, indexColPivot) 
    xParticular = nan(Col,1); xNullspace = nan(Col,1); nFree = nan;
    return; % b is linear independant with the col.s of A 
end
% perform back substitution
matrixEliminated =  backSubstitution(matrixRowEchelon, ...
    indexColPivot, rankOfMatrix);
% find the nullspace basis and the particular solution
indexFree = setdiff(1:nCol,indexColPivot);
nFree = nCol - rankOfMatrix;
xParticular = zeros(nCol, 1);
xParticular(indexColPivot(logical(matrixEliminated(:,end)))) = 1;

xNullspace = zeros(nCol, nFree);
for i = 1:nFree
    iFree = indexFree(i);
    xNullspace(iFree,i) = 1;
    xNullspace(indexColPivot(logical(matrixEliminated(:,iFree))), i) = 1;
    
end

end