# Claude採番待ちqueue

CodexがstableなRegistry IDを採番できない間に、ユーザーとClaudeが発見・整理・明示実行した作業を
一時的に受け渡す。このfileはTask Registryではなく、Claudeが自律的に次作業を選ぶbacklogでもない。

## 規則

- 仮IDは`CP-YYYYMMDD-NNN`とする。同日の末尾番号を増やし、再利用しない。
- ユーザーが「記録」「分解」「採番待ち」を依頼しただけなら、候補を記録して着手しない。
- ユーザーがClaudeへ具体的で境界のある実行を明示依頼した場合、その範囲だけ採番前に実行できる。
- 仮IDはTask precedence、正式な完了報告、別taskの依存、commit messageのstable IDとして使わない。
- ClaudeはRegistryの状態、最終受入、公開方針、Codex担当の完成判定を代行しない。
- 一件を終えても、別の採番待ち候補へ自動的に移らない。
- Codex復帰後、重複・衝突を確認し、正式登録、既存taskへの統合、却下のいずれかを判断する。
- 正式採番後も仮IDを消さず、正式IDと処理結果を記録して追跡可能にする。

## entry template

### `CP-YYYYMMDD-NNN` — <短い名称>

- queue状態: `CANDIDATE` / `USER_AUTHORIZED` / `AWAITING_CODEX` / `RECONCILED`
- 発見元・ユーザー指示:
- 種別候補: `DISCOVERY` / `DECISION` / `EXECUTION`
- 対象範囲:
- 対象外:
- 完了条件:
- 前提・既存task候補:
- 担当候補・受入担当:
- 停止条件:
- 成果・検証: 未着手
- Codex reconciliation: 未処理

## 採番待ち

### `CP-20261008-001` — task graphの可視化PoC（1枚目「今、何が動いていて、次に何が開くか」）

- queue状態: `RECONCILED`
- 発見元・ユーザー指示: 2026-10-08、ユーザーの「ビジュアライズしてなにか絵でおれにみせてほしい」への提案（技術・範囲・見せ方）を受け、
  「グラフのビジュアライズPoCを採番待ちタスクとして承認。実行し、結果をしめしてください。」
- 種別候補: `EXECUTION`
- 対象範囲: Task Registry / Task precedenceから、`ACTIVE`のtaskとその直前・直後のtaskだけを1枚のSVGに描く。完了済みは件数にまとめる。
  Python標準libraryだけで描き、生成物はClaude専用の`.task-graphs/`（Git対象外）へ置く。
- 対象外: 2枚目（流れの物語）・3枚目（symbolの隣）、Graphvizなど外部toolの導入、tracked fileへの生成物の追加、Registryの変更。
- 完了条件: 現在のRegistryから1枚の絵が再生成でき、Claudeが画像で見え方を確かめ、ユーザーへ示す。
- 前提・既存task候補: `GRAPH-001`（Claude用task graph DB）の延長。Gate列（`GRAPH-016`）が入れば線の種類に反映する。
- 担当候補・受入担当: Claude / ユーザー（見え方）、Codex（正式化の要否）
- 停止条件: 外部toolの導入やtracked fileの追加が必要になった場合。
- 成果・検証（2026-10-08 / Claude Opus 5.5）:
  - 生成物（Git対象外、Claude専用）: `.task-graphs/claude-viz.py`（描画script、Python標準libraryのみ）と、その出力
    `.task-graphs/claude-viz-now.svg`。再生成は`.task-graphs/claude-tg.sh && python3 .task-graphs/claude-viz.py`。
  - 描いた範囲: `ACTIVE` 6件と、つながる辺6本の相手（完了3件、凍結3件）。依存の無い`ACTIVE` 3件は「単独で進行中」として下にまとめた。
  - 見せ方: 箱は3種（進行中・止まっている・完了）で、状態語・種別・担当を箱の中に文字でも書く。線は「着手の前提」（太い実線）と
    「完了の前提」（点線）。凡例は絵の中。各箱にhover時の説明（task ID・全文の名称・状態・担当）を付けた。
  - 確認: macOSの`qlmanage`で一時directoryへPNG化して目視し、右列の欠け（確認用thumbnailの切り取り）と、英単語の途中での改行を直した。
    残る見た目の課題: 日本語の単語の途中で改行することがある（辞書を使わないため）。
  - ユーザーの指摘（SVGが古いアプリで開けない、拡大縮小がいまいち、PNGが切れている）を受け、SVGを窓幅に合わせる形にし、プレビュー用に`.task-graphs/claude-viz-now.png`（3600×2610）も出すようにした。
  - 外部toolの導入、tracked fileへの生成物の追加、Registryの変更はしていない。
