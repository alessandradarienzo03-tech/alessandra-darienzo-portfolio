# Symbolic AI & Constraint Reasoning

**Declarative Modelling with IDP3 / FO(·)**

A compact symbolic-AI portfolio project built from two formal-modelling case
studies developed in the KU Leuven *Modelling of Complex Systems* course.

Rather than learning patterns from data, these projects specify the rules of a
problem explicitly and use a reasoning engine to:

- generate models satisfying logical constraints;
- detect unsatisfiable configurations;
- solve optimization problems;
- search for counterexamples;
- model state transitions over time;
- reason under non-deterministic dynamics.

> **Publication note:** the original course-submission code is intentionally
> not included in this public repository. The Sokoban assignment explicitly
> prohibits publishing the solution code online. The Masyu implementation is
> likewise documented conceptually here until publication permission is
> confirmed.

---

## Why This Project Matters

Most projects in this portfolio use statistical learning, optimization,
reinforcement learning or numerical simulation.

This project adds a different AI paradigm:

```text
data-driven AI
learn patterns from observations

vs.

symbolic AI
encode knowledge explicitly and reason over it
```

The two case studies illustrate how formal logic can be used for both static
constraint problems and dynamic systems.

---

# Case Study 1 — Masyu: Constraint Modelling, Optimization & Counterexamples

Masyu is a loop-based logic puzzle defined on a rectangular grid containing
black and white pearls.

The task is to construct a **single connected non-branching loop** satisfying
different local geometric rules depending on the pearl type.

The project formalizes the puzzle in IDP3 using first-order logic with
inductive definitions.

## Core Logical Model

The public documentation focuses on the reasoning structure rather than the
submitted source code.

The model represents:

- grid positions;
- black and white pearls;
- undirected loop edges;
- loop connectivity;
- local pearl constraints.

### Loop geometry

Edges may connect only orthogonally adjacent cells.

Every position has degree:

```text
0  -> outside the loop
2  -> part of the loop
```

This excludes branching and ensures each loop cell has exactly two incident
edges.

### Connectivity

A recursive `Reachable` relation defines the transitive closure of the edge
relation.

All cells with degree two must be mutually reachable, forcing all selected
edges to belong to one connected loop instead of multiple disjoint cycles.

### Pearl constraints

The loop must pass through every pearl.

For a **white pearl**:

```text
the path passes straight through the pearl
and turns immediately before or after it
```

For a **black pearl**:

```text
the path turns 90° at the pearl
and continues straight through both adjacent cells
```

These local rules are combined with the global connectivity theory.

---

## Reasoning Task 1 — Model Expansion

The base puzzle theory is solved through **model expansion**.

Given:

```text
grid structure
+ pearl positions
+ formal Masyu theory
```

the IDP reasoner generates loop configurations that satisfy every constraint.

Conceptually:

```text
formal rules + partial structure
            ↓
        model expansion
            ↓
valid Masyu loop(s)
```

This is declarative problem solving: the implementation specifies *what* a
valid loop is rather than coding a procedural search algorithm.

---

## Reasoning Task 2 — Minimal Unsatisfiable Pearl Configurations

A second task searches for a configuration containing exactly three pearls
such that:

```text
the full three-pearl puzzle has no solution
```

but:

```text
removing any one pearl makes the puzzle solvable
```

This is a search for a **minimal unsatisfiable configuration**.

The reasoning workflow is:

```text
generate candidate 3-pearl configuration
        ↓
check full puzzle with model expansion
        ↓
if UNSAT:
    remove pearl 1 → check SAT
    remove pearl 2 → check SAT
    remove pearl 3 → check SAT
        ↓
accept only if every reduced puzzle is satisfiable
```

This goes beyond ordinary puzzle solving: the system reasons about the
structure of *inconsistency itself*.

---

## Reasoning Task 3 — Optimization

The third task constrains the Masyu loop to visit exactly **16 cells** and asks
the solver to maximize the number of pearls that can simultaneously satisfy
the puzzle rules.

The objective can be expressed conceptually as:

