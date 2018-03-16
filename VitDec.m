classdef VitDec < handle
    properties
        columns = 0;
        path_metrics = zeros(4, 6); %5 inputs results in 4x6 matrix of metrics
        
        paths1 = zeros(1,2);
        paths2 = zeros(1,4);
        paths_full = zeros(1,8); %Middle path with full set of branches ... set by decode_data()
        paths4 = zeros(1,4);
        paths5 = zeros(1,2); 
        
        %encoder outputs to compute hamming distance w/ received symbol
        x = [0,1,1,0,1,0,0,1;
            0,1,0,1,1,0,1,0];
                       
    end
	methods
        function fill_trellis(obj, in)
		   n_full_stages = obj.columns-4; %stages w/ 8 branches
           
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
           
           %add branch metric plus path metric from which it came
           obj.path_metrics(1,3) = obj.paths2(1) + obj.path_metrics(1,2);
           obj.path_metrics(2,3) = obj.paths2(2) + obj.path_metrics(1,2);
           obj.path_metrics(3,3) = obj.paths2(3) + obj.path_metrics(2,2);
           obj.path_metrics(4,3) = obj.paths2(4) + obj.path_metrics(2,2);
           
           %Stages 3- columns-2
           %loop through all stages w/ full set of branches
           for i = 1:n_full_stages
               obj.paths_full(i,1) = obj.hamming_distance(obj.x(1:2,1),in(1:2,i+2));
               obj.paths_full(i,2) = obj.hamming_distance(obj.x(1:2,2),in(1:2,i+2));
               obj.paths_full(i,3) = obj.hamming_distance(obj.x(1:2,3),in(1:2,i+2));
               obj.paths_full(i,4) = obj.hamming_distance(obj.x(1:2,4),in(1:2,i+2));
               obj.paths_full(i,5) = obj.hamming_distance(obj.x(1:2,5),in(1:2,i+2));
               obj.paths_full(i,6) = obj.hamming_distance(obj.x(1:2,6),in(1:2,i+2));
               obj.paths_full(i,7) = obj.hamming_distance(obj.x(1:2,7),in(1:2,i+2));
               obj.paths_full(i,8) = obj.hamming_distance(obj.x(1:2,8),in(1:2,i+2));

               obj.path_metrics(1,i+3) = min([obj.paths_full(i,1) + obj.path_metrics(1,i+2);
                                        obj.paths_full(i,5) + obj.path_metrics(3,i+2)]);
               obj.path_metrics(2,i+3) = min([obj.paths_full(i,2) + obj.path_metrics(1,i+2);
                                        obj.paths_full(i,6) + obj.path_metrics(3,i+2)]);
               obj.path_metrics(3,i+3) = min([obj.paths_full(i,3) + obj.path_metrics(2,i+2);
                                        obj.paths_full(i,7) + obj.path_metrics(4,i+2)]);
               obj.path_metrics(4,i+3) = min([obj.paths_full(i,4) + obj.path_metrics(2,i+2);
                                        obj.paths_full(i,8) + obj.path_metrics(4,i+2)]);
           end 
           
           %Second to last stage...simplified b/c we know it is a 0 bit
           obj.paths4(1) = obj.hamming_distance(obj.x(1:2,1),in(1:2,obj.columns-1));
           obj.paths4(2) = obj.hamming_distance(obj.x(1:2,3),in(1:2,obj.columns-1));
           obj.paths4(3) = obj.hamming_distance(obj.x(1:2,5),in(1:2,obj.columns-1));
           obj.paths4(4) = obj.hamming_distance(obj.x(1:2,7),in(1:2,obj.columns-1));
           
           
           obj.path_metrics(1,obj.columns) = min([obj.paths4(1) + obj.path_metrics(1,obj.columns-1);
                                    obj.paths4(3) + obj.path_metrics(3,obj.columns-1)]);
           obj.path_metrics(3,obj.columns) = min([obj.paths4(2) + obj.path_metrics(2,obj.columns-1);
                                        obj.paths4(4) + obj.path_metrics(4,obj.columns-1)]);
           
           
           %Last Stage...simplified bc we know it is a 0 bit
           obj.paths5(1) = obj.hamming_distance(obj.x(1:2,1),in(1:2,obj.columns));
           obj.paths5(2) = obj.hamming_distance(obj.x(1:2,5),in(1:2,obj.columns));
           
           obj.path_metrics(1,obj.columns+1) = min([obj.paths5(1) + obj.path_metrics(1,obj.columns);
                                        obj.paths5(2) + obj.path_metrics(3,obj.columns)]);
                                    
        end        
   
        function output = traceback(obj)
            n_full_stages = obj.columns-4;
            %output = zeros(1,obj.columns);
            output(1,1:obj.columns) =  99;  %set to 99 for debugging purposes
            currstate = [1,obj.columns+1];
            
            %Last Stage 
            if  obj.path_metrics(1,obj.columns+1) == obj.path_metrics(1,obj.columns)+ obj.paths5(1) 
               currstate = [1,obj.columns];
               output(obj.columns) = 0;
            else
                currstate = [3,obj.columns];
                output(obj.columns) = 0;
            end
            
            %Second to last stage
            if currstate == [1,obj.columns]
                if obj.path_metrics(1,obj.columns) == obj.path_metrics(1,obj.columns-1) + obj.paths4(1)
                   currstate = [1,obj.columns-1];
                   output(obj.columns-1) = 0;
                else
                    currstate = [3,obj.columns-1];  %if it didn't come from (1,4) then it came from (3,4)
                    output(obj.columns-1) = 0;
                end
            elseif currstate == [3,obj.columns]
                if obj.path_metrics(3,obj.columns) == obj.path_metrics(2,obj.columns-1) + obj.paths4(2)
                   currstate = [2,obj.columns-1];
                   output(obj.columns-1) = 0;
                else
                    currstate = [4,obj.columns-1];  %if it didn't come from (2,4) then it came from (4,4)
                    output(obj.columns-1) = 0;
                end
            end
            
            %Stage 3 - columns-2
            for i=1:n_full_stages
                if currstate == [1,obj.columns-i]
                    if obj.path_metrics(1,obj.columns-i) == obj.path_metrics(1,obj.columns-1-i) + obj.paths_full(obj.columns-3-i,1)
                       currstate = [1,obj.columns-1-i];
                       output(obj.columns-1-i) = 0;
                    else
                        currstate = [3,obj.columns-1-i];  %if it didn't come from (1,3) then it came from (3,3)
                        output(obj.columns-1-i) = 0;
                    end
                elseif currstate == [2,obj.columns-i]
                    if obj.path_metrics(2,obj.columns-1) == obj.path_metrics(1,obj.columns-1-i) + obj.paths_full(obj.columns-3-i,2)
                       currstate = [1,obj.columns-1-i];
                       output(obj.columns-1-i) = 1;
                    else
                        currstate = [3,obj.columns-1-i];  
                        output(obj.columns-1-i) = 1;
                    end
                 elseif currstate == [3,obj.columns-i]
                    if obj.path_metrics(3,obj.columns-1) == obj.path_metrics(2,obj.columns-1-i) + obj.paths_full(obj.columns-3-i,3)
                       currstate = [2,obj.columns-1-i];
                       output(obj.columns-1-i) = 0;
                    else
                        currstate = [4,obj.columns-1-i];  
                        output(obj.columns-1-i) = 0;
                    end 
                elseif currstate == [4,obj.columns-i]
                    if obj.path_metrics(4,obj.columns-1) == obj.path_metrics(2,obj.columns-1-i) + obj.paths_full(obj.columns-3-i,4)
                       currstate = [2,obj.columns-1-i];
                       output(obj.columns-1-i) = 1;
                    else
                        currstate = [4,obj.columns-1-i];  
                        output(obj.columns-1-i) = 1;
                    end
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
		   [rows,columns]= size(in);
		   obj.columns = columns;
           obj.path_metrics = zeros(4, columns+1);
           obj.paths_full = zeros(columns-4, 8);
           
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
