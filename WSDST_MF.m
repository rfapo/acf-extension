function C  = WSDST_MF( Is, P )
%weak stabilized diferential spartio temporal motion features

if(numel(Is) < 2), C = []; return; end; 

%Alocate variables
imQtd = numel(Is);
[height, width , ~ ]  = size(Is{1});
C = zeros(height, width, imQtd - 1,'single');
sigma = P(1);

%get image in instant t
t_img = rgbConvert(Is{1},'LUV');
t_img = t_img(:,:,1);
    

for t = 2:imQtd
   
    if(~isempty(Is{t}))
        prev_img = rgbConvert(Is{t}, 'LUV'); prev_img = prev_img(:,:,1);
        
        %compute optical flow by lucas kanade
        [Wx, Wy] = optFlowLk(prev_img, t_img , sigma);
        
        %warp images
        [X, Y] = meshgrid(1:size(prev_img,2),1:size(prev_img,1));
        Warped_prev = interp2(prev_img, X+Wx, Y+Wy, 'cubic');
        Warped_prev(isnan(Warped_prev)) = prev_img(isnan(Warped_prev));

        
        %subtract frames and normalize [0, 1]
        %C(:,:,t-1) = imsubtract(t_img,Warped_prev);
 		Sub = imsubtract(t_img,Warped_prev);
        mmin = min(Sub(:));
        mmax = max(Sub(:));
        C(:,:,t-1) = (Sub-mmin) ./ (mmax-mmin);
    end;
end;

% csize = 4; bsize = 2; bpixs = csize * bsize; ovlap = bpixs/2; 
% %block normalization sxsxt and clip to 0.5
% for by = 1:ovlap:height
% 	for bx = 1:ovlap:width
% 		for bz = 1:ovlap:imQtd - 1
% 			
% 			%get a block
% 			bye = min(by+bpixs-1,height); bxe = min(bx+bpixs-1,width); bze = min(bz+bpixs-1,imQtd - 1);
% 			bck = C(by:bye,bx:bxe,bz:bze); 
% 			
% 			%l1-normalization and clip to 0.5
% 			l1norm = norm(bck(:),1); if(l1norm > 0.05), l1norm = 0.05; end; bck = bck ./ l1norm;
% 			C(by:bye,bx:bxe,bz:bze) = bck;						
% 		end;
% 	end;
% end;

end




