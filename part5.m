%This is the script for part 5 
%----------------Part (a)---------------
inputs = zeros(8,5);
ftns = Helper;
%part 5.a
for i = 1:8
    inputs(i,1:3) = ftns.input_vector(i-1);
end

encoder = ConvEnc;
decoder = VitDec;
channel = Channel;

errors = 80;
encoded_all = zeros(8,10);
corrupted_1_error = zeros(80,10);
corrupted_2_error = zeros(361,10);
len_2_errors = 1;
corrupted_3_error = zeros(5761,10);
len_3_errors = 1;
repeats2 = 0;
repeats3 = 0;
decoded_all_1_error = zeros(80,5);
decoded_all_2_error = zeros(320,5);
decoded_all_3_error = zeros(960,5);
count = 0;
for i = 1:8
    input = inputs(i,1:5);
    encoded = encoder.encode_data(input);
    encoded_all(i,1:10) = ftns.make_row(encoded);
    for j = 1:10
        corrupt1 = channel.flip_one(encoded,j);
        corrupted_1_error(i*10-(10-j),1:10) = ftns.make_row(corrupt1);
        decode = decoder.decode_data(corrupt1);
        decoded_all_1_error(i*10-(10-j),1:5) = decode;
        for k = 1:10
            if k~=j
                temp = ftns.make_row(channel.flip_two(encoded,j,k));
                repeat = false;
                for iter = 1:len_2_errors
                    if temp == corrupted_2_error(iter,1:10)
                        repeats2 = repeats2 + 1;
                        repeat = true;
                    end
                end
                if ~repeat
                    corrupted_2_error(len_2_errors,1:10) = temp;
                    len_2_errors = len_2_errors + 1;
                end 
                for l = 1:10
                    if l ~= k && l ~= j
                        count = count + 1;
                        temp1 = ftns.make_row(channel.flip_three(encoded,j,k,l));
                        repeat1 = false;
                        for r = 1:960
                            if temp1 == corrupted_3_error(r,1:10)
                                repeats3 = repeats3 + 1;
                                repeat1 = true;
                            end
                        end
                        if ~repeat1
                            corrupted_3_error(len_3_errors,1:10) = temp1;
                            len_3_errors = len_3_errors + 1;
                        end
                    end
                end 
            end
        end
    end
end
len_2_errors = len_2_errors - 1;
len_3_errors = len_3_errors - 1;


disp(count)
fprintf("---Summary For making 360 errors: (Repeats: %d) (Length: %d)\n", repeats2,len_2_errors);
fprintf("---Summary For making 960 errors: (Repeats: %d) (Length: %d)\n", repeats3,len_3_errors);