- Codex reconciliation: 2026-10-08、既存のClaude用task graph DB独立試験へ統合。標準libraryだけでの再生成と非空出力をCodexが確認し、詳細正本へPoC結果を記録。新規stable IDは不要。

### `CP-20261008-002` — task graphの可視化（中間ゴール観点）

- queue状態: `RECONCILED`
- 発見元・ユーザー指示: 2026-10-08、`CP-20261008-001`の絵を見たユーザーの「これはこれでいいね。中間ゴール観点でみせてほしい」
- 種別候補: `EXECUTION`
- 対象範囲: Registryの「現在の中間ゴール」3件と「後続の中間ゴール」4件ごとに、関係するtaskの状態と依存を1枚のSVG／PNGに描く。
  生成物は`.task-graphs/`（Git対象外）。描き方は`CP-20261008-001`と同じ方式。
- 対象外: Registryへのgoal→task対応の追加、goal文の変更、外部toolの導入、commit。
- 完了条件: 現在のRegistryから再生成でき、Claudeが画像で見え方を確かめ、ユーザーへ示す。
- 前提・既存task候補: `CP-20261008-001`。goalとtaskの対応はRegistryに記録が無い（goalはID・状態を持たない）ため、
  Claudeがgoal本文の語とtaskの詳細正本から読んだ対応を「候補」として絵に明記する。
- 担当候補・受入担当: Claude / ユーザー（見え方）、Codex（正式化と対応記録の要否）
- 停止条件: 対応の読み取りに方針判断が要る場合（対応が見つからないgoalは「記録なし」と描き、推測で埋めない）。
- 成果・検証（2026-10-08 / Claude Opus 5.5）:
  - 生成物（Git対象外）: `.task-graphs/claude-viz-goals.py`、出力`.task-graphs/claude-viz-goals.svg` / `.png`、
    PNG書き出しの共通script `.task-graphs/claude-viz-png.sh`（macOSの`qlmanage`と`sips`だけを使う）。
  - goalとtaskの対応は、goal本文の語とtaskの詳細正本から読んだ候補で、根拠の語をgoalの箱に書いた。状態・名称・依存はRegistryから毎回読む。
  - 見えた事実: 今のゴール「Claudeへのtask出しの分解」と後続の「OptionalArrayの1.0判断」は、向かうtaskがRegistryに無い。
    0.5.0の流れは先頭の「tag地点」の判断がユーザー待ちで、後の2件は凍結。RedBlackTree 1.0の流れは外部待ち2件の先にある。
  - 確認: PNGを画像で目視し、根拠の行が途中で切れていたのを折り返しに直した。残る見た目の課題は、日本語の単語の途中や
    閉じ括弧の前での改行。
- Codex reconciliation: 2026-10-08、既存のClaude用task graph DB独立試験へ統合。goal対応を非正本の候補表示に限定する境界を詳細正本へ記録。新規stable IDは不要。

### `CP-20261008-003` — 連絡: task管理の手順を「分解・インライン化・割当」に分ける検討をCodexへ依頼

- queue状態: `RECONCILED`
- 発見元・ユーザー指示: 2026-10-08、task粒度についての会話。ユーザー:「タスク管理のタスク分解、タスクアサインを
  タスク分解、タスクインライン化、タスクアサインにする検討タスクとしては承認。ただし担当はCodex」、
  続けて「連絡タスクとしてくるんじゃえば」。Claudeが実行するのは、この連絡を書くことだけ。
- 種別候補: 連絡（Claude）。連絡先の検討は`DISCOVERY`候補（方針を決める段で`DECISION`が分かれる可能性あり）
- 対象範囲: 下の「Codexへの連絡」を書き、Codexの整理時に渡す。
- 対象外: 検討そのもの、Registryの行の統合や削除、playbookの書き換え、今すぐの適用（ユーザー:「のちのちの課題」）。
- 完了条件: 連絡が書かれ、Codexが正式登録・既存task（`OPS-001`など）への統合・却下のいずれかを決める。
- 前提・既存task候補: `OPS-001`（playbookの移植可能化）と関係する可能性。見るときだけ畳む表示は`CP-20261008-001` / `002`の絵。
- 担当候補・受入担当: 連絡はClaude、検討はCodex / 受入はユーザー
- 停止条件: Claudeは検討に着手しない。
- 成果・検証（2026-10-08 / Claude Opus 5.5）: 連絡を書いた（下）。
- Codexへの連絡:
  - ユーザーが、task管理の手順を「分解 → 割当」から「分解 → インライン化 → 割当」へ分ける検討を、Codex担当のtaskとして承認した。
    時期は「のちのちの課題」。
  - 背景: 細かい分解は、組み替え（分割・統合・順序変更・`EXCLUDED`）をしやすくするための意図的な設計（ユーザー説明）。
    「細かすぎる」という要望には、行をまとめるのではなく、構造が固まった後のインライン化で応える。
  - 会話で出た目安の候補（未合意）: 流れの形が固まっている、外から依存されていない、担当・詳細正本・受入がそろっている。
    凍結・判断待ちの流れはインライン化しない。
  - 関連の観測: 2026-10-08は1日で69件が完了し、1件ごとの割当・受入・中継が重かった（Claudeの観測）。
    ただし中継の重さは粒度ではなく受け渡しの仕組みの問題として、別に扱うのがよいとユーザーと整理した。
