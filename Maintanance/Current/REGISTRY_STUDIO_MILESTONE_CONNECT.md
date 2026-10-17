# Registry Studio：タスクを到達点へつなぐ操作の追加（OPS-061）

> **確定範囲（2026-10-17、OPS-066試行）** 受入済み：タスク編集欄の「到達点へつなぐ」（行き先は版のENDか途中カード、版ゲートは拒否）。Fable自己受入（ユーザー指示）。証拠：commit `9ddb150f`、verify.cjs・sync・stub DOMスモークテスト。未確認：Safariでの実表示・実クリック・保存JSONの実ダウンロード。次の確認点：ユーザー試用で画面を一度触る。本書の「関係の種類」の記述は同日のOPS-062で失効。状態の正本はRegistry。

2026-10-17 / 作成・実装・検証・受入 Fable（調整代理、OPS-044）。親は恒久task OPS-048（Studio、Astra）。ユーザー同席。

## 発端とユーザー指示

ユーザー「これなんだけど、タスクをENDにつなぐことができないんだよね」。調査の結果、タスク編集欄の「前提を追加」は前提候補がタスクだけで、既存の線の「つなぎ替え」でしか到達点へ結べず、線のないタスクには入口がなかった（README にも「マイルストーン編集は未実装」）。Fableが Registry の「マイルストーン接続」へ直接行を足す案と、Studio に操作を足す案を示し、ユーザー「うん。自分でタスク作って、自分で確認して、自分で受け入れて」。

自己受入はこのユーザー指示に基づく例外であり、代理委任の「自身の実装成果の独立受入は他者へ」の原則を一般に変えるものではない。

## 範囲

- 対象：`Maintanance/RegistryApp/index.html`（編集欄とデータ操作）、`verify.cjs`（検査）、`README.md`（手順）。
- 対象外：`sync.py`・`registry.json`の構造、Registry のマイルストーン接続の正本化規則（接続は保存JSONを取り込むAIが Registry へ行を足して正本になる。Studio は Registry を読み書きしない）、到達点カードや列の編集、HEAD。

## 実装

- データ操作 `addMilestoneRelation(data, taskId, targetId, relation)`：候補を複製して `milestoneRelations` に `{prerequisite: task, successor: 到達点, relation, constraint: '', conditionReview: '相談待ち', source: {path: '', quote: ''}}` を足し、`check()` を通してから返す（元データは不変）。
  - 到達点は版の `END-x.y.z` か途中のカード `MS-*`。版ゲート（`GATE-x.y.z`）は拒否する（`Milestones/README.md`「版ゲートへ入る線は、そのフォルダのENDからだけ」）。ユーザーの説明：タスクは版の中の行動なので、ENDに結ばないとどの版の仕事か分からなくなる。GATEは版と版の継ぎ目で、タスクの行き先ではない。
  - 初版ではGATEを選ぶと裏でENDへ付け替えていたが、ユーザー指摘「GATEにつないじゃだめ」で同日中にGATEを選択肢から外し、拒否へ変更した。
  - 関係の種類は `required / material / after / resume` に限る。`stage` はゲートの列専用。
  - 同じ接続の重複、存在しないタスク・到達点は例外で止める。
- 編集欄（タスク選択時）：「このタスクがつながる到達点」の一覧（END または MS をそのまま表示、削除ボタンは既存の `removeRelation`）と、「到達点（版のENDか途中のカード。版ゲートへは直接つなげない）」「関係」の選択、「到達点へつなぐ」ボタン。ENDの選択肢には行き先の版ゲートを「END-0.5.4（→ GATE-0.6.0）」のように併記し、初期値は未達の最初のEND。`formDirty` のときは既存と同じ案内で止める。追加後は `dirty` を立てて再描画し、保存JSONの `changes` に `milestoneRelations` として出る。
- 選べる到達点は `doc.milestones` のうち `GATE-*` 以外（`END-*` と `MS-*`）。END は図では描かれないが、タスクの行き先としては選べる。

## 検証

