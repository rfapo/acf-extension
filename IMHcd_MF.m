function C = IMHcd_MF( Is, P )
%IMHcd_MF Internally motion  istogram of central displacement
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
        
        %compute central diference of opical flow for a block 3x3 cell of 3x3 pixels
        Dfx = blockproc(Wx,[9 9], @IMHcd_aux, 'PadPartialBlocks', true ); Dfy = blockproc(Wy,[9 9], @IMHcd_aux, 'PadPartialBlocks', true);
                
        %compute magnitude and orientation 
        M = sqrt((Dfx .^2) + (Dfy .^ 2)); O = atan2(Dfy,Dfx);
        
        %perform block normalization
        Hf = gradientHist(single(M),single(O),3,6,0,0,0.2,1);
        
        if(t == 2)            
            [h, w, ~] = size(Hf); 
            H = single.empty(h,w,0);            
        end;
        
        %assingment
        H = cat(3,H,Hf);                
    end;
end;

C = H;
end

function H = IMHcd_aux( B )

%get the central cell
D = B.data; [h, w] = size(D); vIdxs=4:6; Ih=(vIdxs <= h); Iw=(vIdxs <= w);
M=D(vIdxs(Ih), vIdxs(Iw)); 

%perform the subtraction to the relative central cell
fun = @(block_struct) block_struct.data - M; D = blockproc(D ,[3 3], fun);

%exclude the central cell
vIdxs=[1,2,3,7,8,9]; Ih=(vIdxs <= h); Iw=(vIdxs <= w); H=D(vIdxs(Ih), vIdxs(Iw));

end


