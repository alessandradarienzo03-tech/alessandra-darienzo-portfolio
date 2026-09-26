function [initialObservation, loggedSignals] = rl_reset_function()
%RL_RESET_FUNCTION Reset the dynamic-duopoly RL environment.

    nSteps = 24;

    % Random positive initial productions, as in the final project.
    x0 = 0.1 + 0.2 * rand(2,1);

    k0 = 0;
    D0 = 0.9425 + ...
        0.3575 * sin(2*pi*(k0 - 13)/nSteps);

    % Same starting control used for RL / NMPC comparisons.
    initialControl = 1.0;

    loggedSignals.State = x0;
    loggedSignals.Step = k0;
    loggedSignals.PreviousControl = initialControl;

    initialObservation = [x0; D0];
end
