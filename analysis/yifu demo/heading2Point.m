function heading = heading2Point(in_x1,in_y1,in_x2,in_y2)
  deltaY = in_y2-in_y1;
  deltaX = in_x2-in_x1;
  heading = atan(deltaY ./ deltaX);
  
  % region I. deltaX > 0 & deltaY > 0
  % region II. deltaX < 0 & deltaY > 0
  heading(deltaX < 0 & deltaY > 0) = heading(deltaX < 0 & deltaY > 0) + pi;
  % region III. deltaX < 0 & deltaY < 0
  heading(deltaX < 0 & deltaY < 0) = heading(deltaX < 0 & deltaY < 0) - pi;
  % region IV. deltaX > 0 & deltaY < 0  
  
  % convert to north as 0 deg
  heading(heading>0) = -2*pi + heading(heading>0);
  heading = abs(heading);
  heading = heading + pi/2;
  heading(heading>2*pi) = heading(heading>2*pi) - 2*pi;
  heading = rad2deg(heading);
end