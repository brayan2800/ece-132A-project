classdef Channel
    methods (Static)
        function corrupt = flip_one(cw,which)
            codeword = Helper.make_row(cw);
            if codeword(1,which) == 1
                codeword(1,which) = 0;
            else %corrupt(which) == 0
                codeword(1,which) = 1;
            end
            corrupt = zeros(2,5);
            corrupt(1,1:5) = codeword(1:5);
            corrupt(2,1:5) = codeword(6:10);
        end
        function corrupt = flip_two(cw,w1,w2)
            codeword = Helper.make_row(cw);
            if codeword(1,w1) == 1
                codeword(1,w1) = 0;
            else %corrupt(w1) == 0
                codeword(1,w1) = 1;
            end
            if codeword(1,w2) == 1
                codeword(1,w2) = 0;
            else %corrupt(w1) == 0
                codeword(1,w2) = 1;
            end
            corrupt = zeros(2,5);
            corrupt(1,1:5) = codeword(1:5);
            corrupt(2,1:5) = codeword(6:10);
        end
        function corrupt = flip_three(cw,w1,w2,w3)
            codeword = Helper.make_row(cw);
            if codeword(1,w1) == 1
                codeword(1,w1) = 0;
            else %corrupt(w1) == 0
                codeword(1,w1) = 1;
            end
            if codeword(1,w2) == 1
                codeword(1,w2) = 0;
            else %corrupt(w1) == 0
                codeword(1,w2) = 1;
            end
            if codeword(1,w3) == 1
                codeword(1,w3) = 0;
            else %corrupt(w3) == 0
                codeword(1,w3) = 1;
            end
            corrupt = zeros(2,5);
            corrupt(1,1:5) = codeword(1:5);
            corrupt(2,1:5) = codeword(6:10);
        end
    end
end