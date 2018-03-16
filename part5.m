ftns = Helper;
A_flip_masks = uint16(ftns.get_mask_vec(10,1));
B_flip_masks = uint16(ftns.get_mask_vec(45,2));
C_flip_masks = uint16(ftns.get_mask_vec(120,3));

inputs = zeros(8,5);
for i = 1:8
    inputs(i,1:3) = ftns.input_vector(i-1);
end

encoder = ConvEnc;
decoder = VitDec;
channel = Channel;

encoded = zeros(8,10);
decoded = zeros(8,5);
for i = 1:8
    encoded(i,1:10) = ftns.make_row(encoder.encode_data(inputs(i,1:5)));
end

%To get the minimum hamming distance
first = true;
d_H_min = 0;
for k = 1:8
    for j = 1:8
        if j > k
            local_d_H = ftns.hamming_distance(encoded(k,1:10),encoded(j,1:10),10);
            if first
                first = false;
                d_H_min = local_d_H;
            end
            if local_d_H < d_H_min
                d_H_min = local_d_H;
            end
        end
    end
end
max_corrected = floor(d_H_min/2);


corrupt_1_bits = uint16(zeros(80,1));
corrupt_2_bits = uint16(zeros(360,1));
corrupt_3_bits = uint16(zeros(960,1));

for k = 1:8
    for j = 1:10
        corrupt_1_bits((k-1)*10+j,1) = uint16(channel.flip_bits(encoded(k,1:10),A_flip_masks(1,j)));
    end
end

% vec_corrupted = zeros(80,10);
% for k = 1:80
%     disp(corrupt_1_bits(k,1))
%     vec_corrupted(k,1:10) = double(ftns.dec2binvec(corrupt_1_bits(k,1),10))
% end


correct1 = 0;
for k = 1:8
    for j = 1:10
        corrupt = ftns.dec2binvec(corrupt_1_bits((k-1)*10+j,1),10);
        dec = decoder.decode_data(ftns.make_col(corrupt));
        if dec == inputs(k,1:5)
            correct1 = correct1 + 1;
        end
    end
end


for k = 1:8
    for j = 1:45
        corrupt_2_bits((k-1)*45+j,1) = uint16(channel.flip_bits(encoded(k,1:10),B_flip_masks(1,j)));
    end
end

correct2 = 0;
for k = 1:8
    for j = 1:45
        corrupt = ftns.dec2binvec(corrupt_2_bits((k-1)*45+j,1),10);
        col = ftns.make_col(corrupt);
        dec = decoder.decode_data(ftns.make_col(corrupt));
        if dec == inputs(k,1:5)
            correct2 = correct2 + 1;
        end
    end
end



for k = 1:8
    for j = 1:120
        corrupt_3_bits((k-1)*120+j,1) = uint16(channel.flip_bits(encoded(k,1:10),C_flip_masks(1,j)));
    end
end

correct3 = 0;
for k = 1:8
    for j = 1:120
        corrupt = ftns.dec2binvec(corrupt_3_bits((k-1)*120+j,1),10);
        dec = decoder.decode_data(ftns.make_col(corrupt));
        if dec == inputs(k,1:5)
            correct3 = correct3 + 1;
        end
    end
end


fprintf("---- Results\n")
fprintf("          (a) Decoder decoded %d out of 80 inputs correctly\n", correct1);
fprintf("          (b) Decoder decoded %d out of 360 inputs correctly\n", correct2);
fprintf("          (c) Decoder decoded %d out of 960 inputs correctly\n", correct3);
fprintf("          (d) The minimun Hamming Distance is %d\n              So the max number of bits the decoder can correct is %d\n", d_H_min, max_corrected);









