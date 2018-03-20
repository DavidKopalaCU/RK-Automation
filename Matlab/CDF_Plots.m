clc; clear;
close all

% Va              = -.3:0.01:.3;
% MeasurementNo   = '0';
 User            = 'David';
 Wafer           = '315LT1';
 Date            = '2018_03_20';
 Piece           = '-';
 Device          = '-';
 Material_Set    = '-';
 InputFile       = 'D:\David\RK-Automation\LayoutFiles\Regular_FirstRow.csv';

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