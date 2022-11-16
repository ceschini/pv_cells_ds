function transImg = MYTRANSFORM(img)
%img = imread('3.jpg'); 
%Y = im2double(rgb2gray(img));
Y = img;
%imtool(Y);
[transImg, Dotau, A, E, f, tfm_matrix, focus_size, error_sign, UData, VData, XData, YData, A_scale] = TILT(Y,'homography',[130,500;12,490]);
%imwrite(mytrans,'3trans.jpg')
end

%1:110,526,20,512
%2:110,526,40,512
%3:110,468,40,480