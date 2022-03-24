function [funcs] = RaptorFuncsCluster() 
    funcs.Init      = @Init;
    funcs.Encoder   = @Encoder;
    funcs.Decoder   = @Decoder;
    funcs.GenEdge   = @GenEdge;
    funcs.GenDegree = @GenDegree;
end

function [paras] = Init() 
    paras.LDPCfuncs = LDPCFuncsCluster();
    paras.LDPCParas = paras.LDPCfuncs.Init();
    paras.K = paras.LDPCParas.K; % 504
    paras.ldpcN = paras.LDPCParas.N; % 504
    paras.N = 1000;
end

function [out] = Encoder(source, paras) 
    if length(source) ~= paras.K
        error('length of Raptor error!')
    end
    % 1) LDPC Coding
    source = reshape(source, length(source), 1);
    codeLDPC = paras.LDPCfuncs.Encoder(source, paras.LDPCParas);

    % 2) LT Coding
    degree = GenDegree(paras.ldpcN, paras.N);
    edgeMatrix = GenEdge(paras.ldpcN, degree);
    codeRaptor = mod(edgeMatrix.' * codeLDPC, 2);
    
    % 3) output 
    out.code = codeRaptor;
    out.edgeMatrix = edgeMatrix;
end

function [out] = Decoder(source, paras) 
end

function [edgeMatrix] = GenEdge(k, degree) % k means infomation len
    len = length(degree);
    edgeMatrix = zeros(k, len);
    for i = 1:len
        edge = sort(randperm(k, degree(i)));
        edgeMatrix(edge, i) = 1;
    end
end

function [degree] = GenDegree(k, len)  % k means infomation len
    pArray = Distribution(k)
    vals = 1:k;
    stem(pArray)
    randNum = randsample(vals, len, true, pArray);
    degree = randNum;
end

function [pArray] = Distribution(len) 
    %pArray = [0.1; 0.6; 0.3];
    [pArray] = IdealSolitionDistri(len) 
end

function [pArray] = IdealSolitionDistri(k) 
    i = (1:k).';
    pArray = 1./(i+i.^2);
    pArray(1) = 1/k;
end
function [out] = RobustSolitionDistri() 
end
