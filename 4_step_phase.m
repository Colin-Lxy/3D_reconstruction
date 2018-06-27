clear all
clf
clc
I1=zeros(256,256);
I2=zeros(256,256);
I3=zeros(256,256);
I4=zeros(256,256);

figure(1);        %生成四幅干涉图并显示 
a=-80:0.1:80;
b=meshgrid(a);
I1=cos(b-pi);
%Ia(:,:,1)=I1;Ia(:,:,2)=0;Ia(:,:,3)=0;(red)

imshow(I1);

figure(2);
I2=cos(b-pi/2);
imshow(I2);

figure(3);
I3=cos(b);
imshow(I3);

figure(4);
I4=cos(b+pi/2);
imshow(I4);
for j=1:256
    for i=1:256
phase(i,j)=atan2(I2(i,j)-I4(i,j),I1(i,j)-I3(i,j));   
 end
    end

%四步相移法计算出相位
          
figure(5);
imshow(mat2gray(phase));

figure(6);
imshow(phase);

n=zeros(256,256);   %解包
n(1,1)=0;
for i=2:256
    if abs(phase(1,i)-phase(1,i-1))<pi
        n(1,i)=n(1,i-1);
    elseif phase(1,i)-phase(1,i-1)<=-pi
        n(1,i)=n(1,i-1)+1;
    elseif phase(1,i)-phase(1,i-1)>=pi
        n(1,i)=n(1,i-1)-1;
    end
end

for i=1:256
    for j=2:256
        if abs(phase(j,i)-phase(j-1,i))<pi
            n(j,i)=n(j-1,i);
        elseif phase(j,i)-phase(j-1,i)<=-pi
            n(j,i)=n(j-1,i)+1;
        elseif phase(j,i)-phase(j-1,i)>=pi
            n(j,i)=n(j-1,i)-1;
        end
    end
end    

pphase=phase+2*pi.*n;
figure(7);
imshow(mat2gray(pphase));
figure(8);
surf(pphase(2:end-1,2:end-1));
