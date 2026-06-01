import Lake
open Lake DSL

package «formal-martingales» where
  -- Lean 4 library for martingale inequalities, anytime-valid inference,
  -- and concentration results. Depends on mathlib; not an upstream PR.

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "25b7ac7d0cf8eef34ced5525f4a62b7613ad649b"

@[default_target]
lean_lib FormalMartingales where
  roots := #[`FormalMartingales]
