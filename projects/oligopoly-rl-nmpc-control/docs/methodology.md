# Methodology

## 1. Theoretical Starting Point

The project starts from a nonlinear industrial-production model for an
oligopoly.

In the reference formulation, firms adjust production according to marginal
profit. Under isoelastic inverse demand:

```text
P = 1 / Q
```

with:

```text
Q = q1 + q2 + q3
```

and linear production cost:

```text
Ci(qi) = ci qi
```

the production dynamics become nonlinear because each firm's marginal profit
depends on total market output and the competitors' production.

The reference paper treats the firms' unit production costs as possible
control inputs and develops an H-infinity nonlinear optimal-control solution.

The portfolio project does **not** reproduce that H-infinity controller.
Instead, it adapts the production-dynamics idea to a two-firm market and
compares two different control paradigms:

- Deep Q-Learning;
- Nonlinear Model Predictive Control.

## 2. Duopoly Adaptation

The state is reduced to two production variables:

```text
x = [x1, x2]'
```

where:

- `x1` = production of firm 1;
- `x2` = production of firm 2.

Firm 1 is controlled through its unit production-cost / incentive parameter:

```text
u = c1
```

while firm 2 keeps:

```text
c2 = 1.0
```

The final dynamic model uses:

```text
dx1/dt = a x1 [D(t)x2/(x1+x2)^2 - u]

dx2/dt = b x2 [D(t)x1/(x1+x2)^2 - c2]
```

with:

```text
a = 9.2
b = 8.3
```

## 3. Why the First RL Formulation Was Not Enough

The first reinforcement-learning experiments used a static market and a target
production state.

Training initially showed unstable rewards and poor tracking.

After redesigning the reward and adding constraints, the agent converged
toward the closest physically reachable equilibrium rather than the requested
target.

This was interpreted as a modelling issue rather than simply an algorithmic
failure.

With static demand, the environment naturally tends toward a static market
equilibrium, so the control problem gives the agent little reason to learn a
meaningful time-dependent policy.

## 4. Time-Varying Demand Extension

The main project therefore introduces an exogenous demand cycle:

```text
D(t) = 0.9425 + 0.3575 sin(2π(t - 13)/24)
```

The price is changed accordingly:

```text
P(t) = D(t) / Q(t)
```

where:

```text
Q(t) = x1(t) + x2(t)
```

This creates a genuinely dynamic economic-control problem.

A low control value stimulates firm-1 production, while a higher value
discourages it.

The desired action therefore varies across the demand cycle.

## 5. Uncontrolled Benchmark

The baseline uses a constant control:

```text
u = 1.0
```

for the full time horizon.

The original presentation reports:

```text
mean profit, firm 1 = 0.2272
mean Q - D mismatch = -0.4633
```

The negative mismatch indicates persistent underproduction relative to market
demand.

## 6. DQN Environment

The reinforcement-learning state is:

```text
[x1, x2, D]
```

and the discrete action set is:

```text
u = 0.55 : 0.05 : 1.65
```

The Q-network contains:

```text
3 input variables
64-unit fully connected layer + ReLU
64-unit fully connected layer + ReLU
one Q-value per discrete action
```

The training configuration uses:

```text
Double DQN
experience replay buffer = 100,000
mini-batch size = 64
discount factor = 0.98
epsilon-greedy exploration
maximum episode length = 24
```

## 7. Reward Design

The final project objective is economic rather than pure state tracking.

The reward combines:

```text
firm-1 profit
- market mismatch penalty
- control-shaping penalty
- state-violation penalties
- negative-profit penalties
```

Firm-1 profit is:

```text
pi1 = (P - u)x1
```

and market imbalance is represented by:

```text
Q - D
```

A late-stage project implementation also includes an explicit
demand-responsive reference control:

```text
high demand -> lower preferred u
low demand  -> higher preferred u
```

This means the final RL controller is best described as an
**economics-informed DQN**, not as an unconstrained agent discovering the
economic direction entirely from scratch.

