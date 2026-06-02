# Ville's inequality

> Classical result: Ville (1939). Lean development maintained under Apache 2.0.
> Author: Rob Sneiderman
> Status: proved (finite-horizon + anytime forms)

## Informal statement

Let `f = (f n)` be a nonnegative supermartingale adapted to a filtration `𝒢` on a probability space `(Ω, μ)`. For any level `ε > 0`,

```
μ ( sup over all n of f n  ≥  ε )  ≤  E[f 0] / ε.
```

The supremum is taken over the whole trajectory, so the bound holds uniformly in time. There is also a finite-horizon version that bounds the running maximum `max over k ≤ n of f k`, and the anytime version is recovered from it by letting the horizon grow.

The probability-normalized corollary is the form used in practice. If `E[f 0] ≤ 1`, then for any `α ∈ (0, 1]`,

```
μ ( sup over all n of f n  ≥  1/α )  ≤  α.
```

## Why it matters

A supermartingale with starting expectation at most one and the property above is exactly an e-process. Ville's inequality is what turns such a process into a valid sequential test: a level `α` test rejects when the process first crosses `1/α`, and the inequality controls the type-I error uniformly over every stopping rule the analyst might use. The same bound, inverted, produces confidence sequences whose coverage holds at every sample size at once rather than at a single fixed `n`. This is the backbone of anytime-valid inference, where an experimenter may peek at the data and stop whenever they like without inflating error.

Doob's submartingale maximal inequality, which mathlib already has, is the dual statement. The two read as a matched pair: Doob bounds how high a submartingale climbs, Ville bounds how high a nonnegative supermartingale climbs. The directions are genuinely different, since negating a nonnegative supermartingale produces a submartingale that loses nonnegativity, so one inequality does not transfer to the other by sign flip.

## Formalization notes

The proof reuses mathlib's martingale machinery rather than rebuilding it. The dependency surface is:

- `Mathlib.Probability.Martingale.OptionalStopping` for optional stopping and hitting times.
- `Supermartingale.neg` and `Submartingale.expected_stoppedValue_mono` for the stopped-value bound.
- conditional expectation and the filtration API underneath both.

The argument has three moves. First, a supermartingale optional-stopping bound: the expected value at a bounded stopping time is at most `E[f 0]`. Second, the hitting time of the level set `{y | ε ≤ y}` is a bounded stopping time on the finite horizon, and on the crossing event the stopped value is at least `ε`, which gives the finite-horizon inequality. Third, the finite-horizon crossing events increase to the anytime crossing event, so `tendsto_measure_iUnion_atTop` lifts the bound to the countable horizon.

The Lean statements mirror the shapes mathlib uses for Doob (`ε * μ {... sup' ...} ≤ ENNReal.ofReal (E[f 0])`) so the two inequalities compose cleanly. The headline declaration is `FormalMartingales.ville_inequality`; the probability-normalized forms carry the `_of_integral_le_one` suffix.

Around 320 lines, no proof gaps, axioms `[propext, Classical.choice, Quot.sound]` only.

## Reference

J. Ville, *Étude critique de la notion de collectif*, Gauthier-Villars, Paris, 1939.
