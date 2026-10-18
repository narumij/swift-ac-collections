# Registry Studio同期の一コマンド化

## TL;DR（人間向け）

正本からStudioのtask・依存・親子・常設区分とJSON/HTMLを同期し、書込みなしの差分検知も行う試作を仕上げて受け入れた。属性削除・出典版変更・seed欠落の扱いを補修し、同期・既存検証・差分なしを確認した。当時はマイルストーンを既存JSONから持ち越す方式で、実画面や将来のゲート方式を保証するものではない。

2026-10-16 / Astra. OPS-057 under permanent OPS-048. The user requested the finishing assignment to Hime.

<a id="目的範囲"></a>
## Purpose and scope

Use sync.py from CP-20261016-007 to update tasks, edges, parentage, permanent categories, JSON, HTML seed, bundled documents and pending-numbering display from canonicals and run existing validation in one operation. --check detects missed synchronization without writing. Do not unintentionally lose current display attributes.

Carry milestones/relations forward from existing JSON; do not add derivation. Report carried-source mismatches rather than silently treating them as current. Gate-canonical/decision-archive method decisions and layout redesign are separate.

<a id="仕上げと確認"></a>
## Finishing and verification

- Check normal update/--check and detect task/dependency/parent/permanent/source differences and JSON/seed mismatch.
- Check whole milestone/relation quotations and source revisions; identify changes that cannot be automatically repaired rather than falsely reporting success.
- Allow actual Node/marked runtimes to be specified; distinguish failed/skipped generation or existing tests from successful completion.
- Avoid meaningless differences on rerun and explain what failures rewrite and how to recover.
- Document daily updates, carried-forward limitations and matching distributable HTML in README.

Return inputs, execution results, changed files and unsupported limits. No complete generalization is required; operate as a prototype repaired when needed within scope.

<a id="受渡し受入"></a>
## Handoff and acceptance

Formal assignment/occupancy is CLAUDE_TASK.md, OPS-057; Astra verifies after return. On 2026-10-16 Astra checked and accepted the return. User commit approval received; complete.

<a id="astra受入記録2026-10-16"></a>
## Astra acceptance record (2026-10-16)

Reviewed with Hime's original return preserved. Repaired detection of parent-attribute deletion and Rules revision/HEAD changes; milestone source changes no longer return normal success before verification. Missing seed is now a recoverable exception. Independently checked removed parentTask, changed Rules hash and no-change detection. Current-data synchronization and all existing verify.cjs checks passed; subsequent --check had no differences. Checked full existence of source quotations and updated hashes/line numbers for gate additions/link changes through this work. This does not establish actual-screen rendering verification.


## 根拠と更新条件の追記（2026-10-17 / 姫・Opus 5.5 / OPS-076第4区切り）

入力版`1175e583b1857819e9e0b07b83a1cb5fc8be657a`。本文・原返却は変えていない。確認は`git show <版>:…`等の固定treeの読み取りだけで、実行・再レビューはしていない。

| 主張 | 確認方法と結果（成立範囲） | 更新のきっかけ |
| --- | --- | --- |
| `sync.py`に書き込みなしの`--check`がある（7・13行目） | `Maintanance/RegistryApp/sync.py` 492行目に`if '--check' in sys.argv:`。分岐があることだけを確かめ、実行はしていない | `sync.py`の変更 |
| 生成物の置き場 | 版では`serve.py`がありサーバー実行型。生成HTMLは`Maintanance/Cache/RegistryStudio/`に出る（`.gitignore`の`/Maintanance/Cache/**`。ignoreの判定は作業ツリーの`git check-ignore`で見たもので、固定treeの事実は`.gitignore`の行だけ） | Studioの構成の変更 |
