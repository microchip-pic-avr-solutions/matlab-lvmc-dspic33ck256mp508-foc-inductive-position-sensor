%% ************************************************************************
% Model         :   PMSM Field Oriented Control
% Description   :   Set Parameters for PMSM Field Oriented Control
% File name     :   mcb_pmsm_foc_inductive_position_dsPIC33_data.m
% Copyright 2023 The MathWorks, Inc.

%% Simulation Parameters

%% Set PWM Switching frequency
PWM_frequency 	= 20e3;    %Hz          // converter s/w freq
T_pwm           = 1/PWM_frequency;  %s  // PWM switching time period

%% Set Sample Times
Ts          	= T_pwm;        %sec        // simulation time step for controller
Ts_simulink     = T_pwm/2;      %sec        // simulation time step for model simulation
Ts_motor        = T_pwm/2;      %Sec        // Simulation sample time
Ts_inverter     = T_pwm/2;      %sec        // simulation time step for average value inverter
Ts_speed        = 30*Ts;        %Sec        // Sample time for speed controller

%% Set data type for controller & code-gen
dataType = fixdt(1,16,14);    % Fixed point code-generation
dataType2 = fixdt(1,16,12);    % Fixed point code-generation

%% System Parameters
% Set motor parameters

%Short Hurst Motor (Uncomment while using this motor from line below)
pmsm.model  = 'Hurst075';          %           // Manufacturer Model Number
pmsm.sn     = 'DMB0224C10002';         %           // Manufacturer Model Number
pmsm.p = 5;                     %           // Pole Pairs for the motor
pmsm.Rs = 2.8322;                %Ohm        // Stator Resistor
pmsm.Ld = 0.00242345;               %H          // D-axis inductance value
pmsm.Lq = 0.0023278;               %H          // Q-axis inductance value
pmsm.Lav= (pmsm.Ld+pmsm.Lq)/2;     %H          // avg inductance value
pmsm.Ke = 7.5678;                  %Bemf Const	// Vline_peak/krpm
pmsm.Kt = 0.03;                %Nm/A       // Torque constant
pmsm.J = 5.5e-6;     %Kg-m2      // Inertia in SI units
pmsm.B = 15.2987e-6;     %Kg-m2/s    // Friction Co-efficient
pmsm.I_rated= 1.16*sqrt(2);     %A      	// Rated current (phase-peak)
pmsm.QEPSlits = 1000;           %           // QEP Encoder Slits
pmsm.N_max  = 2500;             %rpm        // Max speed
pmsm.FluxPM     = (pmsm.Ke)/(sqrt(3)*2*pi*1000*pmsm.p/60); %PM flux computed from Ke
pmsm.T_rated    = (3/2)*pmsm.p*pmsm.FluxPM*pmsm.I_rated;   %Get T_rated from I_rated

%% Inductive Position Sensor offset parameters
sine.offset = 7760 ;
cosine.offset = 7848 ;

%% Inverter parameters

inverter.model         = 'LVMC';         % 		// Manufacturer Model Number
inverter.sn            = 'INV_XXXX';         		% 		// Manufacturer Serial Number
inverter.V_dc          = 24;       					%V      // DC Link Voltage of the Inverter
inverter.ISenseMax     = 21.85; 					%Amps   // Max current that can be measured
inverter.I_trip        = 10;                  		%Amps   // Max current for trip
inverter.Rds_on        = 1e-3;                      %Ohms   // Rds ON
inverter.Rshunt        = 0.01;                     %Ohms    // Rshunt
inverter.R_board       = inverter.Rds_on + inverter.Rshunt/3;  %Ohms
inverter.MaxADCCnt     = 4095;      				%Counts // ADC Counts Max Value
inverter.invertingAmp  = -1;                        % 		//Non inverting current measurement amplifier
inverter.deadtime      = 1e-6;
inverter.OpampFb_Rf    = 4.02e3;                    %Ohms  //Opamp Feedback resistance for current measurement
inverter.opampInput_R  = 532;                       %Ohms  //Opamp Input resistance for current measurement
inverter.opamp_Gain    = inverter.OpampFb_Rf/inverter.opampInput_R; %Opamp Gain used for current measurement

%% Derive Characteristics
pmsm.N_base = 3125;%mcb_getBaseSpeed(pmsm,inverter); %rpm // Base speed of motor at given Vdc

%% PU System details // Set base values for pu conversion
PU_System = mcb_SetPUSystem(pmsm,inverter);

%% Controller design // Get ballpark values!
% Get PI Gains
PI_params = mcb.internal.SetControllerParameters(pmsm,inverter,PU_System,T_pwm,Ts,Ts_speed);
