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
e = GetEnvironment();
dobot = GetDobot();
% UR3 = GetUR3();
steps = 50; 
tileCounter = 1;

% dobot
tileNum = e.LoadTiles(); 
goalDobot = e.payloadLocation(tileCounter,:);
goalDobot(3) = goalDobot(3) + 0.3;
qMatrixDobot = dobot.GetQMatrix(goalDobot,true);

% ur3
% goalUR3 = [-1.5 0 0]; % change only y 
% rock(1) = e.GetRock(goalUR3);
% qMatrixUR3 = UR3.GetQMatrix(goalUR3,true);
% % animate
% for i = 1 : size(qMatrixUR3,1) % use ur3 due to its larger size 
%     dobot.model.animate(qMatrixDobot(i,:));
%     dobot.transformGripper(steps,true);
%     UR3.model.animate(qMatrixUR3(i,:));
%     UR3.transformGripper(steps,true);
% end

% dobot
goalDobot = e.getTileLocation(tileCounter);
qMatrixDobot = dobot.GetQMatrix(goalDobot,false);

for i = 1 : size(qMatrixDobot,1) 
    dobot.model.animate(qMatrixDobot(i,:));
    dobot.transformGripper(steps,false);     
    e.UpdateLocation(tileCounter, dobot.GeteeBase,'tile');
    
end

tileCounter = tileCounter + 1;

