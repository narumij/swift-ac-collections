# OptionalArray体系監査

最終更新: 2026-10-08 / Codex

## 目的

OptionalArrayの公開契約を、実装、test、git履歴に照らして閉じ、Codexのユーザードキュメント
作業フェーズへ渡せる状態にする。本書は体系監査の正本であり、利用者向け本文そのものではない。

## 範囲と受入基準

対象は `Sources/OptionalArrayModule/OptinalArray.swift` の公開7型・公開宣言29件、および
`Tests/OptionalArrayModuleTests` の4ファイルである。

完了には次をすべて満たす。

- 公開宣言ごとに境界、所有、寿命、破棄、変更、`Sendable`、次元契約を確認する。
- 各契約をtest、利用例、git履歴上の決定と対応付ける。
- 事実、過去判断、現在の推論を区別する。
- 未検証契約と判断点を分離する。
- 判断点は一判断ごとのDECISION taskへ登録し、agentが結論を補わない。
- Test as Specification整理後、契約表、test根拠、決定事項、未決定事項を引き渡す。

利用者向け本文、コメントドック全件整備、storage再設計、strict memory safety恒久適用は含めない。

## 現物

- 実装: `OptinalArray.swift` 1ファイル、487行。
- 公開所有型: `OptionalArray1D`、`OptionalArray2D`、`OptionalArray3D`、
  `OptionalArray4D`。
- 公開非所有View: `OptionalArray1DView`、`OptionalArray2DView`、
  `OptionalArray3DView`。
- 公開宣言: 型7、initializer 4、`removeAll()` 4、subscript 7、`indices` 7、計29。
- 公開適合: 所有4型が `Element: Sendable` のとき `@unchecked Sendable`。
- test: `OptionalArrayTests.swift`、`OptionalArrayDeathTests.swift`、
  `EDPC-J.swift`、`EDPC-L.swift`。

## 公開契約表

| 公開面 | 宣言数 | 実装から確認できる契約 | 主な既存根拠 | 現在の状態 |
| --- | ---: | --- | --- | --- |
| 所有型1D〜4D | 4 | move-only。raw storageを所有し、deinitで設定済み要素と2本のbufferを破棄 | 2D〜4Dの参照型deinit test | 1Dの残存要素deinitを直接固定するtestがない |
| initializer | 4 | 全slotを未設定にし、次元積をcapacityとして確保 | 初期nil、2D〜4Dの基本アクセス | 負値、積overflow、zero dimensionの契約が未整理 |
| `removeAll()` | 4 | 設定済み要素を破棄し、全slotを未設定へ戻す。capacityは保持 | 1D〜4D基本test、2D参照破棄、3D/4D再利用test | 1D/2Dの参照型再利用は直接未固定 |
| 所有型subscript | 4 | 1Dはoptional値を取得・変更。2D〜4Dは一段低い非所有Viewを返す | 基本アクセス、storage共有、4D次元回帰test | NOP setterはpointer-backed Viewで完了済みの変更を連鎖subscriptへwritebackする実装手段。View全体代入の提供を意図したものではない |
| 所有型`indices` | 4 | 1Dはcapacity、2Dはheight、3Dはdepth、4Dはsize3を外側範囲として返す | 各型のindices test | 命名と軸順序の体系判断は未実施 |
| View型1D〜3D | 3 | storageを所有せず親のbufferを参照。親より長く保持できない | storage共有、コメントドック | 寿命は型システムで拘束されず、恒久対応は凍結中のstorage再設計範囲 |
| View subscript | 3 | 1Dはoptional値を変更。2D/3Dは一段低いViewを返す | View上書き寿命、View境界Death Test、full-plane stride回帰test | 3D Viewの2D面stride不足を修正済み。NOP setterの位置づけは所有型と同じ |
| View `indices` | 3 | count、height、depthを外側範囲として返す | `testViewIndices`、4D次元回帰test | 3D Viewのdepth境界と非対称な面strideを回帰testで固定済み |
| `@unchecked Sendable` | 4適合 | move-only所有型を、ElementがSendableならTask間移送可能と宣言 | 1Dだけのcompile test（`testSendable_compiles`）。2D〜4Dのcompile testはない | 並行共有を許す契約ではないことの明文化と根拠確認が必要 |

## test対応の現在地

### 仕様根拠として機能しているもの

- 1D〜4Dの基本的な初期状態、設定、取得、nil代入、`removeAll()`。
- 2D〜4Dが返すViewによる親storageの変更。
- 所有4型とView 3型の`indices`。
- 参照型要素の上書き、nil代入、`removeAll()`、所有型deinitでの一回だけの破棄。
- 3D/4Dの`removeAll()`後のslot再利用。
- 1D所有型とView、および2D/3D Viewの一部境界違反。
- `OptionalArray1D`の条件付き`Sendable`がcompileすること（2D〜4Dのcompile testはない）。

### 利用例

`EDPC-J.swift` と `EDPC-L.swift` は競技プログラミングでの実利用形状を示すcompile対象である。
両fileの関数はどのtestからも呼ばれず、アルゴリズムの期待値testとしては実行されていない。
公開宣言ごとの契約を閉じる仕様testとも区別する。

### 未検証または部分的なもの

- initializerの負値、zero dimension、次元積overflow。
- 2D〜4D所有型の外側subscriptについて、負値・上端・read/writeの組合せ。
- 多次元Viewの未網羅な各軸について、非対称な次元を使ったoffsetと境界。
- 1D所有型の、設定済み参照要素を残したままのdeinit。
- 1D/2Dの`removeAll()`後の参照型slot再利用。
- `@unchecked Sendable`の採用理由と、許される並行利用の境界。

## 履歴から確認できること

| 履歴 | 確認できる事実 |
| --- | --- |
| `6fd45542`（2026-06-07） | BareArrayとOptionalArrayを現モジュール構成へ導入。OptionalArray実装と基本testを同時追加 |
| `55d19905`（2026-06-09） | EDPC-J / EDPC-Lの利用例を追加 |
| `9b100953`（2026-06-10） | 所有4型へ条件付き`@unchecked Sendable`を追加 |
| `7d4c45af`（2026-10-02） | 参照型寿命testを追加 |
| `0d6f370f`（2026-10-02） | slot所有、nil代入、View非所有・親寿命依存をコメントドックへ明記 |
| `80747415` / `f5a8852b`（2026-10-03） | strict memory safety対応を段階的に実施し、恒久適用はstorage再設計まで保留 |
| `b3570172`（2026-10-04） | 3D Viewの上端判定をheightからdepthへ修正し回帰testを追加 |

2026-10-08のユーザー確認により、NOP setterは連鎖subscriptを成立させる過程で必要になった実装手段で、
View全体代入を提供するための公開契約ではないと確定した。実装へwriteback目的のコメントを追加した。
同日、3D Viewのpointer offsetが2D面strideを欠いていたことを、非対称次元の回帰testが修正前に
aliasとして検出した。`width * height * position`へ修正し、別sliceが独立することを固定した。

履歴は現在の契約を支持する根拠として使えるが、位置づけ、名称、initializerの不正次元を
どう扱うかについて、ユーザー決定が存在することは現時点で確認できていない。

## 要確認事項

### 実装上の事実確認

1. 所有2D〜4DとView 2D/3DのNOP setterは連鎖subscriptのwriteback用と確定した。将来accessor構成を
   変更する場合も、連鎖した要素変更が成立することを維持する。
2. 3D Viewの2D面offsetは修正済み。残る多次元経路も、非対称次元のtest対応監査で確認する。

### 判断候補

次はまだ決定taskではない。事実監査後、一判断ずつ登録する。

- OptionalArrayを競技プログラミング用の低レベル公開部品として維持するか。
- `OptionalArray1D`だけ次元suffixを持ち、BareArrayの1D所有型は`BareArray`である不揃いをどうするか。
- 2D/3Dの`width`・`height`・`depth`と4Dの`size0`〜`size3`をどの体系へ揃えるか。
- initializerの不正な次元をpreconditionとして明文化・検査するか。

## 次の作業

1. 公開宣言29件をtest単位まで対応付け、未検証一覧を確定する。
2. 残る多次元経路を非対称次元で確認する。
3. 名称・次元体系をBareArrayと比較する。
4. 確認後に必要なDECISION taskを一判断ずつ登録する。

## Claude向け証拠収集package

次のpackageは互いに独立して着手できる。Claudeの提出はCodexが検収するための材料であり、提出だけで
親監査を完了しない。共通停止条件は次のとおり。

- 公開方針、名称、契約、修正方針を決定しない。
- production code、test、利用者向け文書を変更しない。
- 推測を事実として埋めず、根拠がない欄は「未確認」とする。
- 不具合または新しい判断点を見つけた場合、実装せず根拠と最小再現候補を報告する。
- 結果は本書の対応する表へ追記できるが、既存のCodex結論を上書きしない。

