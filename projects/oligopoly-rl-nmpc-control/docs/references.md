# References

## Main Theoretical Reference

**Rigatos, G., Siano, P., Ghosh, T., & Xin, B. (2019).**  
*A Nonlinear Optimal Control Approach for Industrial Production Under an
Oligopoly Model.*  
IEEE Systems Journal, 13(2), 1991–2000.  
DOI: `10.1109/JSYST.2018.2866431`

The paper provides the theoretical starting point for the nonlinear
oligopoly-production dynamics.

It models production adjustment through marginal profit, writes the oligopoly
as a nonlinear state-space system and develops an H-infinity feedback-control
method based on repeated local linearization and algebraic Riccati equations.

The portfolio project uses the production-dynamics framework as inspiration
but replaces the paper's triopoly H-infinity controller with:

- a two-firm dynamic market;
- time-varying demand;
- Deep Q-Learning;
- Nonlinear Model Predictive Control.

## MATLAB / Numerical Methods Used

The implementation relies on standard MATLAB numerical and control tools:

- `ode45` for nonlinear state integration;
- Reinforcement Learning Toolbox for DQN;
- Deep Learning Toolbox for the neural Q-function;
- `fmincon` with SQP for NMPC optimization.

The licensed IEEE PDF supplied with the academic project is not redistributed
in the public repository.
