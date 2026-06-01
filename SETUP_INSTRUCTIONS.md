# Setup: pushing formal-martingales to GitHub

This repo is bootstrapped, built, and committed locally. One step remains, and it is the one step that must be run by Rob, not by an automated session: creating the GitHub repo and pushing.

## Run this to publish

```bash
cd ~/Projects/formal-martingales
git log --oneline   # sanity check: should show 1 commit on main, clean tree
gh repo create Robby955/formal-martingales \
  --public \
  --source=. \
  --remote=origin \
  --push \
  --description "Lean 4 library for martingale inequalities, anytime-valid inference, and concentration results. Depends on mathlib."
```

## This repo is PUBLIC, on purpose

Note the `--public` flag. This is deliberate and different from `research-ops-stack`, which is private.

`formal-martingales` is the portfolio piece. It is meant to be visible: a public Lean library, owned and maintained, that shows a verified theorem with a clean axiom footprint and a stated roadmap. Making it private would defeat its purpose. Do not switch the flag to `--private`.

If you want a moment to review before it goes public, the safe order is: read `README.md`, skim `docs/`, run `lake build` once to confirm it compiles on your machine, then run the command above.

## What is already done

- Project bootstrapped against mathlib, pinned to revision `25b7ac7d0cf8eef34ced5525f4a62b7613ad649b` and toolchain `leanprover/lean4:v4.30.0-rc2` (the revision the Ville proof was verified against).
- `lake build` passes end to end (2525 jobs).
- `#print axioms` on every headline declaration is `[propext, Classical.choice, Quot.sound]`.
- One commit on `main`, authored by `robbysneiderman@gmail.com`.
- No remote configured yet, nothing pushed. The command above adds the remote and pushes.

## After the push

The build on a fresh clone needs `lake exe cache get` before `lake build`, since `.lake/` is gitignored. The committed `lake-manifest.json` pins every dependency revision, so a clone reproduces the exact build.
