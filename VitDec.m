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
           obj.paths1(1) = hamming_distance(obj.x(1:2,1),in(1:2,1));
           obj.paths1(2) = hamming_distance(obj.x(1:2,2),in(1:2,1));
           
           obj.path_metrics(1,2) =  obj.paths1(1);
           obj.path_metrics(2,2) = obj.paths1(2);
           
           %stage 2
           obj.paths2(1) = hamming_distance(obj.x(1:2,1),in(1:2,2));
           obj.paths2(2) = hamming_distance(obj.x(1:2,2),in(1:2,2));
           obj.paths2(3) = hamming_distance(obj.x(1:2,3),in(1:2,2));
           obj.paths2(4) = hamming_distance(obj.x(1:2,4),in(1:2,2));
           
           obj.path_metrics(1,3) = obj.paths2(1) + obj.path_metrics(1,2);
           obj.path_metrics(2,3) = obj.paths2(2) + obj.path_metrics(1,2);
           obj.path_metrics(3,3) = obj.paths2(3) + obj.path_metrics(2,2);
           obj.path_metrics(4,3) = obj.paths2(4) + obj.path_metrics(2,2);
           
           %Stage 3
           obj.paths3(1) = hamming_distance(obj.x(1:2,1),in(1:2,3));
           obj.paths3(2) = hamming_distance(obj.x(1:2,2),in(1:2,3));
           obj.paths3(3) = hamming_distance(obj.x(1:2,3),in(1:2,3));
           obj.paths3(4) = hamming_distance(obj.x(1:2,4),in(1:2,3));
           obj.paths3(5) = hamming_distance(obj.x(1:2,5),in(1:2,3));
           obj.paths3(6) = hamming_distance(obj.x(1:2,6),in(1:2,3));
           obj.paths3(7) = hamming_distance(obj.x(1:2,7),in(1:2,3));
           obj.paths3(8) = hamming_distance(obj.x(1:2,8),in(1:2,3));
        
           obj.path_metrics(1,4) = min([obj.paths3(1) + obj.path_metrics(1,3);
                                    obj.paths3(5) + obj.path_metrics(3,3)]);
           obj.path_metrics(2,4) = min([obj.paths3(2) + obj.path_metrics(1,3);
                                    obj.paths3(6) + obj.path_metrics(3,3)]);
           obj.path_metrics(3,4) = min([obj.paths3(3) + obj.path_metrics(2,3);
                                    obj.paths3(7) + obj.path_metrics(4,3)]);
           obj.path_metrics(4,4) = min([obj.paths3(4) + obj.path_metrics(2,3);
                                    obj.paths3(8) + obj.path_metrics(4,3)]);
                                
           %Stage 4
           obj.paths4(1) = hamming_distance(obj.x(1:2,1),in(1:2,4));
           obj.paths4(2) = hamming_distance(obj.x(1:2,3),in(1:2,4));
           obj.paths4(3) = hamming_distance(obj.x(1:2,5),in(1:2,4));
           obj.paths4(4) = hamming_distance(obj.x(1:2,7),in(1:2,4));
           
           
           obj.path_metrics(1,5) = min([obj.paths4(1) + obj.path_metrics(1,4);
                                    obj.paths4(3) + obj.path_metrics(3,4)]);
           obj.path_metrics(3,5) = min([obj.paths4(2) + obj.path_metrics(2,4);
                                        obj.paths4(4) + obj.path_metrics(4,4)]);
           
           
           %Stage 5
           obj.paths5(1) = hamming_distance(obj.x(1:2,1),in(1:2,5));
           obj.paths5(2) = hamming_distance(obj.x(1:2,5),in(1:2,5));
           
           obj.path_metrics(1,6) = min([obj.paths5(1) + obj.path_metrics(1,5);
                                        obj.paths5(2) + obj.path_metrics(3,5)]);
                                    
        end        
   
        function output = traceback(obj)
        end
        
        function output = decode_data(obj, in)
            fill_trellis(obj, in);
            
        end
    end
end