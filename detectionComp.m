close all;clear all;

%1: set07_V011_I00299

Ifn = 'C:\Users\RFSC\Documents\Development Files\MatlabWorkspace\ acf-extension\data-exp\images\set07_V011_I00299.jpg'; I=imread(Ifn);
GT_fn = 'C:\Users\RFSC\Documents\Development Files\MatlabWorkspace\ acf-extension\data-exp\annotations\set07_V011_I00299.txt'; [~,bbsGT] = bbGt( 'bbLoad', GT_fn);

load('C:\Users\RFSC\Documents\Development Files\MatlabWorkspace\ acf-extension\data\results\tcc_results\ACF\models\fold3\AcfCaltechDetector.mat')
bbs=acfDetect(I, Ifn, detector); figure(1); im(I); bbApply('draw',bbs,'g');bbApply('draw',bbsGT,'b');

load('C:\Users\RFSC\Documents\Development Files\MatlabWorkspace\ acf-extension\data\results\tcc_results\ACF_IMHcd\models\fold10\AcfCaltechDetector.mat')
bbs=acfDetect(I, Ifn, detector); figure(2); im(I); bbApply('draw',bbs,'g');bbApply('draw',bbsGT,'b');acfTrain