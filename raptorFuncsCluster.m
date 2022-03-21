function [funcs] = raptorFuncsCluster() 
    funcs.Init              = @Init;
    funcs.Encoder           = @Encoder;
    funcs.Decoder           = @Decoder;
end

function [paras] = Init() 
    LDPCfuncs = LDPCFuncsCluster();
    LDPCParas = LDPCfuncs.Init();
end

function [out] = Encoder(source, paras) 
end

function [out] = Decoder(source, paras) 
end
