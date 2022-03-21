function [funcs] = LDPCFuncsCluster() 
    funcs.Init              = @Init;
    funcs.Encoder           = @Encoder;
    funcs.Decoder           = @Decoder;
    funcs.PcMatrix2QcMatrix = @PcMatrix2QcMatrix;
end
function [paras] = Init() 
    paras.iterTimes = 100;
    [paras.pcMatrix, paras.z] = LookUpH();
    paras.qcMatrix = PcMatrix2QcMatrix(paras.pcMatrix, paras.z);
    [m, n] = size(paras.qcMatrix);
    paras.K = n - m;
    paras.N = n;

    paras.encoder = comm.LDPCEncoder(sparse(paras.qcMatrix));
    paras.decoder = comm.LDPCDecoder( ...
        'ParityCheckMatrix', sparse(paras.qcMatrix), ...
        'OutputValue', 'Whole codeword', ...
        'DecisionMethod', 'Soft decision', ...
        'MaximumIterationCount', paras.iterTimes, ...
        'IterationTerminationCondition', 'Parity check satisfied' ...
    );
end

function [out] = Encoder(source, paras) 
    source = reshape(source, length(source), 1);
    out = paras.encoder(source);
end

function [out] = Decoder(llr, paras) 
    llr          = reshape(llr, length(llr), 1);
    out.llrOut   = paras.decoder(llr);
    out.cout     = mod((out.llrOut>0)+1, 2); % <0 -> 1, > 0 -> 0
    out.infoOut  = out.cout(1:paras.K);
    out.decodeOk = sum(mod(paras.qcMatrix * out.cout, 2));
end

function [qcMatrix] = PcMatrix2QcMatrix(pcMatrix, z) 
    [pcMatrix, z] = LookUpH();
    [sizeM, sizeN] = size(pcMatrix);

    qcMatrix = zeros(sizeM*z, sizeN*z);
    for m = 1:sizeM
        for n = 1:sizeN
            shift = pcMatrix(m, n);
            if shift == -1
                qcMatrix((m-1)*z+1:m*z, (n-1)*z+1:n*z) = zeros(z, z);
            else
                qcMatrix((m-1)*z+1:m*z, (n-1)*z+1:n*z) = circshift(eye(z), -shift);
            end
        end
    end

    % output
    qcMatrix;
end

function [pcMatrix, z] = LookUpH() 
    pcMatrix = [
        16 17 22 24  9  3 14 -1  4  2  7 -1 26 -1  2 -1 21 -1  1  0 -1 -1 -1 -1
        25 12 12  3  3 26  6 21 -1 15 22 -1 15 -1  4 -1 -1 16 -1  0  0 -1 -1 -1
        25 18 26 16 22 23  9 -1  0 -1  4 -1  4 -1  8 23 11 -1 -1 -1  0  0 -1 -1
         9  7  0  1 17 -1 -1  7  3 -1  3 23 -1 16 -1 -1 21 -1  0 -1 -1  0  0 -1
        24  5 26  7  1 -1 -1 15 24 15 -1  8 -1 13 -1 13 -1 11 -1 -1 -1 -1  0  0
         2  2 19 14 24  1 15 19 -1 21 -1  2 -1 24 -1  3 -1  2  1 -1 -1 -1 -1  0
    ];
    z = 21;
end
