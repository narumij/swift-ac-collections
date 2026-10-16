# 候補CIの比較元ベンチマーク停止調査

RELEASE-083 / 2026-10-16 / 依頼・受入Astra、調査Claude（姫）。ユーザーの調査依頼に基づく。目的は0.6.0リハの停止原因を確定し、比較を成立させる最小修正案を返すこと。原因未確定でも必要な不足証拠を具体化して返せる。

## 固定入力

- 候補: a5a39d124eb4c63fa3fe3539f2024bedc367d1e9
- 比較元: 0.5.3 / 139ffef8db3eb75d118dbaecc8a1ec05d2e9894f
- run: https://github.com/narumij/swift-ac-collections/actions/runs/38906685897 （attempt 1）
- 実行workflow側SHA: 4a7ef4e3b9f30a369dc0425c2f304e5d92e7ab33。issue_commentは候補側のworkflowと版が違う可能性があるため、実行版を照合する。
- ローカル成果物: Benchmarks/_Artifacts/PerformanceCI/a5a39d124eb4c63fa3fe3539f2024bedc367d1e9-candidate/ （読み取り専用）
- `.github/workflows/candidate.yml` SHA-256: `ee96cebf3777cf5e68a72db67c0bf28bd2cf6d0137208223515357521edcc606`
- `Benchmarks/Libraries/CI.json` SHA-256: `ae78926adb7c16cec4c266f962cd37691784c01656dc51c223157eba2edffeae`
- `Benchmarks/Libraries/CI-Small.json` SHA-256: `af951833fbb7b436c2fbe17a8d7582f4b5905306215e7f6aa0d3fd8ef9608ef8`

## 既知の事実と仮説

GitHub結果はdebug-all-tests・release-all-tests・documentation成功、performanceのRun baseline benchmarks失敗。候補測定JSONは29項目、比較元JSON・比較結果・実行ログは成果物にない。候補と比較元の実行バイナリ・環境記録は保存されている。環境はLinux x86_64 / Swift 6.4.1。

Astraの静的照合では、現行測定リストを比較元へコピーする一方、0.5.3にはBareArrayBenchmarks.swift・OptionalArrayBenchmarks.swiftと対応する新しい測定項目がない。これが停止原因の候補であり、実行エラーで確定したわけではない。権限なしのログAPI取得は403だった。赤黒木の修正や候補の性能退行と断定しない。

## 調査依頼

1. 実際に実行されたworkflowの版、比較元tag、候補SHA、失敗stepを照合する。取得可能なら失敗ログから最初のエラーを特定する。ログ取得不能なら明記し、推測を事実扱いしない。
2. 0.5.3の登録済みbenchmarkと、コピー後・名前変換後の要求リストを比較する。名前変更だけの差と、旧版にないAPI・測定の差を分ける。grep失敗が条件分岐で処理されることなど、shellの実際の停止条件も確認する。
3. 必要なら隔離した写しで最小再現する。Linux実行バイナリをmacOSでそのまま実行しない。全規模の性能再測定は不要。
4. 最小修正案を提示する。比較可能項目と候補版だけの新規測定を明示し、欠落を黙って除外してPASSにする案や閾値緩和は避ける。通常CIへの波及も必要範囲だけ確認する。

## 編集・実行境界

編集可は下記Return欄と Maintanance/Current/Evidence/RELEASE-083/ の調査証拠のみ。製品、Benchmarks、workflow、Registry、Rules、元artifact、依頼本文は変更しない。修正案は証拠フォルダのpatchや文章で返す。GitHubは読み取りのみ、再実行・コメント投稿・commit・pushは含めない。別のユーザー直接依頼やASan作業を変更しない。一時物はCOMMONSに従い隔離し、作成時から所在と掃除状態を記録する。

依頼作成完了をもって入力・依頼本文を固定し受渡し。Astraは返却までReturn・証拠を編集しない。終了時に結論、根拠、再現範囲、修正案、未確認事項、作業終了・範囲解放を記載する。

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

## Astra受入（2026-10-16）

調査として受入。原Returnは保持。実行workflow SHAと現行candidate.ymlのhash一致、要求28＋1件中の8件欠落、再現ログのunknown tasks／exit 1とfilter後exit 0、提案patchのgit apply --check成功を独立確認した。再現の再実行はしていない。CI実ログ未取得のため「実CIの最初のエラー行まで確認済み」とは扱わず、比較元で成立する停止原因の再現として受け入れる。候補の性能退行の有無は比較未完了なので未判定。

提案は未適用。許可リスト案は欠落を明示できるが、比較元SHA／版への適用範囲を限定しないと後の欠落も同じ8件として許可し得る。実装時は今回の0.5.3由来の例外とし、別baselineで新たな欠落を隠さない条件を加える。通常CIへ同じ仕組みを入れるかは実装範囲の判断に残す。閾値変更・CI再実行・候補確定はしていない。RELEASE-083はユーザーcommit承認によりDONE。
