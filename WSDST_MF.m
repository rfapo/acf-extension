function [ C ] = WSDST_MF( Is, P )
%weak stabilized diferential spartio temporal motion features

%Alocate variables
imQtd = numel(Is);
[height, width , ~ ]  = size(Is{1});
C = zeros(height, width, imQtd - 1);
sigma = P(1);

%get image in instant t
t_img = rgbConvert(Is{1},'LUV');
t_img = t_img(:,:,1);
    

for t = 2:imQtd
   
    prev_img = rgbConvert(Is{t}, 'LUV'); prev_img = prev_img(:,:,1);
    
    %compute optical flow by lucas kanade
    [Wx, Wy] = optFlowLk(prev_img, t_img, sigma);
    
    %warp images
    [X, Y] = meshgrid(1:size(prev_img,2),1:size(prev_img,1));
    Warped_prev = interp2(prev_img, X+Wx, Y+Wy, 'cubic'); 
    Warped_prev(isnan(Warped_prev)) = prev_img(isnan(Warped_prev));
    
    %subtract frames and normalize [0, 1]
    Sub = imsubtract(t_img,Warped_prev);
    mmin = min(Sub(:));
    mmax = max(Sub(:));
    C(:,:,t-1) = (Sub-mmin) ./ (mmax-mmin);
end;


end

