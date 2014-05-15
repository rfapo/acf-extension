% Demo for aggregate channel features object detector on Caltech dataset.
%
% (1) Download data and helper routines from Caltech Peds Website
%  www.vision.caltech.edu/Image_Datasets/CaltechPedestrians/
%  (1a) Download Caltech files: set*.tar and annotations.zip
%  (1b) Copy above files to dataDir/data-USA/ and untar/unzip contents
%  (1c) Download evaluation code (routines necessary for extracting images)
% (2) Set dataDir/ variable below to point to location of Caltech data.
% (3) Launch "matlabpool open" for faster training if available.
% (4) Run demo script and enjoy your newly minted fast ped detector!
%
% Note: pre-trained model files are provided (delete to re-train).
% Re-training may give slightly variable results on different machines.
%
% Piotr's Image&Video Toolbox      Version 3.23
% Copyright 2013 Piotr Dollar & Ron Appel.  [pdollar-at-caltech.edu]
% Please email me if you find bugs, or have suggestions or questions!
% Licensed under the Simplified BSD License [see external/bsd.txt]

%% extract training and testing images and ground truth
dataDir = 'C:/Users/RFSC/Documents/Development Files/MatlabWorkspace/ acf-extension/data-USA';
for s=1:2
  if(s==1), type='train'; else type='test'; end
  if(exist([dataDir type '/annotations'],'dir')), continue; end
  dbInfo(['Usa' type]); dbExtract([dataDir type],1);
end

%% set up opts for training detector (see acfTrain)
opts=acfTrain(); 
%model parameters
opts.modelDs=[50 20.5]; 
opts.modelDsPad=[128 64];
opts.stride = 4;
opts.nWeak=[32 128 512 2048];
opts.pBoost.pTree.fracFtrs=1/16;

%features parameters
opts.pPyramid.smooth=.5; 
opts.pPyramid.pChns.pColor.smooth=0;
opts.pPyramid.nPerOct = 8;

% %Custom channel
% opts.pPyramid.pChns.pCustom=struct('name','hogentropy','hFunc',@HOGEntropy); 
% opts.pPyramid.pChns.complete=0;

%% seq features-------------------------------------------------

% %seq channel - weak stabilized
% opts.pPyramid.pChns.pSeq = struct('name', 'WSSD', 'hFunc', @WSDST_MF);
% opts.pPyramid.pChns.pSeq.pFunc = {16};
% opts.pPyramid.pChns.pSeq.skip = 4; opts.pPyramid.pChns.pSeq.span = 8;
% opts.pPyramid.pChns.pSeq.imgBaseDir = 'C:/Users/RFSC/Documents/Development Files/MatlabWorkspace/ acf-extension/data/data_feat_test';
% opts.pPyramid.pChns.pSeq.modelDs =  opts.modelDs;
% opts.pPyramid.pChns.pSeq.modelDsPad = opts.modelDsPad;
% opts.pPyramid.pChns.pSeq.chnDepth = opts.pPyramid.pChns.pSeq.span;

% %seq channel - MBH
% opts.pPyramid.pChns.pSeq = struct('name', 'MBH', 'hFunc', @MBH_MF);
% opts.pPyramid.pChns.pSeq.pFunc = {[2, 2, 3e-6]};
% opts.pPyramid.pChns.pSeq.skip = 1; opts.pPyramid.pChns.pSeq.span = 1;
% opts.pPyramid.pChns.pSeq.imgBaseDir = 'C:/Users/RFSC/Documents/Development Files/MatlabWorkspace/ acf-extension/data/data_feat_test';
% opts.pPyramid.pChns.pSeq.modelDs =  opts.modelDs;
% opts.pPyramid.pChns.pSeq.modelDsPad = opts.modelDsPad;
% opts.pPyramid.pChns.pSeq.chnDepth = 12 * opts.pPyramid.pChns.pSeq.span;

% %seq channel - IMHcd
% opts.pPyramid.pChns.pSeq = struct('name', 'IMHcd', 'hFunc', @IMHcd_MF);
% opts.pPyramid.pChns.pSeq.pFunc = {[2, 2, 3e-6]};
% opts.pPyramid.pChns.pSeq.skip = 1; opts.pPyramid.pChns.pSeq.span = 1;
% opts.pPyramid.pChns.pSeq.imgBaseDir = 'C:/Users/RFSC/Documents/Development Files/MatlabWorkspace/ acf-extension/data/data_feat_test';
% opts.pPyramid.pChns.pSeq.modelDs =  opts.modelDs;
% opts.pPyramid.pChns.pSeq.modelDsPad = opts.modelDsPad;
% opts.pPyramid.pChns.pSeq.chnDepth = 6 *  opts.pPyramid.pChns.pSeq.span;


%-----------------------------------------------------------------------------------------
%% 

%training data parameters
opts.posGtDir=[dataDir 'train/annotations']; 
opts.posImgDir=[dataDir 'train/images']; 
opts.pJitter=struct('flip',1);
opts.name='models/AcfCaltech';
pLoad={'lbls',{'person'},'ilbls',{'people'},'squarify',{3,.41}};
opts.pLoad = [pLoad 'hRng',[50 inf], 'vRng',[0.65 1] ];
opts.pJitter = {[]};
opts.winsSave = 0;

%% train detector (see acfTrain)
detector = acfTrain( opts );

%% modify detector (see acfModify)
%detector = acfModify(detector,'cascThr',-1,'cascCal',-.005);

%% run detector on a sample image (see acfDetect)
imgNms=bbGt('getFiles',{[dataDir 'test/images']});
I=imread(imgNms{1864}); fn = imgNms{1864}; tic, bbs=acfDetect(I, fn, detector); toc
figure(1); im(I); bbApply('draw',bbs); pause(.1);

%% test detector and plot roc (see acfTest)
[~,~,gt,dt]=acfTest('name',opts.name,'imgDir',[dataDir 'test/images'],...
  'gtDir',[dataDir 'test/annotations'],'pLoad',[pLoad, 'hRng',[50 inf],...
  'vRng',[.65 1],'xRng',[5 635],'yRng',[5 475]],'show',2);

%% optionally show top false positives ('type' can be 'fp','fn','tp','dt')
if( 0 ), bbGt('cropRes',gt,dt,imgNms,'type','fn','n',50,...
    'show',3,'dims',opts.modelDs([2 1])); end
