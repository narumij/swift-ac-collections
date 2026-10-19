# Studio表示状態のViewModel集約 — 設計協議

## TL;DR（人間向け）
Modelの変更から表示状態を作る試験と、その表示状態どおりViewが表示・動作する試験を分けたい。文字帯・メンバー・作業カードが履歴を別々に解釈せず、一か所で現在表示状態を組み立てる設計を姫と協議する。設計協議後、2026-10-19ユーザーが4段階の実装・試験・技術受入を承認。4段階の実装と技術受入を完了。ユーザーが成果のコミットを承認。

OPS-153 / 2026-10-19 / Astra調整。ユーザー明示依頼。親OPS048。OPS149停止仕様とOPS151開始表示の意味を保ち、OPS152監視UI実装へ拡張しない。

## 現状の入口
index.template.htmlにconfirmedStarts、createActivityView、workLaneItems、presenceStates、startPendings、createPresenceLampsがある。OPS151の未commit修正を含む現在の作業版を読む。正本やログは書き換えない。関連taskの限定検索では同じ集約協議は見つからなかった（全履歴無探索）。

## Astraの初案（未確定）
- 入力はイベント、承認、Registry状態、continuity、読取成否と時刻を含むModelのsnapshot。別APIの非同時更新/古い応答は入力境界で識別する。
- 表示状態を純粋なderive関数で作り、文字帯/current、メンバー、作業カード、読み取り状態を同じsnapshotから返す。履歴の意味判断をrendererに持たせない。
- Viewは渡された文言・状態・行・操作可否を描き、操作意図をコマンドへ返す。業務意味や権限をViewに再推定させない。DOM差分/フォーカス/スクロール保持はView責務に残す。
- 試験1：Modelの変化列→表示状態（開始/返却/停止/古い応答/不調/回復等）。試験2：固定表示状態→DOM/操作意図（文言・色・disabled・保持）。最小の境界接続試験は残す。
- 新フレームワーク導入は必須でない。既存関数の移動/包装から始め、意味変更と構造変更を混ぜない。

## 第1正式依頼 H-20261019-08
姫へ。上記と現行の3表示経路を限定調査し、実現性、最小ViewModel形、何がModel/Viewに残るか、段階移行3〜5区切り、区切りごとの対象ファイル/検査/終了条件、コストと残る限界を短く返す。全体アーキテクチャ刷新に広げない。既存未commit成果を保護し、読むだけ。

占有：本書の姫第1返却欄と本人activity/continuityのみ。コード/規約/Registry/承認/commit/実サーバー/画面操作なし。第2往復まで連続待機。OPS151の編集占有は返却済みで再開しない。

## 姫第1返却

2026-10-19 姫・Opus 5.5。読んだのは、作業版（OPS-151の未commit修正を含む）の`index.template.html`の表示経路と、それを試す`test-*.cjs`。読んだだけで、何も変えていない。

### 実現性：高い。土台の半分はもう純粋関数になっている

| 経路 | 履歴の解釈（純粋か） | 意味の判断がViewに残っている所 |
| --- | --- | --- |
| 作業カード | `workLaneItems`は純粋で、カードごとの段階・次の担当・開始を返す（すでにViewModelに近い） | `createWorkLaneView`が、表示文字の配列・承認バッジの文言・titleを組み立てる |
| メンバー | `presenceStates`・`startPendings`は純粋 | `createPresenceLamps`の`text()`が、ラベル・旧ACKの注記・開始待ちの行・継続の文言を組み立てる。取得不調時の文言も |
| 文字帯（current） | なし。`createActivityView.update`の中で、`confirmedStarts`と`isStateNotice`を使って直接選んでいる | 選択も文言もViewの中 |
| **4本目：WAKE** | `wakeOwners`・`wakeStatus`も、履歴を別に解釈している | 依頼文の上の3表示とは別系統。集約の対象に入れるかどうかを決める必要がある（姫の推奨：入れる） |

入力の境界は、すでに一部できている。continuityは`seq`と`serverMs`で、遅れた古い応答を捨てている（`createContinuityStatus`）。activityは`inFlight`で同時に1本しか取らない。承認とactivityは別々の周期で届き、両者を同時に揃える仕組みはない。

### 最小のViewModelの形

```js
deriveStudio(snapshot) → {
  current: {heading, detail, title} | null,
  members: [{owner, state, lines:[...], pending, stale}],          // lines = 今のランプ文字の各行
  cards:   [{taskId, stage, next:{kind,text}, lines:[5], title}],   // lines = 今のカード5行
  wake:    {owners:[...], byOwner:{owner:{kind,id,at}}},
  status:  {activity:'ok'|'trouble', approvals:'ok'|'trouble', continuity:'ok'|'trouble'|'none', text}
}
snapshot = {events, approvals, registryState, continuity:{marks, serverMs, failed}, now,
            ok:{activity, approvals}}   // 各ソースの最後の正常値と、いまの成否
```

- `now`をsnapshotに入れる。継続の鮮度（55秒）は時刻で変わるので、これがないと純粋関数にならない。
- ここに入らない「新着の光」は、前回からの差分で決まる遷移の効果なので、Viewに残す。

### どこに残るか

- **Model（入出力）**：
  - 3つのpoller、fetch、`validateActivityRows`などの検証
  - ソースごとの最後の正常値・成否・受信時刻を持つsnapshotの組み立て
  - 古い応答を捨てる処理（continuityの`seq`・`serverMs`はそのまま）
- **ViewModel（純粋）**：上の`deriveStudio`。中身は、今ある`workLaneItems`・`presenceStates`・`startPendings`・`confirmedStarts`・`wakeStatus`に、文言の組み立てを移したもの。
- **View**：
  - DOMの差分、フォーカス中はカードを動かさないこと、スクロールの保持
  - 光らせるタイマー
  - ボタンのdisabled（VMが決めた値を映すだけ）
  - 操作の意図（WAKEの送信、承認）をコマンドとして返すこと

### 段階移行（4区切り）

意味を変えない確認は、全区切りで同じ方法で行う。区切り0の前に、固定の履歴fixture（実データ200件の写しと、合成した開始・返却・停止・古い応答・不調・回復）で今の表示文字を全部書き出しておく（golden）。各区切りの後、同じ文字になることを比べる。

1. **メンバーの文言をVMへ**
   - 内容：`memberLines(states, pendings, continuityText, failed)`を純粋関数として切り出し、ランプは`lines`を描くだけにする。
   - 対象：`index.template.html`、`test-handoff-signals.cjs`、`test-start-pending.cjs`
   - 終了条件：`createPresenceLamps`の中に`PRESENCE_LABELS`への参照がない。goldenが一致。全cjsがPASS。
2. **カードの文言をVMへ**
   - 内容：表示文字の配列・承認バッジ・titleを`workLaneItems`の出力（`lines`・`title`）に移す。
   - 対象：同じファイルと`test-work-lane.cjs`
   - 終了条件：`createWorkLaneView`の中で文言を連結していない。goldenが一致。
