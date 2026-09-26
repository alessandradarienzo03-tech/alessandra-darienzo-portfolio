# Reinforcement Learning & Nonlinear MPC for a Dynamic Cournot Duopoly

**Optimal production control under time-varying demand**

A nonlinear control and reinforcement-learning project studying how a firm can
adapt its production incentives inside a Cournot-style duopoly when market
demand changes over time.

The project combines:

- nonlinear dynamical systems;
- industrial organization and oligopoly modelling;
- bounded-rational production adjustment;
- Deep Q-Learning (DQN);
- reward shaping and constrained control;
- Nonlinear Model Predictive Control (NMPC);
- numerical simulation with ODE solvers;
- economic-performance benchmarking.

The central modelling question is:

> **Can a data-driven control policy improve a firm's economic performance and
> reduce market demand–supply mismatch in a nonlinear oligopoly, and how does
> that policy compare with an online optimization-based controller?**

---

## 1. From Oligopoly Theory to a Dynamic Control Problem

The project starts from a nonlinear oligopoly model in which firms update their
production according to marginal profit.

For a two-firm market:

```text
x1(t) = production of firm 1
x2(t) = production of firm 2
Q(t)  = x1(t) + x2(t)
```

The original theoretical model uses an inverse-demand structure in which price
decreases as total market output increases.

Production costs are linear and the firms adjust output myopically in response
to marginal profit.

The resulting system is nonlinear and coupled: the evolution of each firm's
production depends both on its own state and on the competitor's production.

In this project, the unit production cost of firm 1 is treated as the control
variable:

```text
u(t) = c1(t)
```

while the unit cost of firm 2 remains fixed.

---

## 2. Baseline: Uncontrolled Nonlinear Dynamics

The first implementation studies the free evolution of the duopoly under a
constant control input.

With static demand, the system converges toward a stable operating point.

The first DQN formulation attempted to force the nonlinear system toward a
fixed desired production state.

### What went wrong

The initial agent showed unstable training and poor target tracking.

After reward redesign and additional constraints, the agent converged toward
the closest physically reachable equilibrium rather than the requested target.

Representative result:

```text
reachable state ≈ [0.55, 0.19]
learned constant control u ≈ 0.35
```

This exposed an important modelling limitation:

> under a static market formulation, the optimal behaviour tends toward a
> static equilibrium and does not create a meaningful dynamic control problem.

That observation motivated the main extension of the project.

---

## 3. Model Extension: Time-Varying Electricity Demand

The market model is extended with a sinusoidal demand profile intended to
represent an intraday electricity-demand cycle:

```text
D(t) = 0.9425 + 0.3575 sin(2π(t - 13)/24)
```

The market price becomes:

```text
P(t) = D(t) / Q(t)
```

with:

```text
Q(t) = x1(t) + x2(t)
```

The nonlinear production dynamics become:

```text
dx1/dt = a x1 [ D(t)x2 / (x1+x2)^2 - u ]

dx2/dt = b x2 [ D(t)x1 / (x1+x2)^2 - c2 ]
```

where the final implementation uses:

```text
a = 9.2
b = 8.3
c2 = 1.0
```

This creates a genuinely time-dependent control problem: the economically
desirable action now changes with the demand cycle.

---

## 4. Uncontrolled Benchmark

The uncontrolled benchmark keeps:

```text
u = c1 = 1.0
```

throughout the full 24-step demand cycle.

The simulations show that a fixed control cannot make aggregate production
track the changing market demand.

A representative benchmark reported in the project is:

| Metric | Uncontrolled |
|---|---:|
| Mean profit — firm 1 | 0.2272 |
| Mean demand–supply mismatch `Q - D` | -0.4633 |

This benchmark provides the reference against which the learned and optimized
control policies are compared.

---

## 5. Reinforcement Learning Formulation

The final RL environment observes:

```text
state = [x1, x2, D]
```

and chooses the production-cost control:

```text
u ∈ {0.55, 0.60, ..., 1.65}
```

The controller is implemented as a **Deep Q-Network (DQN)** with:

```text
Input: 3 state variables
Hidden layer: 64 + ReLU
Hidden layer: 64 + ReLU
Output: Q-value for each discrete control action
```

