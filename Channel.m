classdef Channel
    methods (Static)
        function corrupt = flip_bits(cw,mask)
            int = uint16(Helper.binvec2dec(cw, 10));
            mask = uint16(mask);
            bit_flipped = bitand(bitcmp(bitand(int,mask)),mask);
            clear_bit_flipped = bitand(int,bitcmp(mask));
            corrupt = bitor(bit_flipped,clear_bit_flipped);
        end
    end
end