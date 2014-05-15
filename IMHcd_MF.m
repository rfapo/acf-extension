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
        Dfx = IMHcd_aux(Wx); Dfy = IMHcd_aux(Wy);
        
        %compute magnitude and orientation
        M = sqrt((Dfx .^2) + (Dfy .^ 2)); O = wrapTo2Pi(atan2(Dfy,Dfx));
        
        %compute oriented histogram and block normalization
        C = gradientHist(single(M),single(O),3,6,0,0,0.2,1);
        
        
    end;
    
end;
end

function H = IMHcd_aux( I )
%define variables
[h,w]=size(I); csize=3; bsize=3; bpixs=(csize * bsize);
hbcks = ceil(h/bpixs); wbcks=ceil(w/bpixs); H=cell(1,hbcks * wbcks); blks_count = 1;
for by = 1:bpixs:h
    for bx = 1:bpixs:w
        
        %get padded block
        bye = min(by+bpixs-1, h); bxe = min (bx+bpixs-1, w); bck = I(by:bye,bx:bxe);
        [bh, bw]=size(bck); bck=padarray(bck,[(bpixs-bh) (bpixs-bw)],0,'post'); [bh, bw]=size(bck);
        %get central cell for this block
        C = bck(4:6,4:6);
        cells = cell(1,8); cell_count = 1;
        for cy = 1:csize:bh
            for cx = 1:csize:bw
                
                %jump central cell
                if(cy==4 && cx==4), continue;end;
                %get cell
                cye = min(cy+csize-1, bh); cxe = min (cx+csize-1, bw); Cel = bck(cy:cye,cx:cxe);
                %subtract to central cell and accumulate
                cells{cell_count} = Cel - C; cell_count=cell_count+1;
            end;
        end;
        %reshape to 2x4 blocks
        H{blks_count} = cell2mat(reshape(cells,4,2)'); blks_count = blks_count + 1;
    end;
end;

%reshape to hblcks x wblcks
H = cell2mat(reshape(H, wbcks, hbcks)');
end


