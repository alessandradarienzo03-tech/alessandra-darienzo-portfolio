function [A, b] = build_rate_constraints( ...
    horizon, maxDeltaU, previousControl)
%BUILD_RATE_CONSTRAINTS Linear inequalities for |Delta u| constraints.
%
% Produces A*u <= b for:
%
%   |u(1) - u_previous| <= maxDeltaU
%
% and:
%
%   |u(k) - u(k-1)| <= maxDeltaU

    nConstraints = 2 * horizon;

    A = zeros( ...
        nConstraints, ...
        horizon);

    b = zeros( ...
        nConstraints, ...
        1);

    row = 1;

    % First control relative to previously applied input.
    A(row,1) = 1;
    b(row) = maxDeltaU + previousControl;
    row = row + 1;

    A(row,1) = -1;
    b(row) = maxDeltaU - previousControl;
    row = row + 1;

    % Consecutive controls.
    for k = 2:horizon

        A(row,k) = 1;
        A(row,k-1) = -1;
        b(row) = maxDeltaU;
        row = row + 1;

        A(row,k) = -1;
        A(row,k-1) = 1;
        b(row) = maxDeltaU;
        row = row + 1;
    end
end