3. **文字帯とWAKEをVMへ**
   - 内容：`currentBand(rows)`を切り出し、`createActivityView`が受け取るようにする。WAKEの状態も同じ入口から渡す。
   - 対象：同じファイル、`test-activity.cjs`、`test-wake.cjs`
   - 終了条件：Viewの中に`isStateNotice`・`confirmedStarts`・`wakeStatus`の呼び出しがない。
4. **単一のsnapshotと`deriveStudio`、試験の二段化**
   - 内容：今の`createWorkLane`がsnapshotの置き場を兼ねる形にし、1回のderiveで3〜4つのViewへ配る。
   - 新しい`test-view-model.cjs`（試験1）：snapshotの列→VM。開始・返却・停止要求・古い応答・不調・回復を流す。
   - 既存のDOM試験（試験2）：固定したVM→DOMと操作意図、の形へ寄せる。境界の接続を確かめる試験は1本残す。
   - 終了条件：goldenが一致。試験1が履歴の解釈をすべて覆う。試験2の側に履歴のfixtureが残っていない。

各区切りは独立にcommitできる大きさ（数十〜150行の移動）にする。意味の変更（OPS-149の停止表示など）は、区切り4の後に別の依頼で行い、構造の変更と混ぜない。

### コストと残る限界

- **コスト**：区切り1〜3は、それぞれ小さな依頼1回ずつ。区切り4がいちばん大きい（配線の変更と試験の書き直し）。
  - いちばん手間がかかるのは、ソースの文字列を直接確かめる試験（`html.includes(...)`）が10本の試験ファイルにあること。構造を変えるたびに壊れる。区切りごとに、振る舞いの検査へ置き換えていく必要がある。
- **残る限界**：
  - 試験2は、文字・属性・操作意図までしか見ない。CSSによる実際の見た目（色の薄さ、折り返し）は、引き続きheadlessの画像確認が要る。
  - 直近200件の窓の制約は、VMにしても残る（OPS-149の全log導出は別件）。
  - 承認とactivityが別々の時刻のsnapshotであることは消えない。VMでは、ソースごとの成否と時刻を表示できるようになるだけ。


## Astra照合・第2依頼 H-20261019-09

方向に賛成。既存純粋関数を活かし、構造変更とOPS149の意味変更を分離する。次の5点だけ最小案へ補正して合意可否を返してください。実装なし。

1. goldenは現状互換の証拠で、正しさの証明ではない。旧宛先残存/200件窓など既知制約を明記し、要求に対する合成fixtureも別に残す。「すべて覆う」は採用せず、列挙した契約ケースを確認するとの表現へ。
2. snapshotは同一時点のサーバーtransactionではなく、各ソースの最新受信値の組合せ。ソースごとgeneration/受信時刻/成否/最終正常値を持ち、入力更新一回ごとに一回deriveし同じVM revisionを各Viewへ配る。遅延応答・失敗・再取得の順序試験は入力境界側、純粋derive試験と分ける。
3. WAKEは同じ履歴解釈に依存するため集約対象へ含める案を支持。ただし承認UI全体は今回対象外。操作可否はVMの表示情報であり権限付与ではなく、サーバーで従来どおり再検証する。送信中/失敗の操作状態は入力Model側に保持してVMへ渡す。
4. 初回から巨大な新抽象を作らず、今のcreateWorkLaneへ純粋derive入口を寄せる。Viewは必要なら文言の装飾/DOMだけ担当し、履歴・業務状態の判断は持たない。flashは意味判断でなく表示効果として許容。
5. 試験を三つに明示：入力更新→snapshot（配送順序）、snapshot→VM（意味）、VM→DOM/操作意図（描画）。ユーザーの二段試験の核心は後二つで、最小の境界接続試験も維持する。追加規模やファイル分離は実装前に各区切りで決める。

## 姫第2返却

2026-10-19 姫・Opus 5.5。5点とも合意する。第1返却の「試験1が履歴の解釈をすべて覆う」は撤回し、1の表現に置き換える。補足は、実装前に決めておくべき3点だけ。

1. **goldenの位置づけ**：合意。goldenは「今と同じ表示」の証拠でしかない。既知の制約は、goldenの横に一覧で残す。
   - 旧宛先「デバッグ試行」の開始待ちが残る
   - 直近200件の窓
   - 取消の書式が未定
   - 同名の会話は区別できない

   要求に対する合成fixtureは、別のファイルに分けて残す。

   **補足**：表示文字は環境で変わる。`validateActivityRows`の`shortTime`は`Intl.DateTimeFormat(undefined, …)`で、実行環境のロケールとタイムゾーンを使う。ランプとWAKEの時刻は`ja-JP`固定だが、タイムゾーンは実行環境のまま。継続の文言は`now`で変わる。goldenを取るときは、`TZ`とロケールを固定し、`now`を注入する。そうしないと、別の機械で偽の不一致が出る。
2. **ソースごとの世代**：合意。snapshotは、各ソースの最新の受信値の組み合わせで、ソースごとに世代・受信時刻・成否・最終正常値を持つ。入力の更新1回ごとにderiveを1回行い、同じVM revisionを全Viewへ配る。順序の試験（遅延・失敗・再取得）は入力境界の側に置く。continuityの`seq`・`serverMs`はすでにその型になっている。

   **補足**：今は1秒ごとに継続の文言を塗り直している（`setInterval(status.paint,1000)`）。データが届かなくても、時刻だけで表示が変わる。だから「時計」も1つのソースとして扱い、毎秒の`now`の更新を入力の更新1回に数える。そうしないと、「入力の更新ごとに1回」の約束と鮮度の表示が両立しない。
3. **WAKE**：合意（集約の対象に入れる。承認UIの全体は対象外。操作可否はVMの表示情報で権限ではなく、サーバーが従来どおり再検証する）。

   **補足**：`createWakeControl`は、`busy`・`note`・`noteFor`の送信状態と、選択中の担当（`select.value`）を自分で持っている。送信状態は入力Model側へ移す。選択中の担当は、ユーザーの画面操作の状態なので、これも入力として渡す（VMが選択を決めない）。
4. **入口の置き場所**：合意。新しい大きな抽象は作らず、今の`createWorkLane`にderiveの入口を寄せる。第1返却の区切り4の書き方は、この意味に読み替える。Viewに残すのは、文言の装飾・DOM・フォーカス・スクロール・光の効果だけ。
5. **試験の3層**：合意。
   - 入力の更新→snapshot（配送の順序）
   - snapshot→VM（意味）
   - VM→DOMと操作意図（描画）

   ユーザーの言う二段は後の2つで、最小の境界接続試験も残す。区切りごとの追加の規模とファイルの分け方は、各区切りの実装前に決める。


## Astra最終整理 — 設計提案（未実装）

第2返却の補足を含め合意。既存の純粋関数を活かした段階移行が可能。Modelは通信の最後の正常値・成否・世代・受信時刻と、時計/操作状態を保持。deriveStudio(snapshot)が一度意味を解釈し、同じrevisionのcurrent/members/cards/wakeへ分配する。ViewはDOM・文言装飾・フォーカス/スクロール保持・表示効果と操作意図のみ担当し、履歴を再解釈しない。

### 提案する作業内訳

