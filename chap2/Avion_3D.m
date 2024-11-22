
function Avion_3D(uu)
 
    % Se proceseaza intrarile functiei

    pn       = uu(1);    % Pozitia av. pe axa X0 (North)
    pe       = uu(2);    % Pozitia av. pe axa Y0 (East)
    pd       = uu(3);    % Pozitia av. pe axa Z0 (Down)   
    u        = uu(4);    % Viteza av. pe axa X  
    v        = uu(5);    % Viteza av. pe axa Y
    w        = uu(6);    % Viteza av. pe axa Z
    phi      = uu(7);    % Unghiul de ruliu         
    theta    = uu(8);    % Unghiul de tangaj         
    psi      = uu(9);    % Unghiul de giratie         
    p        = uu(10);   % Viteza unghiulara a av. pe axa X 
    q        = uu(11);   % Viteza unghiulara a av. pe axa Y 
    r        = uu(12);   % Viteza unghiulara a av. pe axa Z 
    t        = uu(13);   % timpul

    % Se definesc variabilele locale ale functiei

    persistent handle_avion
    persistent Noduri
    persistent Fetze
    persistent culori_Fetze
    
    % Prima apelare a functiei, initializarea graficului 
    % si a variabilelor locale
    
    if t==0
        figure(1), clf 
        [Noduri,Fetze,culori_Fetze] = deseneaza_av;
        handle_avion = definesteAvion(Noduri,Fetze,culori_Fetze,...
                                    pn,pe,pd,phi,theta,psi,[],'normal');
        title('Avion')
        xlabel('X')
        ylabel('Y'),
        zlabel('-Z')
        view(32,47)     % Se seteaza unghiul din care sa se vada figura
        axis([-20,20,-20,20,-20,20]);
	    grid;
        hold on
        
    % la fiecare moment de timp, avionul se redeseneaza

    else 
        definesteAvion(Noduri,Fetze,culori_Fetze,pn,pe,pd,phi,...
                     theta,psi,handle_avion,'normal');
    end
end

%=======================================================================
% Deseneaza avion
%=======================================================================

function handle = definesteAvion(N,F,Culori,pn,pe,pd,...
                               phi,theta,psi,handle,mode)
  N = rotate(N, phi, theta, psi);      % Rotatia avionului
  N = translate(N, pn, pe, pd);        % Translatia avionului
  % Se trec muchiile din sistemul de coordonate inertial in sist. de coord.
  % legat rigid de avion
  R = [0, 1, 0;...
       1, 0, 0;...
       0, 0, -1];
  N = R*N;
  
  if isempty(handle)
  handle = patch('Vertices', N', 'Faces', F,'FaceVertexCData',Culori,...
                 'FaceColor','flat','EraseMode',mode);
  else
    set(handle,'Vertices',N','Faces',F);
    drawnow
  end
end

%%%%%%%%%%%%%%%%%%%%%%%

function Puncte = rotate(Puncte,phi,theta,psi)

  % Se defineste matricea de rotatie
  
  R_ruliu = [1, 0, 0;...
             0, cos(phi), sin(phi);...
             0, -sin(phi), cos(phi)];
  R_tangaj = [cos(theta), 0, -sin(theta);...
              0, 1, 0;...
              sin(theta), 0, cos(theta)];
  R_giratie = [cos(psi), sin(psi), 0;...
               -sin(psi), cos(psi), 0;...
               0, 0, 1];
  R = R_ruliu*R_tangaj*R_giratie; 
  
    % Se observa ca matricea de rotatie R poate sa nu actioneze asupra
    % vectorului Puncte sau poate sa il reteasca pe acesta spre stanga. 
    % Totusi, se doreste ca punctele sa fie rotite catre dreapta, astfel
    % ca matricea de rotatie R va fi transpusa.
    
  R = R';

  % se rotesc muchiile
  
  Puncte = R*Puncte;
  
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Se translateaza nodurile in functie de coord. de pozitie pn, pe, pd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Puncte = translate(Puncte,pn,pe,pd)

  Puncte = Puncte + repmat([pn;pe;pd],1,size(Puncte,2));
  
end

%=======================================================================
% Se defineste structura avionului
%=======================================================================

function [N,F,culori_Fetze] = deseneaza_av

% Se definesc nodurile (locatia fizica a nodurilor)

N = [...
    	4, 0, 0;...              % pt 1
    	2, -0.2, -0.7;...        % pt 2
    	2, 0.2, -0.7;...         % pt 3
    	2, 0.2, 0.7;...          % pt 4
    	2, -0.2, 0.7;...         % pt 5
    	0, -0.2, 0.7;...         % pt 6
	    0, 0.2, 0.7;...          % pt 7
	    0, 0.2, -0.7;...         % pt 8
	    0, -0.2, -0.7;...        % pt 9
	   -3, 0, 0;...              % pt 10
	    2.5, -4, -0.7;...        % pt 11
	    0, -4, -0.7;...          % pt 12
	    0, 4, -0.7;...           % pt 13
	    2.5, 4, -0.7;...         % pt 14
 	   -2.5, -1.5, 0;...         % pt 15
       -3, -1.5, 0;...           % pt 16
	   -3, 1.5, 0;...            % pt 17
       -2.5, 1.5, 0;...          % pt 18
       -2.5, 0, 0;...            % pt 19
	   -3, 0, -2;...             % pt 20
       -2.5, 0, -2;...           % pt 21
    ]';

% Se definesc fetele ca o serie de noduri formata din nodurile 
% definite mai sus 

  F = [...
        1, 2, 1, 5, 2;...        % Bot avion
        1, 2, 1, 3, 2;...  
        1, 3, 1, 4, 3;...  
        1, 4, 1, 5, 4;... 
	    2, 9, 8, 3, 2;...        % Fuselaj
        5, 6, 7, 4, 5;...
        2, 9, 6, 5, 2;...
        3, 8, 7, 4, 3;...
        11, 12, 13, 14, 11;...   % aripa
	    9, 10, 9, 8, 10;...      % Fuselaj_continuare
        9, 10, 9, 6, 10;...
	    6, 10, 6, 7, 10;...  
        7, 10, 7, 8, 10;...
        15, 16, 17, 18, 19;...   % Ampenaj_orizontal
        19, 21, 20, 10, 19;...   % Ampenaj_vertical
       ];

% Se definesc culorile pentru fiecare fata

  myred = [1, 0, 0];
  mygreen = [0, 1, 0];
  myblue = [0, 0, 1];
  
  culori_Fetze = [...
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