| package | 成果物 |
| --- | --- |
| 公開宣言ledger | 29宣言を一件ずつsource位置・種別・コメントへ対応付けた表 |
| 所有型test根拠 | 所有4型の公開memberごとのtest名・検証事実・不足表 |
| View test根拠 | View 3型の公開memberごとのtest名・検証事実・不足表 |
| 境界test | access経路 × 負値/上端 × read/write × 構成のmatrix |
| 参照型寿命 | 型・操作ごとの期待破棄回数とtest有無のmatrix |
| 次元・offset | 各次元の軸順、indices、stride、offset式と非対称次元testの対応表 |
| Sendable履歴 | 導入履歴、記録された理由、現行test、未記録事項の区分表 |
| 不正次元 | 負値、zero、overflowの現挙動とtest有無。方針提案は別欄へも書かない |
| EDPC利用例 | 利用公開面、利用形状、アルゴリズム固有部分の分類表 |
| コメントcoverage | 29宣言 × 契約項目の記載有無表。文案は作らない |

### 証拠package横断coverage assignment（2026-10-08）

担当: Claude。提出済み10 packageを、公開宣言29件と本書の受入基準（境界、所有、寿命、破棄、変更、
`Sendable`、次元契約、test、利用例、履歴）へ再配置し、各セルを`充足` / `部分` / `未確認` / `相互不一致`
で表にする。各判定には既存packageの節・行または現物の位置を付ける。新しい広範な再調査は行わず、
既存package間の重複と食い違いも明示する。

不足を直ちにtest taskやDECISIONへ変換せず、公開方針、名称、不正次元、`Sendable`、寿命の契約を
決定しない。production code、test、利用者向け文書、既存のCodex結論は変更しない。不具合または
新しい判断点が見つかった場合は、根拠と最小再現候補を記録して停止する。成果物は本節の直後へ
`### OPT-025 受入基準coverage matrix`として追記し、Codexが`OPT-008` / `OPT-009`の完成判定に使う。

### OPT-025 受入基準coverage matrix

2026-10-08 / Claude Opus 5.5（`claude-opus-5-5`）。既存10 packageの再配置で、新しい調査は行っていない。`#`は
OPT-015の宣言番号。同じ判定になる宣言はまとめて1行にした。`—`はその基準が当てはまらない
（例: indicesに破棄はない）ことを表す。参照の`T` / `D` / `L`はOPT-015冒頭の略記と同じ。
ドキュメントコメントの記載有無はOPT-024にあり、この表では各基準の根拠に含めない（コメントはtestでも履歴でもない）。

| # | 宣言 | 境界 | 所有 | 寿命 | 破棄 | 変更 | `Sendable` | 次元 | test | 利用例 | 履歴 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `OptionalArray1D` | — | 部分（残存deinitのtestなし、OPT-016） | 部分（同） | 部分（`removeAll()`の1件だけ、OPT-019） | — | 部分（compileだけのT277。理由未記録、OPT-021） | — | 部分 | —（EDPCは使わない、OPT-023） | 充足（OPT-021、本文の履歴表） |
| 6 / 11 / 16 | `OptionalArray2D` / `3D` / `4D` | — | 充足（T374 / T357 / T391、OPT-019） | 充足（同） | 充足（同） | — | **相互不一致**（本文62行目は4型のcompile testありとするが、testは1Dだけ、OPT-016） | — | 部分（Sendableを除く） | 2D・3Dは部分（compileだけで実行されない。**本文67行目と相互不一致**、OPT-023）。4Dは— | 充足 |
| 2 | 1D `init(capacity:)` | 部分（負値・zeroの現挙動は実測、testは0件、OPT-022） | — | — | — | — | — | 部分（同） | 部分（T8の初期nil） | — | 部分（不正次元の決定記録なし、本文95-96行目） |
| 7 / 12 / 17 | 2D〜4Dのinit | 部分（OPT-022。`-Ounchecked`の積overflowは停止事項として記録済み） | — | — | — | — | — | 部分（offset式は机上と一時dirの実行で確認、OPT-020。不正次元のtestなし） | 部分（初期nilは一部slotだけ、OPT-016） | 2D・3Dは部分（OPT-023）。4Dは— | 部分（1と同じ） |
| 3 | 1D `removeAll()` | — | — | — | 部分（1件の破棄だけ。再利用のtestなし、OPT-019） | 充足（T37） | — | — | 部分 | — | 充足 |
| 8 | 2D `removeAll()` | — | — | — | 部分（T339の2件。再利用のtestなし） | 充足（T72） | — | — | 部分 | — | 充足 |
| 13 / 18 | 3D / 4D `removeAll()` | — | — | — | 充足（T410 / T435、再利用とdeinit 1回） | 充足（T119 / T168） | — | — | 充足 | — | 充足 |
| 4 | 1D subscript | 部分（D10 / D17 / D24。上端の書込みなし、OPT-018） | 充足（T286） | — | 充足（上書き・nil、T286） | 充足（T16 / T27） | — | — | 部分 | — | 充足（二重解放の修正履歴、OPT-021の`7d4c45af`） |
| 9 / 14 / 19 | 2D〜4D所有型の外側subscript | 部分（実装はL163 / L236 / L311の`precondition`。testは0件、OPT-018） | — | — | — | 充足（storage共有T86 / T132 / T182） | — | 部分（alias検出testなし: 行stride・面stride・立方体stride、OPT-020） | 部分 | 2D・3Dは部分（OPT-023） | 充足（NOP setterの位置づけは本文90行目） |
| 5 / 10 / 15 / 20 | 所有4型の`indices` | — | — | — | — | — | — | 充足（T51 / T97 / T144 / T221 / T233、OPT-020） | 充足 | — | — |
| 21 | `OptionalArray1DView` | — | 部分（非所有の直接testなし、間接だけ、OPT-017） | 部分（親より長く保持する違反は型で拘束されず、testできない、OPT-017） | — | 充足（T86 / T312） | —（適合なし。除外理由は未記録、OPT-021） | — | 部分 | — | 充足（`0d6f370f`のコメント明記、本文の履歴表） |
| 24 / 27 | `OptionalArray2DView` / `3DView` | — | 部分（同上） | 部分（同上） | — | 充足（T132 / T182） | —（21と同じ） | — | 部分 | — | 充足（3DViewは`b3570172` / `89a93f9d`） |
| 22 | 1DView subscript | 部分（D31 / D38の負値だけ、OPT-018） | 充足（T312） | — | 充足（T312、親の`removeAll()`も含む） | 充足（T312） | — | — | 部分 | 2D・3D経由で部分（OPT-023） | 充足 |
| 25 | 2DView subscript | 部分（D45の負値だけ。上端と純粋な読み取りなし） | — | — | — | 充足（T132） | — | 部分（T208が面と行の区別だけ、OPT-020） | 部分 | 3D経由で部分 | 充足 |
| 28 | 3DView subscript | 部分（D52 / D59。純粋な読み取りなし） | — | — | — | 充足（T182） | — | 充足（T195 / T208、修正`89a93f9d`） | 部分 | — | 充足 |
| 23 / 26 / 29 | View 3型の`indices` | — | — | — | — | — | — | 充足（T233、T195） | 充足 | — | — |

構成の注記（境界の列すべてに共通）: Death TestはmacOSのDebugでだけ既定で走り、Releaseと`-Ounchecked`は未実施（OPT-018）。
したがって、境界の「部分」は「どの構成でもtestで固定されていない経路がある」を含む。

package間の重複と食い違い:

- 重複（内容は一致）: T86はOPT-016（2Dのsubscript）とOPT-017（1DViewの親storage共有）の両方に出る。T312はOPT-017とOPT-019の
  両方に出る。行・面・立方体strideのalias test不足は、OPT-016とOPT-020が同じ事実を書いている。
  不正次元の`-Ounchecked`の挙動は、OPT-018の構成表とOPT-022で一致する。
- package同士の食い違い: 見つからなかった。
- 本文との食い違い（既出の2件、Codex intakeで`OPT-009`へ移管済み）: `Sendable`のtest範囲（本文62行目）と、
  EDPCの実行有無（本文67行目）。
- 停止事項: 新しいdefectと判断点はない。`-Ounchecked`の積overflowは、OPT-022で記録済みの停止事項のまま。

Codex acceptance（2026-10-08）: 指定された受入基準への再配置、根拠位置、重複・不一致の区別を
満たすため受け入れた。これはcoverage不足をすべてtest化する判断でも、公開契約を確定する判断でもない。
本文との既知不一致2件は、判断を伴わない事実補正として別taskへ渡す。

### OPT-026 監査本文の証拠同期 assignment（2026-10-08）

担当: Claude。OPT-025で本文との不一致として再確認された次の2点だけを、本文の`公開契約表`と
`test対応の現在地`へ反映する。

- 条件付き`Sendable`のcompile testは所有4型すべてではなく1Dだけに存在する。
- EDPC-J / EDPC-Lは利用形状を示すcompile対象だが、testとして実行されてはいない。

既存testの価値、必要な追加test、公開契約、`Sendable`採用理由、利用例の採否を判断しない。
source、test、利用者向け文書、証拠表は変更しない。2点以外の本文へ変更を広げず、別の不一致を
見つけた場合は根拠を報告して停止する。

Codex acceptance（2026-10-08）: 2点だけが証拠表どおりに補正され、契約判断やtest追加へ広がって
いないため受け入れた。`OPT-026`を完了とする。

### OPT-027 判断候補の決定来歴 assignment（2026-10-08）

担当: Claude。本文の判断候補4件（低レベル公開部品としての位置づけ、`OptionalArray1D`の型名、
2D〜4Dの次元property名、不正次元の契約）について、git履歴、commit message、現行maintenance文書に
明示的な決定が存在するかを一件ずつ確認する。成果物は候補、検索範囲、発見した記録、
`決定あり` / `実装事実のみ` / `履歴なし` / `未確認`の表とする。

