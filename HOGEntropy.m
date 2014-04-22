function [ C ] = HOGEntropy( I, P )
%HOGEntropy Entropy of the histogram of oriented gradient

C = [];

if(~isempty(I))
    colorChn = 0; %P{1};
    normRad = 5; %P{2};
    normConst = .005; %P{3};
    full = 1; %P{4};
    binSize = 4; %P{5};
    nOrients = 6;
    softBin = 0;
    useHog = 0;
    clipHog = 0.2;
    
    %compute histogram oforiented gradient
    [M,O]=gradientMag(I,colorChn,normRad,normConst,full);
    H = gradientHist(M,O,binSize,nOrients,softBin,useHog,clipHog,full);
    
    %compute entropy
    D = H ./ repmat(sum(H,3),[1,1,nOrients]); 
    D = D .* log(D);
    D (isnan(D)) = 0;
    C = - sum(D,3);   
    
    %block normalization
    %fun = @(block_struct)(block_struct.data ./ (norm(block_struct.data(:)) + 0.01));
    %C = blockproc(C,[2*binSize, 2*binSize], fun);
    
end;
C = single(C);

end