| 区切り | 作業 | 検証/終了条件 |
| --- | --- | --- |
| 事前固定 | OPS151の受入版を固定、既知制約一覧と表示baselineを保存。TZ/locale/nowを固定 | baselineは互換の証拠、要求合成fixtureは別にする |
| 1 | メンバー文言/開始待ち/鮮度の表示状態を純粋関数へ | 固定入力→文言が一致、View内の状態推定を除く |
| 2 | 作業カードの文言・バッジ・titleをVMへ | 意味と表示を分離、固定VM→DOM/操作の試験 |
| 3 | current文字帯とWAKE導出を同じ入口へ | 履歴解釈をViewから除去、選択/送信状態を入力化 |
| 4 | source別snapshotと単一derive・revision配布を統合 | 入力順序、snapshot→VM、VM→DOMの試験を分離し、境界接続を少数残す |

対象はindex.template.htmlと対応cjs、必要な規約説明。新frameworkやサーバー全面改修は不要。区切り1〜3は限定抽出、4が配線/試験移行の中心で最も大きい。行数や期間は未検証のため確約しない。source文字列依存の試験を振る舞い試験へ置き換える費用がある。各区切りを受入・commit可能にし、意味変更を混ぜない。

### 残る限界

200件窓・取消未実装・旧宛先/同名会話の識別問題は構造変更だけで解消しない。OPS149等の別機能変更として扱う。各APIのsnapshotは非同時であり、VMは整合した同時点を捏造しない。時計の更新も入力更新。CSSの実見た目はDOM試験だけで保証せず隔離ブラウザ確認を残す。VMの操作可否は権限ではなく、サーバー検証を維持する。

### ユーザー判断

上の段階移行へ進むか。今回は協議依頼までなので実装未着手。OPS152監視UIへは広げていない。

## 協議受入・待機終了

姫の2往復を設計提案として受入。WAKE-20261019-Oへ同番号ACKと本人endedで今回の待機を終了。新規作業なし。


## 実装開始のユーザー承認・割当 H-20261019-10

2026-10-19「実装と試験までおねがいします」により4段階の実装・試験・技術受入を許可。以前の実装判断待ちは解消。commit・実サーバー再起動・ユーザー画面操作は含まない。OPS149の停止理由/代理確認、OPS152の監視UIの意味変更は混ぜない。

姫へ：まず事前固定と区切り1のみ実施してください。現HEAD 73b623eaの受入済み開始表示を基準とし、既存表示baselineを固定TZ/locale/nowで保存。実ログを公開証拠へ不用意に複製せず必要な匿名合成fixtureと互換出力を使う。既知の200件窓/旧宛先/取消未定/同名制約を添える。メンバー文言・開始待ち・鮮度を純粋関数へ移し、Viewは渡された表示状態を描く。履歴/業務状態の意味を変えない。

占有：index.template.html、test-handoff-signals.cjs、test-start-pending.cjs、必要な新規test-view-model*.cjs/fixtureと本書のH-10返却欄。既存試験が構造依存で壊れた場合、該当表示の振る舞い検査への限定移行は可、無関係なassert削除不可。対象拡張が必要なら対象と理由を返す。Registry/他正本/サーバーコードは編集しない。調整役は実装ファイルを並行編集しない。

返却：対象・baseline固定条件・確認した契約ケース・未確認・差分と検証結果。変更前後hashを記録。区切り1後は返却して連続待機、次の区切りは新割当を受ける。本人着手はreason先頭にH-20261019-10、返却も同IDを使う。


## 独立評価の二観点（2026-10-19ユーザー補足）

評価責務を、入力記録→VMの意味・状態判定と、VM→画面の表示・操作一致に分ける。同一の入力・VM revisionを基準に対応を照合する。常駐2役の新設ではなく、評価対象の切分けである。DOM試験の通過を実画面確認と呼ばず、実ブラウザで確認しなかった視覚事項は未確認と明記する。配送順序の入力境界試験は別途維持する。

## 姫H-20261019-10返却（事前固定と区切り1）

2026-10-19 姫・Opus 5.5。事前固定と区切り1だけを行った。commitなし、実サーバーと画面の操作なし。

**対象とhash（SHA-256）**：
- `index.template.html`：`1f03f5fb…6fc6a`（HEAD `73b623ea`と同じ）→ `b15cac3d…e0f`
- `test-handoff-signals.cjs`：`ac07c363…95f5`、`test-start-pending.cjs`：`31b7bf6e…1109`。どちらも変更なし。
- 新規：`test-view-model-members.cjs`（`f883c071…2f`）、`view-model-members.baseline.json`（`e7cc46d7…ef`）

**baselineの固定条件**：
- 実ログは使っていない。匿名の合成シナリオ14段で、メンバー欄のDOM（文字・state・pending・新着・stale・順序）を段ごとに記録した。
- 取得元は、抽出前の`73b623ea`のコード。
- 固定したもの：
  - `TZ=UTC`
  - ロケール（`Intl.DateTimeFormat`の未指定ロケールを`ja-JP`にする）
  - 時刻（イベントは固定の基準時刻から1秒刻み、継続の鮮度は固定のmarkと経過秒を本物の`continuityState`に渡す）
- 14段の内訳：
  - 初回の読み込み（新着なし、旧ACKの注記、ユーザーの除外）
  - 同じ行の再取得
  - 新しい宛先への依頼（開始待ち・本人記録なし）
  - 実務記録の新着と、光のタイマー
  - 継続（新しい・古い・終了のみの担当、ユーザーの無視）
  - IDなしのworking（対応未確認）と、IDつきのworking（閉じる）
  - 開始待ち5件（3行と件数）
  - 取得不調
  - 不調中の継続の更新とタイマー（塗り直さない）
  - 窓が縮んだ回復（去った担当を消す）
  - 継続の取得不調
- 既知の制約は、baselineファイルの`knownLimits`に書いた。
  - 直近200件だけからの導出
  - 改名した宛先や無応答の宛先の開始待ちが残る（取消の書式が未定）
  - 同じ表示名の会話は区別できない
  - 光は状態ではなく表示効果
- baselineは「前と同じ出力」の証拠で、正しさの証明ではない。

**変更（区切り1）**：
- 純粋関数を4つ切り出した。
  - `memberModel(rows)`：履歴を1回だけ読む（`presenceStates`と`startPendings`）。
  - `memberViewModels(model, continuityOwners, continuityText)`：担当ごとの表示状態（`owner`・`state`・`pending`・`head`・`body`）を、表示の順に返す。
  - `memberFailureText`：取得不調のときの文字。
  - `newRecordOwners`：新着の担当。
- `createMemberLampView`：DOMだけを持つView。渡された表示状態を描き、順序の保持・光・不調の文字表示だけをする。「・新着」は、Viewが付ける表示効果として残した。
- `createPresenceLamps`：外から見た形（`update`・`continuity`・`failure`）は変えず、最新の入力を持ってderiveを1回呼び、結果をViewへ渡す役にした。既存の試験と配線は、そのまま使える。

**確認した契約のケース**（`test-view-model-members.cjs`の(b)。網羅ではなく、挙げたもの）：
- 順序：activityの担当（新しい順）→開始待ちだけの宛先→継続だけの担当。ユーザーはメンバーにしない。
- `head`と`body`の組み立て（時刻、旧ACKの注記、開始待ちの行、継続の文字）。
- 表示状態に光が入らないこと。
- 同じ入力から同じ結果が出ること（純粋）。
- 取得不調の文字。
- 新着の担当（初回は空、以後は未読の記録の担当だけ）。
- Viewのソースが履歴の関数・ラベル表・時刻の書式化を参照していないこと。

