# Verification

This page records the local checks used for the current public theorem surface.

## Build

```bash
lake build
```

Expected result:

```text
Build completed successfully
```

## Example

```bash
lake env lean examples/EProcessTest.lean
```

Expected result: Lean type-checks the downstream-consumption example and prints
the checked theorem signatures for:

```text
FormalMartingales.ville_inequality
FormalMartingales.ville_inequality_of_integral_le_one
FormalMartingales.EValue
FormalMartingales.EProcess
FormalMartingales.EProcess.of_supermartingale
FormalMartingales.EProcess.value_evalue
FormalMartingales.eprocess_sequential_test_typeI
FormalMartingales.doob_maximal_ineq_exists_le_of_integral_le_one
```

## Axiom Footprint

```bash
lake env lean --stdin <<'EOF'
import FormalMartingales
#print axioms FormalMartingales.ville_inequality
#print axioms FormalMartingales.doob_maximal_ineq
#print axioms FormalMartingales.doob_maximal_ineq_expectation_bound
#print axioms FormalMartingales.doob_maximal_ineq_exists_le
#print axioms FormalMartingales.doob_maximal_ineq_exists_le_expectation_bound
#print axioms FormalMartingales.doob_maximal_ineq_of_integral_le_one
#print axioms FormalMartingales.doob_maximal_ineq_exists_le_of_integral_le_one
#print axioms FormalMartingales.EProcess.of_supermartingale
#print axioms FormalMartingales.EProcess.value_evalue
#print axioms FormalMartingales.EProcess.sequential_test_typeI
#print axioms FormalMartingales.eprocess_sequential_test_typeI
EOF
```

Expected result: each listed declaration depends only on:

```text
[propext, Classical.choice, Quot.sound]
```

## Proof-Gap Scan

```bash
rg -n "sorry|admit" FormalMartingales/Martingale/Doob.lean FormalMartingales/Sequential/EProcess.lean examples/EProcessTest.lean
```

Expected result: no matches.
