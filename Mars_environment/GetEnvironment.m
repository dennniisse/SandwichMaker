classdef GetEnvironment < handle
    properties
        payload_h = [patch patch patch patch patch patch patch patch patch]; % must initialise as a patch
        payloadLocation;
    end
    
    properties (Access = private)
        imgSize = 12;
        env_h; rocks_h; % environment handles
        count = 0; % keeps count of environment handle
        payloadVertexCount; v; % to move payload
    end
    
    methods
        function self = GetEnvironment
            count = 0;
        end
        function LoadEnvironment(self)
%             self.env_h(1) = surf([-self.imgSize,-self.imgSize;self.imgSize,self.imgSize],[-self.imgSize,self.imgSize;-self.imgSize,self.imgSize],[0,0;0,0],'CData',imread('ground_mars.jpg'),'FaceColor','texturemap');
%             self.env_h(2) = surf([self.imgSize,-self.imgSize;self.imgSize,-self.imgSize],[self.imgSize,self.imgSize;self.imgSize,self.imgSize],[5,5;0,0],'CData',imread('wall_mars.jpg'),'FaceColor','texturemap');
%             self.env_h(3) = surf([self.imgSize,self.imgSize;self.imgSize,self.imgSize],[self.imgSize,-self.imgSize;self.imgSize,-self.imgSize],[5,5;0,0],'CData',imread('wall_mars_1.jpg'),'FaceColor','texturemap');
%             self.env_h(4) = PlaceObject("spacebase.ply", [7.8 7 0]);
            self.env_h(5) = PlaceObject("crate.ply",[0 0 0]);
%             self.rocks_h(1) = PlaceObject("BeachRockFree_decimated.ply",[-self.imgSize self.imgSize 0]);
%             self.rocks_h(2) = PlaceObject("BeachRockFree_decimated.ply",[-(self.imgSize-4) self.imgSize 0]);
%             self.rocks_h(5) = PlaceObject("rockypath.ply",[0 0 0]);
            hold on;
        end
        
        
        function RemoveEnvironment(self)
            delete(self.env_h);
            delete(self.rocks_h);
        end
        
        function [index] = GetRock(self,base)
            self.count = self.count + 1; % this is used as the index for the payload_h
            index = self.count;           
            % upload into environment
            % Obtain ply data
            [f,self.v,data] = plyread('rock.ply','tri');
            % scale vertex colour
            vertexColours = [data.vertex.red, data.vertex.green, data.vertex.blue] / 255;
            % Get payload vertices count, will be used  to transform payload location
            self.payloadVertexCount = size(self.v,1); %Obtain row size only
            self.payload_h(self.count) = trisurf(f,self.v(:,1)+base(1)...
                , self.v(:,2)+base(2)...
                , self.v(:,3)+base(3)...
                ,'FaceVertexCData',vertexColours,'EdgeColor','interp','EdgeLighting','flat');
            
            % store location
            self.payloadLocation(self.count, 1) = base(1);
            self.payloadLocation(self.count, 2) = base(2);
            self.payloadLocation(self.count, 3) = base(3);
            
        end
        
        function UpdateLocation(self,index,eeBase)
            self.payloadLocation(index, 1) = eeBase(1,4);
            self.payloadLocation(index, 2) = eeBase(2,4);
            self.payloadLocation(index, 3) = eeBase(3,4);
            newLocation = [eeBase * [self.v,ones(self.payloadVertexCount,1)]']';
            self.payload_h(index).Vertices = newLocation(:,1:3);
        end
        
        
    end
    
end