**検証**：
- baselineの比較（14段）：PASS。HEADのテンプレートで同じ試験を流すと、比較の部分は通り、新しい関数がないので(b)で止まる（baselineが抽出前のコードで再現できることの確認）。
- 否定対照：一時コピーで注記の文字と「・新着」の文字を変えると、それぞれ0段目と2段目で落ちた。一時コピーは削除済み。
- `node test-*.cjs`：16本すべてPASS。`sync.py`（verify.cjsを含む）は成功、`--check`はずれなし、`git diff --check`は問題なし。

**振る舞いの差（1点、報告）**：光のタイマーが3秒後に塗り直すとき、前は継続の関数をその時点で呼び直していた。今は、最後に描いた表示状態を使う。継続の文字（「N秒前」）が最大で1回分古いまま残りうるが、継続は毎秒塗り直されるので、すぐ追いつく。baselineの範囲では差は出ない。Viewに履歴や入力を読み直させないための変更。問題なら、Viewが再描画を依頼する形に戻せる。

**未確認**：実画面の見た目（CSSは変えていない）。Python側の試験（変更範囲の外）。


## 独立評価後の境界確認 H-20261019-11

ROUND1で固定VMの[A,B]→[B,A]がDOMへ反映されず旧順が残ると確認。旧挙動にもあり新回帰ではないが、「VMどおりView」の試験境界が未成立。仕様側の意図（既存順保持）と実装側の不一致を姫と整理する。まず最小方針を返してください、コードはまだ変更しない。

推奨：既存表示の安定順を保つなら、順序を明示的な表示入力としてModel/VM側で確定し、Viewは渡された順に描く。履歴解釈でなく表示順の保持であり、前回順をsnapshotのUI入力とする案。単にDOMを並べ替えて旧動作を変える案と比較し、最小修正/fixture/段階4への接続を短く示す。固定VM→DOMの順序変更検査は必要。flashタイマーは最後のVMを再描画する扱いで受け入れるが、時刻source更新による鮮度は段階4で確認する。

占有は本書H-11返却欄と本人記録のみ。実装占有は返却固定、返却後次割当まで待機。

## 姫H-20261019-11返却（表示順の境界）

2026-10-19 姫・Opus 5.5。コードは変えていない。

**事実**：Viewの並べ方は、前から「最初に現れた順」だった。`lamps`のMapに入った順にDOMを置き、去った担当は消え、戻ると末尾に付く。VMの「新しい順」が効くのは、最初に現れた瞬間だけ。もう一つ、OPS-141の姫第3返却の追記（MEMBER_STATE_PROTOCOL_REVIEW.md 161行）とコードのコメントにある「newest first」は、私の書いた説明で、実際の表示を正しく言っていなかった。書かれた説明と動作がずれているのは、この記述が原因。

**比較**：
- **案A（Astraの推奨）：順序を表示の入力にする。** 純粋関数`stableMemberOrder(prevOrder, vms)`を作る。前回の順に並んでいた担当はその順のまま残し、新しい担当はVMの順で末尾に足し、去った担当は除く。前回の順は、プレゼンターが持つUIの入力にする。Viewは渡された順に描くだけにする。今の見え方は変わらず、baselineはそのまま通るはず。
- **案B：DOMをVMの「新しい順」に並べ替える。** 記録が増えるたびに担当の並びが動く。動作の変更になるので、構造の変更と混ぜない原則に反する。

姫の推奨は案A。ただ、本来どちらの並びがよいかは画面の決めごとなので、ユーザーに確かめる点として残す（下）。

**最小の修正（許可が出たら）**：
1. `stableMemberOrder`を足し、`createPresenceLamps`が前回の順を持って、`memberViewModels`の結果をこの順に並べてからViewへ渡す。
2. Viewの`show`は、渡された順とDOMの順が違えば、渡された順にDOMを置き直す。既存試験のスタブには`insertBefore`がないので、`appendChild`で順に付け直す形にする。`lamps`の挿入順には頼らない。
3. 説明を直す。コメントと規約の「newest first」を、「最初に現れた順を保つ。新しい担当は末尾」に置き換える。MEMBER_STATE_PROTOCOL_REVIEW.mdの私の追記は、受入済みの記録なので書き換えない。訂正はこの返却に置く。

**fixture**：
- `stableMemberOrder`の契約：順の保持、新しい担当を末尾へ、去った担当の除去、戻った担当は末尾、空の前回
- 固定VM→DOM：`[A,B]`の後に`[B,A]`を渡すと、DOMが`[B,A]`になる（ROUND1と同じ形）
- 既存のbaseline14段：そのまま一致すること

**段階4へのつなぎ**：前回の順は、WAKEの選択中の担当と同じ「UIの入力」として、snapshotに入れる。deriveは、それを受けて順序を確定したVMを返す。Viewは順序を決めない。

**ユーザーに確かめる点**：メンバー欄の並びは、「最初に現れた順を保つ」（今の動作）と「新しい活動の順に並び替える」のどちらがよいか。決まるまでは、案Aで今の動作を保つ。


## H-20261019-12：既存順維持の補正＋区切り2

案Aを採用。今回ユーザーは既存表示意味を保つ構造変更を承認しているため、現動作の維持はその範囲で進める。新しい活動順へ変更する案Bは別の将来判断であり、今回の再承認待ちにしない。H-11の最小修正とfixtureを実施し、同じ占有で区切り2（作業カードの文言・バッジ・titleをVMへ、固定VM→DOM/操作の試験）まで進めて返却する。

占有：H-10のコード/試験群にtest-work-lane.cjsと必要な新規test-view-model-cards.cjs/匿名baseline、COMMUNICATION_PROTOCOL.mdの表示順説明だけを追加。過去返却は改変せず訂正は今回記録へ。先に補正と試験を終えてから区切り2を行い、結果を分けて返す。次の区切り3/4はまだ編集しない。commit/実サーバー/画面操作なし、返却後連続待機。

## 姫H-20261019-12返却（既存順の補正と区切り2）

2026-10-19 姫・Opus 5.5。補正を先に終え、その後で区切り2を行った。commitなし、実サーバーと画面の操作なし。区切り3・4のコードには触れていない。

### A. 既存順維持の補正（H-11の案A）

- `stableMemberOrder(prevOrder, vms)`を足した（純粋関数）。表示中の担当は前の順のまま、新しい担当はVMの順で末尾、去った担当は除く、戻った担当は末尾。
- プレゼンター（`createPresenceLamps`）が前回の順をUIの入力として持ち、並べたVMをViewへ渡す。
- View（`createMemberLampView`）は`lamps`の挿入順に頼らず、渡された順とDOMの順が違えば、渡された順に付け直す。
- 説明：コードのコメントに「表示順はstableMemberOrderが決める（最初に現れた順）」を足した。`COMMUNICATION_PROTOCOL.md`のMember statusに順序の一項を足し、以前の「newest first」は初出のときだけ成り立つ、と書いた。過去の返却は書き換えていない。
- 試験（`test-view-model-members.cjs`に追加）：
  - `stableMemberOrder`の5つのケース（前回なし、保持、新しい担当を末尾へ、去った担当の除去、戻った担当は末尾）
  - 固定VM→DOM：`[A,B]`→`[B,A]`でDOMが`[B,A]`になる（ROUND1と同じ形）、出入りのある順、stateとpendingの描画
