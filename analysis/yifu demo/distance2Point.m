function dist = distance2Point(in_x1,in_y1,in_x2,in_y2)
    deltaX = in_x2-in_x1;
    deltaY = in_y2-in_y1;

    dist = sqrt(deltaX.^2 + deltaY.^2);
end