% Online Automatic Anomaly Detection for Photovoltaic Systems Using Thermography Imaging and Low Rank Matrix Decomposition  
%
% Qian Wang, Kamran Paynabar, Massimo Pacella, August 2020. 

k = 20;
nTimes = 50;

imgDir = dir('target/*R.jpg');
anoInds = [31:33,39:43,66,83:85,103:104];

TpreList = zeros(1,nTimes);
TrpcaList = zeros(1,nTimes);
TpostList = zeros(1,nTimes);
TList = zeros(1,nTimes);

TPList = zeros(1,nTimes);
TNList = zeros(1,nTimes);
FPList = zeros(1,nTimes);
FNList = zeros(1,nTimes);

accuracyList = zeros(1,nTimes);
precisionList = zeros(1,nTimes);
recallList = zeros(1,nTimes);
F1List = zeros(1,nTimes);

for t=1:nTimes
    
    tStart = tic; 
    
    normInds = 1:120;
    normInds(anoInds) = [];
    tmp = randsample(length(normInds),k);
    blInds = normInds(tmp);
    normInds(tmp) = [];

    imgs = {};
    for i = 1:length(blInds)
        blIndex = blInds(i);
        img = imread(['target/' imgDir(blIndex).name]); 
        transImg = MYTRANSFORM(img);
        %imwrite(transImg,['target/' imgDir(blIndex).name 'Trans.jpg'])
        cropImg = MYCROP(transImg);
        %imwrite(cropImg,['target/' imgDir(blIndex).name 'Crop.jpg'])
        img = im2double(rgb2gray(cropImg));
        img = imresize(img,[size(img,1),225]);
        imgs{i} = img;
    end
    Y_base = vertcat(imgs{:});

    imgInds = [anoInds normInds];  

    Tpre = zeros(1,length(imgInds));
    Trpca = zeros(1,length(imgInds));
    Tpost = zeros(1,length(imgInds));

    testPosList = [];
    for i=1:length(imgInds)
        imgIndex = imgInds(i);
        tic;
        img = imread(['target/' imgDir(imgIndex).name]); 
        transImg = MYTRANSFORM(img);
        %imwrite(transImg,['target/' imgDir(imgIndex).name 'Trans.jpg'])
        cropImg = MYCROP(transImg);
        %imwrite(cropImg,['target/' imgDir(imgIndex).name 'Crop.jpg'])
        tarImg = im2double(rgb2gray(cropImg));
        imgSize = size(tarImg,1);

        Y = vertcat(tarImg, Y_base);
        Tpre(imgIndex) = toc;

        tic;
        [L,S]=RobustPCA(Y);
        Trpca(imgIndex) = toc;

        tic;
        I = S(1:imgSize,:);
        J = medfilt2(I,[15 15]);
        %level = graythresh(J);
        BW = imbinarize(J,0.025); % 0.03
        Tpost(imgIndex) = toc;

        %final = horzcat(Y(1:imgSize,:),L(1:imgSize,:),S(1:imgSize,:),BW); 
        %imwrite(final,['target/' imgDir(imgIndex).name 'Res.jpg']);

        if any(any(BW))
            testPosList = [testPosList imgIndex];
        end
    end
    
    tEnd = toc(tStart);

    TpreList(t) = mean(Tpre);
    TrpcaList(t) = mean(Trpca);
    TpostList(t) = mean(Tpost);
    TList(t) = tEnd;

    TPList(t) = sum(ismember(testPosList,anoInds));
    FPList(t) = length(testPosList)-TPList(t);
    FNList(t) = length(anoInds) - sum(ismember(anoInds,testPosList));
    TNList(t) = 120-k-TPList(t)-FPList(t)-FNList(t);

    accuracyList(t) = (TPList(t)+TNList(t))/(120-k);
    precisionList(t) = TPList(t)/(TPList(t)+FPList(t));
    recallList(t) = TPList(t)/(TPList(t)+FNList(t));
    F1List(t) = 2/(1/precisionList(t)+1/recallList(t));
    
end

Tpre = mean(TpreList)
Trpca = mean(TrpcaList)
Tpost = mean(TpostList)
T = mean(TList)

TP = mean(TPList)
FP = mean(FPList)
FN = mean(FNList)
TN = mean(TNList)

accuracy = mean(accuracyList)
precision = mean(precisionList)
recall = mean(recallList)
F1 = mean(F1List)

