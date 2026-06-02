# formal-martingales

[![CI](https://github.com/Robby955/formal-martingales/actions/workflows/ci.yml/badge.svg)](https://github.com/Robby955/formal-martingales/actions/workflows/ci.yml)
[![Lean](https://img.shields.io/badge/Lean-v4.30.0--rc2-blue.svg)](lean-toolchain)
[![mathlib](https://img.shields.io/badge/mathlib-25b7ac7-blue.svg)](https://github.com/leanprover-community/mathlib4/tree/25b7ac7d0cf8eef34ced5525f4a62b7613ad649b)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

> Classical result: Ville (1939). Lean development maintained under Apache 2.0.
> Author: Rob Sneiderman
> Status: Ville's inequality proved; finite-horizon Doob maximal API proved; e-value/e-process sequential-testing API proved; concentration and confidence-sequence constructions planned.

A Lean 4 library for martingale inequalities, anytime-valid inference, and concentration results. It depends on [mathlib](https://github.com/leanprover-community/mathlib4) and builds the supermartingale and time-uniform side of the theory that downstream statistical work needs.

The library imports mathlib's martingale infrastructure (Doob's maximal inequality, optional stopping, conditional expectation) as a dependency and adds the results that sequential analysis and statistical learning theory call for.

![Proof-chain dependency: mathlib's Doob maximal inequality and optional stopping feed Ville's inequality, the finite-horizon Doob API, and the proved e-value/e-process API; confidence sequences and concentration applications remain planned.](docs/figures/proof-chain.png)

## First result: Ville's inequality

For a nonnegative supermartingale `f` adapted to a filtration `𝒢` under a finite measure `μ`, and a level `ε ≥ 0`,

```
ε · μ {ω | ∃ n, ε ≤ f n ω}  ≤  E[f 0].
```

In words: the probability that a nonnegative supermartingale ever reaches level `ε`, at any time, is at most `E[f 0] / ε`. This is the anytime (time-uniform) form. It is the supermartingale dual of Doob's submartingale maximal inequality, and it does not follow by negating Doob, since negating a nonnegative supermartingale gives a submartingale that is no longer nonnegative. The proof goes through optional stopping at the hitting time of the level set, then passes from the finite horizon to the countable horizon.

The probability-normalized corollary is the shape used in sequential testing: if `E[f 0] ≤ 1`, then the event that `f` ever crosses level `α⁻¹` has measure at most `α`. That is the inequality behind e-values, e-processes, and confidence sequences.

See [`docs/ville.md`](docs/ville.md) for the full informal statement and formalization notes, [`docs/verification.md`](docs/verification.md) for the verification commands, and [`docs/roadmap.md`](docs/roadmap.md) for the theorem roadmap.

## Status

The repository is honest about what is proved and what is in progress.

- **Proved** (`FormalMartingales/Martingale/Ville.lean`): Ville's inequality in finite-horizon form (`ville_maximal_ineq`) and anytime form (`ville_inequality`), the supporting supermartingale optional-stopping bound (`Supermartingale.expected_stoppedValue_le_start`), and the probability-normalized corollaries (`*_of_integral_le_one`). Every headline declaration reduces to mathlib's standard axiom base only.
- **Proved** (`FormalMartingales/Martingale/Doob.lean`): the finite-horizon Doob maximal API, including the owned wrapper around mathlib's `MeasureTheory.maximal_ineq`, the terminal-expectation bound, `∃ k ≤ n` crossing forms, and probability-normalized corollaries. These declarations have no project-specific axioms.
- **Proved** (`FormalMartingales/Sequential/EProcess.lean`): the owned `EValue` and `EProcess` API, the deterministic-time result `EProcess.value_evalue`, the constructor `EProcess.of_supermartingale`, and the sequential-test type-I error theorem `eprocess_sequential_test_typeI`.
- **Planned**: time-uniform Azuma-Hoeffding, Freedman / Bernstein anytime bounds, richer e-process constructions, Howard-Ramdas style confidence sequences, and the time-uniform statistical-learning bounds that bridge to [FormalSLT](https://github.com/Robby955/FormalSLT).

## Using the library

A downstream development imports `FormalMartingales` and applies the shipped theorems. The worked file [`examples/EProcessTest.lean`](examples/EProcessTest.lean) derives the type-I error guarantee of an e-process sequential test from Ville's inequality, and a finite-horizon crossing bound from the Doob API:

```lean
import FormalMartingales

open scoped NNReal ENNReal MeasureTheory ProbabilityTheory Topology
open ProbabilityTheory Finset MeasureTheory

variable {Ω : Type*} {m0 : MeasurableSpace Ω} {μ : Measure Ω}
  {𝒢 : Filtration ℕ m0} {e : ℕ → Ω → ℝ}

/-- An e-process crosses `α⁻¹` with probability at most `α`, at any stopping rule. -/
theorem eprocess_sequential_test_typeI
    [IsFiniteMeasure μ] [SigmaFiniteFiltration μ 𝒢]
    (he : EProcess e 𝒢 μ) {α : NNReal} (hα : 0 < α) :
    μ {ω | ∃ n : ℕ, ((α⁻¹ : NNReal) : ℝ) ≤ e n ω} ≤ (α : ℝ≥0∞) :=
  FormalMartingales.eprocess_sequential_test_typeI he hα
```

Check it against the compiled library with `lake env lean examples/EProcessTest.lean`.

## Structure

```
FormalMartingales.lean                  -- top-level module, re-exports the library
FormalMartingales/Martingale/Doob.lean  -- finite-horizon Doob maximal API, proved
FormalMartingales/Martingale/Ville.lean -- Ville's inequality (finite-horizon + anytime, proved)
FormalMartingales/Sequential/EProcess.lean -- e-values, e-processes, sequential test API, proved
examples/EProcessTest.lean              -- downstream-consumption example
docs/                                   -- informal notes, verification, roadmap, figures
LICENSE                                 -- Apache 2.0
CITATION.cff                            -- citation metadata
```

All declarations live in the `FormalMartingales` namespace.

## Building

This project pins mathlib to a fixed revision and uses the matching Lean toolchain (`lean-toolchain`). With [`elan`](https://github.com/leanprover/elan) installed:

```bash
lake exe cache get   # fetch prebuilt mathlib oleans
lake build           # build the library
lake env lean examples/EProcessTest.lean   # type-check the example
```

CI runs the same steps on every push to `main` and every pull request, on Linux and macOS.

## Reproduce

The proved results are pinned to a fixed toolchain and mathlib revision, so a clean checkout
reproduces the same build and the same axiom footprint.

| Pin | Value |
| --- | --- |
| Commit | `7595261e` (this README's `main`) |
| Lean toolchain | `leanprover/lean4:v4.30.0-rc2` (`lean-toolchain`) |
| mathlib | `25b7ac7d0cf8` (`lake-manifest.json`) |

```bash
git clone https://github.com/Robby955/formal-martingales
cd formal-martingales
git checkout 7595261e
lake exe cache get
lake build
lake env lean examples/EProcessTest.lean
```

## Verification

The local verification commands are recorded in [`docs/verification.md`](docs/verification.md). The proved Ville declarations reduce to mathlib's standard axiom base only:

```
#print axioms FormalMartingales.ville_inequality
-- [propext, Classical.choice, Quot.sound]
```

The finite-horizon Doob API has the same axiom footprint. For example:

```
#print axioms FormalMartingales.doob_maximal_ineq_exists_le_of_integral_le_one
-- [propext, Classical.choice, Quot.sound]
```

The e-process sequential-test API has the same axiom footprint:

```
#print axioms FormalMartingales.eprocess_sequential_test_typeI
-- [propext, Classical.choice, Quot.sound]
```

## Citation

Citation metadata is in [`CITATION.cff`](CITATION.cff); GitHub renders a "Cite this repository" prompt from it. To cite directly:

```bibtex
@software{sneiderman_formal_martingales,
  author  = {Sneiderman, Rob},
  title    = {{formal-martingales}: Ville's inequality and anytime-valid martingale tools in Lean 4},
  year     = {2026},
  url      = {https://github.com/Robby955/formal-martingales},
  license  = {Apache-2.0}
}
```

## Contributing

Issues and pull requests are welcome. New declarations should reduce to mathlib's standard axiom
base, and CI (`lake build` plus the example type-check) must stay green.

## License

Apache 2.0. See [`LICENSE`](LICENSE).

## Part of TheoremPath

This library is part of [TheoremPath](https://theorempath.com), a portfolio of machine-checked
mathematics and statistical-learning work by [Rob Sneiderman](https://robbysneiderman.com). Its
planned concentration and confidence-sequence results bridge to the sibling
[FormalSLT](https://github.com/Robby955/FormalSLT) library.
