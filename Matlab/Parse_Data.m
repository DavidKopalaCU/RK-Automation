clc; clear; close all
%--------------------------------------------------------------------------
%                     Input: Name of Wafer Piece
%--------------------------------------------------------------------------
Va              = -.3:0.01:.3; 
MeasurementNo   = '21';
User            = 'John';
Wafer           = 'TWGSMV5.2';
Date            = '2018_01_23';
Piece           = 'D';
Device          = 'B.SD.2.2';
Material_Set    = '-';
%--------------------------------------------------------------------------
%                     Location of Files and Folders
%--------------------------------------------------------------------------
folder = strcat('D:\',User,'\',Wafer,'\',Piece,'\',Device,'\',Date,...
    '_MEASURE#',MeasurementNo);

% Where the excel sheet is located: Within the wafer folder
mkdir(folder);

%--------------------------------------------------------------------------
%                  Fit I(V) & Calculate Respon & Resist
%--------------------------------------------------------------------------

Vbias       = str2num(Vdc);
Idark       = cell2mat(Idc);
pidc        = polyfit(Vbias',Idark,7);
Idcfit      = polyval(pidc,Vbias'); close all; plot(Vbias',Idcfit)

for j = 2:length(Vbias)-1
    Id(j-1) = (Idark(j+1)-Idark(j-1))./(Vbias(j+1)-Vbias(j-1));
    Vd(j-1) = (Vbias(j+1)+Vbias(j-1))./2;
    Idfit(j-1) = (Idcfit(j+1)-Idcfit(j-1))./(Vbias(j+1)-Vbias(j-1));
    Vdfit(j-1) = (Vbias(j+1)+Vbias(j-1))./2;
end
for j = 2:length(Vd)-1
    Idd(j-1) = (Id(j+1)-Id(j-1))./(Vd(j+1)-Vd(j-1));
    IdR(j-1) = (Id(j+1)+Id(j-1))./2;
    Vdd(j-1) = (Vd(j+1)+Vd(j-1))./2;
    Iddfit(j-1) = (Idfit(j+1)-Idfit(j-1))./(Vdfit(j+1)-Vdfit(j-1));
    IdRfit(j-1) = (Idfit(j+1)+Idfit(j-1))./2;
    Vddfit(j-1) = (Vdfit(j+1)+Vdfit(j-1))./2;
end

%--------------------------------------------------------------------------
%                           Plot Figures
%--------------------------------------------------------------------------
figure(1)
h1 = plot(Vbias,Idark,'o','LineWidth',1.3);
xlabel('V_b_i_a_s (Volts)','fontsize',14);
ylabel('I_d_c (A)','fontsize',14); 
grid on; set(gcf,'color','white');set(gca,'FontSize',14);
title(strcat(Wafer,'\',Device,'\',Material_Set),'FontSize',12)
saveas(h1,strcat(folder,'\',Wafer,'_',Device,'_IV.fig'))


figure(2)
h2 = plot(Vd,1./Id,'o','LineWidth',1.2);
xlabel('V_b_i_a_s (Volts)','fontsize',14); ylabel('R_d \Omega','fontsize',14)
grid on; set(gcf,'color','white');set(gca,'FontSize',14);
title(strcat(Wafer,'\',Device,'\',Material_Set),'FontSize',12)
saveas(h2,strcat(folder,'\',Wafer,'_',Device,'_Rd.fig'))

figure(3)
h3 = plot(Vdd,Idd./(2.*IdR),'o','LineWidth',1.2);
xlabel('V_b_i_a_s (Volts)','fontsize',14); ylabel('Responsivity (A/W)','fontsize',14)
grid on; set(gcf,'color','white');set(gca,'FontSize',14);
title(strcat(Wafer,'\',Device,'\',Material_Set),'FontSize',12)
saveas(h3,strcat(folder,'\',Wafer,'_',Device,'_Resp.fig'))

figure(1)
hold on
h1 = plot(Vbias,Idcfit,'LineWidth',2);
xlabel('V_b_i_a_s (Volts)','fontsize',14); ylabel('I_d_c (A)','fontsize',14)
grid on; set(gcf,'color','white');set(gca,'FontSize',14);
title(strcat(Wafer,'\',Device,'\',Material_Set),'FontSize',12)
legend('Measured','Fitted - 7^t^h Order Polynomial','location','best')
saveas(h1,strcat(folder,'\',Wafer,'_',Device,'_IVfit.fig'))

figure(5)
h2 = plot(Vdfit,1./Idfit,'LineWidth',2);
xlabel('V_b_i_a_s (Volts)','fontsize',14); ylabel('R_d \Omega','fontsize',14)
grid on; set(gcf,'color','white');set(gca,'FontSize',14);
title(strcat(Wafer,'\',Device,'\',Material_Set),'FontSize',12)
saveas(h2,strcat(folder,'\',Wafer,'_',Device,'_Rdfit.fig'))

figure(6)
h3 = plot(Vddfit(2:end-2),Iddfit(2:end-2)./(2.*IdRfit(2:end-2)),'LineWidth',2);
xlabel('V_b_i_a_s (Volts)','fontsize',14); ylabel('Responsivity (A/W)','fontsize',14)
grid on; set(gcf,'color','white');set(gca,'FontSize',14);
title(strcat(Wafer,'\',Device,'\',Material_Set),'FontSize',12)
saveas(h3,strcat(folder,'\',Wafer,'_',Device,'_Respfit.fig'))

%--------------------------------------------------------------------------
%                           Find relavant points
%--------------------------------------------------------------------------
% (peak responsivity & zero bias responsivity and resistance

xd          = Vdfit;
Rd          = 1./Idfit;
xdd         = Vddfit(2:end-2);
beta        = Iddfit(2:end-2)./(2.*IdRfit(2:end-2));


z   = knnsearch(xd',0);  % The index of value of Resistance at zero voltage
y   = knnsearch(xdd',0); % The index of value of Responsivity at zero voltage
% The index of the value where Responsivity is maximum
u   = find(abs(beta)==max(abs(beta)));
% Index of the value of the voltage where responsivity is zero
v   = knnsearch(beta',0); 

ZeroResistance      = Rd(z);     % The value of Resistance at zero voltage
ZeroResponsivity    = beta(y); % The value of Responsivity at zero voltage
% The value and voltage where Responsivity is maximum
PeakResponsivity    = beta(u); VoltagePeak = xdd(u);
% The value of the voltage where responsivity is zero
ZeroVoltage         = xdd(v);

y_intercept     = ZeroResponsivity;
x_intercept     = ZeroVoltage;
slope           = -(y_intercept/x_intercept);

orderfit        = 7;
Vbmin           = floor(-0.25.*1000)./1000;
Vbmax           = floor(0.25.*1000)./1000;
Vlim            = min(abs(Vbmin),Vbmax);    
VbiasR          = -Vlim:0.001:Vlim;
p               = polyfit(Vbias',Idark,orderfit);
p(end)          = 0;
yfit            = polyval(p,VbiasR);

f1 = find(VbiasR==-0.03);    f2 = find(VbiasR==0.03);
c1 = -yfit(f1);             c2 = yfit(f2);
f3 = find(VbiasR==-0.1);    f4 = find(VbiasR==0.1);
c3 = -yfit(f3);             c4 = yfit(f4);

if c1>=c2
    asym_30mV = c1/c2;
    if c3>=c4
        asym_100mV = c3/c4;
    else
        asym_100mV = c4/c3;
    end
else
    asym_30mV = c2/c1;
    if c3>=c4
        asym_100mV = c3/c4;
    else
        asym_100mV = c4/c3;
    end
end
save(strcat(folder,'\',Wafer,'_',Device,Material_Set,'_IVData.mat'));
% Display Values
disp(blanks(1)') 
disp(['Zero Bias Resistance   ='  blanks(4) num2str(round(ZeroResistance)) '  Ohm']);
disp(['Zero Bias Responsivity ='  blanks(4) num2str(ZeroResponsivity) '    A/W']);
disp(['Peak Responsivity      ='  blanks(4) num2str(PeakResponsivity) '     A/W at'...
    blanks(1) num2str(VoltagePeak*1000) '   mV']);
disp(['Asymmetry at  30 mV    ='  blanks(4) num2str(asym_30mV)]);
disp(['Asymmetry at 100 mV    ='  blanks(4) num2str(asym_100mV)]);

figure(5)
legend(['R_0 = ' num2str(round(ZeroResistance)) ' \Omega'],'location','best')

figure(6)
legend(['\beta_0 = ' num2str(ZeroResponsivity,2) ' A/W'],'location','best')
% 
% %--------------------------------------------------------------------------
% %                           Create Excel File
%--------------------------------------------------------------------------

cd(Dist)
excel = strcat (Wafer,'_',Piece,'_',Material_Set,'.xlsx');
% Write everything to an excel sheet
% Summary od diode
sheet1 = 'Summary'; Title = [{'Diode'},{'Zero Bias Responsivity (A/W)'},...
    {'Zero Bias Resistance (Ohm)'}];
xlswrite(excel,Title,sheet1,'A1:I1'); 

% Read in the old data, text and all
[~,~,Data]=xlsread(excel,sheet1);
% Get the row number of the end
nextRow=size(Data,1)+1;           
% This tells excel where to stick it
xlRange1 = sprintf('%s%d','A',nextRow); xlswrite(excel,{Device},sheet1,xlRange1);
xlRange2 = sprintf('%s%d','B',nextRow); xlswrite(excel,ZeroResponsivity,sheet1,xlRange2);
xlRange3 = sprintf('%s%d','C',nextRow); xlswrite(excel,ZeroResistance,sheet1,xlRange3);