%% CHECKLIST
% Finish end effector and add the end effector to the move function
%%
classdef GetUR3 < handle
    properties
        model
        modelRight
        modelLeft
    end
    properties (Access = private)
        imgSize = 12;
        workspace = [-12 12 -12 12 -0.05 5];
        steps = 50;
        gripperOffset = 0.2;
        qMatrix = [];       
        
        
    end
    
    methods
        function self = GetUR3(self)
            self.GetRobot();
            self.GetGripper();
            self.initPickUp();
        end      
                
        function OpenGripper(self)
            rightQ = [0,-5]*pi/180;
            leftQ = 5*pi/180;
            self.modelRight.animate([0,rightQ(2)]); %move gripper
            self.modelLeft.animate(leftQ); %move gripper 
        end 
        
        % Calculates trajectory and returns the qMatrix but doesn't animate
        function [qMatrix] = GetQMatrix(self,newQ) 
            goal = newQ;
%             reachable = self.checkReach(goal);            
            self.move(goal);
            qMatrix = self.qMatrix; 
        end 
        
%         function move(self,goal,gripperBool) 
%             q2 = goal;
%             q2(3) = goal(3) + self.gripperOffset;
%             newQ = eye(4)*transl(q2)*troty(pi);
%             finalPos = self.model.ikcon(newQ);
%             intPos = self.model.getpos();
%             s = lspb(0,1,self.steps);
%             qMatrix = nan(self.steps,self.model.n);
%             for i = 1:self.steps
%                 qMatrix(i,:) = (1-s(i))*intPos + s(i)*finalPos;
%                 self.model.animate(qMatrix(i,:));
%                 self.transformGripper(self.steps,gripperBool);
%                 drawnow();                
%             end
%         end

        % applies RMRC
       
        
        function initPickUp(self)    
            qMatrix = [self.model.getpos];
            qWayPoints = ([qMatrix;...
                0 1.1436 0 0 0 0 -1.6197;...
                0 1.1436 -0.7079 0 0 0 -1.6197;...
                0 1.1436 -0.7079 2.5908 -0 0 -1.6197;...
                0 1.1436 -0.7079 2.5908 -3.4388 0 -1.6197;...
                0 1.1436 -0.7079 2.5908 -3.4388 -1.5793 -1.6197]); 
            steps = round(self.steps / size(qWayPoints,1));
