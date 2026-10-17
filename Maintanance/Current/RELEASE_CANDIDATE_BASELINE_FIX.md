# 候補CIの比較元未登録taskへの限定対応

RELEASE-084 / 2026-10-16 / 作成・受入Astra、実装・検証Claude（姫）。ユーザーの「進行は任せる」に基づく限定依頼。RELEASE-083の調査受入済み成果を入力とする（commit待ちは実装開始を妨げない）。

## 方針と完了条件

候補CIが0.5.3を比較元にするとき、新規8測定が比較元に存在しないことを明示し、比較可能な測定と候補のみの測定を分ける。通常CIは今回変更しない。30%閾値・既存測定内容は維持する。

- 比較元SHAを139ffef8db3eb75d118dbaecc8a1ec05d2e9894fへ厳密に限定して、調査の8件だけを比較不能として許容する。別SHAの欠落は同じ名前でも失敗させる。存在する8件を機械的に除外しない。
- 候補側の全29測定を維持し、共通21件と比較元にない8件を結果・artifactに明示する。全29件の性能回帰が検証済みという表示にしない。
- 想定外の欠落、候補側の測定欠落、比較可能項目ゼロは失敗。名前変換後の完全なtitleで照合する。benchmark infoの出力形式を確認する。
- 取得可能な比較診断はstderrも保存し、測定結果や実装をbaselineへ移植しない。
- 実行workflowはdefault branch側から取得される。修正をPRに置くだけではコメント起動の仕組みが更新されない点を引継ぎに記載する。mainへ反映する操作は委任しない。

## 入力

- Current/RELEASE_CANDIDATE_BASELINE_INVESTIGATION.md の原ReturnとAstra受入。
- Current/Evidence/RELEASE-083/proposed/candidate-ci-baseline-tasks.patch は参考案。上記の制約に合わせて補修する。
- Current/PERFORMANCE_CI_CHANGE_GUIDE.md。特に古いPermutationと現行の性能契約の違いを保つ。8件欠落を直しても、異なる契約の比較まで有効と認定しない。比較契約の不一致が見つかれば報告して停止し、閾値・比較元を独断変更しない。
- .github/workflows/candidate.yml と Benchmarks/Libraries/CI.json・CI-Small.json。着手時にhashを記録する。

## 編集・検証範囲

編集可: .github/workflows/candidate.yml、Benchmarks/Scripts/配下の本対応専用filterと検証補助、Benchmarks/Libraries/配下の本対応専用の例外定義、以下Return、Maintanance/Current/Evidence/RELEASE-084/。

既存CI.json・CI-Small.json、ci.yml、製品・測定workload・Registry・Rules・他の返却物は変更しない。変更範囲外が必要なら理由を返す。共有.buildを使わず隔離した最小再現とし、一時物はCOMMONSに従う。

既知SHA＋8欠落、既知SHA＋想定外欠落、別SHA＋同じ8欠落、欠落なし、候補欠落、空比較、旧名変換を検証する。YAML・埋込shellの構文とpipelineの失敗伝播も確認。全規模性能測定・GitHub再実行・投稿・merge・commit・pushは含めない。修正を意味ある単位に整理し、後のcommitの分け方をReturnへ書く。

依頼完成をもって編集範囲を受渡し。Astraは返却まで対象を編集しない。既存のASan直接依頼とは独立。

## Return

未着手。変更一覧、入力hash、検証結果、未確認・残判断、公開前に必要な反映順序、作業終了・範囲解放を返す。

### Claude返却（2026-10-16 22:49〜23:00、停止報告）

**停止した。** 正本の入力にある停止条件「比較契約の不一致が見つかれば報告して停止し、閾値・比較元を独断変更しない」に当たる事実を、実装の前に見つけた。ファイルの変更はこのReturnだけ。workflow・Scripts・Libraries・Evidenceには何も作っていない。

**入力hash（着手時、HEAD `964c12bc`）:** `candidate.yml` `ee96cebf…c606`、`CI.json` `ae78926a…eaff`、`CI-Small.json` `af951833…ef8`。RELEASE-083の固定入力と同じ。

**見つけた不一致（事実）:**
- 0.5.3（`139ffef8`、2026-10-10）と比べられる21件のうち、3件はPermutationの測定。
  - `Permutations.SubSequenceN subscript sequential access (batched)`
  - `Permutations.SubSequenceN subscript shuffled access (batched)`
  - `Permutations nextPermutations end-to-end checksum`（CI-Small）