方針、名称、契約を提案・決定せず、BareArrayの凍結taskを再開しない。Archived資料は具体的な参照が
検索で見つかった場合だけ確認し、広い再構築を行わない。source、test、本文の既存結論を変更しない。
新しい判断点は結論を埋めず根拠だけを記録し、Codexへ返す。

### OPT-027 判断候補の決定来歴

2026-10-08 / Claude Opus 5.5（`claude-opus-5-5`）。HEAD `d66bf0f1`。検索範囲は共通で、`git log -S`（Sources）、
全branchのcommit message（`--grep`）、`Maintanance/`のArchived以外のMarkdown、`Tests/TESTING.md`、`README.md`。
Archivedは検索で具体的な参照が見つかった`PROGRESS_OVERVIEW_HISTORY_2026-10-07.md`だけを開いた。
OptionalArray関係のcommit messageは、2026-06の4件がすべて「bare, optional」「memo」「refactoring」で、本文が無い。

| 候補 | 検索範囲（共通以外） | 発見した記録 | 区分 |
| --- | --- | --- | --- |
| 競技プログラミング用の低レベル公開部品としての位置づけ | sourceの冒頭コメントとdoc comment | `OptinalArray.swift:12-13`の「コピペで提出に使っていただいて構いません。提出の際のライセンス記載は不要です」（`40d09031`、2026-06-08から）。型のdoc commentは「メモ化用配列」（`6fd45542`から）。EDPC-J / EDPC-Lの利用例（`55d19905`）。`README.md`にはOptionalArrayの記載が無い。facadeは2026-10-05から無条件に再公開（`d421972b`、`AcCollections.swift:3`） | 実装事実のみ（用途を示すコメントと利用例はあるが、公開部品として維持するという決定の記録は無い） |
| `OptionalArray1D`の型名（BareArrayの1D所有型は`BareArray`） | `-S"OptionalArray1D"`、`-S"BareArray1D"` | 導入の`6fd45542`（2026-06-07）から`OptionalArray1D`。BareArrayは同じcommitから1D所有型が`BareArray`で、`BareArray1D`という所有型の記録は無い（`BareArray1D`の検索に当たるのは`1b461564`以降の`BareArray1DView`）。`1b461564`（2026-06-08）で両moduleの`*Slice*`が`*View`へ改名された。2026-10-07以前の追加メニューに「`OptionalArray`の名称を再検討する」と「`BareArray`の名称を再検討する」があった（`Archived/PROGRESS_OVERVIEW_HISTORY_2026-10-07.md:350-351`、未着手のchecklist）。Registry `OPT-001`は「体系監査・名称再検討」 | 実装事実のみ（名称の再検討は課題として記録されているが、決定は無い） |
| 2D〜4Dの次元property名（2D / 3Dの`width`・`height`・`depth`、4Dの`size0`〜`size3`） | `-S"size0"`、`-S"width"`、BareArrayのinit | 導入の`6fd45542`から同じ名前（`size0`は`1b461564` / `cc0293ba`でも変更されている）。BareArrayのinitも同じ体系（`BareArray.swift:94,103,171,181,249,260`）。名前を選んだ理由の記録は見つからない | 実装事実のみ |
| 不正次元（負値・zero・積overflow）の契約 | `-S"init(capacity"`、`StrictMemorySafetyReadiness.md`、`Tests/TESTING.md` | 導入時からinitに次元の検査は無い（`6fd45542`）。現挙動はOPT-022で実測した。本文95-96行目に「不正次元をどう扱うかのユーザー決定は確認できていない」とある。検索範囲の文書に、不正次元の契約を決めた記録は無い | 履歴なし |

停止事項: なし。どの候補にも明示的な決定は見つからず、判断候補は4件とも未決のままである（本文の既存結論と一致）。
4件の選択肢や方針は書いていない。

Codex acceptance（2026-10-08）: `OPT-027`を受け入れた。公開宣言・契約・履歴とtest根拠の
各package、横断coverage、本文同期が受入基準を満たしたため、`OPT-008`と`OPT-009`を完了とする。
4件の判断候補は未決のまま維持し、名称・次元体系の比較を`OPT-010`で続ける。

### OPT-028 名称・次元surface比較 assignment（2026-10-08）

担当: Claude。OptionalArray 1D〜4D・View 1D〜3Dと、現行BareArray 1D〜4D・View 1D〜3Dについて、
型名、View名、initializer label、保存される次元property、各subscriptが落とす軸、`indices`が表す軸を
宣言と実装位置付きで対応表にする。不揃いと一致を機械的に示し、履歴調査はOPT-027を再利用する。

名称案、移行方法、source compatibility、どちらへ揃えるかを提案・決定しない。BareArrayの監査taskを
再開せず、比較に必要な現行宣言だけを読む。source、test、利用者向け文書、既存の判断候補を変更しない。
offset defect等を見つけた場合は実装せず、根拠と最小再現候補を記録して停止する。Codexが`OPT-010`の
判断候補整理に使う。

### OPT-028 名称・次元surface比較

2026-10-08 / Claude Opus 5.5（`claude-opus-5-5`）。HEAD `12d7f133`の現行宣言だけを読んだ。`O:L<n>`は`OptinalArray.swift`、
`B:L<n>`は`BareArray.swift`の行。履歴はOPT-027を参照（どちらの名前も導入の`6fd45542`から、Viewは`1b461564`で`*Slice*`から改名）。
「落とす軸」は、そのsubscriptの引数が選ぶ軸（外側の軸）を指す。

| 次元 | 項目 | OptionalArray | BareArray | 一致 / 不揃い |
| --- | --- | --- | --- | --- |
| 1D | 所有型名 | `OptionalArray1D`（O:L21） | `BareArray`（B:L21） | 不揃い（次元suffixの有無） |
| 1D | initializer label | `init(capacity:)`（O:L28） | `init(repeating:count:)`（B:L24）、`init(count:_:)`（B:L32） | 不揃い（`capacity`と`count`。BareArrayは初期値を受け取る2種） |
| 1D | 保存される次元property | `count`（O:L23） | `count`（B:L47） | 一致 |
| 1D | subscriptの要素型・accessor | `Element?`、get / `_modify`（O:L64） | `Element`、`unsafeAddress` / `unsafeMutableAddress`（B:L51-59） | 不揃い（型の性質による違い） |
| 1D | `indices`の軸 | `0..<count`（O:L96） | `0..<count`（B:L80） | 一致 |
| 2D | 所有型名 | `OptionalArray2D`（O:L120） | `BareArray2D`（B:L91） | 一致（同じ命名形） |
| 2D | initializer label | `init(width:height:)`（O:L129） | `init(repeating:width:height:)`（B:L94）、`init(width:height:_:)`（B:L103） | 次元labelは一致。初期値引数の有無だけ違う |
| 2D | 保存される次元property | `width`, `height`, `capacity`（O:L124-126） | `capacity`, `width`, `height`（B:L121-124） | 一致（宣言順だけ違う） |
| 2D | subscriptが落とす軸 / 返す型 | `height`（O:L163）/ `OptionalArray1DView`、offset `width * position`（O:L165） | `height`（B:L131）/ `BareArray1DView`、offset `width * position`（B:L132） | 一致 |
| 2D | `indices`の軸 | `0..<height`（O:L181） | `0..<height`（B:L157） | 一致 |
| 3D | 所有型名 | `OptionalArray3D`（O:L191） | `BareArray3D`（B:L168） | 一致 |
| 3D | initializer label | `init(width:height:depth:)`（O:L201） | `init(repeating:width:height:depth:)`（B:L171）、`init(width:height:depth:_:)`（B:L181） | 次元labelは一致 |
| 3D | 保存される次元property | `width`, `height`, `depth`, `capacity`（O:L195-198） | `capacity`, `width`, `height`, `depth`（B:L203-207） | 一致 |
| 3D | subscriptが落とす軸 / 返す型 | `depth`（O:L236）/ `OptionalArray2DView`、offset `width * height * position`（O:L238） | `depth`（B:L214）/ `BareArray2DView`、offset `width * height * position`（B:L216） | 一致 |
| 3D | `indices`の軸 | `0..<depth`（O:L254） | `0..<depth`（B:L241） | 一致 |
| 4D | 所有型名 | `OptionalArray4D`（O:L264） | `BareArray4D`（B:L246） | 一致 |
| 4D | initializer label | `init(size0:size1:size2:size3:)`（O:L275） | `init(repeating:size0:size1:size2:size3:)`（B:L249）、`init(size0:size1:size2:size3:_:)`（B:L260） | 次元labelは一致。両moduleとも4Dだけ`size0`〜`size3`で、2D / 3Dの`width`系と体系が違う |
| 4D | 保存される次元property | `size0`〜`size3`, `capacity`（O:L268-272） | `capacity`, `size0`〜`size3`（B:L284-289） | 一致 |
| 4D | subscriptが落とす軸 / 返す型 | `size3`（O:L311）/ `OptionalArray3DView(width: size0, height: size1, depth: size2)`、offset `size0 * size1 * size2 * position`（O:L313-317） | `size3`（B:L296）/ `BareArray3DView(width: size0, height: size1, depth: size2)`、同じoffset（B:L297-299） | 一致 |
| 4D | `indices`の軸 | `0..<size3`（O:L331） | `0..<size3`（B:L324） | 一致 |
| View 1D | 型名 | `OptionalArray1DView`（O:L343） | `BareArray1DView`（B:L334） | 一致 |
| View 1D | 保存property / `indices` | `count` / `0..<count`（O:L355、L396） | `count` / `0..<count`（B:L342、L363） | 一致 |
| View 2D | 型名 | `OptionalArray2DView`（O:L403） | `BareArray2DView`（B:L369） | 一致 |
| View 2D | 保存property | `width`, `height`（O:L419-420） | `capacity`, `width`, `height`（B:L379-382） | 不揃い（BareArrayのViewだけ`capacity`を持つ） |
| View 2D | 落とす軸 / offset / `indices` | `height` / `width * position` / `0..<height`（O:L426-428、L443） | `height` / `width * position` / `0..<height`（B:L389-390、L403） | 一致 |
| View 3D | 型名 | `OptionalArray3DView`（O:L450） | `BareArray3DView`（B:L409） | 一致 |
| View 3D | 保存property | `width`, `height`, `depth`（O:L467-469） | `capacity`, `width`, `height`, `depth`（B:L422-426） | 不揃い（同上） |
| View 3D | 落とす軸 / offset / `indices` | `depth` / `width * height * position` / `0..<depth`（O:L475-477、L493） | `depth` / `width * height * position` / `0..<depth`（B:L433-435、L448） | 一致 |

