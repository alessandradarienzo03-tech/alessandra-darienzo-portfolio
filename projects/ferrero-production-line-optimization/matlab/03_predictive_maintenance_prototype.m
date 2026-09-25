%% Predictive Maintenance Prototype
% Ferrero Challengineers | Team BuenoUnina
%
% Proof of concept:
% - simulate progressive equipment degradation;
% - define warning and failure thresholds;
% - trigger a maintenance warning;
% - estimate time to failure with a simple linear trend.
%
% This is a demonstrative prototype, not a production failure-prediction model.

clear; clc; close all;
rng(42);  % Reproducible simulation

%% Simulation parameters
time = (1:100)';

warning_level = 70;
failure_threshold = 80;

% Synthetic degradation index.
% It can be interpreted as a simplified health indicator built from
% condition-monitoring signals such as temperature or vibration.
degradation = 50 + cumsum(randn(100, 1) + 0.5);

maintenance_trigger = degradation > warning_level;

%% Linear time-to-failure estimate
linear_fit = polyfit(time, degradation, 1);

if linear_fit(1) > 0
    predicted_failure_time = ...
        (failure_threshold - linear_fit(2)) / linear_fit(1);
else
    predicted_failure_time = NaN;
end

%% Diagnostics
if any(maintenance_trigger)
    first_warning_idx = find(maintenance_trigger, 1, 'first');

    fprintf('Maintenance warning triggered at time step %d.\n', ...
        time(first_warning_idx));
else
    fprintf('No maintenance warning triggered in the simulation horizon.\n');
end

if ~isnan(predicted_failure_time)
    fprintf('Estimated failure time: %.2f time units.\n', ...
        predicted_failure_time);
else
    fprintf('Failure time could not be estimated from the current trend.\n');
end

%% Visualization
figure;
plot(time, degradation, 'LineWidth', 2);
hold on;

yline(warning_level, '--', 'Warning Threshold');
yline(failure_threshold, '--', 'Failure Threshold');

scatter( ...
    time(maintenance_trigger), ...
    degradation(maintenance_trigger), ...
    40, 'filled');

if ~isnan(predicted_failure_time)
    scatter( ...
        predicted_failure_time, ...
        failure_threshold, ...
        100, 'filled');

    text( ...
        predicted_failure_time, ...
        failure_threshold, ...
        '  Predicted Failure');
end

xlabel('Time');
ylabel('Synthetic Degradation Index');
title('Predictive Maintenance Proof of Concept');
legend( ...
    'Degradation', ...
    'Warning Threshold', ...
    'Failure Threshold', ...
    'Maintenance Trigger', ...
    'Predicted Failure', ...
    'Location', 'best');

grid on;
hold off;
