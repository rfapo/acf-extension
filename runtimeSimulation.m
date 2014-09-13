clear all;

%% names
%{name, folder, best fold}
names = {%'ACF', 'ACF', '7';
    %'ACF + EHOG', 'ACF_ENT', '4';    
    %'ACF + MBH', 'ACF_MBH', '7';
    %'ACF + IMHcd', 'ACF_IMHCD', '10';
    'ACF + WSTD', 'ACF_WSSD', '10';
    'ACF + EHOG + MBH', 'ACF_ENT_MBH', '3';
    'ACF + EHOG + IMHcd', 'ACF_ENT_IMHCD', '1';    
    'ACF + EHOG + WSTD', 'ACF_ENT_WSSD', '10'};

detectores = cell(1,size(names,1));

%% load detectors
for i = 1:size(names,1)
    detectorPath = strcat('C:\Users\RFSC\Documents\Development Files\MatlabWorkspace\ acf-extension\data\results\tcc_results\',names{i,2},'\models\fold',names{i,3},'\AcfCaltechDetector.mat');
    det = load(detectorPath); detectores{i} = det.detector;
end;
%% Load images
allDataDir = 'C:\Users\RFSC\Documents\Development Files\MatlabWorkspace\ acf-extension\data-exp';
imgNms=bbGt('getFiles',{[allDataDir '\images']}); gtNms=bbGt('getFiles',{[allDataDir '\annotations']});
nImgs = numel(imgNms);

%pload parameters
pLoad={'lbls',{'person'},'ilbls',{'people'},'squarify',{3,.41}};
pLoad = [pLoad 'hRng',[50 inf], 'vRng',[0.65 1] ];

%% run each detector on samples images
for d = 1:size(names,1)
    fprintf('Detector %s has just started \n', names{d,1});
    
    timerElap = zeros(1,nImgs);
    for i = 1:nImgs
        fn = imgNms(i); fn = fn{:}; I = imread(fn); gtDir = gtNms(i);
        tic; bbs=acfDetect(I, fn, detectores{d}); timerElap(i) = toc;        
        
        if (mod(i,100) == 0) , fprintf('%.4f%% concluded \n', (i/nImgs)); end;
    end;
    
    %print and save information
    fprintf('%s average time: %.4f seconds \n', names{d,1}, mean(timerElap));
    fprintf('%s std time: %.4f seconds \n', names{d,1}, std(timerElap));
    fprintf('%s average runtime %.4f fps \n', names{d,1}, nImgs/sum(timerElap));
    save(strcat(names{d,1},'runtime'), 'timerElap');
    fprintf('Detector %s finished \n', names{d,1});
    
end;