名称・次元以外で目に入った宣言上の差（比較対象外。記録だけ）: OptionalArrayは2D〜4Dだけ`@frozen`（O:L119 / L190 / L263）で、
BareArrayにはどの型にも`@frozen`が無い。BareArrayの所有型にも`@unsafe internal init(payload:...)`がある（B:L42 / L114 / L193 / L273）。

停止事項: なし。3D View・4Dのoffsetは、両moduleとも`width * height * position`と`size0 * size1 * size2 * position`で、
OptionalArrayで修正済みの面stride不足（`89a93f9d`）と同じ形の欠落はBareArray側にも無い。

Codex acceptance（2026-10-08）: 比較対象と位置が揃い、命名案やBareArray監査へ範囲を広げていないため
受け入れた。1D所有型名のsuffix差、4Dだけの`size0`〜`size3`、Viewの`capacity`差を判断入力として
分離できたため、`OPT-028`と親の`OPT-010`を完了とする。

## 判断taskへの分離（2026-10-08）

監査で明示決定が存在しないと確認した事項を、一判断ずつ次の4件へ分離した。いずれもUser / Codexが
決定し、Claudeへ結論を委譲しない。

1. 公開位置づけ: 競技プログラミング用の低レベル公開部品として1.0でも公開を続けるか。
2. 1D所有型名: `OptionalArray1D`を維持するか、次元suffixを持たない体系へ揃えるか。
3. 次元名称体系: 2D / 3Dの`width`・`height`・`depth`と4Dの`size0`〜`size3`の混在を維持するか統一するか。
4. 不正次元契約: 負値、zero、次元積overflowをどの事前条件として扱うか。

各判断ではsource compatibility、BareArrayとの整合、既存testと利用例への影響を入力にするが、
BareArrayの凍結task、storage再設計、strict memory safety恒久適用は再開しない。4件の登録により
`OPT-011`を完了とし、結論が揃うまでTest as Specification整理は凍結を維持する。

### 公開位置づけの決定（2026-10-08）

ユーザー判断により、OptionalArrayは競技プログラミング用の低レベル公開部品として、1.0でも公開を
継続する。EDPC利用例と`AcCollections`からの現行再公開を維持し、寿命制約、不正次元、名称体系などの
個別契約はそれぞれの判断・文書作業で扱う。公開継続だけを理由に、それらの未決事項を解決済みとはしない。

### 1D所有型名の決定（2026-10-08）

ユーザー判断により、1D所有型名は`OptionalArray1D`を維持する。2D〜4Dとの次元suffixの一貫性と、
`OptionalArray`だけでは一般概念にも読める曖昧さを避けることを優先する。BareArrayとの不揃いは、
凍結中のBareArrayへOptionalArrayを先回りして合わせる理由にはしない。

これは1.0へ向けた現時点の確定判断である。ただし、BareArray監査を正式に再開したとき、または
利用者向け文書作業で具体的な理解・発見性・移行上の問題が確認されたときは、根拠を伴う新しい判断taskとして
再検討してよい。単なる気分の変化だけで現taskを未決へ戻さない。

### 次元名称体系の決定（2026-10-08）

ユーザー判断により、2D／3Dでは`width`・`height`・`depth`、4Dでは`size0`〜`size3`を使う
現行体系を維持する。2D／3Dは空間的な意味名による可読性を優先し、自然な第4軸名を持たない4Dは
汎用的な番号名で扱う。全次元を形式的に統一するためのsource-breakingな改名は行わない。

利用者向け文書では、subscriptが最後の軸（`height`、`depth`、`size3`）を選び、返されたViewで
内側の軸へ進むことを明記する。BareArrayも現時点で同じ次元label体系だが、この決定によって
凍結中のBareArray監査を再開したことにはしない。

### 不正次元契約の決定（2026-10-08）

ユーザー判断により、initializerへ渡す各次元は0以上であり、全次元の積が`Int`で表現可能であることを
事前条件とする。zero dimensionは空配列として許可する。負値または積overflowは契約違反であり、
有効な配列として受け入れない。

通常の検査構成では契約違反を明確に停止させる実装とtestを後続taskで整備する。ただし、
`-Ounchecked`での停止や安全な回復は公開保証に含めず、呼び出し側が事前条件を満たす責任を負う。
この決定はstorage再設計やstrict memory safety恒久適用を再開するものではない。

### OPT-033 次元事前条件の実装・仕様test assignment（2026-10-08）

担当: Claude。`OptionalArray1D`〜`OptionalArray4D`のpublic initializerへ、決定済みの次元契約を
実装する。各入力次元が0以上であることを積の計算前に検査し、2D〜4Dはoverflowを起こさずに
次元積が`Int`で表現可能か確認してからcapacityを確定する。zero dimensionは成功し、空の`indices`と
capacity相当の空状態を維持する。

同じtaskで既存のTesting／Death Test方式に従い、少なくとも次を仕様として固定する。

- 1D〜4Dのzero dimensionが有効で空になること。
- 各initializerの負値が通常の検査構成で停止すること。
- 2D〜4Dの次元積overflowが、overflow計算や不正確保へ進む前に停止すること。
- DebugとReleaseで契約が成立すること。`-Ounchecked`の停止は期待しない。

型名、次元label、公開位置づけ、停止messageの文言、storage構造を変更しない。BareArray、strict memory
safety、コメントドック全件整備、test file全体の番号整理へ範囲を広げない。既存のDeath Test基盤では
契約を固定できない問題を見つけた場合、独自方式を追加せず根拠を報告して停止する。完了時は変更file、
追加した仕様、Debug／Releaseの実行結果を記録し、Codexが受け入れる。

### OPT-033 実施結果

2026-10-08 / Claude Opus 5.5（`claude-opus-5-5`）。未commit（ユーザーのcommit許可待ち）。

変更file:

- `Sources/OptionalArrayModule/OptinalArray.swift`: 1D〜4Dのinitializerだけを変更した。
  - 各次元の`>= 0`を、積の計算より前に`precondition`で検査する。
  - 2Dは`multipliedReportingOverflow`で積を求め、overflowを`precondition`で拒否する。
  - 3D / 4Dは、0の次元があれば積を0とする。無ければ`multipliedReportingOverflow`を順に適用し、
    いずれかのoverflowを`precondition`で拒否する（途中の積だけがoverflowする入力も0なら受け入れる）。
  - 停止messageは付けていない（既存のsubscriptの`precondition`と同じ形）。型名、label、storage、属性は変更していない。
    ドキュメントコメントも追加していない（利用者向け文書はCodexの担当）。
- `Tests/OptionalArrayModuleTests/OptionalArrayTests.swift`: `// MARK: - Dimension contract`に5件を追加した。
  1D〜4Dのzero dimensionで要素を1つも持たないこと、0の次元があれば他の次元が大きくても受け入れることを固定する。
- `Tests/OptionalArrayModuleTests/OptionalArrayDeathTests.swift`: `OptionalArrayDimensionDeathTests`を追加した（13件）。
  内訳は、各initializerの各軸の負値10件と、2D〜4Dの積overflow 3件。既存と同じ`processExitsWith: .failure`方式。

test-first: 修正前に追加testを走らせ、次の失敗を確認した。

- 負の軸のほかに0の軸を置いた負値9件は、修正前はinitが成功して`EXIT_SUCCESS`だった。
- 0の次元と大きな次元を組み合わせたXCTestは、修正前は積の途中のoverflowでprocessごと停止した（signal 5）。
- 1Dの負値と積overflow 3件は、修正前から停止していた（確保の失敗、または乗算のoverflow trap）。

実行結果（macOS、Swift 6.4）:

- `swift test --filter OptionalArrayModuleTests`（Debug）: XCTest 34件、Swift Testing 21件、すべて成功。
- `swift test -c release --filter OptionalArrayModuleTests`（Release）: 同じ件数で、すべて成功。
- `swift test --filter "AcCollectionsTests\."`: 6件成功。
- `-Ounchecked`は実行していない（契約上、停止を期待しない）。互換modeはOptionalArrayに分岐が無いので、ビルドしていない。

