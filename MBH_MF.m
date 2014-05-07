function C  = MBH_MF( Is, P )
%MBH_MF: Montion boundary histogram features

if(numel(Is) < 2), C = []; return; end;

%Alocate variables
imQtd = numel(Is);  

%parse parameters
winSig = P(1); sigma = P(2); thr = P(3);

%get image in instant t
t_img = rgbConvert(Is{1},'LUV');t_img = t_img(:,:,1);
    
for t = 2:imQtd
   
    if(~isempty(Is{t}))
        prev_img = rgbConvert(Is{t}, 'LUV'); prev_img = prev_img(:,:,1);
        
        %compute optical flow by lucas kanade
        [Wx, Wy] = optFlowLk(prev_img, t_img,[], winSig, sigma, thr, 0 );
        
        %compute histogram oriented gradient for flow x
        [Mx,Ox]=gradientMag(single(Wx),0,5,.005,1); Hx = gradientHist(Mx,Ox,4,6,0,0,0.2,1);
        
        %compute histogram oriented gradient for flow y
        [My,Oy]=gradientMag(single(Wy),0,5,.005,1); Hy = gradientHist(My,Oy,4,6,0,0,0.2,1);
        
        if(t == 2)            
            [h, w, ~] = size(Hx); 
            H = single.empty(h,w,0);            
        end;
        
        %assingment
        H = cat(3,H,Hx);
        H = cat(3,H,Hy);        
    end;
end;

C = H;
end

