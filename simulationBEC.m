function simulationResult = simulationBEC(simulationSetting, G, decoder)

MAX_ITER = 2e7;

epsiArray = simulationSetting.epsiArray;
lengthepsiArray = length(epsiArray);
MIN_NUM_ERROR_FRAME = simulationSetting.MIN_NUM_ERROR_FRAME;
[k, n] = size(G);
R = k / n;
% Initialize simulation result
simulationResult.description = simulationSetting.description;
simulationResult.G = G;
simulationResult.decoder = decoder;
simulationResult.epsiArray = simulationSetting.epsiArray;
simulationResult.wer = nan(1, lengthepsiArray);
simulationResult.ber = nan(1, lengthepsiArray);
simulationResult.errorFrameMatrix = nan(MIN_NUM_ERROR_FRAME, n, lengthepsiArray);
simulationResult.errorRecievedSymbolMatrix = nan(MIN_NUM_ERROR_FRAME, n, lengthepsiArray);
simulationResult.errorMessageMatrix = nan(MIN_NUM_ERROR_FRAME, k, lengthepsiArray);

for iepsi = 1:lengthepsiArray
    % Initialize simulation settings
    epsi = epsiArray(iepsi);
    nErrorFrame = 0;
    nErrorBit = 0;
    nFrame = 0;
    tStart = tic;
    
    idx = (sum(G, 2)==16);
    
    rng(1);
    % simulation at this epsi
    for iFrame = 1:MAX_ITER
        % transimit codeword
        nFrame = nFrame + 1;
        u = (randn(1, k) > 0);
        v = mod(u * G, 2);
        
        zeroVec = zeros(1, n);
        isErasureVec = logical(bsc(zeroVec, epsi));
        recievedVec = v;
        recievedVec(isErasureVec) = nan;
        
        [uEsti, vEsti] = decoder.decode(recievedVec);
           
        isError = any(vEsti ~= vEsti);

        if isError
            nErrorFrame = nErrorFrame + 1;
            % nErrorBit = nErrorBit + sum(uEsti~=u);
            simulationResult.wer(iepsi) = nErrorFrame / nFrame;
            simulationResult.ber(iepsi) = nErrorBit / nFrame / k;
            
            simulationResult.errorFrameMatrix(nErrorFrame,:,iepsi) = v;
            simulationResult.errorRecievedSymbolMatrix(nErrorFrame,:,iepsi) = ...
                recievedVec;
            simulationResult.errorMessageMatrix(nErrorFrame,:,iepsi) = u;
        end
        % print some simulation message
        isPrinting = isError;
        if isPrinting
            tSpan = toc(tStart);
            disp('############################################');
            disp([simulationSetting.displayName]);
            disp(simulationSetting.description);
            disp(['% Running time duration at this epsi: ' num2str(tSpan) 's']);
            disp(['% Error frame number at this epsi: ' num2str(nErrorFrame)]);
            disp(['% epsi = ' num2str(epsiArray(iepsi)) ]);
            disp(['% N = ' num2str(n) ' K = ' num2str(k)]);
            disp('% EbNo    wer    ber');
            disp('data = [...');
            disp(num2str([simulationResult.epsiArray' simulationResult.wer' ...
                simulationResult.ber']));
            disp('];');
            disp('epsi = data(:,1); wer = data(:,2); ber = data(:,3);');
            disp('semilogy(epsi, wer, ''-o'', ''Linewidth'', 1.5,''DisplayName'',displayName); hold on;');
            disp('############################################');
        end
        if nErrorFrame == MIN_NUM_ERROR_FRAME
            break;
        end
    end % end of the simulation at this frame
end % end of the simulation at this EbNo
end % end of the simulation function