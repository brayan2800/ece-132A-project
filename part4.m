%This script is for part 4 of the project spec
%Test out code to show that for the 8 generated outputs the decoder
%produces the correct three input bits (plus two zeros)

ftns = Helper; %a list of useful functions used to simply this script

inputs = zeros(8,5); %a matrix of the 8 possible inputs

%generate the inputs rather than hard coding each one
for i = 1:8
    inputs(i,1:3) = ftns.input_vector(i-1);
end

encoder = ConvEnc;% the convolutional encoder
decoder = VitDec;% the hard decoding Viterbi decoder

correct = 0;
encoded = zeros(8,10); % a matrix of the encoded codewords
decoded = zeros(8,5); % a matrix of decoded codewords

%for every row in inputs encode
%   decode and compare to input
for i = 1:8 
    input = inputs(i,1:5);
    encode = encoder.encode_data(input);
    encoded(i,1:10) = ftns.make_row(encode);
    out = decoder.decode_data(encode);
    decoded(i,1:5) = out;
    if input == out
        correct = correct + 1;
        fprintf("Decoded Correctly:\n")
        fprintf('\tInput  :  [%d, %d, %d, %d, %d]\n', input)
        fprintf('\tCodeword: |%d, %d, %d, %d, %d, %d, %d, %d, %d, %d|\n', encoded(i,1:10))
        fprintf('\tDecoded:  [%d, %d, %d, %d, %d]\n', out)
    end
end

fprintf("----(Summary) Decoded Correctly: %d----\n", correct);