```text
maximize
    number of black + white pearls

subject to
    valid connected Masyu loop
    loop length = 16
```

This turns the logical theory into a declarative optimization problem.

---

## Bonus — Counterexample Generation

The bonus task tests a general claim about possible loop lengths.

Rather than proving the statement directly, the model attempts to generate a
valid Masyu loop whose length violates the proposed divisibility property.

Conceptually:

```text
hypothesis:
    every valid loop length is divisible by 4

search:
    valid loop
    length = 6
    at least one pearl
        ↓
model exists?
        ↓
yes → counterexample found
```

This is a compact example of **automated falsification** using model
generation.

---

# Case Study 2 — Sokoban: Temporal & Non-Deterministic Reasoning

The second project models a variant of Sokoban with **Linear Time Calculus
(LTC)**.

Unlike Masyu, which is mainly a static constraint system, Sokoban requires
explicit reasoning about:

- time;
- actions;
- state transitions;
- inertia;
- automatic dynamics;
- non-determinism.

## State Representation

The model includes time-dependent symbols for:

- player position;
- box positions;
- available moves;
- player sliding direction;
- box sliding direction;
- completion status.

Static information includes:

- walls;
- targets;
- ice tiles;
- grid geometry.

---

## Action Semantics

At every time point the player may:

- move up, down, left or right;
- remain still.

Movement is permitted only when the destination satisfies the game rules.

Boxes can be pushed when the square behind them is free.

Once the puzzle is completed, further movement is disabled.

---

## Ice Dynamics

Ice introduces autonomous state evolution.

### Player

When the player enters an ice tile:

```text
start sliding
→ move one cell per time step
→ no new manual action while sliding
```

Sliding stops when the player:

- leaves the ice;
- reaches a wall;
- reaches the grid boundary;
- encounters a non-sliding box.

### Boxes

A pushed box entering ice also slides automatically.

However, the box differs from the player because it may
**non-deterministically stop** while still on ice.

The theory must therefore allow two possible successor states:

```text
continue sliding
or
stop sliding
```

This makes the model an example of reasoning over non-deterministic temporal
dynamics.

---

## Interaction Effects

The assignment also introduces subtle coupled behaviour.

For example:

- momentum is not transferred from one sliding object to another;
- when a box stops directly in front of a sliding player, the player must also
  stop;
- sliding objects evolve automatically without a user-selected move.

These rules require explicit temporal modelling rather than ordinary static
constraints.

---

## Reasoning Tasks

The LTC theory can support several inference modes:

```text
finite model expansion
interactive simulation
scripted simulation
planning-style reasoning
verification-style reasoning
```

The main goal of the project is not to implement a game engine procedurally,
but to define the transition semantics formally enough that the reasoning
system can infer valid evolutions.

---

# Methods Demonstrated

Across both case studies, the project covers:

- first-order logic;
- inductive definitions;
- recursive reachability;
- graph connectivity;
- model expansion;
- satisfiability / unsatisfiability reasoning;
- minimal-unsatisfiable configuration search;
- declarative optimization;
- counterexample generation;
- temporal logic;
- state-transition modelling;
- action preconditions;
- inertia;
- non-deterministic transitions;
- interactive simulation.

---

# Repository Structure

```text
symbolic-ai-constraint-reasoning/
├── README.md
└── docs/
    ├── masyu_case_study.md
    └── sokoban_case_study.md
```

The original `.idp` assignment submissions are intentionally excluded from the
public repository.

---

# Technology

**Language / formalism:** IDP3, FO(·), LTC  
**Paradigm:** symbolic AI / knowledge representation and reasoning  
**Core operations:** model expansion, optimization, counterexample search,
temporal simulation

---

# Key Takeaway

These projects demonstrate a different way of building intelligent systems:

> **instead of fitting a model to observations, define the structure of the
> world explicitly and let a reasoning engine derive the consequences.**

Masyu shows how logic can encode graph structure, consistency and
optimization.

Sokoban extends the same declarative philosophy to dynamic systems with
actions, time and non-deterministic behaviour.
