%% Kinder Bueno Eggs - Bottleneck & Capacity Analysis
% Ferrero Challengineers | Team BuenoUnina
%
% This script evaluates the effective production capacity of four stages:
% Modeller, Primary Packaging, Secondary Packaging and Tray + Cover.
%
% Final project assumption: 250 shifts/year.

clear; clc; close all;

%% Production parameters
stage_names = ["Modeller", "Primary Packaging", ...
               "Secondary Packaging", "Tray + Cover"];

product_weight_g = 10.5;
product_weight_ql = product_weight_g / 100000;

products_per_tray = 80;
modeller_trays_per_min = 25;

speed_products_per_min = [
    modeller_trays_per_min * products_per_tray, ...
    300, ...
    225, ...
    756
];

machine_count = [1, 8, 9, 3];
oee = [0.80, 0.65, 0.70, 0.80];

shift_minutes = 8 * 60;
shifts_per_year = 250;
annual_target_ql = 20000;

%% Capacity calculations
ideal_throughput_ql_shift = ...
    speed_products_per_min .* machine_count .* ...
    product_weight_ql .* shift_minutes;

effective_throughput_ql_shift = ...
    ideal_throughput_ql_shift .* oee;

cycle_time_min_ql = ...
    1 ./ (speed_products_per_min .* machine_count .* ...
          oee .* product_weight_ql);

annual_capacity_ql = ...
    effective_throughput_ql_shift .* shifts_per_year;

meets_target = annual_capacity_ql >= annual_target_ql;

results = table( ...
    stage_names', machine_count', oee', ...
    effective_throughput_ql_shift', ...
    cycle_time_min_ql', annual_capacity_ql', meets_target', ...
    'VariableNames', { ...
        'Stage', 'Machines', 'OEE', ...
        'Throughput_ql_per_shift', ...
        'CycleTime_min_per_ql', ...
        'AnnualCapacity_ql', 'MeetsAnnualTarget'});

disp(results);

%% Bottleneck identification
[~, bottleneck_idx] = min(effective_throughput_ql_shift);

fprintf('\nCurrent bottleneck: %s\n', stage_names(bottleneck_idx));
fprintf('Effective throughput: %.2f qls/shift\n', ...
    effective_throughput_ql_shift(bottleneck_idx));
fprintf('Annual capacity: %.2f qls/year\n', ...
    annual_capacity_ql(bottleneck_idx));

%% Visualization
figure;
bar(categorical(stage_names), effective_throughput_ql_shift);
ylabel('Effective Throughput (qls/shift)');
title('Effective Throughput by Production Stage');
grid on;

figure;
bar(categorical(stage_names), cycle_time_min_ql);
ylabel('Cycle Time (min/ql)');
title('Cycle Time by Production Stage');
grid on;