- 否定対照：一時コピーで付け直しをやめると、「the DOM follows the given order」で落ちた。
- baseline14段は変更なしで一致した（見え方は変わっていない）。

### B. 区切り2：作業カードの文言をVMへ

- **baseline**：`test-view-model-cards.cjs`と`view-model-cards.baseline.json`を作った。匿名の合成シナリオ9段で、カードのDOM（5行の要素・class・文字、title、stage、next、tabIndex、ステータスの文字とstale、scroll）を記録した。
  - 取得元は`73b623ea`のテンプレート（`git show`で一時ファイルへ出した）。固定条件は区切り1と同じ（`TZ=UTC`・`ja-JP`・固定時刻）。
  - 9段の内訳：
    - 依頼・相談待ち・終了
    - 実着手、PINGの無視、検討中、状態通知だけのtask
    - フォーカス中のカードは動かない、scrollの保持、presenceつきの返却、次の担当がユーザー
    - 承認（待ちが先、件数のバッジ、承認だけのtask）
    - activityの不調、両方の不調
    - 窓が縮んだ回復（開始不明）
    - 承認の回復、空
  - 既知の制約はファイルの`knownLimits`に書いた。
- **変更**：純粋関数を3つ足した。
  - `workCardViewModel(it)`：5行・title・stage・nextの種類
  - `workLaneTrouble`：不調の文言
  - `workLaneViewModel(items, trouble)`：カードとステータス文字・stale

  `createWorkLaneView.update(vm)`は、渡された文字を描き、ノードの同一性・フォーカス・scrollを保つだけにした。`createWorkLane`は、`workLaneItems`→`workLaneViewModel`→Viewの順につなぐ。`workLaneItems`の出力と、`createWorkLane`の外から見た形は変えていない。
- **契約のケース**（挙げたもので、網羅ではない）：
  - 5行とtitleの組み立て
  - 確保の件数は、あるときだけ出す
  - Registryの状態と承認がないとき
  - 次の担当が不明、開始不明の説明
  - 不調の文言（なし・片方・両方）
  - 空のレーン
- **固定VM→DOM**：
  - 渡されたとおりに描く（class・tabIndex・title・dataset）
  - フォーカスがないときは、VMの順に並ぶ
  - ノードの同一性を保つ
  - フォーカス中は動かさず、消さない
  - scrollを保つ
- **操作の意図**：カードにはボタンなどの操作がない（tabIndexはフォーカスのためだけ）。承認の操作は別のUIで、今回の対象外。
- **ソース検査**：カードViewが、文言（承認なし・Registry・件・取得不調）と履歴の関数を参照していないこと。
- 否定対照：一時コピーで「承認なし」の文字を変えると、baselineの0段目で落ちた。

### 検証と差分

- `node test-*.cjs`：17本すべてPASS（新規2本を含む）。
- `test-work-lane.cjs`は、そのままPASSしたので変更していない。
- `sync.py`（verify.cjsを含む）は成功、`--check`はずれなし、`git diff --check`は問題なし。
- hash（SHA-256、先頭8桁…末尾8桁）。開始時の`index.template.html`は`b15cac3d…`、`test-work-lane.cjs`は`72161510…`で変更なし。
- `Maintanance/RegistryApp/index.template.html`：`463920fb…5af9545b`
- `Maintanance/RegistryApp/test-view-model-members.cjs`：`71233d12…828db254`
- `Maintanance/RegistryApp/test-view-model-cards.cjs`：`ba4e0e2c…3bab8679`
- `Maintanance/RegistryApp/view-model-cards.baseline.json`：`755cb483…ba433626`
- `Maintanance/Current/COMMUNICATION_PROTOCOL.md`：`a2c6b815…bc5a8fa3`

**未確認**：実画面の見た目（CSSは変えていない）、Python側の試験。


## 区切り1・2の限定受入とH-20261019-13

Astra調整：member/card専用試験を独立実行しPASS。旧順をUI入力で維持したまま固定VM→DOMの順序一致を追加、baseline14段/9段を維持。区切り1/2を限定受入する。全体snapshot・実画面の保証ではない。最終独立評価で指摘再発と全区切り境界を確認する。

姫へ区切り3：current文字帯とWAKE導出を純粋VMへ移す。履歴解釈はViewから外す。WAKEの選択・送信中・失敗状態を入力として扱い、権限検証は従来どおり。匿名baselineと固定VM→DOM/操作意図を分離する。占有はindex.template.html、test-activity.cjs、test-wake.cjs、必要な新規test-view-model-current/wake系と匿名fixture、本書返却欄。既存member/card試験に接続変更の必要があれば最小更新可。区切り4はまだ実装せず返却後待機。commit/実サーバー/ユーザー画面操作なし。

## 姫H-20261019-13返却（区切り3：文字帯とWAKE）

2026-10-19 姫・Opus 5.5。区切り3だけを行った。commitなし、実サーバーと画面の操作なし。区切り4（snapshotの統合）には触れていない。

**baseline**：`test-view-model-current-wake.cjs`と`view-model-current-wake.baseline.json`を作った。匿名の合成シナリオで、文字帯6段とWAKE12段を記録した。
- 取得元は`73b623ea`のテンプレート。固定条件は前の区切りと同じ（`TZ=UTC`・`ja-JP`・固定時刻）。
- 文字帯の6段：
  - 空
  - 実着手が現在の作業になる
  - 状態通知とPING・WAKE・ACKで現在が置き換わらない
  - presenceつきの返却が現在になる、フォーカス中は末尾へ追わない
  - 不調で現在を保つ
  - 窓が縮んだ回復
- WAKEの12段：
  - 担当一覧（新しい順・ユーザーの除外・先頭の選択）
  - 選択、二度押しで送信は1回だけ、送信済みの注記
  - 依頼済み（ボタン無効）、ACK済み
  - 既存の未応答の依頼が返る
  - 担当を変えると注記が消え、戻しても消えたまま
  - 送信の失敗、結果不明（再送しない）
  - 担当一覧が変わったら先頭の担当へ戻る
- 既知の制約はファイルの`knownLimits`に書いた。

**変更**：
- **文字帯**：純粋関数を2つ足した。
  - `currentBandViewModel(rows)`：現在の作業。実着手は含め、状態通知とPINGは除く。
  - `activityTimelineViewModel(rows, withCurrent)`：カード・年齢の段（latestかolderか）・文字帯・ステータス文字。

  DOMは`createActivityTimelineView`が描き、ノードの同一性・末尾追従とアンカーのscroll・フォーカスを保つ。`createActivityView`は外から見た形（`update`・`failure`）を変えず、VMを作ってViewへ渡す役にした。
  - 文字帯は、表示する文字帯があるときだけ導出する（`withCurrent`）。前の動作と同じで、文字帯のないタイムラインは現在の作業を計算しない。`test-event-age.cjs`はタイムラインの部分しか読み込まないので、これがないと落ちる（実際に一度落ちた）。
