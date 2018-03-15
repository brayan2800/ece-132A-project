classdef VitDec < handle
    properties
        path_metrics = zeros(4,6);
        paths1 = zeros(1,2);
        paths2 = zeros(1,4);
        paths3 = zeros(1,8);
        paths4 = zeros(1,4);
        paths5 = zeros(1,2); 
        
        %encoder outputs to compute hamming distance w/ received symbol
        x = [0,1,1,0,1,0,0,1;
            0,1,0,1,1,0,1,0];
                       
    end
	methods
        function fill_trellis(obj, in)
           %stage 1
           obj.paths1(1) = obj.hamming_distance(obj.x(1:2,1),in(1:2,1));
           obj.paths1(2) = obj.hamming_distance(obj.x(1:2,2),in(1:2,1));
           
           obj.path_metrics(1,2) =  obj.paths1(1);
           obj.path_metrics(2,2) = obj.paths1(2);
           
           %stage 2
           obj.paths2(1) = obj.hamming_distance(obj.x(1:2,1),in(1:2,2));
           obj.paths2(2) = obj.hamming_distance(obj.x(1:2,2),in(1:2,2));
           obj.paths2(3) = obj.hamming_distance(obj.x(1:2,3),in(1:2,2));
           obj.paths2(4) = obj.hamming_distance(obj.x(1:2,4),in(1:2,2));
           
           obj.path_metrics(1,3) = obj.paths2(1) + obj.path_metrics(1,2);
           obj.path_metrics(2,3) = obj.paths2(2) + obj.path_metrics(1,2);
           obj.path_metrics(3,3) = obj.paths2(3) + obj.path_metrics(2,2);
           obj.path_metrics(4,3) = obj.paths2(4) + obj.path_metrics(2,2);
           
           %Stage 3
           obj.paths3(1) = obj.hamming_distance(obj.x(1:2,1),in(1:2,3));
           obj.paths3(2) = obj.hamming_distance(obj.x(1:2,2),in(1:2,3));
           obj.paths3(3) = obj.hamming_distance(obj.x(1:2,3),in(1:2,3));
           obj.paths3(4) = obj.hamming_distance(obj.x(1:2,4),in(1:2,3));
           obj.paths3(5) = obj.hamming_distance(obj.x(1:2,5),in(1:2,3));
           obj.paths3(6) = obj.hamming_distance(obj.x(1:2,6),in(1:2,3));
           obj.paths3(7) = obj.hamming_distance(obj.x(1:2,7),in(1:2,3));
           obj.paths3(8) = obj.hamming_distance(obj.x(1:2,8),in(1:2,3));
        
           obj.path_metrics(1,4) = min([obj.paths3(1) + obj.path_metrics(1,3);
                                    obj.paths3(5) + obj.path_metrics(3,3)]);
           obj.path_metrics(2,4) = min([obj.paths3(2) + obj.path_metrics(1,3);
                                    obj.paths3(6) + obj.path_metrics(3,3)]);
           obj.path_metrics(3,4) = min([obj.paths3(3) + obj.path_metrics(2,3);
                                    obj.paths3(7) + obj.path_metrics(4,3)]);
           obj.path_metrics(4,4) = min([obj.paths3(4) + obj.path_metrics(2,3);
                                    obj.paths3(8) + obj.path_metrics(4,3)]);
                                
           %Stage 4
           obj.paths4(1) = obj.hamming_distance(obj.x(1:2,1),in(1:2,4));
           obj.paths4(2) = obj.hamming_distance(obj.x(1:2,3),in(1:2,4));
           obj.paths4(3) = obj.hamming_distance(obj.x(1:2,5),in(1:2,4));
           obj.paths4(4) = obj.hamming_distance(obj.x(1:2,7),in(1:2,4));
           
           
           obj.path_metrics(1,5) = min([obj.paths4(1) + obj.path_metrics(1,4);
                                    obj.paths4(3) + obj.path_metrics(3,4)]);
           obj.path_metrics(3,5) = min([obj.paths4(2) + obj.path_metrics(2,4);
                                        obj.paths4(4) + obj.path_metrics(4,4)]);
           
           
           %Stage 5
           obj.paths5(1) = obj.hamming_distance(obj.x(1:2,1),in(1:2,5));
           obj.paths5(2) = obj.hamming_distance(obj.x(1:2,5),in(1:2,5));
           
           obj.path_metrics(1,6) = min([obj.paths5(1) + obj.path_metrics(1,5);
                                        obj.paths5(2) + obj.path_metrics(3,5)]);
                                    
        end        
   
        function output = traceback(obj)
            output = zeros(1,5);
            currstate = [1,6];
            
            %stage 5 
            if  obj.path_metrics(1,6) == obj.path_metrics(1,5)+ obj.paths5(1) 
               currstate = [1,5];
               output(5) = 0;
            else
                currstate = [3,5];
                output(5) = 0;
            end
            
            %stage 4
            if currstate == [1,5]
                if obj.path_metrics(1,5) == obj.path_metrics(1,4) + obj.paths4(1)
                   currstate = [1,4];
                   output(4) = 0;
                else
                    currstate = [3,4];  %if it didn't come from (1,4) then it came from (3,4)
                    output(4) = 0;
                end
            elseif currstate == [3,5]
                if obj.path_metrics(3,5) == obj.path_metrics(2,4) + obj.paths4(2)
                   currstate = [2,4];
                   output(4) = 0;
                else
                    currstate = [4,4];  %if it didn't come from (2,4) then it came from (4,4)
                    output(4) = 0;
                end
            end
            
            %Stage 3
            if currstate == [1,4]
                if obj.path_metrics(1,4) == obj.path_metrics(1,3) + obj.paths3(1)
                   currstate = [1,3];
                   output(3) = 0;
                else
                    currstate = [3,3];  %if it didn't come from (1,3) then it came from (3,3)
                    output(3) = 0;
                end
            elseif currstate == [2,4]
                if obj.path_metrics(2,4) == obj.path_metrics(1,3) + obj.paths3(2)
                   currstate = [1,3];
                   output(3) = 1;
                else
                    currstate = [3,3];  
                    output(3) = 1;
                end
             elseif currstate == [3,4]
                if obj.path_metrics(3,4) == obj.path_metrics(2,3) + obj.paths3(3)
                   currstate = [2,3];
                   output(3) = 0;
                else
                    currstate = [4,3];  
                    output(3) = 0;
                end 
            elseif currstate == [4,4]
                if obj.path_metrics(4,4) == obj.path_metrics(2,3) + obj.paths3(4)
                   currstate = [2,3];
                   output(3) = 1;
                else
                    currstate = [4,3];  
                    output(3) = 1;
                end
            end
            
            %Stage 2 and 1 combined 
            if currstate == [1,3]
                output(2) = 0;
                output(1) = 0;
            elseif currstate == [2,3]
                output(2) = 1;
                output(1) = 0;
            elseif currstate == [3,3]
                output(2) = 0;
                output(1) = 1;
            elseif currstate == [4,3]
                output(2) = 1;
                output(1) =1;
            end
            
        end
        
        function output = decode_data(obj, in)
            fill_trellis(obj, in);
            output = traceback(obj);
        end
    end
    methods (Static)
        function dis = hamming_distance(x,y)          
            dis = 0;
                if x(1) ~= y(1)
                    dis = dis + 1;
                end
                if x(2) ~= y(2)
                    dis = dis + 1;
                end
        end
    end
end
