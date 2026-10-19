# 候補CIの比較元ベンチマーク停止調査

## TL;DR（人間向け）

候補CIで旧比較元に測定8件がなく停止する経路を隔離再現し、調査として受入した記録。実CI失敗ログの最初の行は未確認で、修正案の採用・適用や性能退行の判定ではない。

RELEASE-083 / 2026-10-16 / Astra assignment/acceptance, Claude (姫) investigation. User-requested investigation to establish why the 0.6.0 rehearsal stopped and propose the smallest repair enabling comparison. An unresolved cause may be returned with specific missing evidence.

<a id="固定入力"></a>
## Fixed inputs

- Candidate: a5a39d124eb4c63fa3fe3539f2024bedc367d1e9
- Baseline: 0.5.3 / 139ffef8db3eb75d118dbaecc8a1ec05d2e9894f
- Run: https://github.com/narumij/swift-ac-collections/actions/runs/38906685897 (attempt 1)
- Executed workflow SHA: 4a7ef4e3b9f30a369dc0425c2f304e5d92e7ab33. issue_comment may use a workflow different from candidate; compare actual execution revision.
- Local artifacts: Benchmarks/_Artifacts/PerformanceCI/a5a39d124eb4c63fa3fe3539f2024bedc367d1e9-candidate/ (read-only)
- `.github/workflows/candidate.yml` SHA-256: `ee96cebf3777cf5e68a72db67c0bf28bd2cf6d0137208223515357521edcc606`
- `Benchmarks/Libraries/CI.json` SHA-256: `ae78926adb7c16cec4c266f962cd37691784c01656dc51c223157eba2edffeae`
- `Benchmarks/Libraries/CI-Small.json` SHA-256: `af951833fbb7b436c2fbe17a8d7582f4b5905306215e7f6aa0d3fd8ef9608ef8`

<a id="既知の事実と仮説"></a>
## Known facts and hypothesis

GitHub reports debug-all-tests/release-all-tests/documentation success and performance “Run baseline benchmarks” failure. Candidate JSON has 29 items; baseline JSON/comparison/execution logs are absent. Candidate/baseline binaries and environment records exist: Linux x86_64 / Swift 6.4.1.

Astra's static comparison found the current list copied to 0.5.3, which lacks BareArrayBenchmarks.swift, OptionalArrayBenchmarks.swift and corresponding new measurements. Candidate cause, not established by an execution error. Unauthenticated log API returned 403. Do not conclude red-black-tree fixes or candidate performance regression caused this.

<a id="調査依頼"></a>
## Investigation assignment

1. Compare executed workflow revision, baseline tag, candidate SHA and failed step. Identify first error from available logs; explicitly leave unavailable logs/inferences unverified.
2. Compare registered 0.5.3 benchmarks with copied/name-converted requests. Separate renames from absent APIs/measurements. Inspect actual shell stopping conditions including grep handled by branches.
3. If needed, minimally reproduce in an isolated copy. Do not execute Linux binaries directly on macOS; no full-scale remeasurement needed.
4. Propose a minimal fix separating comparable items from candidate-only new measurements. Avoid silently omitting missing tasks to PASS or weakening thresholds. Check regular-CI implications only as needed.

<a id="編集実行境界"></a>
## Editing and execution boundaries

Only Return below and investigation evidence under Maintanance/Current/Evidence/RELEASE-083/. Do not alter product, Benchmarks, workflow, Registry, Rules, original artifacts or assignment. Return proposed patch/prose in evidence folder. GitHub read-only; no rerun, comments, commit or push. Do not alter separate direct-user/ASan work. Isolate temporary artifacts under COMMONS, recording locations/cleanup from creation.

Assignment completion fixes inputs/text and hands them off. Astra will not edit Return/evidence until returned. At closure record conclusion, evidence, reproduction scope, proposal, unknowns, completion and scope release.

## Return

2026-10-16 22:25〜22:45 / Claude（姫）。固定入力3ファイルのSHA-256は依頼記載と一致（`ee96cebf…`・`ae78926a…`・`af951833…`）。製品・Benchmarks・workflow・Registry・Rules・元artifactは変更していない。GitHubは書き込みも再実行もしていない。

