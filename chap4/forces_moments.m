% forces_moments.m
%   Computes the forces and moments acting on the airframe. 
%
%   Output is
%       F     - forces
%       M     - moments
%       Va    - airspeed
%       alpha - angle of attack
%       beta  - sideslip angle
%       wind  - wind vector in the inertial frame
%

function out = forces_moments(x, delta, wind, P)
    % relabel the inputs
    pn      = x(1);
    pe      = x(2);
    pd      = x(3);
    u       = x(4);
    v       = x(5);
    w       = x(6);
    phi     = x(7);
    theta   = x(8);
    psi     = x(9);
    p       = x(10);
    q       = x(11);
    r       = x(12);
    delta_e = delta(1);
    delta_a = delta(2);
    delta_r = delta(3);
    delta_t = delta(4);
    w_ns    = wind(1); % steady wind - North
    w_es    = wind(2); % steady wind - East
    w_ds    = wind(3); % steady wind - Down
    u_wg    = wind(4); % gust along body x-axis
    v_wg    = wind(5); % gust along body y-axis    
    w_wg    = wind(6); % gust along body z-axis
    

    
    R     = [cos(theta)*cos(psi), (sin(phi)*sin(theta)*cos(psi))-(cos(phi)*sin(psi)),(cos(phi)*sin(theta)*cos(psi))+(sin(phi)*sin(psi));
             cos(theta)*sin(psi), (sin(phi)*sin(theta)*sin(psi))+(cos(phi)*cos(psi)), (cos(phi)*sin(theta)*sin(psi))-(sin(phi)*cos(psi));
             -sin(theta)        , sin(phi)*cos(theta)                               , cos(phi)*cos(theta)                              ];

    w_v = [w_ns; w_es; w_ds]; %Steady-state in NED
    w_b = R*w_v; %Steady-state in body frame

    % compute wind data in NED
    w_n = w_b(1) + u_wg;
    w_e = w_b(2) + v_wg;
    w_d = w_b(3) + w_wg;

    v_ab = [u-w_n; v-w_e; w-w_d];

    Va = sqrt(v_ab(1)^2 + v_ab(2)^2 + v_ab(3)^2);
    alpha = atan(v_ab(3)/ v_ab(1));
    beta = asin(v_ab(2)/Va);
        
    % gravity forces
    f_g_x = -P.mass * P.gravity * sin(theta);
    f_g_y = P.mass * P.gravity * cos(theta) * sin(phi);
    f_g_z = P.mass * P.gravity * cos(theta) * cos(phi);
    f_g = [f_g_x; f_g_y; f_g_z];

    % stability coefficients
    c_x_alpha = -P.C_D_alpha * cos(alpha) + P.C_L_alpha * sin(alpha);
    c_x_q_alpha = -P.C_D_q * cos(alpha) + P.C_L_q * sin(alpha);
    c_x_delta_e_alpha = -P.C_D_delta_e * cos(alpha) + P.C_L_delta_e * sin(alpha);
    c_z_alpha = -P.C_D_alpha * sin(alpha) - P.C_L_delta_e*cos(alpha);
    c_z_q_alpha = -P.C_D_q * sin(alpha) - P.C_L_q * cos(alpha);
    c_z_delta_e_alpha = -P.C_D_delta_e * sin(alpha) - P.C_L_delta_e * cos(alpha);

    %aerodynamics forces
    tmp = 1/2*P.rho*Va^2*P.S_wing;
    f_a_x = c_x_alpha + c_x_q_alpha*P.c/(2*Va)*q + c_x_delta_e_alpha * delta_e;
    f_a_y = P.C_Y_0 + P.C_Y_beta * beta + P.C_Y_p *P.b/(2*Va)*p + P.C_Y_r*P.b/(2*Va)*r+P.C_Y_delta_a *delta_a+P.C_Y_delta_r *delta_r;
    f_a_z = c_z_alpha + c_z_q_alpha * P.c/(2*Va)*q + c_z_delta_e_alpha * delta_e;
    f_a = tmp * [f_a_x; f_a_y; f_a_z];
    

    %propulsion forces 
    %Compute thrust and torque due to propeller
    %map delta_t throttle command (0 to 1) into motor input voltage
    V_in = P.V_max*delta_t;
    
    %Quadratic formula to solve for motor speed
    a = P.C_Q0 * P.rho * P.D_prop^5 / (2*pi)^2;
    b = (P.C_Q1 * P.rho * P.D_prop^4 *Va)/(2*pi) + P.KQ*P.K_V/P.R_motor;
    c = P.C_Q2 * P.rho * P.D_prop^3 * Va^2 - P.KQ*V_in/P.R_motor + P.KQ * P.i0;
    
    %Consider only positive _rotate_points
    Omega_op = (-b + sqrt(b^2 -4*a*c)) / (2*a);
    
    %compute advance ratio
    J_op = 2*pi*Va/(Omega_op*P.D_prop);

    %compute non-dimensionalized coefficients of thrust and torque
    C_T = P.C_T2*J_op^2 + P.C_T1*J_op + P.C_T0;
    C_Q = P.C_Q2*J_op^2 + P.C_Q1*J_op + P.C_Q0;
    
    %add thrust and torque due to propeller
    n = Omega_op/2*pi;
    f_x_p = P.rho * n^2 * P.D_prop^4 * C_T;
    m_l_p = P.rho * n^2 * P.D_prop^5 * C_Q;

    %aerodynamics moments
    tmp = 1/2 *P.rho * Va^2 * P.S_wing;
    m_l = P.C_ell_0 + P.C_ell_beta *beta + P.C_ell_p * P.b/(2*Va)*p + P.C_ell_r*P.b/(2*Va)*r + P.C_ell_delta_a * delta_a + P.C_ell_delta_r * delta_r;
    m_l = tmp *P.b*m_l;
    m_m = P.C_m_0 + P.C_m_alpha * alpha + P.C_m_q * P.c /(2*Va) * q + P.C_m_delta_e * delta_e;
    m_m = tmp * P.c * m_m;
    m_n = P.C_n_0 + P.C_n_beta * beta + P.C_n_p * P.b/(2* Va) *p + P.C_n_r * P.b/(2* Va) * r + P.C_n_delta_a * delta_a + P.C_n_delta_r * delta_r;
    m_n = tmp * P.b * m_n;


    Force(0) = f_g(1) + f_a(1) + f_x_p;
    Force(1) = f_g(2) + f_a(2);
    Force(2) = f_g(3) + f_a(3);

    Torque(1) = m_l + m_l_p;
    Torque(2) = m_m;   
    Torque(3) = m_n;
   
    out = [Force'; Torque'; Va; alpha; beta; w_n; w_e; w_d];
end