Training configuration includes:

```text
Double DQN
Experience buffer: 100,000
Mini-batch size: 64
Discount factor: 0.98
ε-greedy exploration: 1.0 → 0.05
Maximum episodes: 1,500
Episode horizon: 24 steps
```

---

## 6. Economics-Informed Reward Design

The RL objective is not simply to reach a fixed state.

The final reward combines several competing objectives:

```text
reward
= firm-1 profit
- demand–supply mismatch penalty
- control-shaping penalty
- state-violation penalties
- negative-profit penalties
```

The principal economic term is:

```text
π1 = (P - u)x1
```

while market coordination is encouraged through:

```text
α(Q - D)^2
```

The final implementation also contains explicit **economics-informed reward
shaping**: the preferred control is lower during high-demand periods and higher
during weak-demand periods.

This is an important modelling choice. The time-dependent structure of the
policy is therefore learned under a reward that already encodes the desired
economic direction, rather than being discovered from an unconstrained reward
alone.

---

## 7. Control Constraints

The final environment imposes economically and physically meaningful
constraints.

### Action bounds

```text
0.55 ≤ u ≤ 1.65
```

### Rate limit

```text
|u(k) - u(k-1)| ≤ 0.10
```

### State feasibility

```text
x1 ≥ 0
x2 ≥ 0
```

Violations are handled through penalties and episode termination for severe
cases.

The action-rate constraint prevents unrealistic instantaneous changes in the
control variable.

---

## 8. Learned Demand-Responsive Policy

The trained DQN produces a control policy that changes across the 24-step
market cycle.

The representative final policy is approximately anti-correlated with demand:

```text
high demand → lower u → production is stimulated
low demand  → higher u → production is reduced
```

The policy is smooth because of the imposed control-rate constraint.

Representative results reported across final project runs are approximately:

| Metric | Uncontrolled | DQN |
|---|---:|---:|
| Mean profit — firm 1 | 0.2272 | ~0.36 |
| Mean demand–supply mismatch | -0.4633 | ~-0.438 |

Because the initial state and RL simulation contain stochastic elements, the
presentation reports slightly different DQN values across representative runs.
The public portfolio therefore reports the results as approximate rather than
as a single deterministic benchmark.

---

## 9. Why Compare RL with Nonlinear MPC?

A second controller is implemented to answer a more demanding question:

> Is the learned DQN policy competitive with a controller that explicitly
> solves an optimization problem online at every time step?

The same nonlinear duopoly model and broadly aligned economic objective are
therefore implemented using **Nonlinear Model Predictive Control (NMPC)**.

The comparison is valuable because the two approaches solve the same control
problem in fundamentally different ways:

### DQN

```text
offline learning
→ approximate policy stored in neural network
→ fast action selection online
```

### NMPC

```text
observe current state
→ simulate future trajectories
→ solve constrained nonlinear optimization online
→ apply first optimal control
→ repeat
```

---

## 10. Nonlinear Model Predictive Control

The MPC controller uses a receding prediction horizon:

```text
prediction horizon Np = 8
```

At every time step, MATLAB `fmincon` with SQP solves for a future control
sequence:

```text
u(k), ..., u(k + Np - 1)
```

subject to:

```text
0.55 ≤ u ≤ 1.65

|Δu| ≤ 0.10
```

Future states are obtained by forward simulation of the **full nonlinear
duopoly dynamics** with `ode45`.

Only the first optimized action is applied before the optimization problem is
solved again at the next step.

---

## 11. Why NMPC Instead of Linear MPC?

The project explicitly evaluates the modelling choice.

The system contains terms such as:

```text
x1 x2
1 / (x1 + x2)^2
```

and operates across a time-varying demand trajectory rather than near one
fixed equilibrium.

A first-order local linear approximation would therefore change substantially
across the operating range.

The project consequently retains the nonlinear dynamics directly inside the
prediction model and solves the optimization numerically.

---

## 12. RL vs NMPC

A representative final comparison reported in the presentation is:

| Metric | DQN | NMPC |
|---|---:|---:|
| Average profit — firm 1 | 0.360 | 0.2693 |
| Mean demand–supply mismatch | -0.4377 | -0.4594 |

