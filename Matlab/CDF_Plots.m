clc; clear;
close all

% Va              = -.3:0.01:.3;
% MeasurementNo   = '0';
 User            = 'David';
 Wafer           = '315';
 Date            = '2018_20_02';
 Piece           = '31';
 Device          = '-';
 Material_Set    = '-';
 InputFile       = 'D:\David\RK-Automation\LayoutFiles\DCDevices.csv';

[in_num, in_names, in_raw] = xlsread(InputFile);

final_sheet = strcat('D:\', User, '\', Wafer, '\', Wafer, '_', Piece, '_', Material_Set, '.xlsx');
[num, text, raw] = xlsread(final_sheet, 'Summary');
names = text(:, 1);

keys = {};
resp_values = [0,0];
ohm_values = [0,0];
for i = 1:length(num)
    % curr_name = names{i+1};
    % identifier = curr_name(1:end-1);
    identifier = in_raw(i, 4);
    identifier = num2str(identifier{1});
    key_index = -1;
    for j = 1:length(keys)
        if strcmp(identifier, keys{j}) == 1
            key_index = j;
            break;
        end
    end
    if key_index == -1
        key_index = length(keys) + 1;
        keys{key_index} = identifier;
        identifier
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
    if num(i, 1) > -3 && num(i, 1) < 3
        if num(i, 2) > 0
            resp_values(key_index, value_index) = num(i, 1);
            ohm_values(key_index, value_index) = num(i, 2);
        else
           print('Restistance < 0') 
        end
    else
        print('Resp out of range')
    end
end

%figure('visible', 'off')
figure(1)
for i = 1:size(ohm_values, 1)
    test = cdfplot(ohm_values(i, :)');
    hold on
end
legend(keys, 'Location', 'southeast')
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
legend(keys, 'Location', 'southeast')
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
legend(keys)
title('Responsivity vs Resistance Scatterplot')
xlabel('Resistance (Ohms)')
ylabel('Responsivity (A/W)')
saveas(test, strcat('D:\', User, '\', Wafer, '\',Piece, '\', 'Scatter.fig'))