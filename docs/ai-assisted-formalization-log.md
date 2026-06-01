# AI-assisted formalization log

> Source: development record for this library. Author: Rob Sneiderman. Status: ongoing.

This log records where AI tools helped in building each result and where human mathematical judgment was still required. The aim is a running study of the division of labor in formal proof development: which parts of formalization current AI coding tools accelerate, and which parts still depend on a person who knows the mathematics and the proof assistant. Each entry is written as data for that study, not as a disclaimer.

The pattern across entries is the interesting object. If AI handles search and routine tactic plumbing while humans handle theorem selection, statement design, and the hard proof states, then the log should show that split sharpening over time as the results get harder.

---

## Entry 1: Ville's inequality

**Goal.** Formalize Ville's inequality for nonnegative supermartingales in Lean 4, in both finite-horizon and anytime forms, plus the probability-normalized corollaries used in sequential analysis.

**Where AI assistance was used.**

- Searching mathlib for the right lemmas: hitting times, optional-stopping bounds, the `tendsto_measure_iUnion_atTop` monotone-union limit, and the `ENNReal` coercion lemmas.
- Refactoring proof attempts: turning a first working-but-ugly proof state into the cleaner three-step structure (optional-stopping bound, finite horizon via hitting time, limit to anytime).
- Explaining Lean error messages: decoding elaboration and unification failures, especially around `ℝ≥0`, `ℝ≥0∞`, and the coercions between them.
- Suggesting proof skeletons: proposing tactic sequences for the set-equality rewrites between the `sup'` form and the `∃ k ≤ n` form of the crossing event.

**Where human work was required.**

- Theorem selection: deciding that Ville's inequality, specifically the nonnegative-supermartingale dual, was the right first result, and that the probability-normalized `α` forms were the ones downstream statistics would call.
- Mathematical validation: confirming the proof is genuinely the supermartingale argument through optional stopping, not an invalid sign flip of Doob's submartingale inequality.
- Checking assumptions: verifying that nonnegativity, finite measure, and the sigma-finite filtration hypotheses are each used and correctly placed, and that the bounded-stopping-time condition holds for the hitting time on a finite horizon.
- Adapting to mathlib's probability APIs: matching the statement shapes to the existing `maximal_ineq` conventions so the two inequalities compose, and choosing the namespace and public surface.
- Resolving failed proof states: the steps where suggested tactics did not close the goal and the proof had to be driven by hand, particularly the measurability side conditions and the final `ENNReal` cancellation.

**Outcome.** Around 320 lines, no proof gaps, `#print axioms` reduces to `[propext, Classical.choice, Quot.sound]` on every headline declaration. The result was first prepared as mathlib PR #40085, declined upstream, and relicensed into this library as its first entry.

**Observation for the study.** On a result of this difficulty, AI tools were strong on search and on local tactic suggestions but did not select the theorem, design the statements, or close the genuinely hard proof states without human direction. The measurability obligations and the coercion arithmetic were where suggested tactics most often failed and hand proof took over. That boundary is the thing this log will track as the later, harder results land.

**Theorem.** `ville_inequality` (anytime form), with the finite-horizon `ville_maximal_ineq`, the supporting optional-stopping bound `Supermartingale.expected_stoppedValue_le_start`, and the probability-normalized variants `ville_inequality_of_integral_le_one`, `ville_maximal_ineq_of_integral_le_one`, `ville_maximal_ineq_exists_le`, `ville_maximal_ineq_exists_le_of_integral_le_one`.

**File.** `FormalMartingales/Martingale/Ville.lean` (lines 70–318).

**Notable failure modes.** Suggested tactics most often broke on the measurability side conditions for the hitting time and on the final `ℝ≥0∞` cancellation; those steps were driven by hand. The result first went up as mathlib PR #40085 and was declined upstream before being relicensed here.

**Cross-references.** `MeasureTheory.maximal_ineq` (Doob's submartingale maximal inequality), `MeasureTheory.Submartingale.expected_stoppedValue_mono` (optional-stopping expectation bound), `Supermartingale.neg` (supermartingale to submartingale), `tendsto_measure_iUnion_atTop` (monotone-union measure limit), and the hitting-time API from `Mathlib.Probability.Martingale.OptionalStopping` (`hittingBtwn`, `isStoppingTime_hittingBtwn`, `hittingBtwn_le`, `stoppedValue_hittingBtwn_mem`).

---

Future entries appended chronologically as theorems land — Doob maximal inequality (planned), optional stopping (planned), Azuma–Hoeffding (planned), Freedman (planned).
