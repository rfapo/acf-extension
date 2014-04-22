
close all;

%convert to lumnance
t = rgbConvert(images{595},'LUV');
t= t(:,:,1);
tm = rgbConvert(images{594}, 'LUV');
tm = tm(:,:,1);
figure(1), imshowpair(tm , t, 'montage')

%compute optical flow
[Wx, Wy] = optFlowLk(tm, t, 16);

%warp images
[X, Y] = meshgrid(1:size(tm,2),1:size(tm,1));
Warped_tm = interp2(tm, X+Wx, Y+Wy, 'cubic');
Warped_tm(isnan(Warped_tm)) = tm(isnan(Warped_tm));
figure(2), imshowpair(tm,Warped_tm,'montage')
figure(3), imshowpair(t,Warped_tm,'montage')

%compute diferential time frames features
channel = imsubtract(t, Warped_tm);
mmin = min(channel(:));
mmax = max(channel(:));
normChannel = (channel-mmin) ./ (mmax-mmin);
figure(4), imshowpair(channel, normChannel,'montage')