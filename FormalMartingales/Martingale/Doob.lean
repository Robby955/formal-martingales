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
`MeasureTheory.maximal_ineq`; the declarations here wrap that theorem in the
owned namespace and prove the expectation-bound, crossing-event, and
probability-normalized finite-horizon forms.

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
  simpa using MeasureTheory.maximal_ineq (μ := μ) (𝒢 := 𝒢) (f := f) hsub hnonneg n

/-- Doob's finite-horizon maximal inequality with the integral over the
crossing event bounded by the terminal expectation. -/
theorem doob_maximal_ineq_expectation_bound [IsFiniteMeasure μ]
    (hsub : Submartingale f 𝒢 μ) (hnonneg : 0 ≤ f) {ε : ℝ≥0} (n : ℕ) :
    ε * μ {ω |
      (ε : ℝ) ≤ (range (n + 1)).sup' nonempty_range_add_one fun k => f k ω} ≤
    ENNReal.ofReal (μ[f n]) := by
  refine le_trans (doob_maximal_ineq (μ := μ) (𝒢 := 𝒢) (f := f) hsub hnonneg n) ?_
  exact ENNReal.ofReal_le_ofReal
    (setIntegral_le_integral (hsub.integrable n)
      (Filter.Eventually.of_forall fun ω => hnonneg n ω))

/-- Doob's finite-horizon maximal inequality with the crossing event written as
`∃ k ≤ n`. -/
theorem doob_maximal_ineq_exists_le [IsFiniteMeasure μ]
    (hsub : Submartingale f 𝒢 μ) (hnonneg : 0 ≤ f) {ε : ℝ≥0} (n : ℕ) :
    ε * μ {ω | ∃ k : ℕ, k ≤ n ∧ (ε : ℝ) ≤ f k ω} ≤
    ENNReal.ofReal
      (∫ ω in {ω |
          (ε : ℝ) ≤ (range (n + 1)).sup' nonempty_range_add_one fun k => f k ω},
        f n ω ∂μ) := by
  simpa [Finset.le_sup'_iff] using
    (doob_maximal_ineq (μ := μ) (𝒢 := 𝒢) (f := f) hsub hnonneg (ε := ε) n)

/-- Doob's finite-horizon maximal inequality in `∃ k ≤ n` form, with the
right-hand side bounded by the terminal expectation. -/
theorem doob_maximal_ineq_exists_le_expectation_bound [IsFiniteMeasure μ]
    (hsub : Submartingale f 𝒢 μ) (hnonneg : 0 ≤ f) {ε : ℝ≥0} (n : ℕ) :
    ε * μ {ω | ∃ k : ℕ, k ≤ n ∧ (ε : ℝ) ≤ f k ω} ≤
    ENNReal.ofReal (μ[f n]) := by
  simpa [Finset.le_sup'_iff] using
    (doob_maximal_ineq_expectation_bound (μ := μ) (𝒢 := 𝒢) (f := f)
      hsub hnonneg (ε := ε) n)

/-- Probability-normalized finite-horizon Doob inequality. If a nonnegative
submartingale has terminal expectation at most one, then the finite-horizon
level `α⁻¹` crossing event has measure at most `α`. -/
theorem doob_maximal_ineq_of_integral_le_one [IsFiniteMeasure μ]
    (hsub : Submartingale f 𝒢 μ) (hnonneg : 0 ≤ f) (n : ℕ)
    (hterminal : μ[f n] ≤ 1) {α : NNReal} (hα : 0 < α) :
    μ {ω | ((α⁻¹ : NNReal) : ℝ) ≤
      (range (n + 1)).sup' nonempty_range_add_one fun k => f k ω} ≤
    (α : ℝ≥0∞) := by
  let bad : Set Ω := {ω | ((α⁻¹ : NNReal) : ℝ) ≤
    (range (n + 1)).sup' nonempty_range_add_one fun k => f k ω}
  let ε : NNReal := α⁻¹
  have hdoob :
      ε * μ bad ≤ ENNReal.ofReal (μ[f n]) := by
    simpa [bad, ε] using
      doob_maximal_ineq_expectation_bound
        (μ := μ) (𝒢 := 𝒢) (f := f) hsub hnonneg (ε := ε) n
  have hterminal_enn : ENNReal.ofReal (μ[f n]) ≤ 1 := by
    simpa using (ENNReal.ofReal_le_ofReal hterminal)
  have hscaled : (α⁻¹ : NNReal) * μ bad ≤ 1 := hdoob.trans hterminal_enn
  have hmul : (α : ℝ≥0∞) * ((α⁻¹ : NNReal) * μ bad) ≤ (α : ℝ≥0∞) * 1 := by
    gcongr
  have hα_ne_zero : (α : ℝ≥0∞) ≠ 0 := by exact_mod_cast hα.ne'
  have hcoe_inv : ((α⁻¹ : NNReal) : ℝ≥0∞) = (α : ℝ≥0∞)⁻¹ := ENNReal.coe_inv hα.ne'
  have hcancel :
      (α : ℝ≥0∞) * ((α⁻¹ : NNReal) * μ bad) = μ bad := by
    rw [hcoe_inv]
    exact ENNReal.mul_inv_cancel_left (a := (α : ℝ≥0∞)) (b := μ bad)
      hα_ne_zero ENNReal.coe_ne_top
  change μ bad ≤ (α : ℝ≥0∞)
  rw [← hcancel]
  simpa using hmul

/-- Probability-normalized finite-horizon Doob inequality with the crossing
event written as `∃ k ≤ n`. -/
theorem doob_maximal_ineq_exists_le_of_integral_le_one [IsFiniteMeasure μ]
    (hsub : Submartingale f 𝒢 μ) (hnonneg : 0 ≤ f) (n : ℕ)
    (hterminal : μ[f n] ≤ 1) {α : NNReal} (hα : 0 < α) :
    μ {ω | ∃ k : ℕ, k ≤ n ∧ ((α⁻¹ : NNReal) : ℝ) ≤ f k ω} ≤
    (α : ℝ≥0∞) := by
  simpa [Finset.le_sup'_iff] using
    (doob_maximal_ineq_of_integral_le_one
      (μ := μ) (𝒢 := 𝒢) (f := f) hsub hnonneg n hterminal (α := α) hα)

end

end FormalMartingales