- **WAKE**：純粋関数を3つ足した。
  - `wakeSelection`：選択の戻し先
  - `wakeKey`：注記を消すかどうかの判定キー
  - `wakeViewModel`：担当一覧・ボタンの無効と説明・状態の文字・種類・説明

  `createWakeView`は描画と、操作の意図（変更・押下）を返すことだけを受け持つ。選んだ担当・送信中・注記は、`createWakeControl`が入力の状態として持つ。ボタンの状態は表示の情報で、権限ではない。サーバーが従来どおり毎回検証する（コメントにも書いた）。

**契約のケース**（挙げたもので、網羅ではない）：
- 文字帯：実着手は現在に入り、状態通知とPINGは入らない。依頼だけでも現在になる。記録がなければ「未登録」。年齢の段とステータス文字。表示しないときは導出しない。
- WAKE：
  - 選択の戻し先、判定キー
  - 依頼済みでボタン無効、注記は渡されたまま表示、送信中、担当なしで無効
  - ACKは受信の確認で、待機の終わりはメンバー状態で見る、という説明が出ること

**固定VM→DOMと操作の意図**：
- タイムライン：カードの文字・title・event・年齢・class・tabIndex、文字帯、ノードの同一性、ステータスを渡されたとおりに描く。不調のときは文字帯を保つ。
- WAKE：選択肢・選択値・無効・説明・状態を描く。同じ一覧なら選択肢を作り直さない。変更と押下は、意図として返すだけ。

**ソース検査**：
- タイムラインのViewが、履歴の関数と文言（現在・記録なし・取得不調）を参照していないこと。
- WAKEのViewが、`wakeStatus`・`wakeOwners`・`wakeKey`と、文言（送信中・ACK・依頼済み）を参照していないこと。

**検証**：
- baselineの比較（6+12段）：PASS。
- 否定対照：一時コピーで「送信中…」の文字を変えるとWAKEの2段目で、状態通知の除外をやめると文字帯の2段目で落ちた。一時コピーは削除済み。
- `node test-*.cjs`：18本すべてPASS（新規を含む）。
- `test-activity.cjs`と`test-wake.cjs`は、そのままPASSしたので変更していない。
- `sync.py`（verify.cjsを含む）は成功、`--check`はずれなし、`git diff --check`は問題なし。

**hash（SHA-256、先頭8桁…末尾8桁）**：
- 開始時の`index.template.html`：`463920fb…`
- 終了時：
  - `index.template.html`：`5a50ea3a…29853bf7`
  - `test-view-model-current-wake.cjs`：`308649d2…453d63e5`
  - `view-model-current-wake.baseline.json`：`927b139d…0aba3e31`
- 変更なし：`test-activity.cjs`（`1816840c…598973d7`）、`test-wake.cjs`（`a2abb9a3…79eceb6f`）

**未確認**：実画面の見た目、Python側の試験。


## H-20261019-14：共通配線と最終試験

2026-10-19、ユーザーは「残る第4区切りの共通配線・最終試験も、進めてよいですか？」への回答として「すすめて」と明示承認した。自動承認レビューで止まった第4区切りを再開する。区切り3のcurrent/WAKE専用試験はAstraが独立実行しPASS、6+12段互換と固定VM→DOM/操作の範囲で限定受入済み。

姫へ：source別のlast-good/成否/世代/受信時刻と時計・UI入力をsnapshotへ集約し、純粋deriveStudioから同revisionのmembers/cards/current/wakeを各Viewへ配布。API間の同時性を捏造しない。配送順序（古い応答・失敗・回復）、snapshot→VM、固定VM→DOM/操作、最小接続を分けて試験。安定メンバー順とWAKE選択はUI入力、flash再描画は最新VMのみ、時計tickで鮮度更新を確認する。

占有：index.template.htmlと今回VM試験/匿名baseline、接続変更に必要なactivity/work-lane/wake/handoff/continuity試験、新規test-view-model.cjs等の限定試験、本書返却欄。必要ならCOMMUNICATION_PROTOCOL.mdの実装状況説明のみ可。サーバー/API契約・承認UI全体・保存編集UI・OPS149/152の意味変更は対象外。旧baselineを書換えず、互換差は理由を返す。全関連cjs/sync/checkを実施。

source順序保護、非同時性、実配線とrevision、列挙試験と未確認を返却。独立評価まで連続待機。commit/実サーバー再起動/ユーザー画面操作は禁止を維持。

## 受入後のキャッシュ更新予定

ユーザー追加希望。VM責務・順序保持のUI入力・二段試験・残る限界を、受入済み正本から根拠付きで限定コピーする。既存規則どおり、実装成果のcommit後にのみ開始。commit許可は別途必要で、未commit中は更新しない。全キャッシュ再構築や会話上の仮説の事実化はしない。

## 姫H-20261019-14返却（区切り4：共通snapshotと最終試験）

2026-10-19 姫・Opus 5.5。commitなし。実サーバー（8088）とユーザーの画面には触れていない。サーバー・API契約・承認UI・保存編集UI・OPS-149/152の意味は変えていない。旧baselineの3ファイルも書き換えていない（hashは取得時のまま）。

### 実配線とrevision

- **snapshot**（`emptyStudioSnapshot`）：
  - ソースごと（activity・approvals・continuity）に、世代・受信時刻・最新の成否・最終正常値を持つ。
  - 時計（`clock`）と、UIの状態（`memberOrder`・`wakeSelected`・`wakeBusy`・`wakeNote`・`wakeNoteFor`）も入力として持つ。
  - activityの新着判定のための既読集合も持つ。
- **`applyStudioInput`**（純粋）：入力1件につき、新しいsnapshotを返す。前のsnapshotは変えない。revisionは+1。失敗は最終正常値を残す。WAKEの選択の戻し先と、注記を消す条件は、ここで正規化する。
- **`deriveStudio(s, parts)`**（純粋）：頼まれた部分だけを作る（members・cards・timeline・wake）。全部が同じrevisionを持つ。
  - ソースは受け取ったままの組み合わせとして扱う。たとえば、承認の不調はカードのステータスにだけ出て、タイムラインには出ない。同時点のサーバー状態をでっちあげない。
- **`createStudio`**：唯一のプレゼンター。入力ごとにderiveを1回行い、その入力に依存する部分のViewへ、同じrevisionで渡す。
  - 依存関係：
    - members：activity・continuity・時計
    - cards：activity・approvals
    - timeline：activity
    - wake：activity・wakeの操作
  - 表示中のメンバー順は、UIの入力として書き戻す。
  - WAKEの送信（送信中→1回だけ送る→結果の注記、再送しない）も、Viewではなくここで行う。
- **ページ**（`workLaneInstance`）：studioを1つだけ作り、4つのView（`createActivityTimelineView`・`createWorkLaneView`・`createMemberLampView`・`createWakeView`）を持たせた。入力は次の4つ。
  - activityのpoller（`workLaneInstance().activity/activityFailure`）
  - 承認（既存の`workLaneInstance().approvals/approvalFailure`。承認UIのコードは無変更）
  - continuity（`createContinuityStatus`の`onData`→`studio.continuity`）
  - 時計（`setInterval(()=>studio.tick(performance.now()),1000)`）
