# 正本冒頭に確定範囲と未確認事項を示す

## TL;DR（人間向け）

受入済み対象・証拠・未確認・次の確認点を正本冒頭へ示す形式を、4文書で試して補正付き受入した記録。本文と履歴を保持し、状態の正本はRegistryへ一元化する。全正本への展開や未確認事項の追加検証は、この試行の完了に含めない。

2026-10-17 / OPS-066 / Author Astra. User instruction: 「1と4をあすとらさんがタスク化して、4はユーザー判断にしといて」.

<a id="目的と境界"></a>
## Purpose and boundaries

Interview improvement proposal 1: briefly put accepted scope, evidence commits, unknowns and next check at the start of canonical documents. Registered as a limited trial candidate; body edits were initially unstarted. Later trial/acceptance are recorded below. No duplicated Registry states or bulk migration.

<a id="入力"></a>
## Inputs

[Operational interview](TASK_REGISTRY_OPERATION_INTERVIEW.md) and its Astra/Fable responses: proposals, not permission to change specific authority/contracts.

<a id="完了条件"></a>
## Completion criteria

After fixing targets/scope and starting, present accepted scope/evidence/unknowns/next check at the beginning while preserving history. Compare existing canonicals and evidence access. Current task states stay exclusively in Registry.

<a id="形式試行2026-10-17--fable"></a>
## Format (trial, 2026-10-17 / Fable)

Place one quotation immediately after title, without a new heading or moving prior body/history.

> **確定範囲（日付、OPS-066試行）** 受入済み：何を誰が受け入れたか。証拠：commit hash・証拠の置き場。未確認：やっていないこと。次の確認点：次に見るべき一つ。状態の正本はRegistry。

- Do not repeat ACTIVE/DONE states; only Registry rows carry them.
- Specify accepted target/acceptor (「対象」「受入者」); self-acceptance includes user instruction.
- Evidence: commit hash/directory, no repeated body text.
- On change, do not overwrite without history. Append reason/evidence at end, then correct only affected phrases; retain invalidation as 「〜で失効」.

<a id="試行2026-10-17--fableユーザーops-066をやって"></a>
## Trial (2026-10-17 / Fable; user 「OPS-066をやって」)

Four completed canonicals: two known directly to Fable and two from others with acceptance at end, to compare whether opening blocks expose scope/unknowns without reading to the end.

| Canonical | Task | Evidence |
| --- | --- | --- |
| `REGISTRY_STUDIO_MILESTONE_CONNECT.md` | OPS-061 | Fable's work, commit `9ddb150f` |
| `REGISTRY_STUDIO_SINGLE_LINE_KIND.md` | OPS-062 | Fable's work, commit `9ddb150f` |
| `ASAN_STRIP_ENV_FIXED_REVISION_VALIDATION.md` | RBT-049 | Copied from 「Codex受入（2026-10-17）」 and final Linux section, commits `46d50288` / `7a092b72` |
| `RED_BLACK_TREE_DOCC_PREVIEW_REVIEW.md` | DOC-045 | Copied from completion/scope sections, commit `039b2141` |

Other owners' two blocks copy existing facts, with no new validation. Registry rows/states unchanged. No full rollout within this task.

Trial acceptance request: user specified Astra acceptance of format/four contents on 2026-10-17. After checking, decide whether OPS-066 is DONE or expansion belongs to a separate task.

<a id="astra受入2026-10-17"></a>
## Astra acceptance (2026-10-17)

At user request, compared all four opening blocks with body, prior acceptance and referenced commits. Confirmed prior text retained at trial commit `25518fdd1`, four evidence commits resolve and RBT-049 evidence directory exists.

Corrections at acceptance:
- RBT-049: explicit default failure/strip_env=0 success, distinguishing unperformed fixed-Linux comparison from separate candidate-CI success report.
- DOC-045: narrowed API⇄guide wording to actual inspected paths from type pages to representative APIs/common guides.
- This document: initial unstarted status explicitly historical; clarified updating only affected block phrases after appending reasons/evidence at the end.

Accepted as a format distinguishing accepted scope/evidence/unknowns/next check, with status canonical in Registry. Only four-document trial; no broader rollout or additional verification. No product-test/browser reruns or expansion of earlier validation claims.

## 根拠と更新条件の追記（2026-10-17 / 姫・Opus 5.5 / OPS-076第2区切り）

入力版`56005d06d1ad97ed544cda914e12ee725692dc58`。本文・旧記録は変えていない。各行は「その版で確かめた主張・方法」。確認は`git`の読み取りだけで、ブラウザ・製品テスト・CIは実行していない。

| 主張 | 確認方法と結果 | 更新のきっかけ |
| --- | --- | --- |
| 試行4件の冒頭ブロックが残っている | `git show <版>:Maintanance/Current/<文書>`の3行目が`> **確定範囲（2026-10-17、OPS-066試行）`で始まる：4件とも一致 | 4件のどれかの冒頭を書き換えたとき |
| 証拠commit（試行`25518fdd1`、`9ddb150f`・`46d50288`・`7a092b72`・`039b2141`）が解決できる | `git rev-parse --verify <hash>^{commit}`：5件とも解決 | 履歴の書き換え（通常は起きない） |
| RBT-049の証拠ディレクトリがある | `git cat-file -e <版>:Maintanance/Current/Evidence/RBT-049`：あり | 証拠の移動・圧縮 |

未確認：冒頭ブロックの形式が他の正本へ広がったかは見ていない（本taskの境界どおり全体展開はしていない）。見直す範囲：上の4文書の3行目だけでよい。