既存Death Test基盤の限界（報告）: `.failure`は停止の理由を区別しない。そのため1Dの負値と積overflowのtestは、
修正前の確保失敗・乗算trapでも成功する。「overflow計算や不正確保へ進む前に停止する」ことはtestではなく、
実装（検査が乗算と`allocate`より前にあること）で担保している。独自方式は追加していない。

**範囲外のdefect（修正せず停止）:** 4Dの外側subscriptはoffsetを`size0 * size1 * size2 * position`と左から計算する
（`OptinalArray.swift`の`OptionalArray4D.subscript`）。`size2 == 0`で`size0 * size1`がoverflowする場合、契約上有効な配列
（積は0）でも、範囲内の`a[0]`がoverflow trapで停止する。最小再現（修正後のsourceを一時dirで`-Onone`実行）:
`OptionalArray4D<Int>(size0: Int.max, size1: 2, size2: 0, size3: 1)`はinitに成功し、`a[0]`で終了コード133。
3D（`width * height * position`）は、`height == 0`なら`width * height`が0なので起きない。4D由来の3DView
（`width * height * position` = `size0 * size1 * z`）は、`z`へ届くには`size2 > 0`かつ`size3 > 0`が必要で、そのとき
`size0 * size1`がoverflowするなら全体の積もoverflowしてinitで拒否されるので起きない（机上。実行はしていない）。
修正するかどうかはCodexが判断する。

### Codex intakeとOPT-034 assignment（2026-10-08）

`OPT-033`の次元検査、zero成功test、負値・overflow Death Test、Debug／Release結果は範囲内の成果として
checkpointへ保存した。ただし、報告された4D zero-volumeの外側subscript defectは、zero dimensionを
有効な空配列とする決定済み契約に反するため、`OPT-033`はまだ完了としない。

担当: Claude。`OptionalArray4D.subscript`だけを対象に、`size0`、`size1`、`size2`のいずれかが0なら
途中の次元積を評価せずoffset 0の空`OptionalArray3DView`を返せるようにする。すべて非zeroの場合は、
initializerで全次元積が表現可能と確認済みであることを前提に現行offsetを維持する。

少なくとも、`size3 > 0`で内側各軸が0の3形状を外側subscriptで辿り、返るViewの`indices`が空になる
仕様testを追加する。`Int.max`と別の非zero次元を組み合わせ、修正前の途中積overflowを再現する形を
1件含める。型名、次元契約、initializer、他のsubscript、storage、BareArrayを変更しない。
Debug／ReleaseのOptionalArray testを実行し、新しいdefectを見つけた場合は範囲を広げず報告して停止する。

### OPT-034 実施結果

2026-10-08 / Claude Opus 5.5（`claude-opus-5-5`）。未commit。

- `Sources/OptionalArrayModule/OptinalArray.swift`: `OptionalArray4D.subscript`のgetterだけを変更した。
  `size0` / `size1` / `size2`のいずれかが0ならoffsetを0とし、途中の積を評価しない。すべて非zeroなら現行の
  `size0 * size1 * size2 * position`のまま。返すViewの次元（`width: size0, height: size1, depth: size2`）は変えていない。
- `Tests/OptionalArrayModuleTests/OptionalArrayTests.swift`: `testOptionalArray4DZeroVolumeOuterSubscriptReachesEmptyViews`を追加した。
  `size3 = 1`で`size0` / `size1` / `size2`のそれぞれを0にした3形状と、`(Int.max, 2, 0, 1)`の1形状を外側subscriptで辿る。
- 解釈（記録）: 依頼の「返るViewの`indices`が空になる」は、0の軸に当たるViewまで辿って空になることとして固定した。
  `size0 == 0`や`size1 == 0`のとき、外側subscriptが直接返す3DViewの`indices`は`0..<size2`で、空ではない（既存の意味のまま）。
- test-first: 修正前は、追加したtestがprocessごと停止した（signal 5、`(Int.max, 2, 0, 1)`の途中積overflow）。
- 実行結果: `swift test --filter OptionalArrayModuleTests`をDebugとReleaseの両方で実行し、XCTest 35件とSwift Testing 21件がすべて成功した
  （Release productは実行時刻に更新）。
- 性能: `@inline(__always)`のgetterに分岐を1つ足した。性能は測っていない。OptionalArrayは`Benchmarks/Libraries/CI.json`に入っていない
  ので、performance jobでも確認されない。
- 新しいdefect: なし。

Codex acceptance（2026-10-08）: zero-volume時だけ途中積を避け、非zero時のoffsetとView次元を維持している。
内側3軸それぞれのzeroと途中積overflow形状がtestで固定され、Debug／Releaseが成功したため受け入れる。
`OPT-034`を完了し、これを前提とする`OPT-033`も完了とする。

### OPT-035 Test as Specification配置・移行設計 assignment（2026-10-08）

担当: Claude。`Tests/OptionalArrayModuleTests`の現行4ファイルを読み、各testを公開契約の仕様群へ分類する。
成果物は、仕様番号、提案file名、含める現行test、固定する契約、Swift Testingへ移行可能か、移行時の
注意点を対応させた表とする。EDPC-J / EDPC-Lは実行testではない利用例として別枠に置く。

XCTestからSwift Testingへの移行可否は、次の制約を明示して判定する。

- XCTestCase単位で段階移行し、混在期間を許容する。
- 参照型破棄countなど共有・capture状態と、Swift Testingの並列実行で意味が変わらないか確認する。
- Death Testは既存のSwift Testing基盤を維持し、通常testと混ぜない。
- performance API、setup / teardown、MainActor依存、`continueAfterFailure`の有無を確認する。
- 繰り返し形状は`@Test(arguments:)`候補として記録できるが、採用は決めない。

このtaskではfile rename、test移動、XCTest移行、production変更を行わない。testの追加・削除や仕様範囲も
決めない。新しいdefectまたは判断点は根拠を記録して停止し、Codexが実行taskを分割する入力にする。

### OPT-035 Test as Specification配置・移行設計

2026-10-08 / Claude Opus 5.5（`claude-opus-5-5`）。HEAD `63f40cdd`。現行4 fileを読んだだけで、移動・改名・移行はしていない。
`T<n>` / `D<n>`は現行の`OptionalArrayTests.swift` / `OptionalArrayDeathTests.swift`の行（このHEADの時点。OPT-015冒頭の略記とは行番号が違う）。

前提として確認した事実:

- XCTestは`final class OptionalArrayTests: XCTestCase`の1 class（35件）だけ。`setUp` / `tearDown`、`measure`などのperformance API、
  `@MainActor`、`continueAfterFailure`の変更、`static var`は無い。`XCTUnwrap`も使っていない。
- 参照型破棄のcountは、8件とも各testの中で宣言する`var deinitCount`と、test内の`final class Box`（closureでcountを増やす）で数える。
  test間で共有する状態は無いので、Swift Testingで並列に実行しても意味は変わらない。
- test targetの依存は`OptionalArrayModule`だけ（`Package.swift:292-297`）。RedBlackTreeのprocess-globalなlifetime counterと、
  その専用XCTest基底classの規則（`Tests/CLAUDE.md`）は関係しない。
- Death Testは既にSwift Testing（`#if DEATH_TEST`、`processExitsWith: .failure`）で、2 suite・21件。
- 番号付きfileの命名は、Permutationが`<型名>_<n>_<主題>Tests.swift`（1型）、RedBlackTreeが型ごとのdirectoryと同じ形。
  `_98_`は実装確認、`_99_`はDeath Test（`Tests/CLAUDE.md`）。

提案するfile構成（module内の公開7型を一つの仕様群として扱い、接頭辞を`OptionalArray`にした案。型ごとに分けるかはCodexが判断する）:

| 仕様番号 | 提案file名 | 含める現行test | 固定する契約 | Swift Testingへの移行 | 移行時の注意点 |
| --- | --- | --- | --- | --- | --- |
| 0 | `OptionalArray_0_PublicSurfaceTests.swift` | `testSendable_compiles`（T277） | 所有型の条件付き`Sendable` | 可 | `#if swift(>=5.5)`の囲みは現行toolchainでは不要になるが、外すかは決めていない。`borrowing T`と`~Copyable`の制約はSwift Testingでもそのまま書ける |
| 1 | `OptionalArray_1_InitializationTests.swift` | T8（1D初期nil）、T466 / T471 / T482 / T499 / T513（zero dimension）、T526（4D zero-volumeの外側subscript） | 初期状態、次元契約のうち成功側（zeroを含む）。停止側は`_99_` | 可 | T526はsubscriptの経路も固定するので、`_3_`へ置く案もある（判断点。決めていない） |
| 2 | `OptionalArray_2_ElementAccessTests.swift` | T16、T27、T59、T107、T155 | 取得・設定・nil代入 | 可 | — |
| 3 | `OptionalArray_3_ViewTests.swift` | T86、T132、T182、T195、T208 | Viewによる親storageの共有、非対称次元でのstrideと外側境界 | 可 | — |
| 4 | `OptionalArray_4_IndicesTests.swift` | T51、T97、T144、T221、T233 | 所有4型とView 3型の`indices`の軸 | 可 | — |
| 5 | `OptionalArray_5_RemoveAllTests.swift` | T37、T72、T119、T168 | `removeAll()`後の未設定状態 | 可 | 参照型での`removeAll()`は`_6_`にある。`_5_`と`_6_`のどちらに寄せるかは決めていない |
| 6 | `OptionalArray_6_ReferenceLifetimeTests.swift` | T286、T312、T339、T357、T374、T391、T410、T435 | 上書き・nil代入・`removeAll()`・deinitでの一回だけの破棄、`removeAll()`後の再利用 | 可（状態はtest内だけ） | 8件とも同じ`Box`をtest内に複製している。共通化はtest内容の変更になるので、移行taskとは分けるのが安全 |
| 99 | `OptionalArray_99_DeathTests.swift` | 現行`OptionalArrayDeathTests.swift`の2 suite（D8〜とD72〜） | 境界違反と次元契約違反での停止 | 移行済み（Swift Testing） | file名だけの変更。冒頭の「このファイル自体は整理整頓時に消さないこと」コメントはユーザー指示なので維持する。通常testとは混ぜない |
| 別枠 | `EDPC-J.swift` / `EDPC-L.swift`（番号なし、現名のまま） | `EDPC_J(N:)`、`hoge(N:A:)` | 利用形状のcompileだけ（実行されない、OPT-023） | 対象外 | testではないので番号を付けない |

