# Task graph lint

## TL;DR（人間向け）

Task RegistryとTask precedenceの構造上の疑義（存在しないtaskへの参照・自己依存・重複・不正なFlow・循環など）を、自動修正しない読み取り専用のlintとして検出する仕組みの説明。taskの意味や採否はCodexとユーザーが判断し、0件でも意味上の健全性は証明しない。

Last updated: 2026-10-09 / Codex

<a id="目的"></a>
## Purpose

Detect structural doubts in the Task Registry and Task precedence as a read-only lint, not as a substitute for task judgments.
Codex and the user judge the meaning of the Registry, the necessity for goals, and whether to adopt tasks; this lint does not fix anything automatically.

<a id="実行"></a>
## Running

Run the following from the repository root.

```sh
sh Maintanance/Graph/TaskGraphLint/run.sh
sh Maintanance/Graph/TaskGraphLint/run_fixtures.sh
```

It loads the current Registry into an empty in-memory SQLite DB and prints the result to standard output. If there is even one `ERROR`
the exit status is 1, otherwise 0. A `WARNING` is an observation needing staged migration or a meaning check, and is not a failure.

<a id="初版の規則"></a>
## Rules of the first version

| severity | rule | meaning |
| --- | --- | --- |
| `ERROR` | `dangling_successor` / `dangling_prerequisite` | precedence refers to a task that is not in the Registry |
| `ERROR` | `self_dependency` | a task has itself as a prerequisite |
| `ERROR` | `duplicate_edge` | precedence for the same pair of tasks is duplicated |
| `ERROR` | `invalid_flow` | Flow is other than `SEQUENCE` or `PARALLEL_JOIN` |
| `ERROR` | `dependency_cycle` | the required dependencies contain a cycle |
| `WARNING` | `conditional_prerequisite` | a task that resumes 「場合だけ／場合に限り」 (only if / only when) is used as a required prerequisite |

The conditional check is a conservative natural-language heuristic; zero hits do not prove semantic soundness. Future rules
first get fixtures containing known violations and counterexamples, and are added after false positives are checked.

<a id="graph-019-完了記録"></a>
## GRAPH-019 completion record

- Uses the current Markdown directly as input, so it does not depend on a local DB or hand-made snapshots.
- SQLite uses only `:memory:` and creates no DB file in the repository.
- The lint does not rewrite the Registry or precedence.
- Normal and abnormal fixtures confirm PASS/FAIL and detection of the main ERROR rules.
- The first run confirmed 0 structural ERRORs and 8 WARNINGs for the existing `UNCLASSIFIED`. After that, every edge was classified individually and
  `UNCLASSIFIED` was removed from the current Flow.
