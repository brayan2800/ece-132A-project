classdef ConvEnc < handle
    properties
        state = [0,0];
    end
    methods
        function new = encode_bit(obj,in)   
            currState = obj.state;
            new = zeros(2,1);
            new(2) = xor(currState(1),in);
            new(1) = xor(xor(currState(2),currState(1)),in);
            %update state
            obj.state(2) = in;
            obj.state(1) = currState(2);
        end 
        function msg = encode_data(obj, data)
            msg = zeros(2,5);
            msg(1:2,1) = encode_bit(obj,data(1));
            msg(1:2,2) = encode_bit(obj,data(2));
            msg(1:2,3) = encode_bit(obj,data(3));
            msg(1:2,4) = encode_bit(obj, 0);
            msg(1:2,5) = encode_bit(obj, 0);
        end
        function printAllOutputs(obj)
            currState = obj.state;
            allStates = [0,0;0,1;1,0;1,1];
            for r = 1:4
                obj.state = allStates(r,1:2);
                in0 = obj.state;
                out0 = encode_bit(obj,0);
                fprintf("State: (%d,%d) -- Input: (%d) -- Output: (%d,%d) -- NextState: (%d,%d)\n", in0(1), in0(2), 0, out0(1), out0(2), obj.state(1), obj.state(2));            
                obj.state = allStates(r,1:2);
                in1 = obj.state;
                out1 = encode_bit(obj,1);
                fprintf("State: (%d,%d) -- Input: (%d) -- Output: (%d,%d) -- NextState: (%d,%d)\n", in1(1), in1(2), 1, out1(1), out1(2), obj.state(1), obj.state(2));            
                obj.state = currState;
            end
        end
        function resetState(obj)
           obj.state = [0,0];
        end
    end
end