- `verify.cjs` に検査を追加：`END-0.5.4` へ `required` で追加して `check` 通過、`GATE-0.6.0` を指定すると拒否、元データ・baseline 不変、`delta()` に `milestoneRelations` が出る、`MS-VALIDATION` へ `material` で直結できる、重複・`stage`・不明タスク・不明到達点を拒否、`graphData()` が新しい線を END の先の版ゲートへ描く（`shownFor` = END）。
- `sync.py`（node は Codex 実行環境の v24.19.0、marked 同梱）：完了、verify 全項目 PASS、`--check` ずれなし。
- stub DOM によるスモークテスト：`editor()` を `OPS-059` で描画し、見出し・ボタン・「まだありません。」を確認。到達点の選択肢は `MS-DOC, END-0.5.3（→ GATE-0.5.4）, END-0.5.4（→ GATE-0.6.0）, MS-VALIDATION, END-0.6.0（→ GATE-0.7.0）, MS-SPI, END-0.7.0（→ GATE-0.8.0）, MS-HUMAN, END-0.8.0（→ GATE-0.9.0）, MS-QUALITY, END-0.9.0（→ GATE-1.0.0）, END-1.0.0`、GATE は無し、初期値は `END-0.5.4`、関係は4種。`END-0.5.4` / `required` でクリック → 関係数 32→33、`END-0.5.4 / required / 相談待ち`、`dirty=true`。データ操作に `GATE-0.6.0` を直接渡すと「版ゲートへはタスクをつなげません。…その版のEND-x.y.zを選んでください。」で拒否。初版（GATE選択→END付け替え）の時点では、重複の2回目「この接続は既にあります」と `formDirty` 中の「先に入力の『変更を適用』を押してください。」も確認済みで、この経路は変更していない。
- 未検証：Safari での実表示と実クリック、保存JSONの実ダウンロード。既存機能と同じ制約。

## 受入（Fable、ユーザー指示による自己受入）

2026-10-17。上記の実装が範囲内に収まり、verify・sync・スモークテストの証拠が揃っていること、既存の検査（列の一本道、版ゲートへ入るのはENDだけ、各版フォルダのDAG）を壊していないこと、Registry への自動反映を加えていないことを確認して受け入れる。Safari 実表示はユーザー試用で確認する。OPS-061 は DONE、親 OPS-048 は ACTIVE のまま。

## 取り込み側の手順（この操作で保存されたJSONを受けるAIへ）

`changes` の `milestoneRelations` に `conditionReview: 相談待ち` かつ `source.path` が空の行があれば、それは Studio で新しく足された接続。ユーザーと条件文を決めてから、Registry「マイルストーン接続」の表へ `| 接続元 | 接続先（END-*またはMS-*） | 関係 | 制約 |` の行を足し、`sync.py` を回す。線があるだけで自動開始・凍結解除・判断の代行にはしない。

## 後続（2026-10-17、OPS-062）

同日、ユーザー決定（Astra助言）で線の種類を廃止した。本書の「関係の種類は required / material / after / resume に限る」は失効し、「到達点へつなぐ」は到達点を選ぶだけになった。条件は制約文で持つ。詳細は[OPS-062正本](REGISTRY_STUDIO_SINGLE_LINE_KIND.md)。


## 根拠と更新条件の追記（2026-10-17 / 姫・Opus 5.5 / OPS-076第2区切り）

入力版`56005d06d1ad97ed544cda914e12ee725692dc58`。本文・旧記録は変えていない。各行は「その版で確かめた主張・方法」。確認は`git`の読み取りだけで、ブラウザ・製品テスト・CIは実行していない。

| 主張 | 確認方法と結果 | 更新のきっかけ |
| --- | --- | --- |
| 範囲の`Maintanance/RegistryApp/index.html` | 本版にはない。`bbddb7ff3`（2026-10-17）で`index.template.html`へ改名（サーバー実行型への移行）。事実は古くなったが、実装の判断は変わらない | Studioのファイル構成の変更 |
| 版ゲートへの接続を拒否する | `index.template.html`の本版336行目に「版ゲートへはタスクをつなげません」、341行目に`function addMilestoneRelation` | 該当関数・文言の変更 |
| 関係の種類4つ | 冒頭ブロックと後続節のとおりOPS-062で失効（下の文書の追記を参照） | — |

Safari実表示は未確認のまま（本文どおり）。
