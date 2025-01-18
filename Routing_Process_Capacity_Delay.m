function [ Final_Cost_Matrix ] = Routing_Process_Capacity_Delay( Cost_Matrix, Delay_Matrix, Update_Period, Failure_Time, Recovery_Time, Capacity_Matrix, Number_Couples_Failure )

Sim_Flag = true;
Time = 0;
S = size( Capacity_Matrix );

Combined_Cost = zeros( S(1) , S(2) );

for i = 1 : S(1)
    for j = 1 : S(2)
        Combined_Cost(i,j) = Capacity_Matrix(i,j) * Delay_Matrix(i,j);
    end
end

Number_Routers = S(1);  
Routers = zeros(1,0);
Cost_Routers = zeros(1,0);
Number_Failures = 0;    
Failure_Record = zeros(1,0);   
Recovery_Record = zeros(1,0);   
Router_Updates = zeros(1,0);

Event_List = zeros( 6, Number_Routers + 1 );
Event_List( 1,1 : Number_Routers ) = 1; 
Event_List( 2,1 : Number_Routers ) = 0;
Event_List( 3,1 : Number_Routers) = 1;
Event_List( 4,1 : Number_Routers) = [ 1 : Number_Routers ];
Event_List( 1, end + 1 ) = 5;
Event_List( 2, end ) = exprnd(1/Failure_Time);
Event_List( 3, end ) = 1;

Router_Flags = zeros(1, Number_Routers);

[ Next_Hop, Neighbors ] = Routing_Init_Capacity_Delay( Capacity_Matrix, Delay_Matrix );

