
function drawVehicle(uu,~,~,~)

    % process inputs to function
    pn       = uu(1);       % inertial North position     
    pe       = uu(2);       % inertial East position
    pd       = uu(3);           
    u        = uu(4);       
    v        = uu(5);       
    w        = uu(6);       
    phi      = uu(7);       % roll angle         
    theta    = uu(8);       % pitch angle     
    psi      = uu(9);       % yaw angle     
    p        = uu(10);       % roll rate
    q        = uu(11);       % pitch rate     
    r        = uu(12);       % yaw rate    
    t        = uu(13);       % time

    % define persistent variables 
    persistent vehicle_handle;
    persistent Vertices
    persistent Faces
    persistent facecolors
    
    % first time function is called, initialize plot and persistent vars
    if t==0,
        figure(1), clf
        [Vertices,Faces,facecolors] = defineVehicleBody;
        vehicle_handle = drawVehicleBody(Vertices,Faces,facecolors,...
                                               pn,pe,pd,phi,theta,psi,...
                                               [],'normal');
        title('Avion')
        xlabel('East')
        ylabel('North')
        zlabel('-Down')
        view(32,47)  % set the vieew angle for figure
        axis([-10,10,-10,10,-10,10]);
	   grid;
        hold on
        
    % at every other time step, redraw base and rod
    else 
        drawVehicleBody(Vertices,Faces,facecolors,...
                           pn,pe,pd,phi,theta,psi,...
                           vehicle_handle);
    end
end

  
%=======================================================================
% drawVehicle
% return handle if 3rd argument is empty, otherwise use 3rd arg as handle
%=======================================================================
%
function handle = drawVehicleBody(V,F,patchcolors,...
                                     pn,pe,pd,phi,theta,psi,...
                                     handle,mode)                               
  V = rotate(V, phi, theta, psi);  % rotate vehicle
  V = translate(V, pn, pe, pd);  % translate vehicle
  % transform vertices from NED to XYZ (for matlab rendering)
  R = [...
      0, 1, 0;...
      1, 0, 0;...
      0, 0, -1;...
      ];
  V = R*V;
  
  if isempty(handle),
  handle = patch('Vertices', V', 'Faces', F,...
                 'FaceVertexCData',patchcolors,...
                 'FaceColor','flat',...
                 'EraseMode', mode);
  else
    set(handle,'Vertices',V','Faces',F);
    drawnow
  end
end

%%%%%%%%%%%%%%%%%%%%%%%
function pts=rotate(pts,phi,theta,psi)

  % define rotation matrix (right handed)
  R_roll = [...
          1, 0, 0;...
          0, cos(phi), sin(phi);...
          0, -sin(phi), cos(phi)];
  R_pitch = [...
          cos(theta), 0, -sin(theta);...
          0, 1, 0;...
          sin(theta), 0, cos(theta)];
  R_yaw = [...
          cos(psi), sin(psi), 0;...
          -sin(psi), cos(psi), 0;...
          0, 0, 1];
  R = R_roll*R_pitch*R_yaw;  
    % note that R above either leaves the vector alone or rotates
    % a vector in a left handed rotation.  We want to rotate all
    % points in a right handed rotation, so we must transpose
  R = R';

  % rotate vertices
  pts = R*pts;
  
end
% end rotateVert

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% translate vertices by pn, pe, pd
function pts = translate(pts,pn,pe,pd)

  pts = pts + repmat([pn;pe;pd],1,size(pts,2));
  
end

% end translate


%=======================================================================
% defineVehicleBody
%=======================================================================
function [V,F,facecolors] = defineVehicleBody

% Define the vertices (physical location of vertices
V = [...
    	4, 0, 0;...   % pt 1
    	2, -0.2, -0.7;... % pt 2
    	2, 0.2, -0.7;...   % pt 3
    	2, 0.2, 0.7;...  % pt 4
    	2, -0.2, 0.7;...  % pt 5
    	0, -0.2, 0.7;... % pt 6
	0, 0.2, 0.7;... % pt 7
	0, 0.2, -0.7;... % pt 8
	0, -0.2, -0.7;... % pt 9
	-3, 0, 0;... % pt 10
	2.5, -4, -0.7;... % pt 11
	0, -4, -0.7;... % pt 12
	0, 4, -0.7;... % pt 13
	2.5, 4, -0.7;... % pt 14
 	-2.5,  -1.5,0;... % pt 15
    	-3, -1.5, 0;... % pt 16
	-3, 1.5, 0;... % pt 17
    	-2.5, 1.5, 0;... % pt 18
    	-2.5, 0, 0;... % pt 19
	-3, 0, -2;... % pt 20
    	-2.5, 0, -2;... % pt 21
    ]';

% define faces as a list of vertices numbered above
  F = [...
        1, 2, 1, 5, 2;...  % Bot avion
        1, 2, 1, 3, 2;...  
        1, 3, 1, 4, 3;...  
        1, 4, 1, 5, 4;... 
	   2, 9, 8, 3, 2;... % Fuselaj
        5, 6, 7, 4, 5;...
        2, 9, 6, 5, 2;...
        3, 8, 7, 4, 3;...
        11, 12, 13, 14, 11;... % aripa
	   9, 10, 9, 8, 10;...% Fuselaj_continuare
        9, 10, 9, 6, 10;...
	   6, 10, 6, 7, 10;...  
        7, 10, 7, 8, 10;...
        15, 16, 17, 18, 19;... % Ampenaj_orizontal
        19, 21, 20, 10, 19;... % Ampenaj_vertical
       ];

% define colors for each face    
  myred = [1, 0, 0];
  mygreen = [0, 1, 0];
  myblue = [0, 0, 1];
  myyellow = [1, 1, 0];
  mycyan = [0, 1, 1];

  facecolors = [...
    	mygreen;...    % bot avion
    	mygreen;... 
	mygreen;...
	mygreen;...   
    	myblue;...     % Fuselaj
	myblue;...     
	myblue;...     
	myblue;...              
    	myred;...      % aripa
	myblue;...     % Fuselaj continuare
	myblue;...     
	myblue;...     
	myblue;...       
	myred;...      % Ampenaj_orizontal
myred;...      % Ampenaj_vertical       

    ];
end
  