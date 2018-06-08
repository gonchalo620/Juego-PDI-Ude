clear all, close all, clc
imagen=imread('amarillo3.jpg');
%imagen=imread('esqueje.TIFF');
imagen=imresize(imagen,0.5);
figure(1);imshow(imagen);impixelinfo

[fil,col,cap]=size(imagen);

b=reshape(imagen,[fil,col*cap]);
figure(2);imshow(b);title('Componentes RGB')
impixelinfo

hsv=rgb2hsv(imagen);
figure(3);
imshow(hsv);
title(['HSI o HSV'])
impixelinfo

hsv=reshape(hsv,[fil,col*cap]);
figure(4);imshow(hsv);title('Componentes HSI o HSV')
impixelinfo

hsv=double(hsv);
hsv=hsv/max(hsv(:))*255;
hsv=uint8(hsv);
figure(5);imshow(hsv);title('Componentes HSI o HSV')
impixelinfo

figure(6);imshow([b;hsv]);title(' R G B  ;  H S V')


cform = makecform('srgb2cmyk');
cmyk = applycform(imagen,cform);
cmyk=double(cmyk);
cmyk=cmyk/max(cmyk(:))*255;
cmyk=uint8(cmyk);cmyk2=cmyk;
cmyk=reshape(cmyk,[fil,col*4]);

figure(7);imshow(cmyk);title('C M Y K')
impixelinfo


cmyk2=cmyk2(:,:,1:3);
capa_y=cmyk2(:,:,3);
cmyk2=reshape(cmyk2,[fil,col*3]);
figure(8);imshow(cmyk2);title(' C M Y ')
impixelinfo

close all 

figure(9);
imshow([b;hsv;cmyk2]);
title(' R G B  ;  H S V ; C M Y')
impixelinfo


mascara=capa_y;
mascara(capa_y<220)=0;

figure(10);
imshow([capa_y,mascara]);
title(' Capa y  ;  Mascara')
impixelinfo


mascara=[mascara,mascara,mascara];
mascara=reshape(mascara,[fil,col,cap]);
figure(11)
imshow([mascara]);
title(' Mascara Waffer')
impixelinfo


resultado=imagen;
resultado(mascara==0)=255;
figure(12)
imshow([imagen,mascara,resultado]);
title(' Original, Mascara y Resultado')
impixelinfo