Under this experimental configuration, the DQN policy produces the higher
average profit and a slightly smaller negative demand–supply mismatch.

These results should be interpreted as a **simulation comparison under the
chosen reward, parameters, initial-state generation and horizon**, not as a
general superiority claim for RL over MPC.

The comparison is especially useful because it exposes a broader trade-off:

```text
DQN
learn computationally expensive behaviour offline
but execute cheaply online

vs.

NMPC
solve the nonlinear optimization explicitly online
at every control step
```

---

## 13. Project Progression

One of the strongest aspects of the project is the iterative modelling path:

```text
nonlinear Cournot dynamics
        ↓
uncontrolled simulation
        ↓
first DQN formulation
        ↓
unstable training
        ↓
reward / constraint redesign
        ↓
structural controllability limitation
        ↓
time-varying demand extension
        ↓
economics-informed DQN
        ↓
nonlinear MPC benchmark
        ↓
RL vs optimization comparison
```

The project therefore documents not only a final model, but the reasoning that
led from an insufficient formulation to a more meaningful control problem.

---

## 14. Technical Methods

The project combines:

- Cournot duopoly modelling;
- isoelastic inverse demand;
- nonlinear ordinary differential equations;
- numerical integration with `ode45`;
- discrete-action Deep Q-Learning;
- Double DQN;
- epsilon-greedy exploration;
- experience replay;
- reward shaping;
- action constraints and rate limits;
- nonlinear Model Predictive Control;
- sequential quadratic programming through `fmincon`;
- receding-horizon optimization;
- simulation-based economic benchmarking.

---

## 15. Limitations

The project is a simulation study.

Important limitations include:

- stylized two-firm market structure;
- deterministic sinusoidal demand;
- fixed competitor cost;
- one controlled firm;
- reward-shaping assumptions that influence the learned policy;
- no real electricity-market calibration;
- stochastic RL results depend on initialization and training;
- no claim that DQN generally dominates MPC outside the reported experiment.

These limitations are retained deliberately because they define the next
research questions rather than being hidden.

---

## 16. Future Extensions

Natural extensions include:

- stochastic demand and forecast uncertainty;
- multiple strategic agents;
- continuous-action RL;
- explicit Nash / dynamic-game formulations;
- comparison with actor–critic algorithms;
- robust or stochastic MPC;
- market-price calibration from real electricity data;
- multi-agent reinforcement learning;
- sensitivity analysis of reward weights and prediction horizon.

---

## Repository Structure

```text
oligopoly-rl-nmpc-control/
├── README.md
├── matlab/
│   ├── README.md
│   ├── model/
│   │   ├── duopoly_dynamics.m
│   │   └── uncontrolled_simulation.m
│   ├── rl/
│   │   ├── train_dqn.m
│   │   ├── rl_step_function.m
│   │   ├── rl_reset_function.m
│   │   └── evaluate_dqn.m
│   └── mpc/
│       ├── run_nmpc.m
│       ├── nmpc_cost.m
│       └── build_rate_constraints.m
├── docs/
│   ├── methodology.md
│   └── references.md
└── results/
    ├── README.md
    ├── uncontrolled_dynamics.png
    ├── dqn_control_policy.png
    ├── nmpc_control_policy.png
    └── rl_vs_nmpc.png
```

---

## Technology Stack

**Language:** MATLAB  
**Dynamic simulation:** `ode45`  
**Reinforcement learning:** MATLAB Reinforcement Learning Toolbox  
**Deep learning:** DQN / neural Q-function approximation  
**Optimization:** `fmincon`, SQP  
**Control:** nonlinear MPC, receding horizon  
**Domain:** industrial production, oligopoly dynamics, electricity-market inspired demand

---

## Key Takeaway

The project demonstrates how the same nonlinear economic system can be viewed
through two complementary control paradigms:

> **learn a policy from interaction with the environment, or repeatedly solve
> the nonlinear decision problem online.**

More importantly, it shows how modelling assumptions determine whether a
control problem is meaningful at all: once static demand is replaced by a
time-varying market environment, the duopoly becomes a genuine dynamic
decision problem in which learning, optimization and economic incentives can be
compared directly.
