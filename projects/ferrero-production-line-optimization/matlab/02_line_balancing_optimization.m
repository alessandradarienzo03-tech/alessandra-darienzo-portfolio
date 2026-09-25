%% Kinder Bueno Eggs - Line Rebalancing Optimization
% Ferrero Challengineers | Team BuenoUnina
%
% Integer optimization determines the minimum number of additional
% Primary and Secondary Packaging machines needed to reach 20,000 qls/year.
%
% Requires MATLAB Optimization Toolbox.

clear; clc; close all;

%% Shared production assumptions
product_weight_ql = 10.5 / 100000;
shift_minutes = 8 * 60;
shifts_per_year = 250;
annual_target_ql = 20000;

% Primary Packaging
primary_speed = 300;      % products/min per machine
primary_machines = 8;
primary_oee = 0.65;

% Secondary Packaging
secondary_speed = 225;    % products/min per machine
secondary_machines = 9;
secondary_oee = 0.70;

%% Effective throughput per single machine
primary_per_machine_ql_shift = ...
    primary_speed * product_weight_ql * shift_minutes * primary_oee;

secondary_per_machine_ql_shift = ...
    secondary_speed * product_weight_ql * shift_minutes * secondary_oee;

%% Integer linear program
% Decision variables:
% x(1) = additional Primary Packaging machines
% x(2) = additional Secondary Packaging machines
%
% Objective: minimize x(1) + x(2)

f = [1, 1];
intcon = [1, 2];
lb = [0, 0];

% Convert annual-capacity requirements into A*x <= b.
A = [
    -primary_per_machine_ql_shift * shifts_per_year, 0;
    0, -secondary_per_machine_ql_shift * shifts_per_year
];

b = [
    -(annual_target_ql - ...
      primary_machines * primary_per_machine_ql_shift * shifts_per_year);
    -(annual_target_ql - ...
      secondary_machines * secondary_per_machine_ql_shift * shifts_per_year)
];

options = optimoptions('intlinprog', 'Display', 'off');

[x, objective_value] = intlinprog( ...
    f, intcon, A, b, [], [], lb, [], options);

additional_primary = round(x(1));
additional_secondary = round(x(2));

fprintf('Additional Primary Packaging machines: %d\n', ...
    additional_primary);
fprintf('Additional Secondary Packaging machines: %d\n', ...
    additional_secondary);
fprintf('Total additional machines: %.0f\n', objective_value);

%% Before / after cycle-time comparison
new_primary_count = primary_machines + additional_primary;
new_secondary_count = secondary_machines + additional_secondary;

modeller_cycle = 1 / (2000 * 0.80 * product_weight_ql);
tray_cover_cycle = 1 / (756 * 3 * 0.80 * product_weight_ql);

primary_cycle_before = ...
    1 / (primary_speed * primary_machines * primary_oee * product_weight_ql);

secondary_cycle_before = ...
    1 / (secondary_speed * secondary_machines * secondary_oee * product_weight_ql);

primary_cycle_after = ...
    1 / (primary_speed * new_primary_count * primary_oee * product_weight_ql);

secondary_cycle_after = ...
    1 / (secondary_speed * new_secondary_count * secondary_oee * product_weight_ql);

before = [
    modeller_cycle;
    primary_cycle_before;
    secondary_cycle_before;
    tray_cover_cycle
];

after = [
    modeller_cycle;
    primary_cycle_after;
    secondary_cycle_after;
    tray_cover_cycle
];

stage_names = categorical( ...
    ["Modeller", "Primary Packaging", ...
     "Secondary Packaging", "Tray + Cover"]);

comparison = table(stage_names', before, after, ...
    'VariableNames', {'Stage', 'Before_min_per_ql', 'After_min_per_ql'});

disp(comparison);

figure;
bar(stage_names, [before, after]);
ylabel('Cycle Time (min/ql)');
title('Cycle-Time Rebalancing: Before vs After');
legend('Before', 'After', 'Location', 'best');
grid on;
