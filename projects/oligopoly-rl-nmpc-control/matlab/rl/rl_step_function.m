function [nextObservation, reward, isDone, loggedSignals] = ...
    rl_step_function(action, loggedSignals)
%RL_STEP_FUNCTION One transition of the dynamic-duopoly RL environment.
%
% Observation:
%   [x1; x2; D]
%
% Action:
%   desired firm-1 control u
%
% Portfolio formulation:
%   reward = economic profit
%            - demand/supply mismatch penalty
%            - demand-responsive shaping penalty
%            - feasibility penalties
%
% The source project contains two late-stage step-function variants.
% This cleaned version retains the explicit u_ref(D) shaping formulation
% present in the submitted source material.

    %% Configuration
    Ts = 1.0;
    nSteps = 24;

    mismatchWeight = 15.0;
    shapingWeight = 25.0;

    uMin = 0.55;
    uMax = 1.65;
    maxDeltaU = 0.10;

    demandMin = 0.9425 - 0.3575;
    demandMax = 0.9425 + 0.3575;

    %% Current environment state
    xk = loggedSignals.State;
    k = loggedSignals.Step;
    uPrevious = loggedSignals.PreviousControl;

    %% Enforce action bounds and rate constraint
    desiredControl = double(action);

    lowerRateBound = max( ...
        uMin, ...
        uPrevious - maxDeltaU);

    upperRateBound = min( ...
        uMax, ...
        uPrevious + maxDeltaU);

    u = min( ...
        max(desiredControl, lowerRateBound), ...
        upperRateBound);

    %% Demand at current step
    Dk = 0.9425 + ...
        0.3575 * sin(2*pi*(k - 13)/nSteps);

    %% Nonlinear plant transition
    [~, trajectory] = ode45( ...
        @(t,x) duopoly_dynamics(t, x, u, Dk), ...
        [0 Ts], ...
        xk);

    nextState = trajectory(end,:).';

    x1 = nextState(1);
    x2 = nextState(2);

    totalProduction = x1 + x2;
    safeProduction = max(totalProduction, 1e-6);

    price = Dk / safeProduction;
    profit1 = (price - u) * x1;

    %% Reward
    reward = profit1;

    if profit1 < 0
        reward = reward - abs(profit1)^2;
    end

    mismatch = totalProduction - Dk;
    reward = reward - ...
        mismatchWeight * mismatch^2;

    % Demand-responsive reference:
    % higher demand -> lower u
    % lower demand  -> higher u
    demandNormalized = ...
        (Dk - demandMin) / (demandMax - demandMin);

    demandNormalized = min( ...
        max(demandNormalized, 0), ...
        1);

    referenceControl = ...
        uMax - ...
        (uMax - uMin) * demandNormalized;

    reward = reward - ...
        shapingWeight * ...
        (u - referenceControl)^2;

    %% Feasibility penalty
    negativeStateViolation = max(0, -nextState);
    violationNorm = norm(negativeStateViolation);

    if violationNorm > 0
        reward = reward - ...
            500 * violationNorm^2;
    end

    isDone = false;

    if violationNorm >= 0.05
        reward = reward - 1000;
        isDone = true;
    end

    %% Next observation
    nextK = k + 1;

    nextDemand = ...
        0.9425 + ...
        0.3575 * sin(2*pi*(nextK - 13)/nSteps);

    nextObservation = [nextState; nextDemand];

    loggedSignals.State = nextState;
    loggedSignals.Step = nextK;
    loggedSignals.PreviousControl = u;
end
