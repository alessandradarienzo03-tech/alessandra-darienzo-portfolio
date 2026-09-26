# Sokoban — Temporal Reasoning Case Study

## Objective

Model a dynamic Sokoban variant using Linear Time Calculus (LTC).

The environment contains:

- walls;
- floor cells;
- target cells;
- ice cells;
- one player;
- one or more boxes.

The objective is reached when every box occupies a target.

## Time-Dependent State

The formal state contains symbols for:

```text
PlayerAt(Time)
BoxAt(Time, Box)
CanMove(Time, Direction)
PlayerSliding(Time, Direction)
BoxSliding(Time, Box, Direction)
Completed(Time)
```

The model therefore reasons explicitly about how the world changes from one
time point to the next.

## Player Actions

At each non-sliding step the player can:

- move up;
- move down;
- move left;
- move right;
- remain stationary.

Actions must satisfy collision, boundary and box-pushing constraints.

## Box Pushing

A box may be pushed only if:

```text
player moves toward box
and
cell behind box is free
```

The box moves one cell and the player takes the box's previous position.

## Player Sliding

Entering an ice tile starts automatic motion.

While sliding, the player:

- moves one tile per time step;
- retains the same direction;
- cannot choose another movement action.

Sliding terminates on leaving the ice or when continuation is blocked.

## Box Sliding

Boxes pushed onto ice also move automatically.

Unlike the player, a sliding box may stop spontaneously.

The transition relation must therefore allow both:

```text
BoxSliding(t+1)
```

and:

```text
not BoxSliding(t+1)
```

when both are physically permitted.

## Coupled Dynamics

The specification must also model interactions between independently evolving
objects.

Examples include:

- no transfer of momentum;
- a stopped box can force a following player to stop;
- a sliding object may be blocked by another box;
- completion disables subsequent movement.

## Inference Perspective

The LTC model can support:

- finite model expansion;
- interactive simulation;
- scripted simulation;
- planning-like reasoning;
- lightweight verification.

## Publication Constraint

The course specification explicitly states that the Sokoban project is not
open source and that solution code may not be placed in a public repository.

For this reason, the portfolio contains only this conceptual description and
does not publish the submitted `.idp` solution.