- 3件ともtitleは0.5.3にもある。batchedは`e9126d24`（10-03）から存在する。
- ただし実装の方式が違う。
  - 0.5.3の`PermutationModule/Permutations.swift`には、世代や失効を確かめる仕組みがない（`generation`・`GateKeeper`は0件。`precondition`は範囲検査の1件だけ）。
  - 候補では、`9ff515c9`（2026-10-12「Adopt runtime-checked permutation views」）で、runtime-check付きViewに替わっている（`NextPermutations.swift`で`generation`・`GateKeeper`が15件）。
- `PERFORMANCE_CI_CHANGE_GUIDE.md`の「Permutation実装方式の切替」は、この切替をまたぐ比較を「同じ実装系列内の回帰ではなく方式差」とし、PR #191のmerge commitを以後のruntime-check版baselineとしている。0.5.3はその切替より前なので、この3件を30%閾値で比べると、方式差を回帰として赤にするおそれがある。
- 8件の欠落を直すだけだと、この3件の比較が新たに始まる（今は比較の前に止まっている）。

**残る判断（ユーザー・Astra）:** 0.5.3を比較元にする候補CIで、Permutation 3件をどう扱うか。私は決めていない。
1. 8件と同じ「既知SHA限定の例外」に、理由「契約の切替（`9ff515c9`）」を付けて、比較しない側へ明示する。結果に「Not compared: contract changed」と出す。
2. 比較はするが、この3件だけは合否に使わず、参考として表示する。
3. 0.5.3との性能比較は候補判定に使わないと決める（候補CIの比較元の規則を変えることになる）。
- 正本は「閾値・比較元を独断変更しない」としているので、2と3は特に判断が要る。1でも、比較しない理由が「欠落」から「契約差」に広がる点を承認してもらう必要がある。

**未確認:**
- 3件で実際に30%を超える差が出るかは測っていない（全規模の測定は範囲外）。
- RedBlackTreeの18件に、同じような方式の切替があるかは照合していない。製品コードの0.5.3からの変更は`31aa2f07`の範囲eraseだけ（RELEASE-081の調査）で、CIの18件の測定経路には含まれないと考えるが、未確認。

**作業終了。** 方針が決まるまで停止し、範囲を解放する。commitしていない。

## Astra受入・進行判断（2026-10-16）

停止報告を受け入れた。実装完了ではない。candidate.ymlのrelease tag選択、性能CI変更ガイドの方式差の記述、返却時点でworkflow実装差分がないことを照合した。RELEASE-084はWAITING_USERへ変更する。

CP-20261016-015の調査を本taskとRELEASE-083へ統合する。比較元へのworkload追加未到達とPermutation契約切替が別の問題である点を受け入れる。「候補CIが一度も成功していない」は取得・保存できた記録の範囲だけの主張とし、未取得runまで断定しない。初回失敗の同因説は推定を維持する。

ユーザーがClaudeへ「赤のままmergeし、その後チューニング余地を探す」と伝えた記録を受領した（原文CP-015）。これはユーザー操作の方針として残し、merge実行済み、release合格、比較除外・閾値変更の許可には拡張しない。

次の判断は、本修正を0.6.0前に続けるか、今回の赤を引き受けて後へ送るか。方針確定まで追加実装依頼なし。8件欠落を補修する場合もPermutation 3件を独断で比較対象から外さない。

## 今回の後送判断の確定（2026-10-16 / ユーザー）

ユーザーが「うん。このまま確定しよう」と承認。候補CI修正は0.6.0前には続けず、今回の候補CIの赤を引き受け、ユーザー操作でmainへmergeする方針とする。候補CI成功へ読み替えず、比較元8件欠落とPermutation 3件の契約差を既知の未解決として保持する。閾値・比較対象・workflowは変更しない。

RELEASE-084はWAITING_EXTERNALとして0.6.0リリース完了まで後送。完了後に現行baselineと修正の必要性・範囲を見直してから再開する。release完了だけで旧修正案を自動実施しない。今回のmerge方針と最終タグ・公開判断は分ける。

確認済み通常CIの対象はa5a39d12。手元HEAD 811b7a7aまでの差分は調査・管理記録だけで、製品・Tests・workflowに変更なし。本記録を含む未commit分はcommit・pushしてPRへ載せてからユーザーがmergeする。現在のremote PR head・追加CI結果は今回ネットワーク接続できず未再確認。merge後にmainの対象と検証版との差分を確認して最終release判断へ渡す。

## マージ結果と記録の後送（2026-10-16）

