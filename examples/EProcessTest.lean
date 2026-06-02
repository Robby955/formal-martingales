/-
Copyright (c) 2026 Rob Sneiderman. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Rob Sneiderman
-/

import FormalMartingales

/-! # Example: an e-process gives a level-`α` sequential test

This file shows how a downstream development (for instance a sequential-analysis
layer, or the FormalSLT statistical-learning library) consumes the proved
martingale bounds from `formal-martingales`. It imports the library and uses the
shipped theorems directly; nothing here reproves anything.

An e-process is a nonnegative supermartingale `e` whose starting expectation is
at most one. The matching level-`α` sequential test rejects the null the first
time `e` reaches `α⁻¹`. The statement below is the test's type-I error
guarantee: the chance that `e` ever crosses `α⁻¹`, at any stopping time the
analyst might choose, is at most `α`. That bound is exactly Ville's inequality
in its probability-normalized anytime form.

Build this file on its own against the compiled library with:

```bash
lake env lean examples/EProcessTest.lean
```
-/

open scoped NNReal ENNReal MeasureTheory ProbabilityTheory Topology
open ProbabilityTheory Finset MeasureTheory

namespace FormalMartingales.Examples

variable {Ω : Type*} {m0 : MeasurableSpace Ω} {μ : Measure Ω}
  {𝒢 : Filtration ℕ m0} {e g : ℕ → Ω → ℝ}

/-- Type-I error of the e-process test. For an e-process `e` (a nonnegative
supermartingale with `μ[e 0] ≤ 1`) and a level `α ∈ (0, 1]`, the event that `e`
ever reaches `α⁻¹` has measure at most `α`. The bound holds simultaneously over
every time, so it controls the error of a sequential test that may stop on any
rule. Proved by applying the library's anytime Ville inequality. -/
theorem eprocess_sequential_test_typeI
    [IsFiniteMeasure μ] [SigmaFiniteFiltration μ 𝒢]
    (hsuper : Supermartingale e 𝒢 μ) (hnonneg : 0 ≤ e)
    (hstart : μ[e 0] ≤ 1) {α : NNReal} (hα : 0 < α) :
    μ {ω | ∃ n : ℕ, ((α⁻¹ : NNReal) : ℝ) ≤ e n ω} ≤ (α : ℝ≥0∞) :=
  ville_inequality_of_integral_le_one hsuper hnonneg hstart hα

/-- Finite-horizon Doob crossing bound for a nonnegative submartingale whose
terminal expectation is at most one. -/
theorem submartingale_finite_horizon_crossing_bound
    [IsFiniteMeasure μ]
    (hsub : Submartingale g 𝒢 μ) (hnonneg : 0 ≤ g) (n : ℕ)
    (hterminal : μ[g n] ≤ 1) {α : NNReal} (hα : 0 < α) :
    μ {ω | ∃ k : ℕ, k ≤ n ∧ ((α⁻¹ : NNReal) : ℝ) ≤ g k ω} ≤
    (α : ℝ≥0∞) :=
  doob_maximal_ineq_exists_le_of_integral_le_one hsub hnonneg n hterminal hα

-- A quick check that the library surface is what a consumer expects.
#check @FormalMartingales.ville_inequality
#check @FormalMartingales.ville_inequality_of_integral_le_one
#check @FormalMartingales.doob_maximal_ineq_exists_le_of_integral_le_one

end FormalMartingales.Examples