- Codex reconciliation: 2026-10-08、将来の独立したCodex担当taskとしてRegistryへ正式登録。運用上の観測: Codex担当の作業を承認された場合、queueは「Claudeが連絡を書く」taskとして
  扱えば、今の状態語（`USER_AUTHORIZED`→`AWAITING_CODEX`）のままで回る。状態語を足すかはCodexが判断する。

### `CP-20261009-001` — `f01c66a6`前後の実benchmark hot path機械語比較

- queue状態: `AWAITING_CODEX`
- 発見元・ユーザー指示: 2026-10-09、Codex低消費mode中の雑談でClaudeが提案したA-1に対し、ユーザー:
  「A-1やろうか。採番待ちタスクとして承認します。」
- 種別候補: `DISCOVERY`
- 対象範囲: 本物の`Benchmarks` packageを`f01c66a6^`（`f57a24d2`）と`f01c66a6`でbuildし、
  `Permutations.SubSequenceN subscript sequential access`のhot loopの機械語を比べる。buffer subscript getter、
  header initializer、probe initializerが呼出として残るか、inline化されるかを記録する。
- 対象外: Linuxでの確認、benchmark再計測、source・benchmark・workflowの変更、原因の断定、commit。
- 完了条件: 両版のhot loopの該当命令と、呼出として残るsymbolの有無を示す。差がなければ「macOSでは差なし」と書く。
- 前提・既存task候補: `CLAUDE_TASK.md`の完了済みassignment 2件（witness table比較、二分探索）の補足。
- 担当候補・受入担当: Claude / Codex（取り込みの要否）
- 停止条件: 依存解決ができない、またはhot loopを同定できない場合。
- 成果・検証（2026-10-09 / Claude Opus 5.5）:
  - 環境: Apple M1、macOS 27.0.1、Swift 6.4（`swiftlang-6.4.0.34.1`）。一時directoryへ`git archive`で両版を展開し、
    本物の`Benchmarks` packageを`swift build -c release --product benchmark`でbuild（SwiftPMのcache・config・securityも一時directory）。
    `xcrun objdump -d`で、当該taskの閉包5関数（登録閉包、Timer閉包とforwarder、measure内閉包とforwarder）を比べた。
  - 結果: **macOSでは差なし。** 5関数とも命令数は同じ（73 / 37 / 4 / 30 / 4）で、違いは開始address（両版で0xa8ずれる）と、
    addressから付いたlabel名だけ。
  - hot loop（measure内閉包）は両版とも7命令: `ldr`（`p[i]`）→ `add` → `str`（`sum`）→ `add`（`i += 1`）→
    `ldur`（`endIndex`の再load）→ `cmp` → `b.lt`。ループの外で`swift_beginAccess`を1回呼ぶ。
  - 5関数のどこにも、`Buffer.subscript.getter`、`NextPermutationsBufferHeader.init(count:)`、`NextPermutationsHeaderProbe.init()`
    への呼出はない。両版ともinline化されている。
  - 配置の事実だけ: ループ先頭は`f57a24d2`が`0x10027ac0c`、`f01c66a6`が`0x10027acb4`。性能への影響は判定していない。
  - 0xa8（168 byte）のずれの内訳（`nm -n`の隣接address差で比較）: `PermutationModule`の**特殊化されていない汎用版**の6関数が
    大きくなった分。`Permutation.subscript.getter` +72、同`read` +20、`lastAscentIndex.getter` +36、`lastIndex(where:)`の閉包 +20、
    `nextPermutation()`の閉包 +16、`hash(into:)` +4。合計168。benchmarkの特殊化済みhot pathは変わっていない。
  - 汎用版の中身: 修正前は`Permutation.subscript.getter`が`Buffer.subscript.getter`を1回、`lastAscentIndex.getter`が2回、
    callで呼んでいた。修正後はどちらも0回（inline化）。
  - 未確認: Linux（CIの`ubuntu-24.04`）。`f01c66a6`の3か所がLinuxで効いたかは、この結果からは分からない。
    仮説（未検証）: Linuxでbenchmarkの特殊化が効かず汎用版を通っていたなら、修正前は要素ごとにcallが1回増えていたことになる。
- Codex reconciliation: 未処理
