clc;
I=imread('Box_1.bmp');
im=rgb2gray(I);
im2=edge(im,'Canny',0.088,7.8);
figure(1)
imshow(im2)
[H,T,R] = hough(im2);
% imshow(H,[],'XData',T,'YData',R,...
%             'InitialMagnification','fit');
% xlabel('\theta'), ylabel('\rho');
% axis on, axis normal, hold on;

P  = houghpeaks(H,9,'threshold',ceil(0.3*max(H(:))));
x = T(P(:,2)); y = R(P(:,1));
%plot(x,y,'s','color','white');

lines = houghlines(im2,T,R,P,'FillGap',260,'MinLength',100);
figure(2)
imshow(I)
hold on

for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

end
[b,i]=sort([lines.theta]);
for k = 1:length(lines)
points1(k,1:2)=[lines(i(k)).point1];
points2(k,1:2)=[lines(i(k)).point2];
end

for i=1:9
lines1(:, i) = real(cross([points1(i,1) points1(i,2)  1]', [points2(i,1) points2(i,2) 1]')); %cross product to get points
end

linesx=lines1(1:3,7:9);
linesy=lines1(1:3,1:4);
linesz=lines1(1:3,5:6);

 vpx = zeros(3, 1);
    vpx(1:2) = (linesx(1:2,:))'\(-1*linesx(3,:))';
    vpx(3) = 1;
    
    vpy = zeros(3, 1);
    vpy(1:2) = (linesy(1:2,:))'\(-1*linesy(3,:))';
    vpy(3) = 1;
    
    vpz = zeros(3, 1);
    vpz(1:2) = (linesz(1:2,:))'\(-1*linesz(3,:))';
    vpz(3) = 1;
    [origin,refx,refy,refz,ref,reflength]=imagedata;
    
    Vp=[vpx,vpy,vpz];
    
    figure(3)
imshow(I)
hold on;
a1=plot([refx(1) origin(1)], [refx(2) origin(2)], 'b','LineWidth',5);
l1=num2str(reflength(1));
l1=strcat('x direction = ',l1);
a2=plot([refy(1) origin(1)], [refy(2) origin(2)], 'g','LineWidth',5); 
l2=num2str(reflength(2));
l2=strcat('y direction = ',l2);
a3=plot([refz(1) origin(1)], [refz(2) origin(2)], 'r','LineWidth',5);
l3=num2str(reflength(3));
l3=strcat('z direction = ',l3);
o=plot(origin(1),origin(2),'yo', 'MarkerSize', 6,'MarkerFaceColor','y');
legend([a1;a2;a3;o],l1,l2,l3,'origin');
title("Reference Directions")

hold off;
    scalingx=zeros(3,1);
  scalingy=zeros(3,1);
   scalingz=zeros(3,1);
   for i=1:3
       
   scalingx(i,1)=(ref(i,1)-origin(i))/((Vp(i,1)-ref(i,1))*reflength(1));
   scalingy(i,1)=(ref(i,2)-origin(i))/((Vp(i,2)-ref(i,2))*reflength(2));
   scalingz(i,1)=(ref(i,3)-origin(i))/((Vp(i,3)-ref(i,3))*reflength(3));
   
   end
  
   i=1;
   while(i<4)
       
   if isfinite(scalingx(i,1)) 
  scalex(i)=scalingx(i,1);
   end
       
   if isfinite(scalingy(i,1))
  scaley(i)=scalingy(i,1);
   end
       
   if isfinite(scalingz(i,1))
  scalez(i)=scalingz(i,1);
   end
   i=i+1;
   end
   scalex=nonzeros(scalex)';
   scaley=nonzeros(scaley)';
   scalez=nonzeros(scalez)';
   tol=2;
   scalex=uniquetol(scalex,tol);
   scaley=uniquetol(scaley,tol);
   scalez=uniquetol(scalez,tol);
   
   
   
   Vx=vpx*scalex;
   Vy=vpy*scaley;
   Vz=vpz*scalez;
   
   
   P=[Vx,Vy,Vz,origin'];
   Hxy=[Vx,Vy,origin'];
   Hxz=[Vx,Vz,origin'];
   Hyz=[Vy,Vz,origin'];
   
Hxy=inv(Hxy);
Hxz=inv(Hxz);
Hyz=inv(Hyz);

tform1=projective2d(Hxy');
tform2=projective2d(Hxz');
 tform3=projective2d(Hyz');
 B1=imwarp(I,tform1);
 B2=imwarp(I,tform2);
B3=imwarp(I,tform3);

figure(4) 
imshow(B1)
title("XY Texture plane")
figure(5)
imshow(B2)
title("XZ Texture plane")
figure(6)
imshow(B3)
title("YZ Texture plane")


    function [origin,refx,refy,refz,ref,reflength]=imagedata



%%% reference points

refx=[1653,888,1]';
refy=[597,938.5,1]';
refz=[1045,910.5,1]';
ref=[refx,refy,refz];


origin=[1036,1201.5,1]; %origin

%reference lengths
 reflength(1)=sqrt((refx(1)-origin(1))^2 + (refx(2)-origin(2))^2);
 reflength(2)=sqrt((refy(1)-origin(1))^2 + (refy(2)-origin(2))^2);
 reflength(3)=sqrt((refz(1)-origin(1))^2 + (refz(2)-origin(2))^2);
 
end

   