**結論（再現で確定、CIのログは未確認）:**
比較元0.5.3には、ElementBuffer・OptionalElementBufferの測定8件がまだ登録されていない（測定の追加は`b6ff8a85`、2026-10-12。0.5.3は10-10）。
- workflowは候補の`CI.json`を比較元へコピーし、名前を旧名へ戻して`benchmark library run`する。
- swift-collections-benchmarkは、知らないtaskがあると測定前に`Error: 8 unknown tasks`で異常終了する（`BenchmarkCLI+TaskSelection.swift`の未知taskの検査）。
- `set -euo pipefail`の下なので、ここで「Run baseline benchmarks」stepが失敗する。
- 赤黒木の修正や、候補の性能退行とは関係がない。

1. **実行された版の照合:**
   - issue_commentで起動したworkflowの版`4a7ef4e3`（PR #197のmerge）の`candidate.yml`は、固定入力と同じhash`ee96cebf…`。候補`a5a39d12`との間でも、`.github`と`Benchmarks`に差分はない。
   - 比較元tagは、step「Resolve previous release tag」の規則（候補HEADに含まれる最新のx.y.z）で`0.5.3`になる。artifactの`benchmark-binaries/baseline`が保存されているので、比較元のbuildまでは成功し、実行で止まったと考えられる。
   - **CIの失敗ログそのものは見ていない**（この環境に`gh`がなく、権限なしのAPIは403という既知の記録どおり）。最初のエラー行は、下の再現と静的照合から推定したもの。
2. **要求リストと0.5.3の比較（`task-presence.json`）:**
   - `CI.json`は28件。すべて候補にある。0.5.3には、旧名へ戻した後でも8件がない。残りの20件と`CI-Small.json`の1件は0.5.3にある。
   - 8件は名前変更だけの差ではない。0.5.3にはBareArray・OptionalArrayの測定ファイル自体がない（0.5.3の`Benchmarks`に`BareArray`・`OptionalArray`の文字列は0件）。
   - shellの停止条件: `grep -qF … BareArrayBenchmarks.swift`はファイルがないと終了2を返す。ただし`if !`の中なので`set -e`では止まらず、旧名への置換が実行されるだけ。止まるのは次の`swift run … library run`。
   - `benchmark results compare`は、片方にしかないtaskを標準エラーへ「Tasks missing from …」と出すだけで、失敗にはしない。workflowは標準出力だけを`comparison.txt`へ保存するので、この一覧は記録に残らない。
3. **最小再現（macOS、隔離した写し）:**
   - `git archive 0.5.3`を一時dirへ展開した。現行の`CI.json`と`CI-Small.json`をコピーし、workflowと同じsedで旧名へ戻して、`swift run -c release benchmark library run --max-size 2 --cycles 1`を実行した。結果は`Error: 8 unknown tasks`（8件の名前つき）、exit 1（`repro-baseline-0.5.3.log`）。
   - 修正案のfilterで8件を外した後は、exit 0（`repro-baseline-filtered.log`）。
   - Linuxの実行バイナリは実行していない。全規模の性能測定もしていない。
4. **最小修正案（`Evidence/RELEASE-083/proposed/candidate-ci-baseline-tasks.patch`、未適用）:**
   - 比較元のstepで`benchmark info --tasks`を使い、比較元が知るtaskの一覧を取る。`CI.json`と`CI-Small.json`から知らないtaskを外し、外したtitleを`baseline-missing-tasks.txt`へ書く（`Benchmarks/Scripts/filter_library_for_baseline.py`を新規追加）。
   - 旧名への置換は、`baseline-missing-tasks.txt`にも同じく戻す（候補側の名前で照合するため）。
   - 「Check performance regression」で、外したtaskを「Not compared (missing from baseline …)」として`comparison.txt`へ追記する。そのうえで、明示した許可リスト`Benchmarks/Libraries/CI-baseline-new-tasks.txt`（今回の8件、由来`b6ff8a85`つき）に**ない**欠落が1件でもあれば失敗にする。黙って除外してPASSにはしない。比較元から既存taskが消えた場合や、名前を書き違えた場合は検出できる。閾値（30%）は変更していない。
   - 許可リストの各行は、比較元のreleaseがそのtaskを含むようになったら削除する（ファイル先頭に記載）。
   - 検証: 変更後の`candidate.yml`はRuby PsychでYAMLとして読め、performance jobのstep名は従来どおり。照合部分のshellを模擬入力で実行し、8件だけなら成功、許可リストにない欠落が混ざると失敗（exit 1）になることを確かめた。CIでの実行はしていない。
