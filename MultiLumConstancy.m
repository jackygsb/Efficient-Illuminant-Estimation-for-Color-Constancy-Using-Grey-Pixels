function [CorrImg MultiLum] = MultiLumConstancy(img,numGPs,Inum)
% function [CorrImg MultiLum] = MultiLumConstancy(img,numGPs,Inum)
% inputs:
%         img   ------ Input color-biased image.
%         numGPs ----- The number of grey pixels.
%         Inum  ------ The number of illuminant.
% outputs:
%         CorrImg -----Corrected image.
%         MultiLum  --- pixel-wise illuminant.
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

% Kaifu Yang <yang_kf@163.com>;
% March 2015
%========================================================================%

[ww hh dd] = size(img);
EvaLum =zeros(size(img));

R=img(:,:,1);
G=img(:,:,2);
B=img(:,:,3);

R(R==0)=eps;
G(G==0)=eps;
B(B==0)=eps;

% % Algorithm 1 -- using edge as IIM
% GreyEdge = GetGreyidx(img,'GPedge',sigma);
% Greyidx = GreyEdge;

% Algorithm 2 -- using Local Contrast as IIM
GreyStd = GetGreyidx(img,'GPstd',3);
Greyidx = GreyStd;

tt=sort(Greyidx(:));

Gidx = zeros(size(Greyidx));
Gidx(Greyidx<=tt(numGPs)) = 1;

[row col]=find(Gidx==1);
[gIdx,TempCent]=k_means([row col],Inum);
while size(TempCent,1)<Inum
    [gIdx,TempCent]=k_means([row col],Inum);
end


II=zeros(Inum,3);
Cent = zeros(Inum,2);
[xx,yy]=meshgrid(1:hh,1:ww);
Dist = zeros(ww*hh,Inum);
for ki=1:Inum
    Gidxk=zeros(size(Greyidx));
    Cr = row(gIdx==ki);
    Cc = col(gIdx==ki);
    for i = 1:length(Cr)
        Gidxk(Cr(i),Cc(i))=1;
    end
    RR = Gidxk.*R;
    GG = Gidxk.*G;
    BB = Gidxk.*B;
    II(ki,:) = [sum(RR(:)) sum(GG(:)) sum(BB(:))];
    Cent(ki,:) = floor(TempCent(ki,:));
    Dist(:,ki) = sqrt((Cent(ki,1)-yy(:)).^2 + (Cent(ki,2)-xx(:)).^2)...
        ./sqrt(ww^2 + hh^2);
end

tr = zeros(ww*hh,1);
tg = zeros(ww*hh,1);
tb = zeros(ww*hh,1);
sig = 0.2;
Wi = exp(-(Dist./(2*sig^2)));
Swi=sum(Wi,2);
for jj=1:Inum
    Wi(:,jj)= Wi(:,jj)./Swi;
    tr = tr + Wi(:,jj)*II(jj,1);
    tg = tg + Wi(:,jj)*II(jj,2);
    tb = tb + Wi(:,jj)*II(jj,3);
end
tempr = reshape(tr,[ww hh]);
tempg = reshape(tg,[ww hh]);
tempb = reshape(tb,[ww hh]);

EvaLum(:,:,1) = tempr;
EvaLum(:,:,2) = tempg;
EvaLum(:,:,3) = tempb;

coff = sum(EvaLum,3);
EvaLum(:,:,1) = EvaLum(:,:,1)./coff; % normalization
EvaLum(:,:,2) = EvaLum(:,:,2)./coff; % normalization
EvaLum(:,:,3) = EvaLum(:,:,3)./coff; % normalization
MultiLum = EvaLum;

CorrImg(:,:,1) = img(:,:,1)./EvaLum(:,:,1);
CorrImg(:,:,2) = img(:,:,2)./EvaLum(:,:,2);
CorrImg(:,:,3) = img(:,:,3)./EvaLum(:,:,3);

%=========================================================================%

