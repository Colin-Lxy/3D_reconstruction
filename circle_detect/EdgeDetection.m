function Image_OE=EdgeDetection(image)
%Find edge for an input gray image
%Input:an gray scale image
%Output:
%       1.Image_OE:the detected edge
%reference:P. Perona and J. Malik. Detecting and localizing edges composed
%of steps, peaks and roofs. ICCV, 1990

if(size(image,3)~=1)
    error('The input image should be gray');
end

format long;
load Kernel.mat;
Kernel_num=16;
m_nOrientations=16;
fThreshold=1.0;
nHalfOri=m_nOrientations/2;
m_bank=cell(1,Kernel_num);
[h,w]=size(image);
Yimage=double(image);
for i=1:Kernel_num
    m_bank{i}=imfilter(Yimage,m_kernel{i},'conv','replicate','same');
end

dth = (360/m_nOrientations)*pi/180;
b=zeros(1,128);

Image_OE=zeros(h,w);
Image_Ori=zeros(h,w);
Image_Phase=zeros(h,w);
Image_Scale=zeros(h,w);
m_nScales=1;

for i=1:h
    for j=1:w
        if(i<2||i>=h||j<2||j>=w)
            Image_OE(i,j)=0;
            continue;
        end
        for k=1:Kernel_num
            b(k)=m_bank{k}(i,j)*m_bank{k}(i,j);
        end
        ithMax=1;
        OE_max=-1;
        iS_max=1;
        for s=1:m_nScales
            for ith=1:nHalfOri
                OE_G=b(ith+(s-1)*2*nHalfOri);
                OE_H=b(ith+nHalfOri+(s-1)*2*nHalfOri);
                
                OE=OE_G+OE_H;
                if(OE>OE_max)
                    	OE_max = OE;
						ithMax = ith;
						iS_max = s;
                        
                        Image_OE_G.Pixel(j,i) = OE_G;
						Image_OE_H.Pixel(j,i) = OE_H;
                end
            end
        end
        Image_OE(i,j)=OE_max;
        Image_Ori(i,j)=ithMax-1;
        Image_Scale(i,j)=iS_max-1;
    end
end

fImage=Image_OE;
for i=1:h
    for j=1:w
        if(i<2||i>=h||j<2||j>=w)
            continue;
        end
        oe=Image_OE(i,j);
        id=1;
        for k=-1:1
            for l=-1:1
                a(id)=fImage(i+k,j+l);
                id=id+1;
            end
        end
        if(m_nOrientations==12)
            switch(Image_Ori(i,j))
                case 0
                    oe1=a(4);
                    oe2=a(6);
                    
                case 1
                    oe1=0.5*(a(4)+a(7));
                    oe2=0.5*(a(3)+a(6));
                    
                case 2
                    oe1=0.5*(a(7)+a(8));
                    oe2=0.5*(a(2)+a(3));
                    
                case 3
                    oe1=a(8);
                    oe2=a(2);
                    
                case 4
                    oe1=0.5*(a(8)+a(9));
                    oe2=0.5*(a(1)+a(2));
                    
                case 5
                    oe1=0.5*(a(6)+a(9));
                    oe2=0.5*(a(1)+a(4));
            end
        elseif(m_nOrientations==16)
            switch(Image_Ori(i,j))
                case 0
                    oe1=a(4);
                    oe2=a(6);
                case 1
                    oe1=0.5*(a(4)+a(7));
                    oe2=0.5*(a(3)+a(6));
                case 2
                    oe1=a(7);
                    oe2=a(3);
                case 3
                    oe1=0.5*(a(7)+a(8));
                    oe2=0.5*(a(2)+a(3));
                case 4
                    oe1=a(8);
                    oe2=a(2);
                case 5
                    oe1=0.5*(a(8)+a(9));
                    oe2=0.5*(a(1)+a(2));
                case 6
                    oe1=a(9);
                    oe2=a(1);
                case 7
                    oe1=0.5*(a(6)+a(9));
                    oe2=0.5*(a(1)+a(4));
            end
        end
        
        if(oe<=oe1||oe<=oe2)
            Image_OE(i,j)=0;
        end
    end
end

aver_energy=0;
for i=1:h
    for j=1:w
        aver_energy=aver_energy+Image_OE(i,j);
    end
end
aver_energy=aver_energy/(w*h);
for i=1:h
    for j=1:w
        if(Image_OE(i,j)>(aver_energy*fThreshold))
            Image_OE(i,j)=255;
        else
            Image_OE(i,j)=0;
        end
    end
end

EDGE_TYPE_STEP=0;
EDGE_TYPE_DARKLINE=1;
EDGE_TYPE_LIGHTLINE=2;
EDGE_TYPE_NONE=3;

for i=1:h
    for j=1:w
        s=Image_Scale(i,j);
        oe=Image_OE(i,j);
        iPhase=EDGE_TYPE_NONE;
        if(abs(oe)<1e-8||i<2||i>=h||j<2||j>=w)
            Image_Phase(i,j)=EDGE_TYPE_NONE;
            continue;
        end
        ith=Image_Ori(i,j);
        g2=m_bank{ith+1+s*2*nHalfOri}(i,j);
        h2=m_bank{ith+1+nHalfOri+s*2*nHalfOri}(i,j);
        if(abs(g2*g2)*1.2>abs(h2*h2))
            if(g2>0)
                iPhase=EDGE_TYPE_DARKLINE;
            else
                iPhase=EDGE_TYPE_LIGHTLINE;
            end
            if(h2<0)
                Image_Ori(i,j)=Image_Ori(i,j)+nHalfOri;
            end
        else
            iPhase=EDGE_TYPE_STEP;
            if(h2<0)
                Image_Ori(i,j)=Image_Ori(i,j)+nHalfOri;
            end
        end
        Image_Phase(i,j)=iPhase;
    end
end
Image_OE=uint8(Image_OE);