## 8. Action and State Constraints

The control satisfies:

```text
0.55 <= u <= 1.65
```

with a rate limit:

```text
|u(k) - u(k-1)| <= 0.10
```

The state must remain non-negative:

```text
x1 >= 0
x2 >= 0
```

State feasibility is handled through penalties in the RL reward.

## 9. DQN Evaluation

The trained agent is tested over multiple simulated episodes.

The source testing script selects the episode with the highest mean firm-1
profit among 10 simulations.

Because both the initial state and RL evaluation are stochastic, the project
presentation contains slightly different representative DQN values.

One results slide reports:

```text
mean profit = 0.3651
mean mismatch = -0.4382
```

while the final DQN-vs-NMPC comparison reports:

```text
mean profit = 0.3600
mean mismatch = -0.4377
```

The portfolio uses the latter values for the direct controller comparison and
treats DQN results as approximate rather than deterministic.

## 10. Why Nonlinear MPC

The same economic-control problem is then solved with Model Predictive Control.

The nonlinear model contains terms such as:

```text
x1 x2
1 / (x1 + x2)^2
```

and the operating point changes continuously with demand.

The project therefore avoids a fixed linear approximation and implements
**Nonlinear MPC (NMPC)** using the complete nonlinear dynamics.

## 11. NMPC Formulation

At each control step:

1. observe the current state and demand;
2. define a finite prediction horizon;
3. optimize a future sequence of control inputs;
4. simulate the nonlinear dynamics for each candidate sequence;
5. minimize an economic cost corresponding to the RL objective;
6. apply only the first optimized action;
7. repeat at the next step.

The prediction horizon is:

```text
Np = 8
```

The optimization uses MATLAB `fmincon` with SQP.

The future plant trajectory is simulated with `ode45`.

## 12. NMPC Constraints

The optimizer enforces:

```text
0.55 <= u <= 1.65
```

and:

```text
|Delta u| <= 0.10
```

through linear inequality constraints.

State positivity and negative-profit conditions are handled as penalties
inside the cost function because future states are generated by nonlinear
simulation rather than being direct `fmincon` decision variables.

## 13. DQN vs NMPC

The final presentation reports:

| Metric | DQN | NMPC |
|---|---:|---:|
| Average profit — firm 1 | 0.3600 | 0.2693 |
| Mean Q-D mismatch | -0.4377 | -0.4594 |

The project uses this comparison to study two distinct ways of solving the
same nonlinear control problem.

DQN pays the computational cost mainly during offline training and then
evaluates a learned policy online.

NMPC repeatedly solves a constrained nonlinear optimization problem during
operation.

The reported experiment favours DQN on both metrics, but this is a result of
the chosen model, reward, controller settings and stochastic simulation. It is
not presented as evidence that RL is generally superior to MPC.

## 14. Main Methodological Contribution

The strongest aspect of the project is the modelling progression:

```text
static nonlinear duopoly
-> first RL controller
-> reward redesign
-> controllability limitation
-> time-varying demand
-> economics-informed DQN
-> nonlinear MPC benchmark
-> controller comparison
```

The project therefore studies not just algorithms, but how the formulation of
the economic environment determines what can meaningfully be controlled.

## 15. Limitations

The analysis is simulation-based.

Important limitations include:

- two-firm stylized market;
- deterministic sinusoidal demand;
- fixed competitor cost;
- a single controlled firm;
- reward shaping that influences the DQN policy;
- stochastic initial conditions and RL evaluation;
- no calibration to real electricity-market data;
- no formal general result about DQN versus NMPC.

## 16. Future Work

Possible extensions include:

- stochastic or forecast-based demand;
- continuous-action reinforcement learning;
- multi-agent RL;
- robust and stochastic MPC;
- explicit dynamic-game / Nash formulations;
- real market-price calibration;
- uncertainty-aware controller comparison;
- sensitivity analysis over reward weights and MPC horizon.
