function stdImg = MYCROP(oriImg)
%oriImg = imread('1trans.jpg'); 
img = rgb2gray(oriImg);
thre = graythresh(img);
mask = imbinarize(img,thre);
%filtMask = medfilt2(mask,[10,10]);
%fillMask = ~imfill(~filtMask, 'holes');
erodeMask = imerode(mask,strel('diamond',10)); % sphere 6
fillMask = bwareaopen(erodeMask,2000); %3200
filtMask = medfilt2(fillMask,[10,10]);
dilateMask = imdilate(filtMask,strel('square',10));

%bboxes = regionprops(filtMask,'BoundingBox');

% find largest boundingBox
%boxesArea = zeros(1,length(bboxes));
%for i=1:length(bboxes)
%    tar = bboxes(i).BoundingBox;
%    boxesArea(i) = tar(3)*tar(4);
%end
%[~,index] = max(boxesArea);
%bbox=bboxes(index);

[x,y] = find(dilateMask==1);
min_x = min(x);
max_x = max(x);
min_y = min(y);
max_y = max(y);

cropImg = imcrop(oriImg,[min_y,min_x,max_y-min_y,max_x-min_x]);
stdImg = imresize(cropImg,[size(cropImg,1),225]);
%imwrite(stdImg,'1transcrop.jpg')
end
