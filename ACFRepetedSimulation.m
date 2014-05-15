clear all; close all;

% cross validate using 10 fold with each fold with the same amount of data
folds = 10;
allDataDir = 'C:\Users\RFSC\Documents\Development Files\MatlabWorkspace\ acf-extension\data-exp';
imgNms=bbGt('getFiles',{[allDataDir '\images']}); gtNms=bbGt('getFiles',{[allDataDir '\annotations']});
foldsIdxs = crossvalind('KFold',numel(imgNms),folds);
trainDir = 'C:\Users\RFSC\Documents\Development Files\MatlabWorkspace\ acf-extension\data-USAtrain';
testDir = 'C:\Users\RFSC\Documents\Development Files\MatlabWorkspace\ acf-extension\data-USAtest';

%datadir
dataDir = 'C:/Users/RFSC/Documents/Development Files/MatlabWorkspace/ acf-extension/data-USA';

for nfold = 1:folds
    %delete old files
    rmdir(trainDir,'s'); rmdir(testDir,'s');
    %create new folders
    mkdir([trainDir '/images']);mkdir([trainDir '/annotations']);
    mkdir([testDir '/images']);mkdir([testDir '/annotations']);
    %split the data set and move files
    idxs = (foldsIdxs == nfold);
    bbGt( 'copyFiles', imgNms(idxs), {[testDir '/images']} );bbGt( 'copyFiles', imgNms(~idxs), {[trainDir '/images']});
    bbGt( 'copyFiles', gtNms(idxs), {[testDir '/annotations']} );bbGt( 'copyFiles', gtNms(~idxs), {[trainDir '/annotations']});
    
    fprintf([repmat('-',[1 75]) '\n']);
    fprintf('simulation with fold %i started >>>>\n',nfold);
    
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
    opts.nPos = 2500;
    opts.pJitter=struct('flip',1);
    opts.name= strcat('models/fold', num2str(nfold), '/AcfCaltech');
    pLoad={'lbls',{'person'},'ilbls',{'people'},'squarify',{3,.41}};
    opts.pLoad = [pLoad 'hRng',[50 inf], 'vRng',[0.65 1] ];
    opts.pJitter = {[]};
    opts.winsSave = 0;
    
    %% train detector (see acfTrain)
    detector = acfTrain( opts );
    
%     %% run detector on a sample image (see acfDetect)
%     imgNmsTest=bbGt('getFiles',{[dataDir 'test/images']});
%     I=imread(imgNmsTest{1864}); fn = imgNmsTest{1864}; tic, bbs=acfDetect(I, fn, detector); toc
%     figure(1); im(I); bbApply('draw',bbs); pause(.1);
    
    %% test detector and plot roc (see acfTest)
    [miss,roc,gt,dt]=acfTest('name',opts.name,'imgDir',[dataDir 'test/images'],...
        'gtDir',[dataDir 'test/annotations'],'pLoad',[pLoad, 'hRng',[50 inf],...
        'vRng',[.65 1],'xRng',[5 635],'yRng',[5 475]],'show',2);
    
    save([opts.name 'EvalutionResult'],'miss','roc','gt','dt'); 
    clear opts detector missroc gt dt;
    
    fprintf([repmat('-',[1 75]) '\n']);
    fprintf('simulation with fold %i finished >>>>\n',nfold);
    
end;
