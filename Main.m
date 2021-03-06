%% Housekeeping
clc
clear
close all

%% Problem 1
 n = 2.4;
m1 = n*0.09; % tip mass 1, [kg]
m2 = n*0.09; % tip mass 2, [kg]
Jb = n*0.01; % body MOI, [kg m^2]
k1 = n*.115; % wing 1 hinge spring, [Nm/rad]
k2 = n*.115; % wing 2 hinge spring, [Nm/rad]
l1 = 0.3; % wing 1 length, [m]
l2 = 0.3; % wing 2 length, [m]
r = 0.071; % body radius to wing attachment, [m]

A = [0 0 0 (1+r/l1)/Jb (1+r/l2)/Jb  0;
  0 0 0 -1/(l1*m1)  0        0;
  0 0 0  0  -1/(l2*m2)   0;
  -k1*(1+r/l1) k1/l1 0 0 0    0;
  -k2*(1+r/l2) 0 k2/l2 0 0    0;
       1            0      0    0   0    0];
B = [1/Jb; 0; 0; 0; 0; 0];
C = [0  0  0  0 0  1];
D = [0];
 
sc_plant = ss(A,B,C,D);

%% Parse Experimental Data
[Data,FileName,DataNumInfo] = parseData();

%% Convert, Organize Data
% Let's get the data into the form we want.
% First, let's find the angular position of the body from the gyro reading
ExpCombFreqHz = [];
ExpCombAngMagDB = [];
ExpCombAngVelMagDB = [];
Stackmag = [];
TimeComb = [];
MagComb = [];
PhaseExp = [];

for i = 1:length(Data) % For every data set
    
    %Data{i}(:,2) = Data{i}(:,2)/(10e-3); % Converting from mNm to Nm
    Data{i}(:,4) = 2*pi*Data{i}(:,1); % Frequency in rad/s
    Data{i}(:,2) = Data{i}(:,2)*1000./(2*pi*(Data{i}(:,1))); % Converting from mNm to Nm
    
    Data{i}(:,5) = 1./Data{i}(:,1); % Finding the time values from the frequency
    
    PhaseExp = [PhaseExp;Data{i}(:,3)*180/pi-90];
    
        
    freqRangeHz = Data{i}(:,1); % [Hz]
    MagComb = [MagComb;Data{i}(:,2)];
    ExpCombFreqHz = [ExpCombFreqHz;freqRangeHz]; % [Hz]
    ExpCombAngVelMagDB = [ExpCombAngVelMagDB;20*log10(Data{i}(:,2))]; % [dB]
    
end


[ExpCombFreqHz,CombFreqOrder] = sort(ExpCombFreqHz);

ExpCombAngVelMagDB = ExpCombAngVelMagDB(CombFreqOrder,:);
PhaseExp = PhaseExp(CombFreqOrder,:);


    figure;
    hold on;
    semilogx(ExpCombFreqHz,ExpCombAngVelMagDB,'x',"Linewidth",3)
    xlabel("Frequency [Hz]")
    ylabel('omegab Magnitude [dB]')
    title("Experimental Combined Data Frequency Response")
    set(gca,"Fontsize",20)

%% Problem 1

Re1 = -0.02;
Re2 = -0.01;
Re0 = -0.01;
PlantPoles = eig(A);
[Plantsysnum,Plantsysden] = ss2tf(A,B,C,D);
tf(Plantsysnum,Plantsysden)
[zplant,pplant,kplant] = tf2zp(Plantsysnum,Plantsysden);
pnew = [0, Re0, Re1+PlantPoles(2),Re1+PlantPoles(3),Re2+PlantPoles(5),Re2+PlantPoles(6)];
[NumNew,DenNew] = zp2tf(zplant,pnew,kplant);
tfNew = tf(NumNew,DenNew);

 w = logspace(-.2,2.0,1000);
%  opts = bodeoptions;
%  opts.PhaseWrapping = 'on';
%  opts.PhaseWrappingBranch = -180;
 [mag,phase,w] = bode(tfNew,w);
 mag = squeeze(mag);
 phase = squeeze(phase);
 ind1 = find(phase > 10);
 phase(ind1) = phase(ind1)-360;
%   ind1 = find(phase < -350);
%  phase(ind1) = phase(ind1)+360;
 
 figure;
 subplot(211)
 semilogx(w/(2*pi),20*log10(mag))
 hold on
 semilogx(ExpCombFreqHz,ExpCombAngVelMagDB,'x',"Linewidth",3)
 
 ylabel('Magnitude, [rad/(Nm), dB]')
 title('Figure 2: analytic frequency response with estimated parameters')
 grid
 
 subplot(212)
 semilogx(w/(2*pi),phase)
 hold on
 semilogx(ExpCombFreqHz,PhaseExp,'x',"Linewidth",3)
 ylabel('Phase, [deg]')
 xlabel('Frequency, [Hz]')
 grid
 
