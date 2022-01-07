%Usage: [reference image, registered image] = alignment_live_storm(name live reference image,name storm image)
function [ref_scaled,registered] = alignment_live_storm(live,storm);

% load single image from live imaging for reference image (works best with max projection saved as 8bit .tif)
fn=sprintf('%s.tif',live); 
a=double(imread(fn));

%% include this section if loading time-series/z-stack as reference instead of single image
% info=imfinfo(fn);       % info returns structure whose size is number of images in stack        
% d1 = size(info);
% a=0;
% 
% for i = 1:d1(1)
%     t(:,:,i) = double(imread(fn,i));     %load t-series
% end
% a=max(t,[],3); %generate max projection

% clear t
%%
% load storm .tif image
b=0;
fn2=sprintf('%s.tif',storm); 
b=double(imread(fn2));

%convert live (a2) and storm (b2) images to range 0 to 1 for cpselect
a2=a/(max(max(a)));            
b2=b/(max(max(b)));

% find size of live and storm images
d1=size(a2); 
d2=size(b2); 

% find scaling factors for both dimensions 
% assumes storm image is larger
factor_x = d2(2)/d1(2); 
factor_y = d2(1)/d1(1);

%use smaller scaling factor to scale live image to storm image 
%preserves aspect ratio of live image if non-square 
if factor_x<=factor_y
    a2 = imresize(a2,factor_x);
else
    a2 = imresize(a2,factor_y);
end
ref_scaled = a2;

% select matching landmarks in both images, close window to finish
[reg_points,ref_points] = cpselect(b2,a2,'Wait',true); 
% affine transformation of storm image
t_concord = fitgeotrans(reg_points,ref_points,'affine');
Rfixed = imref2d(size(a2));
registered = imwarp(b2,t_concord,'OutputView',Rfixed);
% display overlaid reference (a2,live scaled) and registered (storm) image
figure('Name','affine registration')
imshowpair(a2,registered)

%save registered storm image as tiff in current folder
I2 = im2uint16(registered);
imwrite (I2, 'reg_storm.tiff'); 
