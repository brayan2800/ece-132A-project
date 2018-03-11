function dis = hamming_distance(x,y)    
    dis = 0;
    if x(1) ~= y(1)
        dis = dis + 1;
    end
    if x(2) ~= y(2)
        dis = dis + 1;
    end
end