# Masyu — Constraint Modelling Case Study

## Objective

Formalize the Masyu puzzle as a declarative constraint system and use the IDP
reasoner for several forms of automated reasoning.

## Representation

The model contains:

```text
Pos
White(Pos)
Black(Pos)
Edge(Pos, Pos)
Reachable(Pos, Pos)
```

`Edge` represents the candidate loop and is constrained to be symmetric.

`Reachable` is defined inductively from `Edge`.

## Global Loop Constraints

The model requires:

- edges only between orthogonally adjacent cells;
- every grid cell to have degree 0 or 2;
- every pearl to lie on the loop;
- all loop cells to belong to one connected component.

The recursive reachability definition prevents the solver from satisfying the
local degree constraints with multiple disconnected loops.

## White Pearl Semantics

At a white pearl:

- the loop must pass straight through;
- at least one neighbouring loop cell must immediately turn.

Both horizontal and vertical cases are represented declaratively.

## Black Pearl Semantics

At a black pearl:

- the loop must turn by 90°;
- both neighbouring cells must continue straight.

The theory explicitly represents the four possible turn orientations.

## Model Expansion

Given a partial structure containing a grid and pearl configuration, IDP model
expansion produces complete interpretations of `Edge` satisfying the theory.

This acts as the puzzle solver.

## Minimal Unsatisfiable Search

The second reasoning task generates three-pearl configurations containing at
least one white and one black pearl.

A candidate is retained only when:

```text
full puzzle = UNSAT
```

and every one-pearl deletion gives:

```text
reduced puzzle = SAT
```

This is a direct search for minimal inconsistency.

## Optimization

For a loop constrained to exactly 16 visited cells, the project maximizes:

```text
number of white pearls + number of black pearls
```

subject to the complete Masyu theory.

This shows how the same declarative specification can be reused for
optimization rather than only feasibility.

## Counterexample Search

The bonus task searches for a valid pearl-containing loop of length 6.

If a model exists, it falsifies the claim that all valid loop lengths must be
divisible by 4.

This is an example of model-based counterexample generation.

## Portfolio Scope

The original coursework source is not included publicly. This document
describes the formal reasoning architecture and the kinds of inference
performed.
