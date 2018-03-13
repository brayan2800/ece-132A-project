clear all;close all;

a = ConvEnc;
b = VitDec;

input = [1,1,1];
enc_out = a.encode_data(input);

dec_out = b.decode_data(enc_out)