移行の進め方の制約（確認できた範囲）:

- XCTestCase単位の段階移行: 現行は1 classなので、class単位だと一括になる。仕様番号ごとにfileを分けたうえで、file単位で移す形なら
  混在期間を作れる。`swift test`はXCTestとSwift Testingの両方を実行し、`--filter`は両方に効く（このsessionのOPT-033 / 034で確認）。
- `XCTAssertEqual` / `XCTAssertNil` / `XCTAssertTrue`は`#expect`へ置き換えられる。`XCTAssertTrue(a === b)`（T410 / T435）は
  `#expect(a === b)`で書ける。失敗後も続ける挙動は、XCTestの既定（`continueAfterFailure == true`）と`#expect`で同じ。
- `@Test(arguments:)`の候補（採用は決めない）: `_99_`の軸ごとの負値10件、`_1_`のzero dimensionの形状、`_6_`の2D〜4Dの残存deinit。
  exit testの本体は引数をcaptureしない書き方が既存にある（`Tests/RedBlackTreeTreeTests/Foundamental/TreeFoundamentalDeathTests.swift:96-`、
  enumを`switch`して各caseで`#expect(processExitsWith:)`を呼ぶ）。所有型は`~Copyable`で型ごとにinitializerが違うので、
  `_6_`を1つのparameterized testにするには型ごとの分岐が要る。

停止事項: 新しいdefectは無い。判断点は表に書いた2つ（T526の置き場所、参照型`removeAll()`の置き場所）と、
型ごとにfileを分けるかどうかで、いずれも決めていない。D45 / D52 / D59の名前と本体（Getの名前で本体は書込み）のずれは、
OPT-018で記録済み。改名はこのtaskの範囲外。

Codex acceptance（2026-10-08）: 公開7型を一つの仕様群として0〜6、99へ分ける案、EDPC利用例の別枠、
XCTestからSwift Testingへの段階移行条件が、現行testと既存規約に対応しているため受け入れる。
`OPT-035`を完了とする。配置の小判断と実行taskへの分割は小休止後にCodexが行い、`OPT-012`は
それまで凍結を維持する。

### OPT-012 Test as Specification実行分割（2026-10-08 / Codex）

OPT-035で残した配置上の小判断を、公開契約の変更を伴わないtest整理として次のとおり確定する。

- 公開7型を型ごとに分断せず、一つの`OptionalArray`仕様群として`OptionalArray_<n>_*Tests.swift`へ置く。
- zero-volume 4Dの外側subscript test（OPT-035のT526）は、次元・zero-volumeの成功契約を固定する
  `_1_InitializationTests`へ置く。
- 参照型要素を使う`removeAll()` testは、破棄回数と再利用を固定する`_6_ReferenceLifetimeTests`へ置く。
  `_5_RemoveAllTests`はoptional値としての基本的な未設定化を固定する。
- 今回はtest frameworkを変更しない。通常testはXCTestを維持し、既にSwift TestingであるDeath Testも
  現状を維持する。Swift Testingへの移行はTest as Specification整理の完了条件に含めない。
- test本文、期待値、production source、公開契約は変更しない。移動に必要なclass名、import、file構造の
  機械的変更だけを許す。

実行を次の3件へ分ける。

#### OPT-036 通常testの番号付き仕様file分割

担当: Claude。現行`OptionalArrayTests.swift`の35 testを、OPT-035の表と上の配置判断どおり
`OptionalArray_0_`〜`OptionalArray_6_`の7 fileへ移す。

- XCTestを維持する。
- testの追加、削除、期待値変更、共通helper化、parameterized化を行わない。
- 各現行testを一度だけ移し、元fileは全test移動後に削除する。
- 新しいdefect、重複、表に無いtest、移動に意味判断が必要な依存を見つけた場合は停止する。
- 完了時に、移動前後のtest名集合が一致することと、通常構成のfocused test成功を記録する。

#### OPT-037 Death Testの番号付きfile改名

担当: Claude。`OptionalArrayDeathTests.swift`を`OptionalArray_99_DeathTests.swift`へ改名する。

- 既存のSwift Testing suite、21 test、`#if DEATH_TEST`、冒頭の保存指示コメントを維持する。
- test名、本体、期待する終了条件を変更しない。
- 通常testへ統合せず、Death Test構成での実行成功を記録する。

#### OPT-036・OPT-037 Claude実施結果（2026-10-08）

2026-10-08 / Claude Opus 5.5（`claude-opus-5-5`）。基点HEAD `24aa7107`。git addまで、commitなし。

- OPT-036: `OptionalArrayTests.swift`の35 testを、上の配置判断どおり7 fileへ移し、元fileを削除した。
  件数は`_0_` 1、`_1_` 7（T8、T466、T471、T482、T499、T513、T526）、`_2_` 5、`_3_` 5、`_4_` 5、`_5_` 4、`_6_` 8。
  class名はPermutationに合わせてfile名と同じ（`OptionalArray_<n>_<主題>Tests: XCTestCase`）。
  各fileは元の`import`2行、各testの直前にあった`// MARK:`、`#if swift(>=5.5)`の囲み、`///`コメント、
  `_1_`の次元契約コメント3行をそのまま持つ。test本文、期待値、test名は変えていない。
- 移動の照合: import・class宣言・閉じ括弧・MARK・空行を除いた行の多重集合が、元fileと新7 fileの合計で一致。
  `swift test list`のtest名集合は移動前後とも56件（通常35、Death Test 21）で、method名の集合が一致。
- OPT-037: `git mv`で`OptionalArray_99_DeathTests.swift`へ改名（類似度100%、内容の変更なし）。
  2 suite・21 test、`#if DEATH_TEST`、冒頭の保存指示コメントを維持。suite名`OptionalArrayDeathTests`は変えていないので、
  `_1_`の次元契約コメントにある`OptionalArrayDeathTests`への言及はそのまま正しい。
- 実行: `swift test --filter OptionalArrayModuleTests`をDebugとReleaseで実行し、どちらもXCTest 35件・失敗0、
  Swift Testing 21件（2 suite）成功。7 suiteそれぞれの実行件数も配置どおり。
- 停止事項: 新しいdefect、重複、表に無いtest、意味判断が必要な依存は無かった。
- 未更新（Codex判断）: `Tests/TESTING.md`の94行目が「`OptionalArrayModuleTests`の4ファイル」と現物確認時点の構成を述べている。
  現在は通常7・Death Test 1・利用例2の10 fileになる。

Codex acceptance（2026-10-08）: 通常35件のtest名集合と配置を移動前後で照合し、Death Testは内容変更なしの
100% renameであることを確認した。Xcodeのbuild-for-testingが成功し、新しい7 fileの通常35件と改名後の
Death Test 21件を指定した実行も56件すべて成功したため、`OPT-036`と`OPT-037`を受け入れて完了とする。
`Tests/TESTING.md`のfile件数更新はこの受入commitへ含めず、後続の完成判定で扱う。

#### OPT-038 OptionalArray Test as Specification完成判定

担当: Codex。OPT-036・037後、file番号、test名集合、公開契約表との対応、通常test、Death Testを検収する。
不足があれば新taskへ分離し、問題がなければOPT-012を完了する。

2026-10-08、ユーザーは現在の中間ゴールに限り、OPT-038からOPT-012の完成、OPT-013の
ユーザードキュメント作業への引き渡し判定までを、依存関係が満たされ次第、追加確認なしで順次解凍して
進めることを承認した。各taskの受入とcommitは省略しない。新しいユーザー判断、公開契約の変更、または
範囲拡張が必要になった場合は自動で進めず停止する。この承認は他の`FROZEN` taskには適用しない。

## Claude証拠表（2026-10-08）

2026-10-08 / Claude Opus 5.5（`claude-opus-5-5`）。`OPT-015`〜`OPT-024`の提出物。表が無かったので
packageごとに節を新設した。既存本文は変更していない。本文と食い違う事実は、各表の備考に
「本文と不一致」と書いた。検収、意味づけ、判断taskの生成はCodexに渡す。

