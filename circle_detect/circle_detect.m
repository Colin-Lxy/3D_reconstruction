addpath('./ellipse_fit');

%%读入图像
show = 1;


I = imread('t2.bmp');

fprintf(1,'step1 : 从图像中提取出圆心\n');

%% 亚像素边缘求圆心
%高斯滤波
kernel = fspecial('gaussian',[3 3],1);
I = imfilter(I,kernel);
%canny边缘提取
circle_edge = edge(I,'canny',0.3);

if show
    figure(1);
    imshow(circle_edge);
end
%提取边界
boundary = bwboundaries(circle_edge,'noholes');

circle_num = 1;%记录有效圆的个数
%去掉边缘大小太大或太小的边界
for i = 1:length(boundary)
    bound = boundary{i};
    sz = size(bound,1);
    if (sz<100)
        continue;
    end
    
    %去掉不闭合的边缘 不闭合的边缘除端点外,所有的点均出现两次 若闭合,则n_repeat=2
    n_repeat = 0;
    for c=1:sz
        originEdgei = [ones(sz,1)*bound(c,1), ones(sz,1)*bound(c,2)];
        closeni = (originEdgei(:,1) == bound(:,1)) & (originEdgei(:,2) == bound(:,2));
        if sum(closeni) == 2
            n_repeat = n_repeat+1;
        end
    end
    if n_repeat ~= 2
        continue;
    end
    
    %求亚像素边缘
    subpixel_edge = edge_correct(I,bound);
    %拟合圆心
    [center,Rerr] = find_circle_center_new(subpixel_edge(:,2),subpixel_edge(:,1));
    
    if Rerr>0.5
        continue;
    end
    
    %保存数据
    circle(circle_num).center =center;
    circle(circle_num).idx = circle_num;
    circle(circle_num).edge = subpixel_edge;
    circle(circle_num).size = sz;
    circle_num = circle_num+1;
    
    if show
    hold on;
    plot(center(2), center(1), 'g+');
    str = num2str(circle_num);
    text(center(1,1),center(1,2),str,'Color','r','FontSize',24,'BackgroundColor',[1 1 1],'EdgeColor','red','FontWeight','bold');
    plot(bound(:,2),bound(:,1),'r','LineWidth',2);
    end
 end

    
