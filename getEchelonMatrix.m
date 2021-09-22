function [matrixRowEchelon, indexColPivot, rankOfMatrix] = ...
    getEchelonMatrix(matrix)
%% get echelon form matrix in gf(2)
%% test code:
% mRow = 7;
% nCol = 10;
% matrix = (randn(mRow, nCol) > 0);
% [matrixEchelon, indexColPivot] = getEchelonMatrix(matrix);
% disp('origin matrix: ');
% disp(num2str(matrix));
% disp('echelon form matrix: ');
% disp(num2str(matrixEchelon));
% disp('index of the col pivots: ');
% disp(num2str(indexColPivot));
%%
[mRow, nCol] = size(matrix);
cCol = 0; 
% count the linear independant columns by now
indexColPivot = nan(1, nCol);
pRow = 1;
% point to the row that should be linear independant with the past rows

for iCol = 1:nCol
    % find the column that is linear independant with the past columns
    colTemp = matrix(pRow:mRow, iCol);
    pivotRowIndex = find(colTemp, 1);
    if isempty(pivotRowIndex), continue; end
    
    pivotRowIndex = pRow + pivotRowIndex - 1;
    cCol = cCol+1;
    indexColPivot(cCol) = iCol;
    % exchange the row if the pivot not on the p-th row
    if pivotRowIndex ~= pRow 
        rowTemp = matrix(pivotRowIndex, :);
        matrix(pivotRowIndex, :) = matrix(pRow,:);
        matrix(pRow,:) = rowTemp;
    end
    pRow = pRow + 1;

    if pRow>mRow, break; end 
        
    % is independnat, perform elimination to the rows below
    for iRow = pRow:mRow
        if matrix(iRow, iCol) == 1
            matrix(iRow,:) = (matrix(iRow,:)~=matrix(pRow-1,:));
        end
    end
end % end of this column
rankOfMatrix = cCol;
matrixRowEchelon = matrix;
indexColPivot = indexColPivot(1:cCol);


% for iCol = 1:nCol
%     % find the column that is linear independant with the past columns
%     for iRow = pRow:mRow
%         isIndependant = (matrix(iRow, iCol) == 1);
%         if isIndependant
%             cCol = cCol+1;
%             indexColPivot(cCol) = iCol;
%             rowTemp = matrix(iRow,:);
%             matrix(iRow,:) = matrix(pRow,:);
%             matrix(pRow,:) = rowTemp;
%             pRow = pRow+1;
%             break;
%         end
%     end
%     if pRow>mRow, break; end 
%         
%     % this column is linear dependant with the past columns
%     if ~isIndependant, continue; end
%     
%     % is independnat, perform elimination to the rows below
%     for iRow = pRow:mRow
%         if matrix(iRow, iCol) == 1
%             matrix(iRow,:) = mod(matrix(iRow,:)+matrix(pRow-1,:),2);
%         end
%     end
% end % end of this column
% rankOfMatrix = cCol;
% matrixRowEchelon = matrix;
% indexColPivot = indexColPivot(1:cCol);
end
