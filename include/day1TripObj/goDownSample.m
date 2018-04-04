function day1_10Hz_Train = goDownSample(day1_10Hz_Train,option)
% day1_10Hz_Train = goDownSample(day1_10Hz_Train,option)
% Objective: Down sample the dataset in obj of day1TripTrain, note. 
%            filtering only operate on for the GPS data.
%
% input:     day1_10Hz_Train , obj of day1TripTrain
%            option , option for downsampling
%            option.algorithm  :'moving','loess'... see help smooth()
%            option.windowSize : window size for smooth(), odd number
%            option.sampleRate : range in [0,1], should be integer to 
%                                dataset current freq Fs/sampleRate
% output:    day1_10Hz_Train, resampled dataset object             

if mod(1/option.sampleRate,1)~=0
    error('invalid sampleRate option, 1/sampleRate should be integer');
end
alg = option.algorithm;
windowSize = option.windowSize;
tripAttr = 3:13; % from lat,lng,heading,spd,...

% cleanUp the raw data respect to the time stamp
TripInCell = day1_10Hz_Train.TripInCell;
% resample the in-uniform data based on the time in second
dataTS = 100000;
timeStampCell = cellfun(@(x) {(x(:,end)-x(1,end))./(10*dataTS)},TripInCell); % get time info
Fs = round(1/mean(diff(timeStampCell{1})));
disp([  'dataset using to perform downsample is ' num2str(Fs) ' Hz']);
% resample all the info of the trip by the time stamp
% resample on lat to get the len of trip info
for i = 1:length(timeStampCell)
lat = resample(TripInCell{i}(:,3),timeStampCell{i},Fs);
resampleLen = length(lat);
attrResample = [];
    for attrnum = 3:13
    attrResample = [attrResample ...
    resample(TripInCell{i}(:,attrnum),timeStampCell{i},Fs)];
    end
timeResample = (((1:resampleLen).*dataTS)+round(TripInCell{i}(1,end),-5))';
attrResample = [repmat(TripInCell{i}(1,[1 2]),resampleLen,1) ...
                attrResample ...
                timeResample];
TripInCell{i} =  attrResample;
end

% perform median filter
medfiltSize = 5;
TripInCell = cellfun(@(x) {[x(:,[1 2]) ...
                            medfilt1(x(:,3),medfiltSize) ...
                            medfilt1(x(:,4),medfiltSize) ...
                            x(:,5:end)]},TripInCell);
% perform filter from option
TripInCell = cellfun(@(x) {[x(:,[1 2]) ...
                            smooth(x(:,3),windowSize,alg) ...
                            smooth(x(:,4),windowSize,alg) ...
                            x(:,5:end)]},TripInCell);

% downsample by interpolation
TripInCell =cellfun(@(x) {x(1:1/option.sampleRate:end,:)},TripInCell);

% output resampled data
day1_10Hz_Train.TripInCell = TripInCell;
day1_10Hz_Train.TripLen = cellfun(@(x) length(x(:,1)),TripInCell);    
day1_10Hz_Train.Log = [day1_10Hz_Train.Log ;
                        ['Data is filtered using ''' alg ''' with sample rate: ' ...
                          num2str(option.sampleRate) ' at ' datestr(now)]]; 
end