- **`continuityLabel`**：継続の文字を作る純粋関数。continuityの境界とderiveの両方が使う。
- **単独の部品**（`createActivityView`・`createPresenceLamps`・`createWorkLane`・`createWakeControl`）：同じ`createStudio`に、Viewを1つだけ持たせた薄い包みにした。既存の試験とbaselineは、本番と同じ道を通る。ページ自体は、これらの包みを使っていない。
  - `createPresenceLamps.continuity(fn, owners)`は、文字を作る関数を渡す試験用の入口（`labelOf`）として残した。
  - `test-event-age.cjs`のようにタイムラインの部分しか読み込まない試験でも動くよう、snapshotは自分が持つ部分の処理しかしない。

### ソースの順序の保護

- activityと承認のpollerは、同時に1本しか取らない（既存のまま）。
- continuityの境界は、遅れた古い応答を捨て、失敗は`failed`として最終正常値を残す（既存のガードの出力を`onData`に変えただけ）。
- snapshot側では、失敗は世代+1・`ok:false`・最終正常値の保持になり、回復で`ok:true`に戻る。

### 互換の差（宣言済み、1件）

- 内容：activityの取得不調の間も、continuityの更新（と時計）でメンバー欄の不調の文字を塗り直し、継続の文字が新しくなる。前は、不調になった時点の文字のまま、activityの回復まで止まっていた。
- 理由：continuityは別のソースで、それぞれ自分の成否を持つ。activityが読めないことを理由に、continuityの新しさを隠さない（同時性をでっちあげないのと同じ考え）。
- baseline：`test-view-model-members.cjs`の10段目と11段目にだけ、`KNOWN_DIFFERENCES`として期待の文字を書いた。差が本物であること、文字以外（state・pending・新着・stale・順序）は同じであることも検査する。baselineのファイルは書き換えていない。他の段は完全に一致する。

### 試験（並べた契約のケース）

1. **入力→snapshot**（`test-view-model.cjs`）：
   - 世代・受信時刻・成否
   - 失敗で最終正常値を残す
   - ソースの独立
   - 未知の入力の拒否
   - 前のsnapshotを変えない
   - continuityの境界が遅れた応答を捨て、失敗のときも最終の印を残す
2. **snapshot→VM**：
   - 部分の選択、純粋性
   - ソースの非同時性（承認の不調・activityの不調・回復で、それぞれの部分の表示）
   - 時計だけで鮮度が変わる（10秒前→55秒前→確認が古い→不調）
   - UIの入力（WAKEの先頭の選択、選択、注記の表示と消去、一覧にない選択の戻し先、メンバー順の保持と去った担当の除去）
3. **配布**：
   - activityは4つのView全部へ、同じrevisionで
   - 承認はカードだけ、時計とcontinuityはメンバー欄だけ、WAKEの選択はWAKEだけ
   - 不調のときは各Viewの不調の描画
   - WAKEの送信は、二度押しで1回だけ、結果の注記が出る
   - 光：3秒後のタイマーは、最新のVM（continuityの更新後のもの）で塗り直す
4. **最小の接続**：ページのstudioが1つだけで4つのViewを持つこと、poller・承認・continuity・時計の配線（ソース検査）。
5. **固定VM→DOMと操作**：区切り1〜3の試験をそのまま使った（メンバー・カード・文字帯・WAKE）。baselineは区切り1〜3と同じ合成シナリオで、3本とも一致（メンバーは宣言した差だけ）。

### 試験ファイルの変更

- 配線の文字を確かめるassertを、新しい形へ置き換えた。
  - `test-continuity.cjs`：`onData:data=>studio.continuity(...)`と1秒の時計
  - `test-work-lane.cjs`：pollerがstudioに1本で入ること、WAKEも同じstudioのViewであること
- `test-view-model-members.cjs`：宣言した差と、sliceの印を直した。
- 新規：`test-view-model.cjs`
- そのほかの試験は変えていない。

### 検証

- `node test-*.cjs`：19本すべてPASS。`sync.py`（verify.cjsを含む）は成功、`--check`はずれなし、`git diff --check`は問題なし。テンプレートの4つのscriptは構文の解析が通る。参照するDOMのidは、どれもちょうど1つずつある。
- **隔離headless**（WebKit、port 18953、`REGISTRY_STUDIO_INBOX`は一時ディレクトリ。activity・continuity・承認・WAKEはブラウザ内の模擬で、サーバーへのPOSTは0件）：
  - ページのエラーは0件。
  - メンバー欄の開始待ち、作業カードの着手、文字帯、WAKEの選択肢が出た。
  - 時計で鮮度が進んだ（53→54秒前）。
  - WAKEの押下で「送信しました…」と出た（模擬に1件）。
  - activityの不調で、レーン「活動の取得不調・最終情報を保持」、メンバー欄の不調の文字が出て、継続が進む（宣言した差）。回復で元に戻る。
  - 証拠：`/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/tmp.bDtqpA3maX/`（`check.cjs`・`results.json`・`stage4.png`）。受入まで残す。
  - 隔離サーバーは自分で止めた。

### hash（SHA-256、先頭8桁…末尾8桁）

- 開始時の`index.template.html`：`5a50ea3a…`。区切り4の前の写しは`/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/tmp.UD4I6pJGJs/before-stage4.html`。
- 終了時：
  - `index.template.html`：`c0f0ea60…c6a28139`
  - `test-view-model.cjs`：`7345921a…bd718232`
  - `test-view-model-members.cjs`：`b6e24446…d1c0152c`
  - `test-continuity.cjs`：`888b6f85…8758ed86`
  - `test-work-lane.cjs`：`d89414e7…a47526f1`
  - `COMMUNICATION_PROTOCOL.md`：`524fe5e2…14eccae2`（§5の「状態の表示」の行に一文足しただけ）
- baselineの3ファイル（変更なし）：
  - members：`e7cc46d7…210cc6ef`
  - cards：`755cb483…ba433626`
  - current-wake：`927b139d…0aba3e31`

### 未確認と残る限界

- Python側の試験、実サーバーでの表示、狭い画面幅（今回は広い画面の1枚だけ）。
- 直近200件の窓、取消の書式が未定、同名の会話を区別できないこと、改名した宛先の開始待ちの残存は、構造の変更では解消しない（別の機能の扱い）。
- 承認とactivityは、別々の時刻の値を組み合わせたもの。
- ボタンの状態は権限ではなく、サーバーが毎回検証する。


## 独立最終評価の限定補正 H-20261019-15

ROUND2の3件で受入を保留。今回契約に関わるため最優先で補正し、全体監査へ広げない。姫へ、次の確定契約へ合わせる実装と回帰試験を行う。

