%day1_10HzRaw = csvread('../V2P/day1_full.mat');
addpath ../V2P ../include ../analysis
load ../V2P/day1_full.mat
load ../V2P/day1F_train.mat
load ../V2P/day1_10Hz_Train.mat
load ../V2P/day1_10H.mat
%day1_10HzRaw = day1_full;
%clear day1_full
% attr 
%{
 Columns 1 through 11
    'VID'    'TripID'    'Lat'    'Long'    'Elevation'    'Speed'    'Heading'    'Ax'    'Ay'    'Az'    'Yawrate'
  Columns 12 through 14
    'RadiusOfCurve'    'Confidence'    'Time'
%}


%% err trip find in 69,86,88,99, 63
%     1-250/0/1-1150/errFull
%     filter the problem segment
%     manually extract the other one trip from day1F_Obj
keepID = day1F_train.TripID;
numID = length(keepID);
keepID(99) = keepID(100);
keepID(100) = 2161745;
day1_10H = cell(numID,1);
day1_10H_tripInfo = [];
featCol = [1 2 8 9 10 11 12 13 14 15 16 18 19 4];
msgl=0;
for i = 1:numID
    day1_10H{i} = day1_10HzRaw(day1_10HzRaw(:,2)==keepID(i),featCol);
    day1_10H_len = length(day1_10H{i}(:,1));
    msgl = printper(i,numID,msgl);
    
end
%% crop the error part start day1_10H here 
day1_10H{69} = day1_10H{69}(251:end,:);
day1_10H{88} = day1_10H{88}(1151:end,:);
day1_10H{63} = day1_10H{63}(130:end,:);

% get the trip obj
day1_10Hz_Train = day1TripTrain(day1_10H);

%rearrange trip
day1_10Hz_Train = day1_10Hz_Train.rearrangeTrip('ascend');

%downsample
option.sampleRate = 0.5;
option.algorithm = 'moving';
option.windowSize = 11;
day1_5Hz_Train = day1_10Hz_Train.downSample(option);

%downsample
option.sampleRate = 0.2;
option.algorithm = 'moving';
option.windowSize = 11;
day1_2Hz_Train = day1_10Hz_Train.downSample(option);

%downsample
option.sampleRate = 0.1;
option.algorithm = 'moving';
option.windowSize = 11;
day1_1Hz_Train = day1_10Hz_Train.downSample(option);

%save ../V2P/day1_2Hz_Train.mat day1_2Hz_Train
%save ../V2P/day1_5Hz_Train.mat day1_5Hz_Train
save ../V2P/day1_1Hz_Train.mat day1_1Hz_Train


    %% for trip one filter method analysis
    thisTrip = day1_10H{1}(:,[3 4]);
    lenTrip = length(thisTrip(:,1));
    %filtTrip1 = [smooth(thisTrip(:,1),31,'loess') ... 
    %    smooth(thisTrip(:,2),31,'loess')];
    filtTrip2 = [medfilt1(thisTrip(:,1),5) medfilt1(thisTrip(:,2),5)] ;
    filtTrip3 = [smooth(filtTrip2(:,1),11) ... 
        smooth(filtTrip2(:,2),11)];
    %headingfilt = medfilt1(day1_10H{1}(:,[7]),3);
   
    filtTrip1 = [smooth(filtTrip2(:,1),15,'loess') ... 
        smooth(filtTrip2(:,2),15,'loess')];
    
    %spdfilt = day1_10H{1}(:,[6]);
   
   %% for trip one
   hold off;
    h = plot(day1_10H{1}(:,4),day1_10H{1}(:,3),'ro-','MarkerFaceColor','r');hold on;
    set(h,'MarkerFaceColor',get(h,'Color'));
    h = plot(filtTrip1(1:10:end,2),filtTrip1(1:10:end,1),'bp-'); hold on;
    
    set(h,'MarkerFaceColor',get(h,'Color'));
    plot(filtTrip3(1:10:end,2),filtTrip3(1:10:end,1),'ks-','MarkerFaceColor','k');
    h = plot(day1F_train.TripInCell{1}(:,4),day1F_train.TripInCell{1}(:,3),'gs-');
    set(h,'MarkerFaceColor',get(h,'Color'));
    title('TripID: 2449640');
    legend({'Raw data','Median+Loess','Median+Mean','No filter'});
  %% for trip one
  
  plot(filtTrip3(3000:10:6000,2),filtTrip3(3000:10:6000,1),'r.'); hold on;
  plot(day1F_train.TripInCell{1}(300:600,4),day1F_train.TripInCell{1}(300:600,3),'g.');
  
  plot_google_map('MapType','roadmap')
  %%