略記: `T<n>`は`OptionalArrayTests.swift`の行、`D<n>`は`OptionalArrayDeathTests.swift`の行、
`L<n>`は`OptinalArray.swift`の行（すべて`85e60200`時点）。

### OPT-015 公開宣言ledger

| # | 宣言 | 種別 | 位置 | ドキュメントコメント |
| ---: | --- | --- | --- | --- |
| 1 | `OptionalArray1D<Element>: ~Copyable` | 型 | L21 | あり L15-20。**`@frozen`なし** |
| 2 | `init(capacity:)` | init | L28 | なし |
| 3 | `removeAll()` | method | L48 | あり L46 |
| 4 | `subscript(position:) -> Element?`（get / `_modify`） | subscript | L64 | あり L57-62 |
| 5 | `indices: Range<Int>` | property | L96 | なし |
| 6 | `OptionalArray2D<Element>: ~Copyable` | 型 | L120 | あり L115-118。`@frozen` |
| 7 | `init(width:height:)` | init | L129 | なし |
| 8 | `removeAll()` | method | L150 | なし |
| 9 | `subscript(position:) -> OptionalArray1DView`（get / NOP set） | subscript | L160 | なし（L172-173は実装コメント） |
| 10 | `indices` | property | L181 | なし |
| 11 | `OptionalArray3D<Element>: ~Copyable` | 型 | L191 | あり L186-189。`@frozen` |
| 12 | `init(width:height:depth:)` | init | L201 | なし |
| 13 | `removeAll()` | method | L223 | なし |
| 14 | `subscript(position:) -> OptionalArray2DView`（get / NOP set） | subscript | L233 | なし |
| 15 | `indices` | property | L254 | なし |
| 16 | `OptionalArray4D<Element>: ~Copyable` | 型 | L264 | あり L259-262。`@frozen` |
| 17 | `init(size0:size1:size2:size3:)` | init | L275 | なし |
| 18 | `removeAll()` | method | L298 | なし |
| 19 | `subscript(position:) -> OptionalArray3DView`（get / NOP set） | subscript | L308 | なし |
| 20 | `indices` | property | L331 | なし |
| 21 | `OptionalArray1DView<Element>`（Copyable） | 型 | L343 | あり L338-342 |
| 22 | `subscript(position:) -> Element?`（get / `_modify`） | subscript | L365 | あり L359-363 |
| 23 | `indices` | property | L396 | なし |
| 24 | `OptionalArray2DView<Element>`（Copyable） | 型 | L403 | あり L399-402 |
| 25 | `subscript(position:) -> OptionalArray1DView`（get / NOP set） | subscript | L423 | なし |
| 26 | `indices` | property | L443 | なし |
| 27 | `OptionalArray3DView<Element>`（Copyable） | 型 | L450 | あり L446-449 |
| 28 | `subscript(position:) -> OptionalArray2DView`（get / NOP set） | subscript | L472 | なし |
| 29 | `indices` | property | L493 | なし |

件数: 型7、init 4、`removeAll()` 4、subscript 7、`indices` 7で計29（本文と一致）。29件の外に、
公開適合4件（L99 / L184 / L257 / L334、`@unchecked Sendable where Element: Sendable`）がある。
View 3型には`Sendable`適合が無い。View 3型のinitは`internal`かつ`@unsafe`。1Dの`description`は`internal`。

### OPT-016 所有4型のtest根拠

| 型 | init | `removeAll()` | subscript | `indices` | `Sendable` | deinit |
| --- | --- | --- | --- | --- | --- | --- |
| 1D | T8（全slotの初期nil） | T37（Int）、T286（参照1件の破棄） | T16、T27、T286（上書き・nil）。境界はD10 / D17 / D24 | T51 | T277 | **なし**（設定済みのまま破棄するtestが無い） |
| 2D | T59で一部slotの初期nilだけ | T72、T339（参照2件、後のdeinitで追加破棄0） | T59、T86（storage共有）。2×2だけで、非対称次元の書込みは**なし**。外側の境界は**なし** | T97、T233 | **なし** | T374（残存2件） |
| 3D | T107で一部だけ | T119、T410（参照・再利用） | T107、T132。非対称次元でのalias検出は**なし** | T144、T233 | **なし** | T357、T410 |
| 4D | T155で一部だけ | T168、T435（参照・再利用） | T155、T182、T195（3D Viewの外側境界）、T208（3D Viewの面stride、`size3: 1`）。外側の立方体strideは**なし** | T221、T233 | **なし** | T391、T435 |

不足: 1Dの残存deinit。1D / 2Dの`removeAll()`後の再利用。2D〜4Dの`Sendable`。2D〜4Dの外側subscriptの境界。
2D所有型の行strideと3D所有型の面strideのalias検出（OPT-020）。init直後の全slot nilは1Dだけ。

**本文と不一致:** 本文62行目「所有4型の条件付き`Sendable`がcompileすること」に対し、T277が使うのは
`OptionalArray1D<Int>`だけ。

### OPT-017 View 3型のtest根拠

| View | 非所有性 | 親storage共有 | subscript | `indices` |
| --- | --- | --- | --- | --- |
| 1DView | 間接だけ: T357 / T374 / T391は連鎖subscriptで一時Viewを作って捨てても、破棄数0を保つ（L369等）。Viewを捨てても要素が破棄されないことの直接testは**なし** | T86（2Dの行）、T312（親の`removeAll()`がView経由の要素を破棄） | T312（上書き・nil）、D31 / D38（負値） | T233（2D / 3D / 4D由来） |
| 2DView | 直接testは**なし** | T132（3Dの面） | T132の書込み、D45（負値、書込み式の中） | T233（3D / 4D由来） |
| 3DView | 直接testは**なし** | T182（4Dの立方体） | D52（負値）、D59（上端）、T195、T208（面stride） | T195、T233 |

不足: Viewをcopyして両方から書き込むtest（Viewは`Copyable`）。2DView / 3DViewの上端・純粋な読み取り。
1DView上端。親より長くViewを保持する寿命違反（型で拘束されず、本文の既述どおりtestできない）。

### OPT-018 境界test matrix

事実: すべての境界検査は`precondition`。一時dirの実測では、`-Onone`と`-O`でtrapし、`-Ounchecked`では
検査が消えて通過した（OPT-022の`2d_negneg_sub`）。`DEATH_TEST`はmacOSでは構成を問わず定義される
（`Package.swift:82`）。既存のDeath Testは`processExitsWith: .failure`で受けており、signalまでは見ていない。
2D以上の外側subscriptはget / NOP setなので、書込み式`a[i][j] = v`でも外側の検査はgetter（例: L163）だけを通る。
外側では読み取りと書込みが同じ検査になる。get と`_modify`の検査が別なのは、1D所有型と1DViewだけ。

| access経路 | 負値・読み取り | 負値・書込み | 上端・読み取り | 上端・書込み |
| --- | --- | --- | --- | --- |
| 1D所有 get / `_modify`（L68 / L77） | D10 | D17 | D24 | **なし** |
| 2D所有 外側（L163） | **なし** | **なし** | **なし** | **なし** |
| 3D所有 外側（L236） | **なし** | **なし** | **なし** | **なし** |
| 4D所有 外側（L311） | **なし** | **なし** | **なし** | **なし** |
| 1DView get / `_modify`（L369 / L378） | D31 | D38 | **なし** | **なし** |
| 2DView 外側（L426） | （同じ検査）D45 | D45 | **なし** | **なし** |
| 3DView 外側（L475） | （同じ検査）D52 | D52 | （同じ検査）D59 | D59 |

| 構成 | 上表のDeath Test | 検査の実挙動（一時dirの実測） |
| --- | --- | --- |
| Debug（`-Onone`） | macOSの`swift test`既定で対象。今回は再実行していない | `precondition`でtrap（133） |
| Release（`-O`） | 未実施（Releaseで走らせた記録も未確認） | `precondition`でtrap（133） |
| `-Ounchecked` | 未実施 | 検査が消えて通過（OPT-022の`2d_negneg_sub`、`3d_mixneg`） |
名前の不一致: D45 `negativeIndexGet_traps_view2D`とD52 / D59 `...Get...`の本体は書込み式（外側の検査は同じgetter）。

### OPT-019 参照型寿命test matrix

期待破棄回数: 構築0、上書き1、設定済みslotへのnil代入1、未設定slotへのnil代入0、`removeAll()`は設定済み件数、
再利用後のdeinitは再設定した件数、deinitは残存件数。2DView / 3DViewは要素を直接持たない。
要素の書込みはすべて1DViewの`_modify`（L377）を通るので、独自の寿命経路は無い。

| 型 | 構築 | 上書き | nil代入 | 未設定へnil | `removeAll()` | 再利用 | deinit（残存） |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1D | T286（0） | T286（1） | T286（1） | **なし** | T286（1件） | **なし** | **なし** |
| 1DView（2D由来） | T312（0） | T312（1） | T312（1） | **なし** | T312（親、1件） | **なし** | 間接（T374が同じ経路） |
| 2D | T374（0） | 1DView経由のみ | 1DView経由のみ | **なし** | T339（2件、後のdeinitで0） | **なし** | T374（2） |
| 3D | T357（0） | 1DView経由のみ | 1DView経由のみ | **なし** | T410（2件） | T410（1） | T357（2） |
| 4D | T391（0） | 1DView経由のみ | 1DView経由のみ | **なし** | T435（2件） | T435（1） | T391（2） |

