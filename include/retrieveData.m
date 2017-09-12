function [vtrip]= retrieveData(daysec,VID)
vtrip = daysec(daysec(:,1)==VID,:);
vtrip = [vtrip zeros(size(vtrip,1),1)];
tripid = unique(vtrip(:,2));
for i=1:size(tripid)
    tLen = sum(vtrip(:,2)==tripid(i));
    vtrip(vtrip(:,2)==tripid(i),7)=[0:tLen-1]';
end

end


