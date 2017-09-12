function [nX,nY,REF] = extractTripIO(trip,windowS,targetT,delay,option)
%[X,Y] = extractTripIO(trip,windowS,targetT,delay,option)
%return feature data X and Y for NN, trip data based on 1Hz 
%Input: trip for one trip [M,6] M number of data in a trip
%       windowS: number of sample as input
%       targetT: target time(s)
%       delay  : delay for each input(s)
%       option : (1) to extract feature column only
%                (0) retain whole parameter < default          
w=windowS;
tar=targetT;
d=delay;
%column feature taken from raw data: trip
F = [1 2 3];


M = length(1:delay:size(trip,1)-w); %size of X
X = zeros(size(trip,2),w,M);
Y = zeros(size(trip,2),M,1);

for i=1:M
    X(:,:,i) = trip(1+d*(i-1):w+d*(i-1),:)';
    Y(:,i)= trip(w+tar+d*(i-1),:)';
end
if nargin<5
    option=0;
end
if option
 nX = X(F,:,:);
 %REF.X = X(:,1,:);
 %nX = X-X(:,1,:);
 nX = reshape(nX,size(nX,1)*size(nX,2),[]);
 nY = Y(F,:,:);

 %REF.Y = Y(1:2,:,:);
 %temp =X(:,1,:);
 %temp = reshape(temp(:),3,[]);
 %nY = Y-temp;
 nY = reshape(nY,size(nY,1),[]);
end

%REF.X = X(1:3,:);
%REF.Y = Y(1:2,:);
%a = X(1:3:end,:)-REF.X(1,:);

end