/-
Copyright (c) 2026 Rob Sneiderman. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Rob Sneiderman
-/

import Mathlib.Probability.Martingale.OptionalStopping
import Mathlib.Topology.Instances.ENNReal.Lemmas
import Mathlib.Topology.Order.OrderClosed

/-! # Doob's maximal inequality API spine

This file records the Doob-side API that the library will use next to Ville's
inequality. The core finite-horizon theorem already exists in mathlib as
`MeasureTheory.maximal_ineq`; the declarations here are statement skeletons
for the owned namespace and the downstream probability-normalized forms.

The intended proof path is to wrap `MeasureTheory.maximal_ineq`, convert the
maximal event to the `∃ k ≤ n` crossing form, and then apply the same
`ℝ≥0∞` algebra used by the probability-normalized Ville corollaries.

### References

* J. L. Doob, *Stochastic Processes*, Wiley, 1953.
* Mathlib theorem: `MeasureTheory.maximal_ineq`.
-/

open scoped NNReal ENNReal MeasureTheory ProbabilityTheory Topology

open Finset MeasureTheory ProbabilityTheory

namespace FormalMartingales

noncomputable section

variable {Ω : Type*} {m0 : MeasurableSpace Ω} {μ : Measure Ω}
  {𝒢 : Filtration ℕ m0} {f : ℕ → Ω → ℝ}

/-- Doob's finite-horizon maximal inequality for nonnegative submartingales,
restated in the `FormalMartingales` namespace. This is the direct wrapper target
for mathlib's `MeasureTheory.maximal_ineq`. -/
theorem doob_maximal_ineq [IsFiniteMeasure μ]
    (hsub : Submartingale f 𝒢 μ) (hnonneg : 0 ≤ f) {ε : ℝ≥0} (n : ℕ) :
    ε * μ {ω |
      (ε : ℝ) ≤ (range (n + 1)).sup' nonempty_range_add_one fun k => f k ω} ≤
    ENNReal.ofReal
      (∫ ω in {ω |
          (ε : ℝ) ≤ (range (n + 1)).sup' nonempty_range_add_one fun k => f k ω},
        f n ω ∂μ) := by
  sorry

/-- Doob's finite-horizon maximal inequality with the integral over the
crossing event bounded by the terminal expectation. -/
theorem doob_maximal_ineq_expectation_bound [IsFiniteMeasure μ]
    (hsub : Submartingale f 𝒢 μ) (hnonneg : 0 ≤ f) {ε : ℝ≥0} (n : ℕ) :
    ε * μ {ω |
      (ε : ℝ) ≤ (range (n + 1)).sup' nonempty_range_add_one fun k => f k ω} ≤
    ENNReal.ofReal (μ[f n]) := by
  sorry

/-- Doob's finite-horizon maximal inequality with the crossing event written as
`∃ k ≤ n`. -/
theorem doob_maximal_ineq_exists_le [IsFiniteMeasure μ]
    (hsub : Submartingale f 𝒢 μ) (hnonneg : 0 ≤ f) {ε : ℝ≥0} (n : ℕ) :
    ε * μ {ω | ∃ k : ℕ, k ≤ n ∧ (ε : ℝ) ≤ f k ω} ≤
    ENNReal.ofReal
      (∫ ω in {ω |
          (ε : ℝ) ≤ (range (n + 1)).sup' nonempty_range_add_one fun k => f k ω},
        f n ω ∂μ) := by
  sorry

/-- Doob's finite-horizon maximal inequality in `∃ k ≤ n` form, with the
right-hand side bounded by the terminal expectation. -/
theorem doob_maximal_ineq_exists_le_expectation_bound [IsFiniteMeasure μ]
    (hsub : Submartingale f 𝒢 μ) (hnonneg : 0 ≤ f) {ε : ℝ≥0} (n : ℕ) :
    ε * μ {ω | ∃ k : ℕ, k ≤ n ∧ (ε : ℝ) ≤ f k ω} ≤
    ENNReal.ofReal (μ[f n]) := by
  sorry

/-- Probability-normalized finite-horizon Doob inequality. If a nonnegative
submartingale has terminal expectation at most one, then the finite-horizon
level `α⁻¹` crossing event has measure at most `α`. -/
theorem doob_maximal_ineq_of_integral_le_one [IsFiniteMeasure μ]
    (hsub : Submartingale f 𝒢 μ) (hnonneg : 0 ≤ f) (n : ℕ)
    (hterminal : μ[f n] ≤ 1) {α : NNReal} (hα : 0 < α) :
    μ {ω | ((α⁻¹ : NNReal) : ℝ) ≤
      (range (n + 1)).sup' nonempty_range_add_one fun k => f k ω} ≤
    (α : ℝ≥0∞) := by
  sorry

/-- Probability-normalized finite-horizon Doob inequality with the crossing
event written as `∃ k ≤ n`. -/
theorem doob_maximal_ineq_exists_le_of_integral_le_one [IsFiniteMeasure μ]
    (hsub : Submartingale f 𝒢 μ) (hnonneg : 0 ≤ f) (n : ℕ)
    (hterminal : μ[f n] ≤ 1) {α : NNReal} (hα : 0 < α) :
    μ {ω | ∃ k : ℕ, k ≤ n ∧ ((α⁻¹ : NNReal) : ℝ) ≤ f k ω} ≤
    (α : ℝ≥0∞) := by
  sorry

end

end FormalMartingales
