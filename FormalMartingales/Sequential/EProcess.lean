/-
Copyright (c) 2026 Rob Sneiderman. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Rob Sneiderman
-/

import FormalMartingales.Martingale.Ville

/-! # E-values and e-processes

This file defines the sequential-testing API built on Ville's inequality.

An `EValue X μ` is an integrable nonnegative real random variable with
expectation at most one under `μ`. An `EProcess e 𝒢 μ` is a nonnegative
supermartingale whose initial value is an e-value. Ville's inequality then gives
the reusable type-I error guarantee for the level-`α` sequential test that
rejects when the process crosses `α⁻¹`.
-/

open scoped NNReal ENNReal MeasureTheory ProbabilityTheory Topology

open ProbabilityTheory MeasureTheory

namespace FormalMartingales

noncomputable section

variable {Ω : Type*} {m0 : MeasurableSpace Ω} {μ : Measure Ω}
  {𝒢 : Filtration ℕ m0} {X : Ω → ℝ} {e : ℕ → Ω → ℝ}

/-- An e-value is an integrable nonnegative real random variable with expectation
at most one under the reference measure. -/
structure EValue (X : Ω → ℝ) (μ : Measure Ω) : Prop where
  integrable : Integrable X μ
  nonneg : 0 ≤ X
  expectation_le_one : μ[X] ≤ 1

/-- An e-process is a nonnegative supermartingale whose initial value is an
e-value. -/
structure EProcess (e : ℕ → Ω → ℝ) (𝒢 : Filtration ℕ m0) (μ : Measure Ω) : Prop where
  supermartingale : Supermartingale e 𝒢 μ
  nonneg : 0 ≤ e
  start : EValue (e 0) μ

namespace EValue

/-- Nonnegativity of an e-value as an almost-everywhere statement. -/
theorem nonneg_ae (hX : EValue X μ) : 0 ≤ᵐ[μ] X :=
  Filter.Eventually.of_forall hX.nonneg

end EValue

namespace EProcess

/-- Build an e-process from the usual supermartingale, nonnegativity, and
initial-expectation hypotheses. -/
theorem of_supermartingale
    (hsuper : Supermartingale e 𝒢 μ) (hnonneg : 0 ≤ e)
    (hstart : μ[e 0] ≤ 1) : EProcess e 𝒢 μ :=
  { supermartingale := hsuper
    nonneg := hnonneg
    start :=
      { integrable := hsuper.integrable 0
        nonneg := hnonneg 0
        expectation_le_one := hstart } }

/-- The initial value of an e-process is an e-value. -/
theorem start_evalue (he : EProcess e 𝒢 μ) : EValue (e 0) μ :=
  he.start

/-- Every deterministic-time value of an e-process is an e-value. -/
theorem value_evalue [SigmaFiniteFiltration μ 𝒢]
    (he : EProcess e 𝒢 μ) (n : ℕ) : EValue (e n) μ := by
  refine ⟨he.supermartingale.integrable n, he.nonneg n, ?_⟩
  have hτ : IsStoppingTime 𝒢 (fun _ : Ω => (n : ℕ∞)) := isStoppingTime_const 𝒢 n
  have hbdd : ∀ ω : Ω, (fun _ : Ω => (n : ℕ∞)) ω ≤ n := by
    intro ω
    rfl
  have hle :=
    Supermartingale.expected_stoppedValue_le_start
      (μ := μ) (𝒢 := 𝒢) (f := e) he.supermartingale hτ hbdd
  change μ[e n] ≤ μ[e 0] at hle
  exact hle.trans he.start.expectation_le_one

/-- Type-I error control for the sequential test that rejects when an e-process
crosses the level `α⁻¹`. -/
theorem sequential_test_typeI [IsFiniteMeasure μ] [SigmaFiniteFiltration μ 𝒢]
    (he : EProcess e 𝒢 μ) {α : NNReal} (hα : 0 < α) :
    μ {ω | ∃ n : ℕ, ((α⁻¹ : NNReal) : ℝ) ≤ e n ω} ≤ (α : ℝ≥0∞) :=
  ville_inequality_of_integral_le_one
    he.supermartingale he.nonneg he.start.expectation_le_one hα

end EProcess

/-- Type-I error control for the level-`α` sequential test induced by an
e-process. -/
theorem eprocess_sequential_test_typeI
    [IsFiniteMeasure μ] [SigmaFiniteFiltration μ 𝒢]
    (he : EProcess e 𝒢 μ) {α : NNReal} (hα : 0 < α) :
    μ {ω | ∃ n : ℕ, ((α⁻¹ : NNReal) : ℝ) ≤ e n ω} ≤ (α : ℝ≥0∞) :=
  he.sequential_test_typeI hα

end

end FormalMartingales
