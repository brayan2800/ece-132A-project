classdef Helper
    methods (Static)
        function row = make_row(cw)
            row = zeros(1,10);
            for i = 1:5
                row(i*2-1) = cw(1,i);
                row(i*2) = cw(2,i);
            end
        end
        function col = make_col(cw)
            col = zeros(2,5);
            for i = 1:5
                col(1,i) = cw(i*2-1);
                col(2,i) = cw(i*2);
            end
        end
        function vec = input_vector(int)
            num = uint16(int);
            bit1 = uint16(1);
            bit2 = uint16(2);
            bit3 = uint16(4);    
            vec(1) = bitand(num,bit1);
            vec(2) = bitshift(bitand(num,bit2),-1);
            vec(3) = bitshift(bitand(num,bit3),-2);    
        end
    end
end