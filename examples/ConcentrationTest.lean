import FormalMartingales

open scoped NNReal ENNReal MeasureTheory ProbabilityTheory Topology

open ProbabilityTheory MeasureTheory

namespace FormalMartingales

variable {Ω : Type*} {m0 : MeasurableSpace Ω} {μ : Measure Ω}
  {𝒢 : Filtration ℕ m0} {X : ℕ → Ω → ℝ} {v : ℕ → ℝ} {theta : ℝ}

#check freedman_exponential_supermartingale_crossing

example [IsFiniteMeasure μ] [SigmaFiniteFiltration μ 𝒢]
    (he : EProcess (fun n ω => Real.exp (theta * X n ω - v n)) 𝒢 μ)
    (htheta : 0 < theta)
    {α : NNReal} (hα : 0 < α) :
    μ {ω | ∃ n : ℕ,
      Real.log (((α⁻¹ : NNReal) : ℝ)) + v n ≤ theta * X n ω} ≤
      (α : ℝ≥0∞) :=
  freedman_exponential_supermartingale_crossing (μ := μ) (𝒢 := 𝒢)
    (X := X) (v := v) (theta := theta) he htheta hα

end FormalMartingales
