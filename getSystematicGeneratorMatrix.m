function [Gsystem, indexInfo] = getSystematicGeneratorMatrix(G)
[matrixRowEchelon, indexInfo, rankOfMatrix] = ...
    getEchelonMatrix(G);
Gsystem =  backSubstitution(matrixRowEchelon, ...
    indexInfo, rankOfMatrix);

end