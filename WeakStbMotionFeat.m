function [ features ] = WeakStbMotionFeat( imagesDir, imagesFiles, height, width, span, skip )

%Alocate variables
imQtd = length(imagesFiles);
t_ini = (span * skip) + 1;
features = containers.Map;

for t = t_ini:imQtd
    difMatrix = zeros(height, width,span);
    tic;
    %read t image
    currentfilename = [imagesDir '/' imagesFiles(t).name];
    currentimage = imread(currentfilename);
    
    t_img = rgbConvert(currentimage,'LUV');
    t_img = t_img(:,:,1);
    for fi = 1:span
        %read t-fm image
        previusFilename = [imagesDir '/' imagesFiles(t-(fi*skip)).name];
        previusImage = imread(previusFilename);
        
        %compute image luminance
        prev_img = rgbConvert(previusImage, 'LUV');
        prev_img = prev_img(:,:,1);
        
        %compute optical flow by lucas kanade
        [Wx, Wy] = optFlowLk(prev_img, t_img, 16);
        
        %warp images
        [X, Y] = meshgrid(1:size(prev_img,2),1:size(prev_img,1));
        Warped_prev = interp2(prev_img, X+Wx, Y+Wy, 'cubic');
        Warped_prev(isnan(Warped_prev)) = prev_img(isnan(Warped_prev));
        
        %subtract frames and normalize [0, 1]
        channel = imsubtract(t_img,Warped_prev);
        mmin = min(channel(:));
        mmax = max(channel(:));
        difMatrix(:,:,fi) = (channel-mmin) ./ (mmax-mmin);
    end;
    
    features(imagesFiles(t).name) = difMatrix(:,:,:);
    toc
    
end;
end

