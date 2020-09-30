function [CorrImg EvaLum] = GPconstancy(img,numGPs,mask)
% function [CorrImg EvaLum] = GPconstancy(img,numGPs,mask)
% inputs:
%         img   ------ Input color-biased image.
%         numGPs ----- The number of grey pixels.
%         mask  ------ The mask of color checker.
% outputs:
%         CorrImg -----Corrected image
%         EvaLum  ---- Estimated illuminant
%
% Main function for performing color constancy system using Grey Pixels in paper:
% Kaifu Yang, Shaobing Gao, and Yongjie Li*.
% Efficient Illuminant Estimation for Color Constancy Using Grey Pixels.CVPR, 2015.
%
% Contact:
% Visual Cognition and Computation Lab(VCCL),
% Key Laboratory for NeuroInformation of Ministry of Education,
% School of Life Science and Technology(SLST),
% University of Electrical Science and Technology of China(UESTC).
% Address: No.4, Section 2, North Jianshe Road,Chengdu,Sichuan,P.R.China, 610054
% Website: http://www.neuro.uestc.edu.cn/vccl/home.html

% ���ӿƼ���ѧ��������ѧ�뼼��ѧԺ��
% ����Ϣ�������ص�ʵ���ң��Ӿ���֪�������
% �й����Ĵ����ɶ������豱·����4�ţ�610054

% ���/Kaifu Yang <yang_kf@163.com>;
% ������/Yongjie Li <liyj@uestc.edu.cn>;
% March 2015
%
%========================================================================%

R=img(:,:,1); G=img(:,:,2); B=img(:,:,3);
R(R==0)=eps;  G(G==0)=eps;  B(B==0)=eps;

% % Algorithm 1 -- using edge as IIM
% sigma = 0.5;
% GreyEdge = GetGreyidx(img,'GPedge',sigma);
% Greyidx = GreyEdge;

% Algorithm 2 -- using Local Contrast as IIM
GreyStd = GetGreyidx(img,'GPstd',3);
Greyidx = GreyStd;

if ~isempty(mask)
    Greyidx(find(mask)) = max(Greyidx(:));
end

tt=sort(Greyidx(:));
Gidx = zeros(size(Greyidx));
Gidx(Greyidx<=tt(numGPs)) = 1;

RR = Gidx.*R;
GG = Gidx.*G;
BB = Gidx.*B;

Rillu = sum(RR(:));
Gillu = sum(GG(:));
Billu = sum(BB(:));

EvaLum =[Rillu Gillu Billu];


CorrImg = zeros(size(img));
CorrImg(:,:,1) = img(:,:,1)./Rillu;
CorrImg(:,:,2) = img(:,:,2)./Gillu;
CorrImg(:,:,3) = img(:,:,3)./Billu;

%=========================================================================%

