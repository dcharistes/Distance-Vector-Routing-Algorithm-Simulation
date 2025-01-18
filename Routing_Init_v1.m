function [Next_Hop, Neighbors] = Routing_Init_v1(Cost_Matrix)
    % This function initializes the next hop and neighbors matrices for a routing table
    
    N = size(Cost_Matrix); 
    % Get the number of nodes in the network
    
    % Initialize next hop and neighbors matrices to be zeros
    Next_Hop = zeros(N);
    Neighbors = zeros(N);
    
    % Iterate through each node (i) and each neighbor (j)
    for i = 1:N
        for j = 1:N
            % Check if the cost between nodes i and j is 0
            if Cost_Matrix(i, j) == 0 
                % If the cost is 0, set the next hop to 0 and the neighbor flag to 0
                Next_Hop(i, j) = 0; 
                Neighbors(i, j) = 0;           
            % Check if the cost between nodes i and j is 999
            elseif Cost_Matrix(i, j) == 999
                % If the cost is 999 (unreachable), set the next hop to 999
                Next_Hop(i, j) = 999;
            else
                % Otherwise, set the next hop to j and the neighbor flag to 1
                Next_Hop(i, j) = j;
                Neighbors(i, j) = 1;
            end
        end
    end
    
    % Display the next hop and neighbors matrices
    disp('Next_Hop =');   
    disp(Next_Hop);  
    disp('Neighbors =');   
    disp(Neighbors);
end