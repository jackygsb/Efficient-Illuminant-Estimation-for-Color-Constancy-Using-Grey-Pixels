function mag = DerivGauss(img,sigma)
% function mag= DerivGauss(img,sigma)
% Design the filters - a derivative of 2D gaussian
% inputs:
%         img ---- one channel of the color-biased image.
%         sigma ---- Local scale.
% outputs:
%         mag --- edge response
%
% Kaifu Yang <yang_kf@163.com>
% March 2015
%=========================================================================%
GaussianDieOff = .000001;

% Design the filters - a gaussian and its derivative
pw = 1:50; % possible widths
ssq = sigma^2;
width = find(exp(-(pw.*pw)/(2*ssq))>GaussianDieOff,1,'last');
if isempty(width)
    width = 1;  % the user entered a really small sigma
end

[x,y]=meshgrid(-width:width,-width:width);
dgau2D=-x.*exp(-(x.*x+y.*y)/(2*ssq))/(pi*ssq);

ax = imfilter(img, dgau2D, 'conv','replicate');
ay = imfilter(img, dgau2D', 'conv','replicate');

mag = sqrt((ax.*ax) + (ay.*ay));

%=========================================================================%
