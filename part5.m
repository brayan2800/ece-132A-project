%The following are matries of decimal numbers that represent the 
%bits that will be flipped for each of the 8 codewords.
ftns = Helper;
A_flip_masks = uint16(ftns.get_mask_vec(10,1));
B_flip_masks = uint16(ftns.get_mask_vec(45,2));
C_flip_masks = uint16(ftns.get_mask_vec(120,3));

inputs = zeros(8,5);%a matrix of the inputs
for i = 1:8
    inputs(i,1:3) = ftns.input_vector(i-1);
end

encoder = ConvEnc; % the convolution encoder
decoder = VitDec; % the hard decoding Viterbi decoder
channel = Channel; % the channel to flip the bits

encoded = zeros(8,10); % a matrix of the 8 codewords
for i = 1:8
    encoded(i,1:10) = ftns.make_row(encoder.encode_data(inputs(i,1:5)));
end

%To get the minimum hamming distance for part 5.d
%Anf the maximum number of errors the decoder can correct
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

% a 80x1 matrix of 1 bit flipped for each of the 8 codewords
% for each codeword there are 10 choose 10 (1) way to flip 1 bit
corrupt_1_bits = uint16(zeros(80,1));
% a 360x1 matrix of 2 bits flipped for each of the 8 codewords
% for each codeword there are 2 choose 10 or (45) ways to flip 2 bits
corrupt_2_bits = uint16(zeros(360,1));
% a 960x1 matrix of 3 bits flipped for each of the 8 codewords
% for each codeword there are 3 choose 10 (120) ways to flip 3 bits
corrupt_3_bits = uint16(zeros(960,1));

%generate the 80 corrupted codewords for 5.a
for k = 1:8
    for j = 1:10
        corrupt_1_bits((k-1)*10+j,1) = uint16(channel.flip_bits(encoded(k,1:10),A_flip_masks(1,j)));
    end
end

%count the number of codewords decoded correctly
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

%generate the 360 corrupted codewords for 5.b
for k = 1:8
    for j = 1:45
        corrupt_2_bits((k-1)*45+j,1) = uint16(channel.flip_bits(encoded(k,1:10),B_flip_masks(1,j)));
    end
end

%count the number of codewords decoded correctly
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

%generate the 960 corrupted codewords for 5.c
for k = 1:8
    for j = 1:120
        corrupt_3_bits((k-1)*120+j,1) = uint16(channel.flip_bits(encoded(k,1:10),C_flip_masks(1,j)));
    end
end

%count the number of codewords decoded correctly
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

%Print the results for a,b,c,d of the spec
fprintf("---- Results\n")
fprintf("          (a) Decoder decoded %d out of 80 corrupted codewords correctly\n", correct1);
fprintf("          (b) Decoder decoded %d out of 360 corrupted codewords correctly\n", correct2);
fprintf("          (c) Decoder decoded %d out of 960 corrupted codewords correctly\n", correct3);
fprintf("          (d) The minimun Hamming Distance is %d\n              So the max number of bits the decoder can correct is %d\n", d_H_min, max_corrected);