%             q = [-0.2043 1.1436 -0.7079 2.5908 -3.4388 -1.5793 -1.6197]
            for i = 1:size(qWayPoints,1)-1
                qMatrix = [qMatrix ; jtraj(qWayPoints(i,:),qWayPoints(i+1,:),steps)];
            end
            for i = 1:size(qMatrix,1)
                self.model.animate(qMatrix(i,:));
                self.transformGripper(steps,false)
                drawnow();
            end
        end 
            
        function initDropOff(self)
            qMatrix = [self.model.getpos];
            qWayPoints = ([qMatrix; ...
                qMatrix(1) 1.1436 -0.7079 2.5908 -3.4388 -1.5793 -1.6197;...
                qMatrix(1) 1.1436 -0.7079 2.5908 -3.4388 0 -1.6197;...
                qMatrix(1) 1.1436 -0.7079 2.5908 0 0 -1.6197;...
                qMatrix(1) 0 -0.7079 0 0 0 0;...
                0 0 0 0 0 0 0]);
            steps = round(self.steps / size(qWayPoints,1));
            
            for i = 1:size(qWayPoints,1)-1
                qMatrix = [qMatrix ; jtraj(qWayPoints(i,:),qWayPoints(i+1,:),steps)];
            end
            
            for i = 1:size(qMatrix,1)
                disp(i);
                self.model.animate(qMatrix(i,:));
                qMatrix(i,:)
                self.transformGripper(steps,false);
                drawnow();
            end
            
        end     
        
        function [reachable] = checkReach(self, goal)
            % 12 < x < 0 reaachable
            % - 0.5 y < 0.5 reachable 
            %V = πr2((4/3)r + a) % check wrkspc volume?? Do I even need
            %this though can just set x y z limit 
            %V/2 % check if item is within rkspc volume 
            
        end 
        
        function transformGripper(self,steps,gripperClose) %true close gripper
            %transform Base
            gripperBase = self.model.fkine(self.model.getpos());
            if (gripperClose == true)
                q = deg2rad(10/steps); % the distance the gripper moves is already set (15deg).
                % Therefore, using steps the UR3 is moving from, the distance at each step can be computer
                rightQ = self.modelRight.getpos() + q ; %return q = [q1 q2], move towards +ve 5deg to close
                leftQ = self.modelLeft.getpos() - q; %return q = [q1], move towards -ve 10deg to close
                self.modelRight.base = gripperBase* troty(pi/2)* trotx(pi/2);
                self.modelLeft.base = gripperBase* troty(pi/2)* trotx(pi/2);
                %Move gripper
                self.modelRight.animate([0,rightQ(2)]); %move gripper
                self.modelLeft.animate(leftQ); %move gripper
            end
            if (gripperClose == false)
                rightQ = self.modelRight.getpos();
                leftQ = self.modelLeft.getpos();
                self.modelRight.base = gripperBase* troty(pi/2)* trotx(pi/2);
                self.modelLeft.base = gripperBase* troty(pi/2)* trotx(pi/2);
                self.modelRight.animate([0,rightQ(2)]); %move gripper
                self.modelLeft.animate(leftQ); %move gripper
            end
        end
        
        function [eebase] = GeteeBase(self)
            eebase = self.model.fkine(self.model.getpos); 
            z = self.gripperOffset;            
            eebase = eebase * transl([0 0 z]) ;
        end 

    end
    
    methods (Access = private)
        
        function GetRobot(self)
            name = 'UR3';
            % dh = [THETA D A ALPHA SIGMA OFFSET]
            L(1) = Link([pi    0      0   pi/2    1   0]);
            L(2) = Link([0    0.383  0   pi/2    0   0]); %.1519 + .5174
            L(3) = Link([0    0   -0.24365   0    0   0]);
            L(4) = Link([0    0   -0.21325   0    0   0]);
            L(5) = Link([0    0.11235     0   pi/2    0   0]);
            L(6) = Link([0    0.08535     0   -pi/2    0   0]);
            L(7) = Link([0    0.0819      0   0   0   0]);
            
            L(1).qlim = [-100 0];
            L(2).qlim = [-360 360]*pi/180;
            L(3).qlim = [-360 360]*pi/180;
            L(4).qlim = [-360 360]*pi/180;
            L(5).qlim = [-360 360]*pi/180;
            L(6).qlim = [-360 360]*pi/180;
            L(7).qlim = [-360 360]*pi/180;
            
            self.model = SerialLink(L,'name',name);
            self.model.delay = 0;
            self.model.base = self.model.base * trotx(pi/2) * troty(pi/2);
            
            for linkIndex = 1:self.model.n
                [ faceData, vertexData, plyData{linkIndex + 1} ] = plyread(['rover_ur3_',num2str(linkIndex),'.ply'],'tri'); %#ok<AGROW>
                self.model.faces{linkIndex + 1} = faceData;
                self.model.points{linkIndex + 1} = vertexData;
            end
            % Plot UR3 as 3D
            q = zeros(1,7); q(7) =  -1.3656;
            %             q = [0    1.0210   -1.5708    1.5708   -3.4016   -1.5984   0]; %
            %             q = [-0.2469    1.1097   -1.3128    3.2072   -3.4505   -1.6088   -1.3656];
            %             q = [-0.2043 1.1436 -0.7079 2.5908 -3.4388 -1.5793 -1.6197];% obtained from sim, main pose
            %             q = [0 1.5708 -1.5708 0 0 -1.5708 0]; % straight man
            %             q = deg2rad([0 90 -45 45 -90 -90 0]); % bad starting pose
            %             q = deg2rad([0 90 -155 130 -90 -90 0]); %ssshhh
            
            self.model.plot3d(q,'workspace',self.workspace,'ortho');
            axis equal;
