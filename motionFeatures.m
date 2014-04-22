clear all; close all;

span = 8;
skip = 4;
height = 480;
width = 640;
sdirectory = 'C:/Users/RFSC/Desktop/DataSet/CaltechPedestrianBenchmark/simulationCode/data_feat_test/images';
[~, setIds, vidIds, ~, ext] = dbInfo('Usa');
features = containers.Map;

for set=1:length(setIds)
    for vid = 1:length(vidIds)
        setVidDir = [sdirectory '/set' num2str(setIds(set), '%0.2d') '/V' num2str(vidIds{set}(vid), '%0.3d')];
        imageFiles = dir([setVidDir '/*.jpg']);
        
        %compute motion Features
        feat = WeakStbMotionFeat(setVidDir,imageFiles, height,width,span,skip);
        
        %update features
        keys = keys(feat);
        values = values(feat);
        for f=1:length(keys)            
            features(keys(f)) = values(f);
        end;             
    end;
end;

save('WeakStabMF', features);










