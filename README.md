# formal-martingales

> Source: Ville's inequality, adapted from PR #40085 (declined upstream; relicensed into this repo). Classical result: Ville (1939).
> Author: Rob Sneiderman
> Status: initial

A Lean 4 library for martingale inequalities, anytime-valid inference, and concentration results. It depends on [mathlib](https://github.com/leanprover-community/mathlib4) and builds the supermartingale and time-uniform side of the theory that downstream statistical work needs.

The library is owned and maintained here rather than upstreamed. It imports mathlib's martingale infrastructure (Doob's maximal inequality, optional stopping, conditional expectation) as a dependency and adds the results that sequential analysis and statistical learning theory call for.

## First result: Ville's inequality

For a nonnegative supermartingale `f` adapted to a filtration `𝒢` under a finite measure `μ`, and a level `ε ≥ 0`,

```
ε · μ {ω | ∃ n, ε ≤ f n ω}  ≤  E[f 0].
```

In words: the probability that a nonnegative supermartingale ever reaches level `ε`, at any time, is at most `E[f 0] / ε`. This is the anytime (time-uniform) form. It is the supermartingale dual of Doob's submartingale maximal inequality, and it does not follow by negating Doob, since negating a nonnegative supermartingale gives a submartingale that is no longer nonnegative. The proof goes through optional stopping at the hitting time of the level set, then passes from the finite horizon to the countable horizon.

The probability-normalized corollary is the shape used in sequential testing: if `E[f 0] ≤ 1`, then the event that `f` ever crosses level `α⁻¹` has measure at most `α`. That is the inequality behind e-values, e-processes, and confidence sequences.

See [`docs/ville.md`](docs/ville.md) for the full informal statement and formalization notes, and [`docs/roadmap.md`](docs/roadmap.md) for the planned theorem sequence.

## Structure

```
FormalMartingales.lean                 -- top-level module, re-exports the library
FormalMartingales/Martingale/Ville.lean -- Ville's inequality (finite-horizon + anytime forms)
docs/                                   -- informal notes, roadmap, formalization log
```

All declarations live in the `FormalMartingales` namespace.

## Building

This project pins mathlib to a fixed revision and uses the matching Lean toolchain (`lean-toolchain`). With [`elan`](https://github.com/leanprover/elan) installed:

```bash
lake exe cache get   # fetch prebuilt mathlib oleans
lake build           # build the library
```

## Verification

Every headline declaration reduces to mathlib's standard axiom base only:

```
#print axioms FormalMartingales.ville_inequality
-- [propext, Classical.choice, Quot.sound]
```

No project-specific axioms. No proof gaps.

## License

Apache 2.0. See [`LICENSE`](LICENSE).
