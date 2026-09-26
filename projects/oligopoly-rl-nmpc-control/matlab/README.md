# MATLAB Implementation

This folder contains a cleaned public implementation of the dynamic-duopoly
control project.

The source project evolved through several MATLAB prototypes. For the portfolio,
the final ideas are reorganized into three modules:

```text
matlab/
├── README.md
├── model/
│   ├── duopoly_dynamics.m
│   └── uncontrolled_simulation.m
├── rl/
│   ├── train_dqn.m
│   ├── rl_reset_function.m
│   ├── rl_step_function.m
│   └── evaluate_dqn.m
└── mpc/
    ├── run_nmpc.m
    ├── nmpc_cost.m
    └── build_rate_constraints.m
```

## Requirements

The scripts require MATLAB with:

- Reinforcement Learning Toolbox for the DQN module;
- Deep Learning Toolbox for the neural Q-function;
- Optimization Toolbox for `fmincon`;
- standard ODE solvers (`ode45`).

## Model

The controlled nonlinear duopoly is:

```text
dx1/dt = a x1 [D x2 / (x1+x2)^2 - u]

dx2/dt = b x2 [D x1 / (x1+x2)^2 - c2]
```

with:

```text
a  = 9.2
b  = 8.3
c2 = 1.0
```

and time-varying demand:

```text
D(k) = 0.9425 + 0.3575 sin(2π(k-13)/24)
```

The control variable `u` is the unit production cost / incentive parameter
associated with firm 1.

## RL Module

The DQN observes:

```text
[x1; x2; D]
```

and selects from the discrete action set:

```text
u = 0.55 : 0.05 : 1.65
```

The action applied to the plant is additionally rate-limited:

```text
|u(k) - u(k-1)| <= 0.10
```

The public step function uses the explicit demand-responsive reward-shaping
variant that was present in the project source material:

```text
reward =
    firm-1 profit
    - demand/supply mismatch penalty
    - demand-responsive control-shaping penalty
    - feasibility penalties
```

### Important source note

The submitted project folder contains **two late-stage RL step-function
variants**: one without the explicit `u_ref(D)` shaping term and one with it.
The cleaned public implementation keeps the explicit shaping formulation
because it makes the final economic-control objective transparent and aligns
with the NMPC cost used in the project comparison.

The numerical performance values shown in the portfolio are the values
reported in the original project presentation; they are not claimed to have
been recomputed from this cleaned repository.

## NMPC Module

The nonlinear MPC:

- predicts with the complete nonlinear dynamics;
- uses a prediction horizon of 8 steps;
- solves the control sequence with `fmincon` / SQP;
- enforces box constraints on `u`;
- enforces the same `0.10` rate limit;
- applies only the first optimized input and repeats the optimization at the
  next time step.

## Suggested Execution Order

Baseline:

```text
model/uncontrolled_simulation.m
```

DQN:

```text
rl/train_dqn.m
rl/evaluate_dqn.m
```

NMPC:

```text
mpc/run_nmpc.m
```

Run the scripts from anywhere; each entry-point script adds the required model
folder to the MATLAB path automatically.
