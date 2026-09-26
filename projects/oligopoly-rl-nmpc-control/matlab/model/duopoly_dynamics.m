function xdot = duopoly_dynamics(~, x, u, D)
%DUOPOLY_DYNAMICS Nonlinear production dynamics for a Cournot-style duopoly.
%
%   x(1) : production of firm 1
%   x(2) : production of firm 2
%   u    : unit production-cost / control parameter of firm 1
%   D    : exogenous market-demand level, held constant over one control step
%
% The equations used in the final project are:
%
%   dx1/dt = a*x1 * (D*x2/(x1+x2)^2 - u)
%   dx2/dt = b*x2 * (D*x1/(x1+x2)^2 - c2)
%
% with a = 9.2, b = 8.3 and c2 = 1.0.

    a  = 9.2;
    b  = 8.3;
    c2 = 1.0;

    x1 = x(1);
    x2 = x(2);

    totalProduction = max(x1 + x2, 1e-8);

    dx1 = a * x1 * ( ...
        D * x2 / totalProduction^2 - u);

    dx2 = b * x2 * ( ...
        D * x1 / totalProduction^2 - c2);

    xdot = [dx1; dx2];
end
