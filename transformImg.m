function output = transformImg(input_image)
image = input_image;
%%
[bw,orig_mask] = createMaskWhite(image);
bw = imfill(bw,'holes');
image2=image;



labeled_image=bwlabel(bw); 
cc=bwconncomp(bw);


properties = regionprops(cc,'Area','BoundingBox');

for i = 1:size(properties,1)
        %Filter out items too large or small
    if (properties(i).Area < 40000 || properties(i).Area > 700000 )
            bw = bw & ~(labeled_image == i);
    end
end
image2(repmat(~bw,[1 1 3])) = 0;

[bw_r,m_r] = createMaskRed(image2);
[bw_b,m_b] = createMaskBlue(image2);
[bw_g,m_g] = createMaskGreen(image2);

cc_r = bwconncomp(bw_r);
properties_r = regionprops(cc_r,'Area','BoundingBox','Centroid');
labeled_image_r=bwlabel(bw_r); 

cc_b = bwconncomp(bw_b);
properties_b = regionprops(cc_b,'Area','BoundingBox','Centroid');
labeled_image_b=bwlabel(bw_b);

cc_g = bwconncomp(bw_g);
properties_g = regionprops(cc_g,'Area','BoundingBox','Centroid');
labeled_image_g=bwlabel(bw_g);

for i = 1:size(properties_b,1)
        %Filter out items too large or small
    if (properties_b(i).Area < 100 || properties_b(i).Area > 4000 )
            bw_b = bw_b & ~(labeled_image_b == i);
    end
end
cc_b = bwconncomp(bw_b);
properties_b = regionprops(cc_b,'Area','BoundingBox','Centroid');
labeled_image_b=bwlabel(bw_b);

[biggest_area,index] = max( [properties_b.Area] );
top_left = properties_b(1).Centroid;
    
for i = 1:size(properties_g,1)
        %Filter out items too large or small
    if (properties_g(i).Area < 100 || properties_g(i).Area > 4000 )
            bw_g = bw_g & ~(labeled_image_g == i);
    end
end
cc_g = bwconncomp(bw_g);
properties_g = regionprops(cc_g,'Area','BoundingBox','Centroid');
labeled_image_g=bwlabel(bw_g);

[biggest_area,index] = max( [properties_g.Area] );
top_right = properties_g(1).Centroid;
    
for i = 1:size(properties_r,1)
        %Filter out items too large or small
    if (properties_r(i).Area < 100 || properties_r(i).Area > 4000 )
            bw_r = bw_r & ~(labeled_image_r == i);
    end
end
cc_r = bwconncomp(bw_r);
properties_r = regionprops(cc_r,'Area','BoundingBox','Centroid');
labeled_image_r=bwlabel(bw_r);
[areas,index2] = sort( [properties_r.Area] );

red = [properties_r(index2(end)).Centroid;properties_r(index2(end-1)).Centroid];


if top_left(1)< top_right(1)
   [~,i]= min(red(:,1));
   [~,j]= max(red(:,1));
   bottom_left = red(i,:);
   bottom_right = red(j,:);
else
    [~,i]= min(red(:,1));
   [~,j]= max(red(:,1));
   bottom_left = red(j,:);
   bottom_right = red(i,:);
end


    %%
points = [top_left;top_right;bottom_left;bottom_right];
    %%







%points are the 4 points
output = image;
img = image;


fixedPoints = [0,0;500,0;0,500;500,500];
movingPoints = points;
tform = fitgeotrans(movingPoints,fixedPoints,'Projective');

RA = imref2d([size(img,1) size(img,2)], [1 size(img,2)], [1 size(img,1)]);

[out,r] = imwarp(img, tform, 'OutputView', RA);
%imshow(out,r);
output=imcrop(out,[0,0,500,500]);

    
end