1. 同revision配布：依存部分だけに絞る最適化は今回採用しない。1入力で単一snapshotをderiveし、存在する全対象Viewへ同revisionを配る。DOM更新の省略は描画値同一性などView側で可能だが、意味導出やrevision配布を省略しない。wrapperが一部Viewのみ持つ場合は存在部分だけでよい。
2. sourceメタデータ：公開入口とページの実接続で受信時刻を保持する。再現可能な注入clockを使い単位を明示。continuity失敗はsource.ok=falseとしlast-good保持、失敗を正常値で上書きしない。最小試験はapply関数直呼びだけでなく公開入口/配線から確認。
3. WAKE：送信開始時の担当と対応キーを固定して応答まで保持。待機中に別担当へ選択が変わっても送信結果をその担当へ付けない。A送信中→B選択→A成功/失敗のfixtureを追加。サーバー契約変更なし。

同じH14占有へ再割当。各補正と否定対照/試験を報告し独立再評価まで待機。共有source設計について異論や未決があれば実装前に返す。activity不調中も独立continuityが更新する明示差は、非同時sourceの扱いに整合する限定差として採用し、旧baselineを維持する。commit/実サーバー/ユーザー画面操作なし。

## 姫H-20261019-15返却（独立評価3件の補正）

2026-10-19 姫・Opus 5.5。3件とも、確定した契約どおりに直した。共有ソースの設計に異論はない。commitなし。実サーバーとユーザーの画面には触れていない。旧baselineの3ファイルは無変更（hashは前回と同じ）。

1. **同revisionを全Viewへ**：依存関係で絞る配布（`STUDIO_PART_SOURCES`）をやめた。入力ごとにsnapshot全体をderiveし、studioが持つ全部のViewへ同じrevisionを渡す。Viewを一部しか持たない包みは、持っている部分だけを描く。DOMの書き込みを省くのは、各Viewの既存の「同じ値なら書かない」に任せた（意味の導出もrevisionの配布も省かない）。
   - 試験：activity・承認・時計・continuity・WAKEの選択のどれでも、4つのViewが同じrevisionを受け取る。Viewを1つだけ持つstudioは、そのViewだけを描く。
   - 否定対照：一時コピーでタイムラインへの配布をactivityの入力だけに戻すと、「approvals: every view, same revision」で落ちた。
2. **ソースのメタデータ**：
   - `createStudio`に時計を注入できるようにした（`now`、既定は`Date.now`）。`receivedAt`は、この壁時計のミリ秒（epochから）。継続の鮮度用の時計は`performance.now()`のままで、別のもの。この単位の区別はコードのコメントにも書いた。
   - 公開の入口（`activity`・`activityFailure`・`approvals`・`approvalFailure`・`continuity`）が、受信時刻を必ず入れる。
   - continuityの失敗は、ソースの`ok:false`として記録する。最終正常値は残り、失敗で正常値を上書きしない。表示は「継続 不調（最後に読めた確認 …）」。
   - 試験は、apply関数の直接呼び出しではなく公開の入口から行った。continuityは、ページと同じ配線（`createContinuityStatus`の`onData`→`studio.continuity(data, perf)`）を通し、成功と失敗の世代・ok・受信時刻・最終正常値を確かめた。
   - 否定対照：一時コピーで、activityの受信時刻を外すと受信時刻の検査で、continuityの失敗を`ok:true`に戻すと「a failed fetch is ok=false」で、それぞれ落ちた。
3. **WAKEの応答の帰属**：送信を始めた時点の担当と、その担当の依頼状態のキーを`ui.wakeSending`として固定し、応答まで持つ。送る相手と、結果の注記の`wakeNoteFor`には、この固定したものを使う。待っている間に別の担当へ選択を変えても、結果をその担当へ付けない。
   - 新しいfixture：A（甲）の送信中→B（乙）を選択→Aの成功／失敗。どちらでも、送り先は甲、乙の表示に注記は出ず、注記は甲の開始時のキーに紐づく。選択を変えなかった場合は、その担当に注記が出る（対照）。サーバーの契約は無変更。
   - 否定対照：一時コピーで注記のキーを「完了時に選ばれている担当」に戻すと、「success: the result of 甲 is not shown for 乙」で落ちた。
   - 振る舞いの補足：開始時のキーで固定したので、送信中にその担当の依頼記録が届いた（依頼済みになった）場合は、完了後の注記ではなく「依頼済み・ACK待ち」が出る（記録がもう反映されているため）。WAKEのbaseline12段は、このケースを含まず一致した。

**検証**：
- `node test-*.cjs`：19本すべてPASS。`sync.py`（verify.cjsを含む）は成功、`--check`はずれなし、`git diff --check`は問題なし。
- 隔離headlessを再実行した（同じ条件、`/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/tmp.bDtqpA3maX/r2/`）。ページのエラーは0件、サーバーへのPOSTは0件（WAKEはブラウザ内の模擬に1件）。表示・不調・回復は前回と同じ。隔離サーバーは止め、一時のinboxは削除済み。

**hash（SHA-256、先頭8桁…末尾8桁）**：
- 開始時の`index.template.html`：`c0f0ea60…`
- 終了時：`index.template.html`は`704d18fa…6d0ec885`、`test-view-model.cjs`は`d0012c2e…cdbd28c1`
- baselineの3ファイル：変更なし

**範囲**：上の3件と、その回帰試験だけ。その他は変えていない。


## Astra技術受入・今回の区切り（2026-10-19）

4段階の実装を補正付きで技術受入。ROUND1の順序境界とROUND2の3件を姫が補正し、独立ROUND3で3件すべて確認、新規指摘なし。Astraが最終19本のJavaScript試験、sync --check、diff --checkを独立実行しPASS。member/card/current/WAKEの匿名baselineと契約試験、入力配送順序・snapshot→VM・固定VM→DOM/操作・実配線を分離して確認した。全View同revision配布、実入口受信時刻と失敗、WAKE送信対象固定を含む。

姫の隔離WebKit結果・画像を読取り確認。広い画面でメンバー/カード/current/WAKEが描画され、模擬送信・不調/回復の結果とエラー0を確認。ユーザー実画面/稼働サーバー/狭幅の確認ではない。サーバー側変更はなくPython試験は対象外。activity不調中に独立continuity/時計が進む明示差は採用し、旧baselineはそのまま保存した。

残境界は200件窓、取消・改名・同名識別、OPS149停止理由/代理停止、OPS152監視UI。これらを今回解決済みとはしない。各APIの値は非同時であり、VMは同時整合を保証しない。コミットは未実施でユーザー承認待ち。受入済み判断の限定キャッシュ更新は、そのcommit後に行う。

一時作業物: 姫が記録した `/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/tmp.bDtqpA3maX/`（隔離WebKitの結果・画像・検証スクリプト、r2を含む）と `/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/tmp.UD4I6pJGJs/before-stage4.html`（区切り4前の控え）は証拠として保持。今回削除していない。

姫へ：H-15補正を受入。WAKE-20261019-Pへ同番号ACKと本人endedを記録し、今回の連続待機を終了。追加実装・キャッシュ更新はまだ依頼していない。


## 完了確定（2026-10-19）

ユーザーが受入済み成果のcommitを明示承認。今回の実装・試験・受入をDONEとする。姫のWAKE-P本人ACK/endedも確認済み。残境界は上記の別taskに保持。成果を先に固定してから、受入済み判断のみAstraのローカルキャッシュへ限定コピーする。
