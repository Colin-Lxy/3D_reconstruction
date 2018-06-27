function corrEdgedata =edge_correct(I,Edgedata)
%I: 图象矩阵
%Edgedata: 边缘坐标(象素级)
%corrEdgedata: 输出修正后的边缘(亚象素级)

[M N] = size(Edgedata);
corrEdgedata = zeros(0,2);

for i = 1:M
    pp = zeros(5,5);
    pp = I(Edgedata(i,1)-2:Edgedata(i,1)+2,Edgedata(i,2)-2:Edgedata(i,2)+2);
    corrpp = facets(pp);
    corrEdgedata(i,:) = Edgedata(i,:)+corrpp;
end



%某像素周围5*5小面（facets）的拟合，由拟合函数的梯度方向和二阶导数求得亚像素边缘
function corrPoint = facets(pointAround)
%pointAround: 待求边缘点周围5*5的小块
%corrPoint: 待求边缘点的修正

Z = reshape(pointAround,[],1);
X = [-2 -1 0  1  2;
     -2 -1 0  1  2;
     -2 -1 0  1  2;
     -2 -1 0  1  2;
     -2 -1 0  1  2;];
Y = X';
X = reshape(X,[],1);
Y = reshape(Y,[],1);
A = [ones(size(X)), X, Y, X.^2, X.*Y, Y.^2, X.^3, X.^2.*Y, X.*Y.^2, Y.^3];
K = A.\double(Z);

k1 = K(1);
k2 = K(2);
k3 = K(3);
k4 = K(4);
k5 = K(5);
k6 = K(6);
k7 = K(7);
k8 = K(8);
k9 = K(9);
k10 = K(10);

%求二阶导数为0的r,theta。（theta固定为垂直于边缘（梯度）方向）
%梯度方向theta，近似为平面法向
temp = sqrt(k2^2+k3^2);
sintheta = k2/temp;
costheta = k3/temp;

%拟合函数二阶导关于r的两个系数
A = 6*(k7*sintheta^3+k8*sintheta^2*costheta+k9*sintheta*costheta^2+k10*costheta^3);
B = 2*(k4*sintheta^2+k5*sintheta*costheta+k6*costheta^2);

r = -A\B;
corrPoint = [r*costheta r*sintheta ];
