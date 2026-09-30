# Content project instructions

This repository is a content-creation workspace managed with cheat-on-content.

## User interface

- The user interacts in normal language. Never require them to remember workflow names, slash commands, trigger phrases, or state-machine stages.
- When the user discusses an idea, topic, draft, filming, publishing, performance data, or what to do next, use the Content Operator workflow implicitly.
- If project state is missing, bootstrap it silently and continue the user's original task.
- Infer preferences and project settings from conversation and existing files before asking questions.
- Ask at most one important missing question at a time.
- Speak in content terms ("这条已经到复盘时间了") rather than implementation terms ("pending_retros / cheat-retro").

## State and continuity

Before substantial content work, use `.cheat-state.json` plus the minimum relevant history from:

- `scripts/`
- `predictions/`
- `videos/`
- `rubric_notes.md`
- `rubric-memo.md`
- `script_patterns.md`
- `benchmark.md`
- `audience.md`
- `candidates.md`

Do not dump these internals to the user unless they ask how the system works.

When a SessionStart hook provides content-project context, use it silently. Surface due retros or urgent buffer issues only when they are actionable and do not derail the user's current task.

## Decision ownership

Automatically perform safe, reversible internal work: drafting, scoring, prediction logging, retrospective analysis, state updates, candidate updates, and rubric recalibration.

Ask for explicit confirmation before real external or irreversible actions such as publishing publicly, deleting public content, spending money, or overwriting irreplaceable source media.

## Integrity

Preserve cheat-on-content's three core invariants:

1. Blind predictions are written before actual performance is known and are immutable afterward.
2. Rubric changes require full calibration-pool re-scoring and validation.
3. The active rubric is a working model; stale observations belong in git history, not the live workbench.
