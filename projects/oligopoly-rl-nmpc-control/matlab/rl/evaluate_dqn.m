%% Evaluate a trained DQN controller

clear;
clc;
close all;

thisFile = mfilename("fullpath");
rlDir = fileparts(thisFile);
modelDir = fullfile(fileparts(rlDir), "model");
addpath(modelDir);
addpath(rlDir);

agentPath = fullfile(rlDir, "trained_agent.mat");

if ~isfile(agentPath)
    error([ ...
        "trained_agent.mat not found. ", ...
        "Run train_dqn.m first."]);
end

load(agentPath, "agent", "env");

Ts = 1.0;
nSteps = 24;
nSimulations = 10;

simulationOptions = rlSimulationOptions( ...
    MaxSteps=nSteps, ...
    NumSimulations=nSimulations, ...
    StopOnError="on");

experience = sim( ...
    env, ...
    agent, ...
    simulationOptions);

%% Score each episode by mean firm-1 profit
meanProfit = zeros(nSimulations,1);
episodeData = cell(nSimulations,1);

for episode = 1:nSimulations

    observation = squeeze( ...
        experience(episode) ...
        .Observation.SystemStates.Data);

    x1 = observation(1,1:end-1);
    x2 = observation(2,1:end-1);

    desiredControl = squeeze( ...
        experience(episode) ...
        .Action.Firm1Control.Data);

    desiredControl = desiredControl(:);

    time = 0:Ts:(nSteps-1)*Ts;

    demand = ...
        0.9425 + ...
        0.3575 * sin(2*pi*(time - 13)/nSteps);

    %% Reconstruct applied rate-limited control
    uMin = 0.55;
    uMax = 1.65;
    maxDeltaU = 0.10;

    appliedControl = zeros(nSteps,1);
    previousControl = 1.0;

    for k = 1:nSteps
        lowerBound = max( ...
            uMin, ...
            previousControl - maxDeltaU);

        upperBound = min( ...
            uMax, ...
            previousControl + maxDeltaU);

        appliedControl(k) = min( ...
            max(desiredControl(k), lowerBound), ...
            upperBound);

        previousControl = appliedControl(k);
    end

    totalProduction = x1 + x2;
    price = demand ./ max(totalProduction, 1e-6);

    profit1 = ...
        (price - appliedControl.') .* x1;

    profit2 = ...
        (price - 1.0) .* x2;

    meanProfit(episode) = mean(profit1);

    episodeData{episode} = struct( ...
        "x1", x1, ...
        "x2", x2, ...
        "u", appliedControl, ...
        "demand", demand, ...
        "profit1", profit1, ...
        "profit2", profit2);
end

[bestProfit, bestEpisode] = max(meanProfit);
best = episodeData{bestEpisode};

Q = best.x1 + best.x2;
meanMismatch = mean(Q - best.demand);

fprintf("\n=== DQN EVALUATION ===\n");
fprintf("Selected episode: %d\n", bestEpisode);
fprintf("Mean firm-1 profit: %.4f\n", bestProfit);
fprintf("Mean Q-D mismatch:  %.4f\n\n", meanMismatch);

%% Export representative control policy
resultsDir = fullfile( ...
    fileparts(fileparts(rlDir)), ...
    "results");

if ~exist(resultsDir, "dir")
    mkdir(resultsDir);
end

time = 0:Ts:(nSteps-1)*Ts;

figure;
stairs( ...
    time, ...
    best.u, ...
    "LineWidth", 1.8);
grid on;
xlabel("Time");
ylabel("u(k)");
title("DQN control policy");

exportgraphics( ...
    gcf, ...
    fullfile(resultsDir, "dqn_control_policy.png"), ...
    "Resolution", 180);

figure;
plot(time, Q, "LineWidth", 1.8);
hold on;
plot( ...
    time, ...
    best.demand, ...
    "--", ...
    "LineWidth", 1.8);
grid on;
xlabel("Time");
ylabel("Production / demand");
legend("Total production Q", "Demand D", ...
    "Location", "best");
title("DQN market response");