ユーザーとの訂正により、手元の記録を先にpushせず、確認済み候補のPR #198をユーザーがmergeした。GitHub APIでmerged=true、main=283c196a4d6025b6f29b246d349a2e5d4cd7aca4、候補a5a39d12とのファイル差分ゼロをAstraが確認。上記の「記録をpushしてからmerge」は旧手順であり、この決定で置き換える。未反映の調査・受入記録は保存後、別branchでmainへ戻す。タグ作成・公開はまだ行っていない。

## 立て直し工程への接続

2026-10-16のタスク整理により、RELEASE-085の協議→RELEASE-086の確定プランを本修正の再開前提とする。0.6.0完了待ちは維持。旧依頼をそのまま再実施せず、プランで必要性と範囲を確認し改めて依頼する。完了ゲートRELEASE-087への実行証拠の合流は計画時に具体化する。

2026-10-16最新ユーザー判断：今回のリリース予定を0.6.0から0.5.4へ振替。本件の「今回のrelease完了後」は0.5.4完了後を指す。過去の実験・方針の記録は保持。現在の境界は[0.5.4ゲート](../Milestones/_Archived/RELEASE_0_5_4_HISTORY.md#release-0-5-4)を参照。

## 再依頼（2026-10-17 / ユーザー「CIの修正依頼もだしてほしい」）

RELEASE-084を以下の限定範囲で再開する。担当Claude（姫）、受入Astra。今回の明示依頼により、本節の確認・修正は0.5.4完了およびRELEASE-086確定を待たず進めてよい。立て直し全体の方針確定・完了を意味しない。過去の停止報告は証拠として保持し、本節を現在の依頼とする。

1. 着手時のbranch・HEAD・作業差分とcandidate.ymlの比較元選択を確認する。ローカルtagと取得できるremote/default branchの情報を区別し、現在の実行で選ばれるbaselineを特定する。ネットワークで確認できない場合は未確認と記載し、推測でtagを作成・変更しない。
2. RELEASE-083の保存証拠を再利用し、現在のbaselineで8件欠落とPermutation 3件の契約差が今も該当するか確かめる。0.5.3向け例外を別SHAへ拡張しない。既に不要になった旧案をそのまま実装しない。
3. 本書の既定方針で解決できる欠落処理・診断保存・結果表示を修正し、限定検証する。現在のbaselineで問題が解消していれば、その証拠を返し不要な修正はしない。契約差が残る場合でも、独立して成立する既定範囲の修正は進めてよい。ただし全体成功として表示せず、未解決比較は失敗または未判定として明示する。
4. 比較対象除外、参考値化、閾値変更、baseline選択規則の変更が必要なら、その部分を未適用とし、推奨案・影響・必要なユーザー判断を短く返す。今回の依頼だけで未決方針を決めない。

編集範囲は既存の「編集・検証範囲」を維持する。通常CI・製品・測定workload・既存CIライブラリ定義は変更しない。Studio健全性修正とは別の作業単位にする。GitHubへのコメント投稿・CI起動・push・merge・tag・commitは委任しない。workflowはdefault branchへの反映後にコメント起動へ効くことを引継ぐ。

返却：変更一覧、固定入力SHA/hash、現在のbaselineとその根拠、最小ケースの検証結果、未解決判断、workflow反映順、推奨commit単位、作業終了・範囲解放。本節の返却欄に記入する。Registryの最終更新はAstraが行う。実装修正が終わってもCI実走成功・リリース可とは呼ばない。

### 再依頼のReturn

**Claude返却（2026-10-17、姫）。結論：現在のbaselineでは問題が解消しているため、workflowの修正はしていない。**

**固定入力：** branch `develop/misc/69`、HEAD `0789479b`、着手時の作業差分なし。`candidate.yml` `ee96cebf3777cf5e…`、`CI.json` `ae78926adb7c16ce…`、`CI-Small.json` `af951833fbb7b436…`（RELEASE-083と同一）。

**現在のbaselineと根拠：**
- candidate.ymlは「候補HEADに含まれる`x.y.z`形式のtagのうち最新」を比較元に選ぶ。
- ローカル：`git tag --merged HEAD`の最新は`0.5.4`（→`b03d0bf2`、PR #199のmerge）。
- remote：`git ls-remote --tags origin`で`refs/tags/0.5.4`＝`b03d0bf2…`を確認（ネットワーク取得済み）。`0.5.3`は`139ffef8`のまま。
- よって`b03d0bf2`を含む候補（今のdevelop系PR）の比較元は0.5.4になる。0.5.3向けの例外は不要。

**8件欠落と契約差の再確認：**
- RELEASE-083で0.5.3に無かった8件は、0.5.4のBenchmarks/Sourcesにすべてある。現行CI.json・CI-Small.jsonの29件で0.5.4に無いものは0件。
- Permutationのruntime-check切替`9ff515c9`は0.5.4の祖先。比較元と候補の性能契約は同じ。
- 0.5.4→HEADで`Benchmarks/`・`Sources/`の差分なし。

**最小ケースの検証：** 0.5.4を一時worktreeへチェックアウトし、候補のCIライブラリを写してcandidate.ymlと同じ手順で`benchmark library run`を実行。CI.json・CI-Small.jsonともexit 0、`unknown tasks`なし、29件記録。証拠は`Evidence/RELEASE-084/`。macOSローカル実行で、Ubuntu runner上の実走ではない。

**変更一覧：** workflow・Scripts・Librariesの変更なし。追加は`Evidence/RELEASE-084/`（README・ログ2件）と本Returnだけ。

**未解決判断（ユーザー）：**
1. 将来、新しい測定を足してリリースする前に候補CIを走らせると、同じ「比較元に無い測定」で止まる構造は残っている（workflowが候補のライブラリを比較元へ写すため）。恒久対策として「比較元に無い測定は未比較として明示し、比較できた件数と分けて表示する」を入れるかは方針判断。推奨は入れる（ただし今回の範囲外、立て直しRELEASE-085/086で扱う）。
2. 0.5.4は候補と測定コードが同一なので、比較は配置ゆれ（過去に±20%の観測あり）だけを測ることになる。30%閾値は変えていない。

**workflow反映順：** 変更なしのため不要。

**推奨commit単位：** 証拠と本Returnの1commit。

**作業終了・範囲解放。** CI実走成功・リリース可とは呼ばない。commit・push・GitHub操作はしていない。

## Astra受入（2026-10-17、0789479b後の返却）

限定再依頼を受入。現在baselineでは旧例外修正が不要という結論を確認した。workflowの数値版tag選択を手元で再現すると0.5.4、SHAはb03d0bf21f110fc64c7dc9dfa0d790dab915b106。9ff515c9が0.5.4の祖先で、0.5.4→HEADのSources・Benchmarks差分はゼロ。保存された最小測定ログのCI.json/CI-Small.json exit=0を確認した。remote確認はClaude返却の証拠であり、Astraは再取得していない。

workflow変更なしを受け入れる。Ubuntu CIの実走合格・性能保証・リリース可否は未認定。将来の測定追加に対する恒久対策はRELEASE-085/086へ残す。RELEASE-084はWAITING_USER（受入済み証拠・記録のcommit確認待ち）。END-0.5.4への接続は維持。追加のClaude実装依頼なし。

2026-10-17、ユーザーが今回の証拠・受入・振り返りのcommitを承認。RELEASE-084はDONEへ更新。限定依頼の完了であり、Ubuntu CI合格・リリース判断や将来の恒久対策完了を意味しない。

## 根拠と更新条件の追記（2026-10-17 / 姫・Opus 5.5 / OPS-076第1区切り）

本文は変更しない。関連taskのRELEASE-084はDONE（占有の重なりなし）。根拠は固定版 `876d405b981baae04dc0d90448094488524b3c79` 基準。

結論「現行baselineでは旧例外修正が不要」（140行のAstra受入）が依存する事実：

| 事実 | 根拠と確認方法 | 結果 | 更新条件・見直す範囲 |
| --- | --- | --- | --- |
| baselineは「HEADに取り込まれた最新の数値版tag」 | `.github/workflows/candidate.yml` 179〜195行（Resolve previous release tag、`git tag --merged HEAD --sort=-version:refname`） | 一致 | この手順が変わったとき |
| 現在その tag は0.5.4（`b03d0bf21f110fc64c7dc9dfa0d790dab915b106`） | `git rev-parse 0.5.4^{commit}` | 一致 | **新しい数値版tag（0.6.0等）を打ったとき**。baselineが動くので結論の再確認が要る |
| 0.5.4→入力版で測定コードと製品に差分なし（122行） | `git diff --name-only 0.5.4 <SHA> -- Benchmarks/Sources Benchmarks/Libraries Sources` | 差分なし。※`Benchmarks/`全体では2026-10-17の計測記録（`Benchmarks/QualityAssessment/`、`515acd61`）が増えたが、測定コードではないので結論に影響しない | `Benchmarks/Sources`・`Benchmarks/Libraries`・`Sources`に差分が入ったとき（特に測定の追加。恒久対策はRELEASE-085/086） |

未確認：GitHub上の候補CIの実走結果（外部の結果でcommitでは固定できない）、Ubuntu環境での性能値。