%             if isempty(findobj(get(gca,'Children'),'Type','Light'))
%                 camlight
%             end
            %             self.model.teach();
            % Colour UR3
            for linkIndex = 1:self.model.n
                handles = findobj('Tag', self.model.name); %findobj: find graphics objects with
                h = get(handles,'UserData');
                try
                    h.link(linkIndex+1).Children.FaceVertexCData = [plyData{linkIndex+1}.vertex.red ... %%as h is a structure we access h.link and iterate
                        , plyData{linkIndex+1}.vertex.green ...                                         %%through each link and obtain its colour
                        , plyData{linkIndex+1}.vertex.blue]/255;
                    h.link(linkIndex+1).Children.FaceColor = 'interp';
                catch ME_1
                    disp(ME_1);
                    continue;
                end
            end
            hold on;
        end
        
        function GetGripper(self)
            gripperBase = self.model.fkine(self.model.getpos());
            L(1) = Link([0 0 0 0 1 0]);
            L(2) = Link([0   0    0.01   0   0   0]);
            L(1).qlim = [0 0]*pi/180; %make base static
            L(2).qlim = [-5 10]*pi/180; %trial and error to figure out the limit using .teach()
            self.modelRight = SerialLink(L,'name','gripperRight');
            self.modelRight.delay = 0;
            self.modelRight.base =  gripperBase * troty(pi/2);%self.modelRight.base * transl([[gripperBase(1), gripperBase(2), gripperBase(3)]]);
            
            %Plot annd Colour Gripper
            for linkIndex = 1:self.modelRight.n
                [ faceData, vertexData, plyData{linkIndex + 1} ] = plyread(['gripper_ur3_',num2str(linkIndex),'.ply'],'tri'); %#ok<AGROW>
                self.modelRight.faces{linkIndex + 1} = faceData;
                self.modelRight.points{linkIndex + 1} = vertexData;
            end
            q = [0,-5]*pi/180; % gripper open as wide as possible
            self.modelRight.plot3d(q,'workspace',self.workspace);
            %             self.modelRight.teach();
            if isempty(findobj(get(gca,'Children'),'Type','Light'))
                camlight
            end
            
            for linkIndex = 0:1
                handles = findobj('Tag', self.modelRight.name);
                h = get(handles,'UserData');
                try
                    h.link(linkIndex+1).Children.FaceVertexCData = [plyData{linkIndex+1}.vertex.red ...
                        , plyData{linkIndex+1}.vertex.green ...
                        , plyData{linkIndex+1}.vertex.blue]/255;
                    h.link(linkIndex+1).Children.FaceColor = 'interp';
                catch ME_1
                    continue;
                end
            end
            
            L = Link([0   0    0.01   0   0   0]);
            L.qlim = [-10 5]*pi/180;
            self.modelLeft = SerialLink(L,'name','gripperLeft');
            self.modelLeft.delay = 0;
            self.modelLeft.base = gripperBase* troty(pi/2); %self.modelLeft.base * transl([[gripperBase]]);
            
            % Plot Left Finger
            [ faceData, vertexData, plyData{2} ] = plyread(['gripper_ur3_3.ply'],'tri'); %#ok<AGROW>
            self.modelLeft.faces{2} = faceData;
            self.modelLeft.points{2} = vertexData;
            self.modelLeft.plot3d(5*pi/180,'workspace',self.workspace,'arrow');
            
            % Colour Left Finger
            if isempty(findobj(get(gca,'Children'),'Type','Light'))
                camlight
            end
            handles = findobj('Tag', self.modelLeft.name);
            h = get(handles,'UserData');
            try
                h.link(2).Children.FaceVertexCData = [plyData{2}.vertex.red ...
                    , plyData{2}.vertex.green ...
                    , plyData{2}.vertex.blue]/255;
                h.link(2).Children.FaceColor = 'interp';
            catch ME_1
            end
        end
                
        function move(self,goal)
            goal(3) = goal(3) + self.gripperOffset;
            goal = transl(goal)  * troty(pi)
            % Set parametersf steps for simu
            t = 1;             % Total time (s)
            deltaT = 0.02;      % Control frequency
            steps = t/deltaT;   % No.steps
            delta = 2*pi/steps; % Small angle change
            epsilon = 0.1;      % Threshold value for manipulability/Damped Least Squares
            W = diag([1 1 1 0.1 0.1 0.1]);    % Weighting matrix for the velocity vector
            
            % Allocate array data
            qMatrix = zeros(steps,7);       % Array for joint anglesR
            qdot = zeros(steps,7);          % Array for joint velocities
            theta = zeros(3,steps);         % Array for roll-pitch-yaw angles
            x = zeros(3,steps);             % Array for x-y-z trajectory
            % Get current pose
            q0 = self.model.getpos;                   % Initial guess for joint angles
            T1 = self.model.fkine(q0);% T1 get curernt Pose and make into homoegenous transform
            x1 = [T1(1,4) T1(2,4) T1(3,4)];% x1 get the x y of T1
            x2 = [goal(1,4) goal(2,4) goal(3,4)];% x2 get the x y of T2 (which is the goal x and y)
            th1 = tr2rpy(T1);
            th2 = tr2rpy(goal);
            
            % Set up trajectory
            s = lspb(0,1,steps);                % Trapezoidal trajectory scalar
            for i=1:steps
                x(:,i) = (1-s(i))*x1 + s(i)*x2; % Points in xyz
                theta(:,i) = (1-s(i))*th1 + s(i)*th2; % R P Y angles
                theta(3,i) = pi/2;
            end
            
            qMatrix(1,:) = self.model.ikcon(T1,q0);   % Solve joint angles to achieve first waypoint
            % Track the trajectory with RMRC
            for i = 1:steps-1
                T1 = self.model.fkine(qMatrix(i,:));                                           % Get forward transformation at current joint state
                deltaX = x(:,i+1) - T1(1:3,4);                                         	% Get position error from next waypoint
                Rd = rpy2r(theta(1,i+1),theta(2,i+1),theta(3,i+1));                     % Get next RPY angles, convert to rotation matrix
                Ra = T1(1:3,1:3);                                                        % Current end-effector rotation matrix
                Rdot = (1/deltaT)*(Rd - Ra);                                                % Calculate rotation matrix error
                S = Rdot*Ra';                                                           % Skew symmetric!
                linear_velocity = (1/deltaT)*deltaX;
                angular_velocity = [S(3,2);S(1,3);S(2,1)];                              % Check the structure of Skew Symmetric matrix!!
                deltaTheta = tr2rpy(Rd*Ra');                                            % Convert rotation matrix to RPY angles
                xdot = W*[linear_velocity;angular_velocity];                          	% Calculate end-effector velocity to reach next waypoint.
                J = self.model.jacob0(qMatrix(i,:));                 % Get Jacobian at current joint state
                m = sqrt(det(J*J'));
                if m < epsilon  % If manipulability is less than given threshold
                    lambda = (1 - m/epsilon)*5E-2;
                else
                    lambda = 0;
                end
                invJ = inv(J'*J + lambda *eye(7))*J'; % DLS Inverse
                qdot(i,:) = (invJ*xdot)';                                                % Solve the RMRC equation (you may need to transpose the         vector)
                for j = 1:7                                                             % Loop through joints 1 to 7
                    if qMatrix(i,j) + deltaT*qdot(i,j) < self.model.qlim(j,1)                     % If next joint angle is lower than joint limit...
                        qdot(i,j) = 0; % Stop the motor
                    elseif qMatrix(i,j) + deltaT*qdot(i,j) > self.model.qlim(j,2)                 % If next joint angle is greater than joint limit ...
                        qdot(i,j) = 0; % Stop the motor
                    end
                end
                qMatrix(i+1,:) = qMatrix(i,:) + deltaT*qdot(i,:);                         	% Update next joint state based on joint velocities
            end
            
            self.qMatrix = qMatrix;
        end
        
        
    end
end