5. **通常CIへの波及:**
   - `ci.yml`のperformance jobも、同じコピーと名前変換の構造を持つ。PRでは比較元がPRのbase（最近のcommit）なので、ふだんは発生しない。
   - 手動実行で`performance_base_ref`に0.5.3などの古いtagを指定すると、同じ理由で止まる。同じ修正を`ci.yml`にも入れるかは判断事項として残す。今回のpatchは`candidate.yml`だけ。

**判断が要ること（提案、Astra・ユーザー）:**
- 許可リスト方式を採るか。代案は「比較元にないtaskは常に比較しない」で一覧だけ出す方法。ただしこれは欠落を見逃しやすい。
- `ci.yml`へも反映するか。

**未確認:**
- CIの失敗ログの実物（最初のエラー行）。
- Linux / Swift 6.4.1での再現（再現はmacOS / Swift 6.4）。
- 修正案をCIで実際に動かすこと。
- `benchmark info --tasks`の出力にラベル付きtaskが含まれる場合の扱い。今回の0.5.3では、titleだけの1行1件だった。

**証拠:** `Maintanance/Current/Evidence/RELEASE-083/`（`task-presence.json`、`repro-baseline-0.5.3.log`、`repro-baseline-filtered.log`、`proposed/candidate-ci-baseline-tasks.patch`）。一時dir `mktemp -d -t release083-work`は返却時に削除した。

**作業終了。** 範囲を解放する。commitしていない。

<a id="astra受入2026-10-16"></a>
## Astra acceptance (2026-10-16)

Accepted as investigation, original Return retained. Independently confirmed executed-workflow SHA/current candidate.yml hash match, 8 missing of 28+1 requests, reproduction unknown-tasks/exit 1 and filtered exit 0, and proposed patch git apply --check success. No reproduction rerun. Without actual failed CI log, accept the reproducible baseline stopping cause, not 「実CIの最初のエラー行まで確認済み」. Candidate regression remains undecided because comparison is incomplete.

Proposal unapplied. An allowlist exposes missing tasks, but without baseline SHA/version bounds may wrongly permit later gaps as the same eight. Implementation must scope the exception to 0.5.3 and avoid hiding new gaps with another baseline. Applying the same mechanism to regular CI remains an implementation-scope decision. No threshold changes, CI reruns or candidate approval. User commit approval made RELEASE-083 DONE.

## 根拠と更新条件の追記（2026-10-17 / 姫・Opus 5.5 / OPS-076第4区切り）

入力版`1175e583b1857819e9e0b07b83a1cb5fc8be657a`。本文・原返却は変えていない。確認は`git show <版>:…`等の固定treeの読み取りだけで、実行・再レビューはしていない。

| 主張 | 確認方法と結果（成立範囲） | 更新のきっかけ |
| --- | --- | --- |
| 固定入力の候補`a5a39d124eb4c63fa3fe3539f2024bedc367d1e9`と比較元`139ffef8db3eb75d118dbaecc8a1ec05d2e9894f`（7〜8行目） | `git rev-parse --verify <hash>^{commit}`：どちらも解決できる。比較元がtag`0.5.3`を指すことは、確認時点の手元のref集合で見たもので、固定treeの事実ではない | なし（固定入力） |

現行の判断（旧例外修正が不要か）は後続の`RELEASE_CANDIDATE_BASELINE_FIX.md`末尾の追記を見る。11行目のローカル成果物（`Benchmarks/_Artifacts/…`）は作業環境のファイルで、確かめていない。