while Sim_Flag
    
    Event = Event_List(1,1);
    Time = Event_List(2,1);
    
    if Event == 1
        [ Event_List, Router_Updates ] = Event1 ( Event_List, Time, Number_Routers, Neighbors, Delay_Matrix, Update_Period, Router_Updates );
    elseif Event == 2
        [ Event_List, Cost_Matrix, Next_Hop, Router_Flags ] = Event2 ( Event_List, Time, Number_Routers, Cost_Matrix, Next_Hop, Router_Flags, Combined_Cost );  
    elseif Event == 3
        [ Event_List ] = Event3 ( Event_List, Time, Router_Flags );
    elseif Event == 4
        [ Sim_Flag, Final_Cost_Matrix ] = Event4 ( Time, Cost_Matrix, Router_Updates, Failure_Record, Recovery_Record );
    elseif Event == 5
        [ Event_List, Neighbors, Cost_Matrix, Next_Hop, Failure_Record, Routers, Cost_Routers ] = Event5 ( Time, Event_List, Number_Failures, Number_Routers, Neighbors, Cost_Matrix, Next_Hop, Recovery_Time, Failure_Time, Failure_Record, Number_Couples_Failure, Routers, Cost_Routers );
    elseif Event == 6
        [ Event_List, Neighbors, Cost_Matrix, Next_Hop, Recovery_Record ] = Event6 ( Time, Event_List, Neighbors, Cost_Matrix, Next_Hop, Recovery_Record, Number_Couples_Failure );
    end
    
    Event_List(:,1)=[];
    Event_List=(sortrows(Event_List',[2,3]))';
end
end

function [ Event_List, Router_Updates ] = Event1 ( Event_List, Time, Number_Routers, Neighbors, Delay_Matrix, Update_Period, Router_Updates )

fprintf('Router %d broadcasts its routing table to its neighbors at time %f\n', Event_List(4,1), Time )

for counter = 1 : Number_Routers
    if Neighbors( Event_List(4,1), counter ) == 1   %if neighbor, counter == 1 then.
        Event_List( 1, end + 1 ) = 2;  %Creating Event2.
        Event_List( 2, end ) = Time + Delay_Matrix( Event_List(4,1), counter ); %after Delay_Matrix time of the two Events.
        Event_List( 3, end ) = 3;
        Event_List( 4, end ) = Event_List(4,1); %Inserting in fourth line Sender router. 
        Event_List( 5, end ) = counter; %Inserting in 5th line neighbour router. 
    end
end
Event_List( 1, end + 1 ) = 1;  %Creating Event1.
Event_List( 2, end ) = Time + Update_Period; %after Update_Period;
Event_List( 3, end ) = 1;
Event_List( 4, end ) = Event_List(4,1); %Inserting in fourth line Sender router. 
Router_Updates(1,end+1) = Event_List(4,1); 
end

function [ Event_List, Cost_Matrix, Next_Hop, Router_Flags ] = Event2 ( Event_List, Time, Number_Routers, Cost_Matrix, Next_Hop, Router_Flags, Combined_Cost )

fprintf('Router %d receives routing update information from router %d at time %f\n', Event_List(5,1), Event_List(4,1), Time )

temp_flag = 1;
for counter = 1 : Number_Routers
    if Combined_Cost( Event_List(4,1), counter ) + Combined_Cost( Event_List(4,1), Event_List(5,1) ) < Combined_Cost( Event_List(5,1), counter )    
        Next_Hop( Event_List(5,1), counter ) = Next_Hop( Event_List(5,1), Event_List(4,1) );   %Update routing information of Next_Hop array.
        Cost_Matrix( Event_List(5,1), counter ) = Cost_Matrix( Event_List(4,1), counter ) + Cost_Matrix( Event_List(4,1), Event_List(5,1) );   %Update Cost_Matrix.
        temp_flag = 0; 
    end
end

Router_Flags( 1, Event_List(5,1) ) = temp_flag;%Inserting flag value into Router_Flags.

Event_List( 1, end + 1 ) = 3;  %Creating Event3.
Event_List( 2, end ) = Time;
Event_List( 3, end ) = 2;

end

function [ Event_List ] = Event3 ( Event_List, Time, Router_Flags )

if sum( Router_Flags ) == length( Router_Flags )  
    fprintf('Routing Initialization has been finalized at time %f\n', Time )
    Event_List( 1, end + 1 ) = 4;  %Creating Event4
    Event_List( 2, end ) = Time;
    Event_List( 3, end ) = 3;
end 

end

function [ Sim_Flag, Final_Cost_Matrix ] = Event4 ( Time, Cost_Matrix, Router_Updates, Failure_Record, Recovery_Record )

fprintf('Simulation end at time %f\n', Time )   

Final_Cost_Matrix = Cost_Matrix;

Sim_Flag = false;  

subplot(2,1,1) 
plot(1:length(Router_Updates),Router_Updates,1:length(Time),Time);
title('Transmitting Time of Updates for each Router');
subplot(2,1,2)
plot( 1:length(Failure_Record), Failure_Record, 1:length(Recovery_Record), Recovery_Record );
legend('Failures', 'Recoveries');

end

function [ Event_List, Neighbors, Cost_Matrix, Next_Hop, Failure_Record, Routers, Cost_Routers ] = Event5 ( Time, Event_List, Number_Failures, Number_Routers, Neighbors, Cost_Matrix, Next_Hop, Recovery_Time, Failure_Time, Failure_Record, Number_Couples_Failure, Routers, Cost_Routers )

for counter = 1:Number_Couples_Failure
    random_router_1 = ceil(rand*Number_Routers);    
    random_router_2 = ceil(rand*Number_Routers);  %Selecting two random neighboring routers.
    while random_router_1 == random_router_2 && Neighbors(random_router_1,random_router_2) == 0
        random_router_1 = ceil(rand*Number_Routers);
        random_router_2 = ceil(rand*Number_Routers);
    end
    Routers(1,end+1) = random_router_1;
    Routers(1,end+1) = random_router_2;

    fprintf('The link between router %d and router %d is off at time %f\n', random_router_1, random_router_2, Time)

    Failure_Record(1,end+1) = Time; %Recording Time of Failiure in a value.
    Neighbors(random_router_1,random_router_2) = 0; %Updating routing information.
    Neighbors(random_router_2,random_router_1) = 0;
    Cost_Matrix(random_router_1, random_router_2) = 999; %Updating cost information.
    Cost_Matrix(random_router_2, random_router_1) = 999;
    Next_Hop(random_router_1, random_router_2) = 999; %Updating next hop information.
    Next_Hop(random_router_2, random_router_1) = 999;
    Number_Failures = Number_Failures + 1;  %Incrementing counter.

    Event_List(1,end+1) = 6; %Creating Event6
    Event_List(2,end) = Time + exprnd(1/Recovery_Time);  %at exponential time(Recovery_Time).
    Event_List(3,end) = 2;
    Event_List(4,end) = Routers(1,1);   
    Event_List(5,end) = Routers(1,2);    %Inserting at 4th and 5th line the failing routers.
    Event_List(6,end) = Cost_Matrix(random_router_1,random_router_2);   

    Event_List(1,end+1) = 5;   %Creating Event5
    Event_List(2,end) = Time + exprnd(1/Failure_Time); %at exponential time(Failure_Time).
    Event_List(3,end) = 1;

    Event_List(1,end+1) = 1;  %Creating Event1 for 1st router
    Event_List(2,end) = Time;
    Event_List(3,end) = 1;
    Event_List(4,end) = Routers(1,1);

    Event_List(1,end+1) = 1;   %Creating Event1 for 2st router
    Event_List(2,end) = Time;
    Event_List(3,end) = 1;
    Event_List(4,end) = Routers(1,2);
    
    Routers(:,1) = [];
    Routers(:,1) = [];
end

end

function [ Event_List, Neighbors, Cost_Matrix, Next_Hop, Recovery_Record ] = Event6 ( Time, Event_List, Neighbors, Cost_Matrix, Next_Hop, Recovery_Record, Number_Couples_Failure )


random_router_1 = Event_List(4,1);  %Resellecting the selected random routers.
random_router_2 = Event_List(5,1);

fprintf('The link between router %d and router %d is now on at time %f\n', Event_List(4,1), Event_List(5,1), Time )

Recovery_Record(1,end+1) = Time;   %Recording time of recovery
Neighbors(random_router_1,random_router_2) = 1; %Updating routing information
Neighbors(random_router_2,random_router_1) = 1;
Cost_Matrix(random_router_1,random_router_2) = Event_List(6,1); %Updating cost information
Cost_Matrix(random_router_2,random_router_1) = Event_List(6,1);
Next_Hop(random_router_1,random_router_2) = random_router_2;
Next_Hop(random_router_2,random_router_1) = random_router_1;

Event_List(1,end+1) = 1;     %Creating Event1 for 1st router
Event_List(2,end) = Time;
Event_List(3,end) = 1;
Event_List(4,end) = random_router_1;

Event_List(1,end+1) = 1;   %Creating Event1 for 2st router
Event_List(2,end) = Time;
Event_List(3,end) = 1;
Event_List(4,end) = random_router_2;

end