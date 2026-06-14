/-
Copyright (c) 2026 Rob Sneiderman. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Rob Sneiderman
-/

import FormalMartingales.Sequential.EProcess
import Mathlib.Analysis.SpecialFunctions.Log.Basic

/-! # Exponential-supermartingale concentration

This file adds the concentration layer used by downstream martingale and statistical-learning
arguments. The main theorem is the standard exponential-supermartingale crossing step behind
Freedman/Bernstein bounds: if `exp (theta * X n - v n)` is an e-process, then `X` crosses the
corresponding logarithmic boundary with probability at most `alpha`.
-/

open scoped NNReal ENNReal MeasureTheory ProbabilityTheory Topology

open ProbabilityTheory MeasureTheory

namespace FormalMartingales

noncomputable section

variable {Ω : Type*} {m0 : MeasurableSpace Ω} {μ : Measure Ω}
  {𝒢 : Filtration ℕ m0} {X : ℕ → Ω → ℝ} {v : ℕ → ℝ} {theta : ℝ}

/-- Time-uniform exponential-supermartingale concentration bound. If `0 < theta` and
`exp (theta * X n - v n)` is an e-process, then the event that `X` crosses the
Freedman/Bernstein logarithmic boundary in multiplication form has measure at most `alpha`.

This is the abstract crossing step used in Freedman/Bernstein arguments after the exponential
process has been constructed. -/
theorem freedman_exponential_supermartingale_crossing
    [IsFiniteMeasure μ] [SigmaFiniteFiltration μ 𝒢]
    (he : EProcess (fun n ω => Real.exp (theta * X n ω - v n)) 𝒢 μ)
    (_htheta : 0 < theta) {α : NNReal} (hα : 0 < α) :
    μ {ω | ∃ n : ℕ,
      Real.log (((α⁻¹ : NNReal) : ℝ)) + v n ≤ theta * X n ω} ≤
      (α : ℝ≥0∞) := by
  refine le_trans (measure_mono ?_) (eprocess_sequential_test_typeI (μ := μ) he hα)
  intro ω hω
  rcases hω with ⟨n, hn⟩
  refine ⟨n, ?_⟩
  have hlevel_pos : 0 < (((α⁻¹ : NNReal) : ℝ)) := by
    exact_mod_cast inv_pos.mpr hα
  have hlinear :
      Real.log (((α⁻¹ : NNReal) : ℝ)) ≤ theta * X n ω - v n := by
    linarith
  have hexp :
      Real.exp (Real.log (((α⁻¹ : NNReal) : ℝ))) ≤
        Real.exp (theta * X n ω - v n) :=
    (Real.exp_le_exp).mpr hlinear
  rw [Real.exp_log hlevel_pos] at hexp
  exact hexp

end

end FormalMartingales
