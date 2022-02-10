function simulationResult = parSimulationAWGN(simulationSetting, G, decoder)

nPar = 2^5;
MAX_NUM_EPOCH = floor(2e7 / nPar);


EbNoArray = simulationSetting.EbNoArray;
lengthEbNoArray = length(EbNoArray);
MIN_NUM_ERROR_FRAME = simulationSetting.MIN_NUM_ERROR_FRAME;
[k, n] = size(G);
R = k / n;
% Initialize simulation result
simulationResult.description = simulationSetting.description;
simulationResult.G = G;
simulationResult.decoder = decoder;
simulationResult.EbNoArray = simulationSetting.EbNoArray;
simulationResult.wer = nan(1, lengthEbNoArray);
simulationResult.ber = nan(1, lengthEbNoArray);
simulationResult.errorFrameMatrix = nan(nPar+MIN_NUM_ERROR_FRAME, n, lengthEbNoArray);
simulationResult.errorRecievedSymbolMatrix = nan(nPar+MIN_NUM_ERROR_FRAME, n, lengthEbNoArray);
simulationResult.errorMessageMatrix = nan(nPar+MIN_NUM_ERROR_FRAME, k, lengthEbNoArray);

for iEbNo = 1:lengthEbNoArray
    % Initialize simulation settings
    sigma = 1 / sqrt(2*R)*10^(-EbNoArray(iEbNo)/20);
    nErrorFrame = 0;
    nFrame = 0;
    nErrorBit= 0;
    tStart = tic;
    rng(1);
    % simulation at EbNoArray(iEbNo)
    for iEpoch = 1:MAX_NUM_EPOCH
        u = (randn(nPar, k) > 0);
        v = mod(u * G, 2);
        bpskSymbol = 1-2*v;
        noise = randn(nPar, n);
        recievedSymbol = bpskSymbol + sigma.*noise;
        
        isErrorFrame = false(nPar, 1);
        nErrorBitArray = zeros(nPar, 1);
        parfor iFrame = 1:nPar
            [uEsti, vEsti] = decoder.decode(recievedSymbol(iFrame,:), sigma);
            isErrorFrame(iFrame) = any(v(iFrame,:)~=vEsti);
            nErrorBitArray(iFrame) = sum(uEsti~=u(iFrame));
        end
        nFrame = nFrame + nPar;
        if any(isErrorFrame)
            
            nErrorFrameLastEpoch = nErrorFrame;
            nErrorFrame = nErrorFrame + sum(isErrorFrame);
            nErrorBit = nErrorBit + sum(nErrorBitArray((isErrorFrame)));

            simulationResult.wer(iEbNo) = nErrorFrame / nFrame;
            simulationResult.ber(iEbNo) = nErrorBit / nFrame / k;

            simulationResult.errorFrameMatrix(nErrorFrameLastEpoch+1:nErrorFrame,:,iEbNo) = v(isErrorFrame,:);
            simulationResult.errorRecievedSymbolMatrix(nErrorFrameLastEpoch+1:nErrorFrame,:,iEbNo) = ...
                    recievedSymbol(isErrorFrame,:);
            simulationResult.errorMessageMatrix(nErrorFrameLastEpoch+1:nErrorFrame,:,iEbNo) = u(isErrorFrame,:);
        end
        % print some simulation message
        tSpan = toc(tStart);
        disp('############################################');
        disp([simulationSetting.displayName]);
        disp(simulationSetting.description);
        disp(['% Running time duration at this EbNo: ' num2str(tSpan) 's']);
        disp(['% Error frame number at this EbNo: ' num2str(nErrorFrame)]);
        disp(['% Eb/No = ' num2str(EbNoArray(iEbNo)) ' dB']);
        disp(['% N = ' num2str(n) ' K = ' num2str(k)]);
        disp('% EbNo    wer    ber');
        disp('data = [...');
        disp(num2str([simulationResult.EbNoArray' simulationResult.wer' ...
                simulationResult.ber']));
        disp('];');
        disp('EbNo = data(:,1); wer = data(:,2); ber = data(:,3);');
        disp('semilogy(EbNo, wer, ''-o'', ''Linewidth'', 1.5,''DisplayName'',displayName); hold on;');
        disp('############################################');
        
        if nErrorFrame >= (MIN_NUM_ERROR_FRAME)
            break;
        end
    end
end % end of the simulation at this EbNo
end % end of the simulation function