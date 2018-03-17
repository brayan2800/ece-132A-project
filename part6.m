clear all;close all;

%Initialize decoder
a = SoftVitDec;

%Output of matched filter demodulator is y=(-sqrt(Eb)+n1,n2)
input = zeros(2,1000);
input(1,1:1000) = -1;

input2 = input;
input3 = input;

%Generate noise with different variance/power
n1 = normrnd(0,sqrt(.503),[2,1000]);
n2 = normrnd(0,sqrt(.24),[2,1000]);
n3 = normrnd(0,sqrt(.125),[2,1000]);

%calculate SNR
ratio1 = snr(input, n1);
ratio2 = snr(input2, n2);
ratio3 = snr(input3, n3);

%Add noise to signal component
input = input + n1;
input2 = input2 + n2;
input3 = input3 + n3;

%Decode
output1 = a.decode_data(input);
output2 = a.decode_data(input2);
output3 = a.decode_data(input3);

num_errors1 = 0;
num_errors2 = 0;
num_errors3 = 0;

%count errors
for i=1:1000
   if output1(i) == 1
      num_errors1 = num_errors1+1; 
   end
   if output2(i) == 1
      num_errors2 = num_errors2+1; 
   end
   if output3(i) == 1
      num_errors3 = num_errors3+1; 
   end
end

fprintf("SNR: 0dB  --  # of errors: (%d)\n", num_errors1);
fprintf("SNR: 3dB  --  # of errors: (%d)\n", num_errors2);
fprintf("SNR: 6dB  --  # of errors: (%d)\n", num_errors3);



