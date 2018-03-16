classdef SoftVitDec < handle
    properties
        columns = 0; %set by encode_data() size depends on input
        path_metrics = zeros(4, 6);  %size set by encode_data() size depends on input
        paths1 = zeros(1,2); %first two stages with fewer branches
        paths2 = zeros(1,4);
        paths_full = zeros(1,8); %Default from hard decoder has default 1 stage w/ 8 branches 
        
        %encoder outputs to compute euclidian distance w/ received symbol
        x = [-1,1,1,-1,1,-1,-1,1;
            -1,1,-1,1,1,-1,1,-1];
                       
    end
	methods
        function fill_trellis(obj, in)
		   n_full_stages = obj.columns-2;
           
           %First two stages only have meaningful path metric value for 1
           %and 2 bubbles
        
           %stage 1
           obj.paths1(1) = obj.sq_euclidian_dist(obj.x(1:2,1),in(1:2,1));
           obj.paths1(2) = obj.sq_euclidian_dist(obj.x(1:2,2),in(1:2,1));
           
           obj.path_metrics(1,2) =  obj.paths1(1);
           obj.path_metrics(2,2) = obj.paths1(2);
           
           %stage 2
           obj.paths2(1) = obj.sq_euclidian_dist(obj.x(1:2,1),in(1:2,2));
           obj.paths2(2) = obj.sq_euclidian_dist(obj.x(1:2,2),in(1:2,2));
           obj.paths2(3) = obj.sq_euclidian_dist(obj.x(1:2,3),in(1:2,2));
           obj.paths2(4) = obj.sq_euclidian_dist(obj.x(1:2,4),in(1:2,2));
           
           obj.path_metrics(1,3) = obj.paths2(1) + obj.path_metrics(1,2);
           obj.path_metrics(2,3) = obj.paths2(2) + obj.path_metrics(1,2);
           obj.path_metrics(3,3) = obj.paths2(3) + obj.path_metrics(2,2);
           obj.path_metrics(4,3) = obj.paths2(4) + obj.path_metrics(2,2);
           
           %Stages 3- (columns+1)
           for i = 1:n_full_stages
               obj.paths_full(i,1) = obj.sq_euclidian_dist(obj.x(1:2,1),in(1:2,i+2));
               obj.paths_full(i,2) = obj.sq_euclidian_dist(obj.x(1:2,2),in(1:2,i+2));
               obj.paths_full(i,3) = obj.sq_euclidian_dist(obj.x(1:2,3),in(1:2,i+2));
               obj.paths_full(i,4) = obj.sq_euclidian_dist(obj.x(1:2,4),in(1:2,i+2));
               obj.paths_full(i,5) = obj.sq_euclidian_dist(obj.x(1:2,5),in(1:2,i+2));
               obj.paths_full(i,6) = obj.sq_euclidian_dist(obj.x(1:2,6),in(1:2,i+2));
               obj.paths_full(i,7) = obj.sq_euclidian_dist(obj.x(1:2,7),in(1:2,i+2));
               obj.paths_full(i,8) = obj.sq_euclidian_dist(obj.x(1:2,8),in(1:2,i+2));

               obj.path_metrics(1,i+3) = min([obj.paths_full(i,1) + obj.path_metrics(1,i+2);
                                        obj.paths_full(i,5) + obj.path_metrics(3,i+2)]);
               obj.path_metrics(2,i+3) = min([obj.paths_full(i,2) + obj.path_metrics(1,i+2);
                                        obj.paths_full(i,6) + obj.path_metrics(3,i+2)]);
               obj.path_metrics(3,i+3) = min([obj.paths_full(i,3) + obj.path_metrics(2,i+2);
                                        obj.paths_full(i,7) + obj.path_metrics(4,i+2)]);
               obj.path_metrics(4,i+3) = min([obj.paths_full(i,4) + obj.path_metrics(2,i+2);
                                        obj.paths_full(i,8) + obj.path_metrics(4,i+2)]);
           end 
        end        
   
        function output = traceback(obj)
            n_full_stages = obj.columns-2;
            output(1,1:obj.columns) =  99;  %Set to 99 for debugging purposes
            currstate = [0,0];
            
            if obj.path_metrics(1,obj.columns+1) == min(obj.path_metrics(1:4,obj.columns+1))
                currstate = [1,obj.columns+1];
            elseif obj.path_metrics(2,obj.columns+1) == min(obj.path_metrics(1:4,obj.columns+1))
                currstate = [2,obj.columns+1];
            elseif obj.path_metrics(3,obj.columns+1) == min(obj.path_metrics(1:4,obj.columns+1))
                currstate = [3,obj.columns+1];
            elseif obj.path_metrics(4,obj.columns+1) == min(obj.path_metrics(1:4,obj.columns+1))
                currstate = [4,obj.columns+1];
            end
            
            %Stage 3 - columns-2
            for i=-1:n_full_stages-2
                if currstate == [1,obj.columns-i]
                    if obj.path_metrics(1,obj.columns-i) == obj.path_metrics(1,obj.columns-1-i) + obj.paths_full(obj.columns-3-i,1)
                       currstate = [1,obj.columns-1-i];
                       output(obj.columns-1-i) = 0;
                    else
                        currstate = [3,obj.columns-1-i];  %if it didn't come from (1,3) then it came from (3,3)
                        output(obj.columns-1-i) = 0;
                    end
                elseif currstate == [2,obj.columns-i]
                    if obj.path_metrics(2,obj.columns-i) == obj.path_metrics(1,obj.columns-1-i) + obj.paths_full(obj.columns-3-i,2)
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
                    if obj.path_metrics(4,obj.columns-i) == obj.path_metrics(2,obj.columns-1-i) + obj.paths_full(obj.columns-3-i,4)
                       currstate = [2,obj.columns-1-i];
                       output(obj.columns-1-i) = 1;
                    else
                        currstate = [4,obj.columns-1-i];  
                        output(obj.columns-1-i) = 1;
                    end
                end
            end
            
            %Stage 2 and 1 combined since they are simplified
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
        %calculate euclidian distance
        function dis = sq_euclidian_dist(x,y)          
           dis = (x(1)-y(1))^2 + (x(2)-y(2))^2;
        end
        
    end
end
