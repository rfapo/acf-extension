function [ C ] = HOGEntropy( I, P )
%HOGEntropy Entropy of the histogram of oriented gradient

C = [];

if(~isempty(I))
    
    %number of orientation in the histogram
    nOrients = 6;
        
    %compute histogram oforiented gradient
    [M,O]=gradientMag(I,0,5,0.005,1);
    H = gradientHist(M,O,4,nOrients,0,0,0.2,1);
    
    %compute entropy
    D = H ./ repmat(sum(H,3),[1,1,nOrients]); 
    D = D .* log(D);
    D (isnan(D)) = 0;
    C = - sum(D,3);   
    
end;
C = single(C);

end


