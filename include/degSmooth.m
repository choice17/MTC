function out_deg = degSmooth(in_deg,option)
% out_deg = degSmooth(in_deg,option)
% Obj: filter noise of deg signal using smooth() function after cos/sine transform
% input: in_deg, vector of degree signal, range: (0-360)
%        option.smoothAlg, smoothing alg selection: 'moving' | 'loess' .etc
%        option.windowSize, window size for filtering
%        default value, 'moving', windowsize = 11;
% output: out_deg, same vector dim to in_deg, filtered degree signal
% written by choi @ 8/9/2017 tcyu@umich.edu
%{ 
  example.
    %%%gen example heading sig 
    dt = 1000;
    t = [0:2*pi/dt:2*pi-2*pi/dt];
    t = [t(1:dt*3/4) t(dt*1/4:end)];
    a = -(sin(t)*180 - 180) + randn(1,length(t))*10;
    a(a>360) = a(a>360)-360;
    a(a<0) = a(a<0)+360;
    ori_a = a;

    %%%filter the deg signal
    AS = degSmooth(ori_a);

    %%%comparison
    figure(1);
    plot(ori_a); hold on;
    plot(AS); hold off;
    title('degree smoothing');
    legend({'orig deg signal','smoothed deg signal'}); 
              
%}


if nargin ==1
    option.smoothAlg = 'moving';
    option.windowSize = 10;    
end

alg=option.smoothAlg;
ws =option.windowSize;

% turn to continuous value for smoothing 
in_deg = in_deg - 180;
C = cos(deg2rad(in_deg));
S = sin(deg2rad(in_deg));

%% smoothing the signal after tranformation
Csmooth = smooth(C,ws,alg);
Ssmooth = smooth(S,ws,alg);

%% retri the orientation (unit deg)
SRe = asin(Ssmooth);
% region I. retri 0 to pi/2
SRe(Ssmooth>0 & Csmooth>0)= SRe(Ssmooth>0 & Csmooth>0);
% region II. retri -pi/2 to 0
SRe(Ssmooth<0 & Csmooth>0)= SRe(Ssmooth<0 & Csmooth>0);
% region III. retri pi/2 to pi
SRe(Ssmooth>0 & Csmooth<0)= pi/2+ (bsxfun(@minus,pi/2,SRe(Ssmooth>0 & Csmooth<0)));
% region IV. retri -pi to pi/2
SRe(Ssmooth<0 & Csmooth<0)= -pi/2 + (bsxfun(@minus,-pi/2,SRe(Ssmooth<0 & Csmooth<0)));

% zero case
SRe(Ssmooth==0 & Csmooth>0) = SRe(Ssmooth==0 & Csmooth>0);
SRe(Ssmooth>0 & Csmooth==0) = SRe(Ssmooth>0 & Csmooth==0);
SRe(Ssmooth<0 & Csmooth==0) = SRe(Ssmooth<0 & Csmooth==0);
SRe(Ssmooth==0 & Csmooth<0) = pi;

out_deg = rad2deg(SRe)+180;
end

