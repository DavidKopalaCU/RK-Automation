%clc; clear;
close all

% Va              = -.3:0.01:.3;
% MeasurementNo   = '0';
% User            = 'David';
% Wafer           = '315LT1';
% Date            = '2018_03_20';
% Piece           = '-';
% Device          = '-';
% Material_Set    = '-';
% InputFile       = 'D:\David\RK-Automation\LayoutFiles\Regular_FirstRow.csv';

pieces = {};
if strcmp(Piece, '') == 1
    piece_dir = strcat('D:\', User, '\', Wafer, '\');
    piece_files = dir(piece_dir);
    piece_flags = [piece_files.isdir];
    piece_dirs = files(piece_flags);
    for i = 3:length(piece_dirs)
        pieces{i-2} = piece_dirs(i);
    end
else
    pieces = {Piece};
end

for g = 1:length(pieces)
    Piece = pieces{g};
    
    parent_dir = strcat('D:\', User, '\', Wafer, '\', Piece, '\'); %'D:\David\315\32\';
    files = dir(parent_dir);
    dirFlags = [files.isdir];
    devices = files(dirFlags);
    [~, idx] = sort([devices.datenum]);
    for x_dir_i = 1 : length(idx) - 2
        x_dir = idx(x_dir_i);
        Device = devices(x_dir).name;
        meas_files = dir(strcat(parent_dir, Device, '\'));
        meas_dirs = meas_files([meas_files.isdir]);
        for y_dir = 3 : length(meas_dirs)
            meas = meas_dirs(y_dir).name;
            folder = strcat(parent_dir, Device, '\', meas);
            
            %folder = strcat('D:\',User,'\',Wafer,'\',Piece,'\',Device,'\',Date,...
            %'_MEASURE#',MeasurementNo);
            Dist        = strcat('D:\', User, '\', Wafer, '\'); %strcat('D:\David\315\');
            mkdir(folder);
            
            filename = strcat(folder, '\IV.csv');%'D:\David\test_LV.csv';
            M = csvread(filename);
            M = sortrows(M);
            
            Vbias_Orig = M(:,2);
            Vbias = Vbias_Orig';
            Idark = M(:,3);
            
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
        end
    end
    
    close all
    
    [in_num, in_names, in_raw] = xlsread(InputFile);
    
    final_sheet = strcat('D:\', User, '\', Wafer, '\', Wafer, '_', Piece, '_', Material_Set, '.xlsx');
    [num, text, raw] = xlsread(final_sheet, 'Summary');
    names = text(:, 1);
    
    keys = {};
    resp_values = [0,0];
    ohm_values = [0,0];
    for i = 1:length(in_raw)
        % curr_name = names{i+1};
        % identifier = curr_name(1:end-1);
        identifier = in_raw(i, 4);
        identifier = num2str(identifier{1});
        key_index = -1;
        temp = size(keys);
        for j = 1:temp(2)
            if strcmp(identifier, keys{1, j}) == 1
                key_index = j;
                break;
            end
        end
        if key_index == -1
            key_index = temp(2) + 1;
            keys{1, key_index} = identifier;
        end
        temp = size(keys);
        name_index = -1;
        for j = 1:temp(1)
            if isempty(keys{j, key_index}) == 1
                name_index = j;
                break;
            end
        end
        if name_index == -1
            name_index = temp(1)+1;
        end
        keys{name_index, key_index} = in_raw{i, 3};
    end
    
    for i = 2:size(raw, 1)
        shape = size(keys);
        key_index = -1;
        for j = 2:shape(1)
            if key_index ~= -1
                break
            end
            for k = 1:shape(2)
                if strcmp(raw{i, 1}, keys{j, k}) == 1
                    key_index = k;
                    break
                end
            end
        end
        value_index = -1;
        for k = 1:length(ohm_values)
            if key_index > size(ohm_values, 1)
                break;
            end
            if ohm_values(key_index, k) == 0
                value_index = k;
                break;
            end
        end
        if value_index == -1
            value_index = length(ohm_values)+1;
        end
        if key_index > size(ohm_values, 1)
            value_index = 1;
        end
        % Check for bounds
        if raw{i, 2} > -3 && raw{i, 2} < 3
            if raw{i, 3} > 0
                resp_values(key_index, value_index) = num(i-1, 1);
                ohm_values(key_index, value_index) = num(i-1, 2);
            else
                disp('Restistance < 0')
            end
        else
            disp('Resp out of range')
        end
    end
    
    %figure('visible', 'off')
    figure(1)
    for i = 1:size(ohm_values, 1)
        test = cdfplot(ohm_values(i, :)');
        hold on
    end
    legend(keys(1, 1:end), 'Location', 'southeast')
    title('Resistance CDF')
    xlabel('Resistance (Ohms)')
    ylabel('%')
    saveas(test, strcat('D:\', User, '\', Wafer, '\', Piece, '\', 'Resistance_CDF.fig'))
    
    figure(2)
    %figure('visible', 'off')
    for i = 1:size(resp_values, 1)
        test = cdfplot(resp_values(i, :)');
        hold on
    end
    legend(keys(1, 1:end), 'Location', 'southeast')
    title('Responsivity CDF')
    xlabel('Responsivity (A/W)')
    ylabel('%')
    saveas(test, strcat('D:\', User, '\', Wafer, '\',Piece, '\', 'Responsivity_CDF.fig'))
    
    colors = ['r', 'g', 'b', 'y', 'm', 'c'];
    figure(3)
    for i = 1:size(ohm_values, 1)
        test = scatter(ohm_values(i, :), resp_values(i, :), 'MarkerFaceColor', colors(i));
        grid on
        hold on
    end
    if size(ohm_values, 1) == size(keys, 2)
        legend(keys(1: 1:end))
    end
    title('Responsivity vs Resistance Scatterplot')
    xlabel('Resistance (Ohms)')
    ylabel('Responsivity (A/W)')
    saveas(test, strcat('D:\', User, '\', Wafer, '\',Piece, '\', 'Scatter.fig'))
end