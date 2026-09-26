%% Nonlinear Model Predictive Control for the dynamic duopoly

clear;
clc;
close all;

thisFile = mfilename("fullpath");
mpcDir = fileparts(thisFile);
modelDir = fullfile(fileparts(mpcDir), "model");
addpath(modelDir);
addpath(mpcDir);

rng(42);

%% Configuration
Ts = 1.0;
nSteps = 24;
predictionHorizon = 8;

mismatchWeight = 15.0;
controlWeight = 0.005;
shapingWeight = 25.0;

uMin = 0.55;
uMax = 1.65;
maxDeltaU = 0.10;

demandMin = 0.9425 - 0.3575;
demandMax = 0.9425 + 0.3575;

%% Initial state and control
xk = 0.1 + 0.2 * rand(2,1);
previousControl = 1.0;

X = zeros(2, nSteps + 1);
U = zeros(1, nSteps);
D = zeros(1, nSteps);
profit1 = zeros(1, nSteps);

X(:,1) = xk;

%% Optimizer
options = optimoptions( ...
    "fmincon", ...
    Algorithm="sqp", ...
    Display="off", ...
    MaxIterations=100, ...
    OptimalityTolerance=1e-4, ...
    StepTolerance=1e-6);

%% Receding-horizon loop
for step = 1:nSteps

    k = step - 1;

    Dk = ...
        0.9425 + ...
        0.3575 * sin(2*pi*(k - 13)/nSteps);

    D(step) = Dk;

    horizon = min( ...
        predictionHorizon, ...
        nSteps - step + 1);

    initialGuess = ...
        previousControl * ones(horizon,1);

    lowerBound = ...
        uMin * ones(horizon,1);

    upperBound = ...
        uMax * ones(horizon,1);

    [A, b] = build_rate_constraints( ...
        horizon, ...
        maxDeltaU, ...
        previousControl);

    objective = @(uSequence) nmpc_cost( ...
        uSequence, ...
        xk, ...
        k, ...
        Ts, ...
        nSteps, ...
        mismatchWeight, ...
        controlWeight, ...
        shapingWeight, ...
        uMin, ...
        uMax, ...
        demandMin, ...
        demandMax);

    optimalSequence = fmincon( ...
        objective, ...
        initialGuess, ...
        A, ...
        b, ...
        [], ...
        [], ...
        lowerBound, ...
        upperBound, ...
        [], ...
        options);

    % Receding horizon: apply only the first input.
    uk = optimalSequence(1);

    [~, trajectory] = ode45( ...
        @(t,x) duopoly_dynamics(t, x, uk, Dk), ...
        [0 Ts], ...
        xk);

    xNext = trajectory(end,:).';

    x1 = xNext(1);
    x2 = xNext(2);

    totalProduction = x1 + x2;
    price = Dk / max(totalProduction, 1e-6);

    profit1(step) = ...
        (price - uk) * x1;

    X(:,step+1) = xNext;
    U(step) = uk;

    xk = xNext;
    previousControl = uk;
end

%% Metrics
Q = X(1,1:end-1) + X(2,1:end-1);

meanProfit1 = mean(profit1);
meanMismatch = mean(Q - D);

fprintf("\n=== NMPC RESULTS ===\n");
fprintf("Mean firm-1 profit: %.4f\n", meanProfit1);
fprintf("Mean Q-D mismatch:  %.4f\n\n", meanMismatch);

%% Export figures
resultsDir = fullfile( ...
    fileparts(fileparts(mpcDir)), ...
    "results");

if ~exist(resultsDir, "dir")
    mkdir(resultsDir);
end

time = 0:Ts:(nSteps-1)*Ts;

figure;
plot(time, U, "LineWidth", 1.8);
grid on;
xlabel("Time");
ylabel("u(k)");
title("NMPC control policy");

exportgraphics( ...
    gcf, ...
    fullfile(resultsDir, "nmpc_control_policy.png"), ...
    "Resolution", 180);

figure;
plot(time, Q, "LineWidth", 1.8);
hold on;
plot(time, D, "--", "LineWidth", 1.8);
grid on;
xlabel("Time");
ylabel("Production / demand");
legend("Total production Q", "Demand D", ...
    "Location", "best");
title("NMPC market response");