nSamp = length(day1F_train.TripInCell{1}(:,4));
Fs = 1;
t = (0:nSamp-1)'/Fs;


subplot 211
obw(day1F_train.TripInCell{1}(:,4),Fs); hold on;
subplot 212
obw(filtTrip3(1:10:end,2),Fs);
%%
nSamp = length(day1_10H{1}(:,4));
Fs = 10;
t = (0:nSamp-1)'/Fs;
subplot 211
obw(day1_10H{1}(:,4),Fs); hold on;
subplot 212
obw(filtTrip3(:,2),Fs);
%%
  
  subplot 411
  plot(day1F_train.TripInCell{1}(:,4),'Linewidth',2); hold on;
  plot(filtTrip3(1:10:end,2),'--','Linewidth',2); hold off;
  subplot 412
  semilogy(fftshift(abs(fft(day1F_train.TripInCell{1}(:,4)))),'Linewidth',2); hold on;
  semilogy(fftshift(abs(fft(filtTrip3(1:10:end,2)))),'-.','Linewidth',2); hold off;
  subplot 413
  plot(day1_10H{1}(:,4),'Linewidth',2); hold on;
  plot(filtTrip3(:,2),'--','Linewidth',2); hold off;
  subplot 414
  semilogy(fftshift(abs(fft(day1_10H{1}(:,4)))),'Linewidth',2); hold on;
  semilogy(fftshift(abs(fft(filtTrip3(:,2)))),'--','Linewidth',2); hold off;
  
  %%
  A = zeros(1,100);
  A(1:10)=1/10 ;
  ws = (0:2/100:(2 - 2/100)) - 1; 
 %%
  
  %plot(abs(ifft(A)));
  %semilogy(ws,fftshift(abs(fft(day1_10H{1}(:,3)))./rawsampleSize),'Linewidth',2); hold on;
  %obw(A,10);
 plot(ws,fftshift(abs(fft(A))),'Linewidth',2); hold on;
  title('frequency response of moving average filter');
  xlabel('angular frequency \omega (x \pi rad/sample)');
  ylabel('magnitude ')
  %obw(day1_10H{1}(:,3),10)
  %%
  rawsampleSize = length(day1_10H{1}(:,3));
  subsampleSize = length(day1F_train.TripInCell{1}(:,3));
  rawfre = 10;
  subfre = 1;
  rawFs = [0:rawfre/rawsampleSize:rawfre-rawfre/rawsampleSize]-rawfre/2;
  subFs = [0:subfre/subsampleSize:subfre-subfre/subsampleSize]-subfre/2;
  ws = [0:2*pi/rawsampleSize:2*pi-pi/rawsampleSize]-2*pi/2;
  ws = (0:2/rawsampleSize:(2 - 2/rawsampleSize)) - 1; 
  subws = [0:2*pi/subsampleSize:2*pi-2*pi/subsampleSize]-2*pi/2;
  freqAnalysis = figure;
  subplot 221
  plot(day1F_train.TripInCell{1}(:,3),'Linewidth',2); hold on;
  %h = plot(filtTrip3(1:10:end,1),'--','Linewidth',2); hold off;
  title('subsample by interpolation');
  xlabel('time(s)');
  ylabel('latitude(degree)')
  %legend({'subsample W/o filter','subsample with Median+Mean'});
  legend({'subsample W/o filter'});
  subplot 222
  semilogy(subws,fftshift(abs(fft(day1F_train.TripInCell{1}(:,3)))./subsampleSize),'Linewidth',2); hold on;
  %semilogy(subFs,fftshift(abs(fft(day1F_train.TripInCell{1}(:,3)))./subsampleSize),'Linewidth',2); hold on;
  %semilogy(subFs,fftshift(abs(fft(filtTrip3(11:10:end-10,1)))./subsampleSize),'-','Linewidth',1); hold off;
  xlabel('frequency(w)');
  ylabel('magnitude(dB)');
 % legend({'subsample W/o filter','subsample with Median+Mean'});
  legend({'subsample W/o filter'});
  subplot 223
  plot(day1_10H{1}(:,3),'Linewidth',2); hold on;
  %h =plot(filtTrip3(:,1),'--','Linewidth',2); hold off;
  xlabel('time(0.1s)');
  ylabel('latitude(degree)');
  %legend({'raw data','Median+Mean filter'})
  legend({'raw data'})
  title('raw data')
  subplot 224
  semilogy(ws,fftshift(abs(fft(day1_10H{1}(:,3)))./rawsampleSize),'Linewidth',2); hold on;
  %semilogy(rawFs,fftshift(abs(fft(day1_10H{1}(:,3)))./rawsampleSize),'Linewidth',2); hold on;
  %semilogy(rawFs,fftshift(abs(fft(filtTrip3(:,1)))./rawsampleSize),'-','Linewidth',1); hold off;
   legend({'subsample W/o filter','subsample with Median+Mean'});
   legend({'subsample W/o filter'});
  xlabel('frequency(x \pi rad/sample)');
  ylabel('magnitude(dB)');
   %legend({'raw data','Median+Mean filter'})
   legend({'raw data'})
  freqAnalysis.NextPlot = 'add';
  %%
  B = axes; 
  %// Set the title and get the handle to it
  ht = title('Trip ID: 2449640 time/freq domain analysis');
  %// Turn the visibility of the axes off
  B.Visible = 'off';
  %// Turn the visibility of the title on
  ht.Visible = 'on';
  %% for trip index 40
   %%
    thisTrip = day1_10H{40}(:,[3 4]);
    lenTrip = length(thisTrip(:,1));
    %filtTrip1 = [smooth(thisTrip(:,1),31,'loess') ... 
    %    smooth(thisTrip(:,2),31,'loess')];
    filtTrip2 = [medfilt1(thisTrip(:,1),5) medfilt1(thisTrip(:,2),5)] ;
    filtTrip3 = [smooth(thisTrip(:,1),31,'loess') ... 
        smooth(thisTrip(:,2),31,'loess')];
    %headingfilt = medfilt1(day1_10H{1}(:,[7]),3);
   
    filtTrip1 = [smooth(filtTrip2(:,1),15) ... 
        smooth(filtTrip2(:,2),15)];
    %spdfilt = day1_10H{1}(:,[6]);
   
   %%
   hold off;
    h = plot(day1_10H{40}(:,4),day1_10H{40}(:,3),'ro-','MarkerFaceColor','r');hold on;
    set(h,'MarkerFaceColor',get(h,'Color'));
    h = plot(filtTrip1(1:5:end,2),filtTrip1(1:5:end,1),'bp-'); hold on;
    set(h,'MarkerFaceColor',get(h,'Color'));
    plot(filtTrip3(1:5:end,2),filtTrip3(1:5:end,1),'ks-','MarkerFaceColor','k');
    plot(day1F_train.TripInCell{40}(:,4),day1F_train.TripInCell{40}(:,3),'gs-');
    %%
   
  rawsampleSize = length(day1_10H{40}(:,3));
  subsampleSize = length(day1F_train.TripInCell{40}(:,3));
  rawfre = 10;
  subfre = 1;
  rawFs = [0:rawfre/rawsampleSize:rawfre-rawfre/rawsampleSize]-rawfre/2;
  subFs = [0:rawfre/subsampleSize:rawfre-rawfre/subsampleSize]-rawfre/2;
  
  freqAnalysis = figure;
  subplot 221
  plot(day1F_train.TripInCell{40}(:,3),'Linewidth',2); hold on;
  h = plot(filtTrip3(1:10:end,1),'--','Linewidth',2); hold off;
  xlabel('time(s)');
  ylabel('latitude(degree)')
  subplot 222
  semilogy(subFs,fftshift(abs(fft(day1F_train.TripInCell{40}(:,3)))./subsampleSize),'Linewidth',2); hold on;
  semilogy(subFs,fftshift(abs(fft(filtTrip3(1:10:end,1)))./subsampleSize),'-','Linewidth',2); hold off;
  xlabel('frequency(Hz)');
  ylabel('magnitude(dB)');
  subplot 223
  plot(day1_10H{40}(:,3),'Linewidth',2); hold on;
  h =plot(filtTrip3(:,1),'--','Linewidth',2); hold off;
  xlabel('time(s)');
  ylabel('latitude(degree)');
  subplot 224
  semilogy(rawFs,fftshift(abs(fft(day1_10H{40}(:,3)))./rawsampleSize),'Linewidth',2); hold on;
  semilogy(rawFs,fftshift(abs(fft(filtTrip3(:,1)))./rawsampleSize),'-','Linewidth',2); hold off;
  xlabel('frequency(Hz)');
  ylabel('magnitude(dB)');
  freqAnalysis.NextPlot = 'add';
  %%
  
  
    H = webmap;
    zoomLevel = 15;
    wmzoom(H,zoomLevel)  
    wmcenter(H,filtTrip3(3000,1),filtTrip3(3000,2));
    H2 = [];
    lat = [];
    lon = [];
    lap = 30;
    for  i = 3000:lap:6000
    
        
        try
        wmremove(H2);
        end
        H2 = wmmarker(H,filtTrip3(i,1),filtTrip3(i,2),'FeatureName','HV','Color','red','Autofit',0);
        lat = [filtTrip3(i-lap,1) filtTrip3(i,1)];
        lon = [filtTrip3(i-lap,2) filtTrip3(i,2)];
        wmline(lat,lon)
        
        if mod(i,800)==0
            tic
             wmcenter(H,filtTrip3(i,1),filtTrip3(i,2));
             toc
        end
   
    
    %if mod(i,100)==0
    %    wmcenter(H,filtTrip3(i,1),filtTrip3(i,2));
    %end
  
    pause(0.0001)
    %wmremove(H)
    
  end
  
    %%
    for i = 6500:1:6600
    text(day1_10H{1}(i,4),day1_10H{1}(i,3)+0.000001,[num2str(i,'%i') ' spd: ' num2str(spdfilt(i,1))],'Color','red');
    text(filtTrip3(i,2),filtTrip3(i,1),[num2str(i,'%i') ' spd: ' num2str(spdfilt(i,1))],'Color','k');
    end
    % plot(day1F_train.TripInCell{1}(:,4),day1F_train.TripInCell{1}(:,3),'gp-');
     %%
   plot_google_map('MapType','roadtype');
   %%
    lat =  42.299827;
    lon = -71.350273;
    description = sprintf('%s<br>%s</br><br>%s</br>', ...
      '3 Apple Hill Drive', 'Natick, MA. 01760', ...
      'https://www.mathworks.com');
    name = 'The MathWorks, Inc.';
    iconDir = fullfile(matlabroot,'toolbox','matlab','icons');
    iconFilename = fullfile(iconDir,'matlabicon.gif');
    wmmarker(lat,lon,'Description',description,'Icon',iconFilename,...
      'FeatureName',name,'OverlayName',name);
  %%
   S = shaperead('tsunamis','UseGeoCoords',true);
    p = geopoint(S);
 
    % Construct an attribute specification.
    attribspec = makeattribspec(p);
   desiredAttributes = ...
       {'Max_Height', 'Cause', 'Year', 'Location', 'Country'};
    allAttributes = fieldnames(attribspec);
    attributes = setdiff(allAttributes, desiredAttributes);
    attribspec = rmfield(attribspec, attributes);
    attribspec.Max_Height.AttributeLabel = '<b>Maximum Height</b>';
    attribspec.Max_Height.Format = '%.1f Meters';
    attribspec.Cause.AttributeLabel = '<b>Cause</b>';
    attribspec.Year.AttributeLabel = '<b>Year</b>';
    attribspec.Year.Format = '%.0f';
    attribspec.Location.AttributeLabel = '<b>Location</b>';
    attribspec.Country.AttributeLabel = '<b>Country</b>';
  
    % Display the locations on a web map as markers.
    webmap('oceanbasemap','WrapAround',false);
    wmmarker(p,'Description',attribspec,'OverlayName','Tsunami Events')
    wmzoom(2)
    
    %%
   h = geoshow(43, -83, 'DisplayType', 'Point')
   %%
   show(prm) 
   
   %%
   day1_10HzTrain = day1TripTrain(day1_10H);
   %%
    
   plot(TripInCell{1}(:,4))
   grid on;
   xlabel('data sample');
   ylabel('longitude');
   axis([450 500 -83.7630 -83.7614])
   
   
   
   