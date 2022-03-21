function [out] = test() 
    clc;
    clear all;
    close all;
    seed = 0;
    rng(seed);

    [LDPCfuncs] = LDPCFuncsCluster();
    LDPCParas = LDPCfuncs.Init();

    M = 4; % Modulation order (QPSK)
    snr = [0.25];
    numFrames = 10;

    pskMod = comm.PSKModulator(M,'BitInput',true);
    pskDemod = comm.PSKDemodulator(M,'BitOutput',true,...
        'DecisionMethod','Approximate log-likelihood ratio');
    pskuDemod = comm.PSKDemodulator(M,'BitOutput',true,...
        'DecisionMethod','Hard decision');
    errRate = zeros(1,length(snr));
    uncErrRate = zeros(1,length(snr));

    for ii = 1:length(snr)
        ttlErr = 0;
        ttlErrUnc = 0;
        pskDemod.Variance = 1/10^(snr(ii)/10);
        for counter = 1:numFrames
            data = logical(randi([0 1],LDPCParas.K,1));
            % Transmit and receive LDPC coded signal data
            encData = LDPCfuncs.Encoder(data, LDPCParas);
            modSig = pskMod(encData);
            rxSig = awgn(modSig,snr(ii),'measured');
            demodSig = pskDemod(rxSig);
            decodeOut = LDPCfuncs.Decoder(demodSig, LDPCParas);
            rxBits = decodeOut.infoOut;
            numErr = biterr(data,rxBits);
            ttlErr = ttlErr + numErr;
            error('auto');
        end
        ttlBits = numFrames*length(rxBits);
        errRate(ii) = ttlErr/ttlBits;
    end
    error('auto');
end
