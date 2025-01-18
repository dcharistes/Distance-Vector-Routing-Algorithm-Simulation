function [ Final_Cost_Matrix ] = Routing_Process_Failures_v1( Cost_Matrix, Delay_Matrix, Update_Period, Failure_Time, Recovery_Time )

Sim_Flag = true;

Time = 0;

S = size( Cost_Matrix );

Number_Routers = S(1);

Number_Failures = 0;

Failure_Record = zeros(1,0);

Recovery_Record = zeros(1,0);

Event_List = zeros( 6, Number_Routers + 1 );

Event_List( 1,1 : Number_Routers ) = 1;
Event_List( 2,1 : Number_Routers ) = 0;
Event_List( 3,1 : Number_Routers) = 1;
Event_List( 4,1 : Number_Routers) = [1:Number_Routers];
disp(Event_List(4,1))

Event_List( 1, end + 1 ) = 5;
Event_List( 2, end ) = exprnd(1/Failure_Time);
Event_List( 3, end ) = 1;

Router_Flags = zeros(1, Number_Routers);

[ Next_Hop, Neighbors ] = Routing_Init_v1( Cost_Matrix );

while Sim_Flag

    Event = Event_List(1,1);
    Time = Event_List(2,1);

    if Event == 1

        [ Event_List ] = Event1 ( Event_List, Time, Number_Routers, Neighbors, Delay_Matrix, Update_Period );

    elseif Event == 2

        [ Event_List, Cost_Matrix, Next_Hop, Router_Flags ] = Event2 ( Event_List, Time, Number_Routers, Cost_Matrix, Next_Hop, Router_Flags );  

    elseif Event == 3

        [ Event_List ] = Event3 ( Event_List, Time, Router_Flags );

    elseif Event == 4

        [ Sim_Flag, Final_Cost_Matrix ] = Event4 ( Time, Cost_Matrix, Failure_Record, Recovery_Record );

    elseif Event == 5

        [ Event_List, Neighbors, Cost_Matrix, Next_Hop, Failure_Record ] = Event5 ( Time, Event_List, Number_Failures, Number_Routers, Neighbors, Cost_Matrix, Next_Hop, Recovery_Time, Failure_Time, Failure_Record );

    elseif Event == 6

        [ Event_List, Neighbors, Cost_Matrix, Next_Hop, Recovery_Record ] = Event6 ( Time, Event_List, Neighbors, Cost_Matrix, Next_Hop, Recovery_Record,Recovery_Time );

    end

    Event_List(:,1)=[];
    Event_List=(sortrows(Event_List',[2,3]))';

end

end

function [ Event_List ] = Event1 ( Event_List, Time, Number_Routers, Neighbors, Delay_Matrix, Update_Period )
    sprintf('Router %d broadcasts its routing table to its neighbors at time %f', Event_List(4,1), Time )
     for counter=1:Number_Routers
         disp(Number_Routers)
         disp(counter)
         disp (Event_List(4,1))
         disp(Neighbors)
        if Neighbors(Event_List(4,1),counter)==1
            Event_List(1,end + 1) = 2;
            Event_List(2,end)=Time + Delay_Matrix( Event_List(4,1), counter );
            Event_List(3,end)=1;
            Event_List(4,end)=Event_List(4,1);
            Event_List(5,end)=counter; 
        else 
            continue
        end    
    end
    Event_List(1,end+1)=1;
    Event_List(2,end)=Time + Update_Period;
    Event_List(3,end)=1;
    Event_List(4,end)=Event_List(4,1);
end

function [ Event_List, Cost_Matrix, Next_Hop, Router_Flags ] = Event2 ( Event_List, Time, Number_Routers, Cost_Matrix, Next_Hop, Router_Flags )
    sprintf('Router %d receives routing update information from router %d at time %f', Event_List(5,1), Event_List(4,1), Time )

    temp_flag = 1;
for counter = 1 : Number_Routers
    if Cost_Matrix( Event_List(4,1), counter ) + Cost_Matrix( Event_List(4,1), Event_List(5,1) ) < Cost_Matrix( Event_List(5,1), counter )
        Next_Hop( Event_List(5,1), counter ) = Next_Hop( Event_List(5,1), Event_List(4,1) ); 
        Cost_Matrix( Event_List(5,1), counter ) = Cost_Matrix( Event_List(4,1), counter ) + Cost_Matrix( Event_List(4,1), Event_List(5,1) );

        temp_flag = 0;     
    end    
end
    Router_Flags( 1, Event_List(5,1) ) = temp_flag;

    Event_List( 1, end + 1 ) = 3;
    Event_List( 2, end ) = Time;
    Event_List( 3, end ) = 1;
end

function [ Event_List ] = Event3 ( Event_List, Time, Router_Flags )

    if sum( Router_Flags ) == length( Router_Flags )
        sprintf('Routing Initialization has been finalized at time %f', Time )        
        Event_List( 1, end + 1 ) = 4;
        Event_List( 2, end ) = Time;
        Event_List( 3, end ) = 1;    
    end 
end

function [ Sim_Flag, Final_Cost_Matrix ] = Event4 ( Time, Cost_Matrix, Failure_Record, Recovery_Record )

    sprintf('Simulation end at time %f', Time )

    Final_Cost_Matrix = Cost_Matrix;

    Sim_Flag = false;

    figure;
    plot( 1:length(Failure_Record), Failure_Record,'o', 1:length(Recovery_Record), Recovery_Record,'o' );
    legend('Failures', 'Recoveries');

end

function [ Event_List, Neighbors, Cost_Matrix, Next_Hop, Failure_Record ] = Event5 ( Time, Event_List, Number_Failures, Number_Routers, Neighbors, Cost_Matrix, Next_Hop, Recovery_Time, Failure_Time, Failure_Record )
    Router1=randi([1,Number_Routers]);
    Router2=randi([1,Number_Routers]);

    while ~(Neighbors(Router1,Router2))
        Router1=randi([1,Number_Routers]);
        Router2=randi([1,Number_Routers]);
    end
    sprintf('The link between router %d and router %d is off at time %f', Router1, Router2, Time )

    Failure_Record(end+1)=Time;

    Neighbors(Router1,Router2)=0;
    Neighbors(Router2,Router1)=0;

    %Old_Cost_Matrix=Cost_Matrix(Router1,Router2);

    Cost_Matrix(Router1,Router2)=999;
    Cost_Matrix(Router2,Router1)=999;

    %Old_Hop=Next_Hop(Router1,Router2);

    Next_Hop(Router1,Router2)=999;
    Next_Hop(Router2,Router1)=999;

    Number_Failures=Number_Failures+1;

    Event_List(1,end+1)=6;
    Event_List(2,end)=Time+exprnd(1/Recovery_Time);
    Event_List(3,end)=1;
    Event_List(4,end)=Router1;
    Event_List(5,end)=Router2;

    Event_List(1,end+1)=5;
    Event_List(2,end)=Time+exprnd(1/Failure_Time);
    Event_List(3,end)=1;

    Event_List(1,end+1)=1;
    Event_List(2,end)=Time;
    Event_List(3,end)=1;
    Event_List(4,end)=Router1;

    Event_List(1,end+1)=1;
    Event_List(2,end)=Time;
    Event_List(3,end)=1;
    Event_List(4,end)=Router2;
end

function [ Event_List, Neighbors, Cost_Matrix, Next_Hop, Recovery_Record ] = Event6 ( Time, Event_List, Neighbors, Cost_Matrix, Next_Hop, Recovery_Record,Recovery_Time )
    sprintf('The link between router %d and router %d is now on at time %f',Event_List(4,1),Event_List(5,1),Time)

    Recovery_Record(end+1)=Time;

    Neighbors(Event_List(4,1),Event_List(5,1))=1;
    Neighbors(Event_List(5,1),Event_List(4,1))=1;

    Next_Hop(Event_List(4,1),Event_List(5,1))=1;
    Next_Hop(Event_List(5,1),Event_List(4,1))=1;

    Cost_Matrix(Event_List(4,1),Event_List(5,1))=1;
    Cost_Matrix(Event_List(5,1),Event_List(4,1))=1;

    Event_List(1,end+1)=1;
    Event_List(2,end)=Time;
    Event_List(3,end)=1;
    Event_List(4,end)=Event_List(4,1);

    Event_List(1,end+1)=1;
    Event_List(2,end)=Time;
    Event_List(3,end)=1;
    Event_List(4,end)=Event_List(5,1);

end

