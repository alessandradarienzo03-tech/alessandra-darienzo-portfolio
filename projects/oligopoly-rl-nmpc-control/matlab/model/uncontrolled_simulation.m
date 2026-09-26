%% Uncontrolled dynamic-duopoly benchmark
% Constant firm-1 control u = 1.0 under time-varying demand.
%
% This script provides the baseline used for comparison with DQN and NMPC.

clear;
clc;
close all;

thisFile = mfilename("fullpath");
modelDir = fileparts(thisFile);
addpath(modelDir);

rng(42);

%% Configuration
T = 24;
u = 1.0;
c2 = 1.0;

% Positive initial productions.
x0 = 0.1 + 0.2 * rand(2,1);

demand = @(t) ...
    0.9425 + 0.3575 * sin(2*pi*(t - 13)/T);

%% Continuous-time simulation
[t, x] = ode45( ...
    @(t,x) duopoly_dynamics(t, x, u, demand(t)), ...
    [0 T], ...
    x0);

D = demand(t);
Q = x(:,1) + x(:,2);
Qsafe = max(Q, 1e-6);
P = D ./ Qsafe;

profit1 = (P - u)  .* x(:,1);
profit2 = (P - c2) .* x(:,2);

meanProfit1 = mean(profit1);
meanProfit2 = mean(profit2);
meanMismatch = mean(Q - D);

fprintf("\n=== UNCONTROLLED BENCHMARK ===\n");
fprintf("Mean profit firm 1: %.4f\n", meanProfit1);
fprintf("Mean profit firm 2: %.4f\n", meanProfit2);
fprintf("Mean Q-D mismatch:  %.4f\n\n", meanMismatch);

%% Results
resultsDir = fullfile( ...
    fileparts(fileparts(modelDir)), ...
    "results");

if ~exist(resultsDir, "dir")
    mkdir(resultsDir);
end

figure;
plot(t, Q, "LineWidth", 1.7);
hold on;
plot(t, D, "--", "LineWidth", 1.7);
grid on;
xlabel("Time");
ylabel("Production / demand");
legend("Total production Q", "Demand D", ...
    "Location", "best");
title("Uncontrolled duopoly under time-varying demand");

exportgraphics( ...
    gcf, ...
    fullfile(resultsDir, "uncontrolled_dynamics.png"), ...
    "Resolution", 180);

figure;
plot(t, profit1, "LineWidth", 1.7);
hold on;
plot(t, profit2, "LineWidth", 1.7);
grid on;
xlabel("Time");
ylabel("Profit");
legend("Firm 1", "Firm 2", "Location", "best");
title("Uncontrolled profits");
