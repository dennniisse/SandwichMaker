% index:
% get tiles current location
% get tiles next location 
% upload rocks, get location 

%%%%% start
% goal = goal to payload
% animate ur3 and cr3 going towards their payload, gripprs closing 
% change goal = new Location
% animate ur3 and cr3, with grippers still (close)
% open grippers
% repeat 

clear; clc; clf;
hold on; 
% hopper = PlaceObject("hopper.ply",[-0.5 0.45 0]);
e = GetEnvironment(); e.LoadEnvironment(); 
dobot = GetDobot();
f = msgbox("Press OK to start"); waitfor(f);
UR3 = GetUR3();
steps = 50; 
tileCounter = 1;
dobotOffset = 0.30;

% dobot
tileNum = e.LoadTiles(); 
goalDobot = e.payloadLocation(tileCounter,:);
qMatrixDobot = dobot.GetQMatrix(goalDobot);

% ur3
goalUR3 = [-1.5 0 0]; 
rock(1) = e.GetRock(goalUR3);
qMatrixUR3 = UR3.GetQMatrix(goalUR3);
% animate
for i = 1 : size(qMatrixUR3,1) % use ur3 due to its larger size 
    dobot.model.animate(qMatrixDobot(i,:));
    dobot.transformGripper(steps,true);
    UR3.model.animate(qMatrixUR3(i,:));
    UR3.transformGripper(steps,true);
end

% % dobot
goalDobot = e.getTileLocation(tileCounter);
qMatrixDobot = dobot.GetQMatrix(goalDobot);

% ur3
goalUR3 = e.hopperLocation;
qMatrixUR3 = UR3.GetQMatrix(goalUR3);
for i = 1 : size(qMatrixDobot,1) 
    dobot.model.animate(qMatrixDobot(i,:));
    dobot.transformGripper(steps,false);  
    ee = dobot.GeteeBase;
    e.UpdateLocation(tileCounter,ee,'tile');    
    
    UR3.model.animate(qMatrixUR3(i,:));
    UR3.transformGripper(steps,false);
    ee = UR3.GeteeBase;
    e.UpdateLocation(rock(1),ee,'rock');
end
e.UpdateLocation(tileCounter,transl([goalDobot(1) goalDobot(2) 0]),'tile');
e.UpdateLocation(rock(1),transl([e.hopperLocation(1) e.hopperLocation(2) 0]),'rock');
tileCounter = tileCounter + 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dobot
tileNum = e.LoadTiles(); 
goalDobot = e.payloadLocation(tileCounter,:);
qMatrixDobot = dobot.GetQMatrix(goalDobot);

% ur3
goalUR3 = [-3.5 -0.1 0]; 
rock(1) = e.GetRock(goalUR3);
qMatrixUR3 = UR3.GetQMatrix(goalUR3);
% animate
for i = 1 : size(qMatrixUR3,1) % use ur3 due to its larger size 
    dobot.model.animate(qMatrixDobot(i,:));
    dobot.transformGripper(steps,true);
    UR3.model.animate(qMatrixUR3(i,:));
    UR3.transformGripper(steps,true);
end

% % dobot
goalDobot = e.getTileLocation(tileCounter);
qMatrixDobot = dobot.GetQMatrix(goalDobot);

% ur3
goalUR3 = e.hopperLocation;
qMatrixUR3 = UR3.GetQMatrix(goalUR3);
for i = 1 : size(qMatrixDobot,1) 
    dobot.model.animate(qMatrixDobot(i,:));
    dobot.transformGripper(steps,false);  
    ee = dobot.GeteeBase;
    e.UpdateLocation(tileCounter,ee,'tile');    
    
    UR3.model.animate(qMatrixUR3(i,:));
    UR3.transformGripper(steps,false);
    ee = UR3.GeteeBase;
    e.UpdateLocation(rock(1),ee,'rock');
end
e.UpdateLocation(tileCounter,transl([goalDobot(1) goalDobot(2) 0]),'tile');
e.UpdateLocation(rock(1),transl([e.hopperLocation(1) e.hopperLocation(2) 0]),'rock');
tileCounter = tileCounter + 1;
