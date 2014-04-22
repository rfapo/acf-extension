function [ C ] = OG_Entropy( I, P )
%entropy of the the gradient

C = [];

if(~isempty(I))
    colorChn = 0; %P{1};
    normRad = 5; %P{2};
    normConst = .005; %P{3};
    full = 1; %P{4};
    binSize = 4; %P{5};
    
    [~,O]=gradientMag(I,colorChn,normRad,normConst,full);
    fun = @(block_struct)  wentropy(block_struct.data(), 'shannon',0);
    C = blockproc(O,[binSize, binSize], fun);
    
    %block normalization
    fun = @(block_struct)(block_struct.data ./ (norm(block_struct.data(:)) + 0.01));
    C = blockproc(C,[2*binSize, 2*binSize], fun);
    
end;

C = single(C);

end