### OPT-020 次元・offset式の照合

| 型 | 添字順 | 外側検査 | offset | `indices` |
| --- | --- | --- | --- | --- |
| 2D `init(width:height:)` | `a[y][x]` | y < height（L163）、x < width（1DView） | `y*width`（L165）+ x | 0..<height |
| 3D `init(width:height:depth:)` | `a[z][y][x]` | z < depth（L236） | `z*width*height`（L238）+ `y*width`（L428）+ x | 0..<depth |
| 4D `init(size0:...:size3:)` | `a[p][z][y][x]` | p < size3（L311） | `p*size0*size1*size2`（L313）+ `z*size0*size1`（L477）+ `y*size0`（L428）+ x | 0..<size3 |
| 2DView | `v[y][x]` | y < height（L426） | `y*width`（L428） | 0..<height |
| 3DView | `v[z][y][x]` | z < depth（L475） | `z*width*height`（L477、`89a93f9d`で修正） | 0..<depth |

机上: 各型の最大offsetは`capacity - 1`で、座標から線形offsetへの対応は全単射。4Dは3DView(width: size0,
height: size1, depth: size2)を返すので、size0が最内軸、size3が最外軸になる。initの引数順は内→外、
subscriptの順は外→内（事実の記録であり、評価ではない）。
実行裏付け: Swift 6.4（swiftlang-6.4.0.34.1）でsourceを一時dirへcopyし、`-Onone` / `-O`で実行した。
2D(3, 5)、3D(2, 3, 5)、4D(2, 3, 5, 7)の全slotへ一意の値を書いて読み戻し、aliasは無かった。各段の`indices`も上表どおり。

既存の非対称次元test: T208（3DView面strideと2DView行strideの区別）、T195（3DViewの外側境界）、
T233（`indices`だけ）。alias検出testが**なし**: 2D所有の行stride（L165）、3D所有の面stride（L238）、
4D所有の立方体stride（L313）。不具合ではなく、testの不足。

### OPT-021 Sendable採用履歴

| 区分 | 内容 |
| --- | --- |
| 導入 | `9b100953`（2026-06-10、メッセージ「sendable」）。所有4型へL99等の4行を追加。同じcommitでBareArray 4型にも同形を追加 |
| 後続変更 | `git log -S Sendable`の対象は`9b100953`とtest追加の`7d4c45af`（2026-10-02）だけ。適合宣言の行は導入後変わっていない |
| 記録された理由 | OptionalArrayについての理由は見つからない（commitメッセージ、`CHANGELOG.md`、`Tests/TESTING.md`、`Maintanance/`をgrep）。近い記録はPermutationModuleのユーザー決定「Swift 6+の`Sendable`対応は必須」（`StrictMemorySafetyReadiness.md:252`）だが、対象はPermutationで、OptionalArrayに及ぶかは未記録 |
| `@unchecked`の技術的事実 | 保持する`UnsafeMutablePointer`が`Sendable`でないため、検査付きの適合は書けない |
| 現行test | T277（1Dだけ、compileのみ）。`Tests/TESTING.md`は追加を2026-10-03 Claude（Sonnet 5）と記録しており、commit日（10-02）と1日ずれる。並行利用の実行testは無い |
| 未記録 | 導入理由。許される並行利用の範囲（移送だけか共有もか）。View 3型を適合から外した理由 |

### OPT-022 不正次元の現挙動

方法: OPT-020と同じ一時dir・toolchain。終了コード133はSIGTRAP、134はSIGABRT。testは0件（既存test無し）。

| 入力 | `-Onone` / `-O` | `-Ounchecked` |
| --- | --- | --- |
| 1D `capacity: 0` | 成功、`indices` 0..<0 | 同じ |
| 1D `capacity: -1` | `allocate`で「failed to allocate 18446744073709551615 bytes」、134 | 同じ |
| 2D `width: 0, height: 3` | 成功、`indices` 0..<3、`a[2].indices` 0..<0 | 同じ |
| 2D `width: 3, height: 0` | 成功、`indices` 0..<0 | 同じ |
| 2D `(-1, -1)`（積は正の1） | init・deinitは成功。`indices`はRangeの検査で133。`a[0]`は`precondition`で133 | init成功。`indices`は`0..<-1`を返す。`a[0]`は通過 |
| 2D `(-1, 2)`（積は負） | `allocate`で134 | 同じ |
| 2D `(Int.max, 2)` | 乗算overflowで133 | 積が負へwrapし、`allocate`で134 |
| 3D `(2^32, 2^32, 1)`、4D `(2^16 ×4)` | 乗算overflowで133 | **積が0へwrapしてinit成功（終了0）**。`indices`は空でない |
| 3D `(-1, -1, 2)`で`a[1][0][0] = 1` | 2DViewの`precondition`（L426）で133 | 書込み成功 |

**停止（安全性に触れる結果）:** `-Ounchecked`では次元積のoverflowがwrapし、確保したcapacity（0）より大きい`indices`を
持つ値が作られる。続く範囲内に見えるaccessは、確保範囲外のmemoryへ触れる。これは実行していない（未定義動作のため）。
`-Ounchecked`ではsubscriptの`precondition`もすべて消えるので、一般の範囲外accessと同じ扱いになる可能性がある。
その位置づけはClaudeでは決めず、この項目はここで止める。

### OPT-023 EDPC利用例の責務分類

| file | 使う公開面 | 固定する利用形状 | アルゴリズム固有 |
| --- | --- | --- | --- |
| `EDPC-J.swift` | `OptionalArray3D.init(width:height:depth:)`、3D外側subscript、2DView・1DViewのsubscript（get / `_modify`） | `nonisolated(unsafe) var`の`~Copyable`値をローカル関数からcaptureし、`if let v = a[i][j][k]`での読み取りと`a[i][j][k] = v`での連鎖書込みを行う。次元は310³の対称なので、軸順は検査されない | 期待値DPの漸化式。入力処理は`#if false`の中 |
| `EDPC-L.swift` | `OptionalArray2D.init(width:height:)`、2D外側subscript、1DViewのsubscript | 同じcapture形状を2Dで使う。3001²の対称 | 区間DPの漸化式 |

**本文と不一致:** `EDPC_J(N:)`と`hoge(N:A:)`は、`Tests/`と`Sources/`のどこからも呼ばれていない（grep）。
compileされるだけで実行されない。本文67行目の「アルゴリズムの期待値testとしては有用」は現状と合わない。
仕様testで代替しにくい候補（契約かどうかは未判断）: captureした`~Copyable`の`var`を通した連鎖subscriptの書込みが
compileできる形。NOP setterのwriteback（本文90行目）がこの形を支えている。

### OPT-024 コメントドックcoverage

判定基準: 明示した文がある場合だけ「あり」とした。`precondition`の本体や型名から読み取れるだけなら「なし」
（基準は`AGENT_TASK_FIT_INTERVIEW.md`のClaude回答で提案したもので、未合意）。

| # | 宣言 | 境界 | 所有 | 寿命 | 破棄 | 変更 | 計算量 |
| ---: | --- | --- | --- | --- | --- | --- | --- |
| 1 | `OptionalArray1D` | なし | あり | なし | あり | あり | なし |
| 3 | 1D `removeAll()` | なし | なし | なし | あり | あり | なし |
| 4 | 1D subscript | あり | なし | なし | あり | あり | なし |
| 6 / 11 / 16 | 2D / 3D / 4D 型 | なし | なし | なし | なし | なし | なし |
| 21 | `OptionalArray1DView` | なし | あり | あり | なし | あり | なし |
| 22 | 1DView subscript | あり | あり | なし | あり | あり | なし |
| 24 / 27 | 2DView / 3DView 型 | なし | あり | あり | なし | あり | なし |

上の表に無い19件（#2, 5, 7〜10, 12〜15, 17〜20, 23, 25, 26, 28, 29）はドキュメントコメントが無く、全項目「なし」。
計算量は29件すべて「なし」。`removeAll()`がcapacityを保持することは、どのコメントにも書かれていない。

## Codex evidence intake（2026-10-08）

`OPT-015`〜`OPT-024`の10 packageは、指定された成果物、禁止事項、停止条件を満たす証拠提出として
受け入れる。これは各不足を修正すると決めたこと、本文の契約解釈を確定したこと、親監査を完了したことを
意味しない。

親監査へ引き継ぐ事項:

- 公開宣言29件のledgerを`OPT-008`の網羅性基準として使う。公開適合4件は29件の外として別記された。
- 所有4型すべての`Sendable` compile testがあるという本文記述は、現行testが1Dだけという証拠と
  照合し、`OPT-009`で訂正または不足task化を判断する。
- EDPC-J / EDPC-Lは現状compileされるだけで呼び出されないため、「期待値testとして有用」という
  本文記述を`OPT-009`で訂正する。
- `-Ounchecked`で不正次元と次元積overflowから確保量と論理次元が食い違い得る事実は、`OPT-008`の
  境界契約・安全性論点として扱う。追加の範囲外accessは実行せず、望ましい方針は後続判断へ分離する。
- 列挙された境界、寿命、stride、`Sendable`、コメントcoverageの不足は、現時点ではtaskではなく
  監査入力である。契約上必要な検証だけをCodexが親監査で選別する。
