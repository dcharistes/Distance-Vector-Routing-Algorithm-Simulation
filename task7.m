Cost_Matrix = [0 4 6 999; 4 0 1 999; 6 1 0 999; 999 999 2 0];
Delay_Matrix = [0 5 5 999; 5 0 5 999; 5 5 0 10; 999 999 5 0]
Update_Period = 0.2;
Failure_Time = 0.1;
Recovery_Time = 0.3;
% [ Next_Hop, Neighbors ] = Routing_Init_v1( Cost_Matrix );
[ Final_Cost_Matrix ] = Routing_Process_Hops_v1( Cost_Matrix, Delay_Matrix, Update_Period, Failure_Time, Recovery_Time );