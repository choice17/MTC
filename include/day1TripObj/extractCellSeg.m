function featureCell = extractCellSeg(tripInCell,windowSize,tar_delay,option)
%% featureCell = extractCellSeg(tripInCell,windowSize,tar_delay,option)
% Objective : extract the segement of each trips
% inputs:     tripInCell, trips stored in cell from day1TripTrain obj
%             windowSize, window size of each segment (# of data point)
%             tar_delay, target delay 
%             option, 'subtract' - subtract the segment with its origin
%                                   location
%                     'keep'     - subtract the segment with its origin
%                                   location(for observation purpose)
% output:     featureCell, features of segment stored in cell separated 
%                           for each trips 

            %only substract the geo data (GPS)
            if nargin<4
                option = 'subtract';
            end
            
            [tripLen,featuredim] = size(tripInCell);
            featureCell = zeros(tripLen-windowSize-tar_delay+1,windowSize*featuredim);
            if strcmp(option,'subtract')
                for timeStamp = 1:tripLen-windowSize-tar_delay+1
                    thisfeatCell = bsxfun(@minus,tripInCell(timeStamp:timeStamp+windowSize-1,:), ...
                        [tripInCell(timeStamp,[1 2]) zeros(1,size(tripInCell,2)-2)]);


                    featureCell(timeStamp,:) = reshape(thisfeatCell',1,[]);
                end
            elseif strcmp(option,'keep')
                for timeStamp = 1:tripLen-windowSize-tar_delay+1
                    thisfeatCell = tripInCell(timeStamp:timeStamp+windowSize-1,:);
                    featureCell(timeStamp,:) = reshape(thisfeatCell',1,[]);
                end
            end                
end



