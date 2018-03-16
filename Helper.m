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
        function val = dec2binvec(i,len)
            int = uint16(i);
            one = uint16(1);
            val = zeros(1,len);
            for k = 1:len
                index = bitshift(one,k-1);
                if bitand(int,index) == index
                    val(1,len - k + 1) = 1;
                end
            end
        end
        function val = binvec2dec(vec,len)
            one = uint16(1);
            val = uint16(0);
            for k = 1:len
                if uint16(vec(k)) == one
                    val = bitor(val,bitshift(one,len - k));
                end
            end
        end
        function vec = get_mask_vec(len,n1s)
            vec = zeros(1,len);
            one = uint16(1);
            count = 0;
            for x = 1:1023
                bin = uint16(x);
                nOnes = 0;
                for i = 1:10
                    if bitand(one,bin) == one
                        nOnes = nOnes + 1;
                    end
                    bin = bitshift(bin,-1);
                end
                if nOnes == n1s
                    count = count + 1;
                    vec(1,count) = uint16(x);
                end
            end
        end
    end
end