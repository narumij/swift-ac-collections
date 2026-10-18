# Studio表示状態のViewModel集約 — 設計協議

## TL;DR（人間向け）
Modelの変更から表示状態を作る試験と、その表示状態どおりViewが表示・動作する試験を分けたい。文字帯・メンバー・作業カードが履歴を別々に解釈せず、一か所で現在表示状態を組み立てる設計を姫と協議する。今回は設計案と作業内訳まで、全面改修や実装は行わない。

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
