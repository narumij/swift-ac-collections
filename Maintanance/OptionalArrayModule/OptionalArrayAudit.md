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
| `@unchecked Sendable` | 4適合 | move-only所有型を、ElementがSendableならTask間移送可能と宣言 | compile test | 並行共有を許す契約ではないことの明文化と根拠確認が必要 |

## test対応の現在地

### 仕様根拠として機能しているもの

- 1D〜4Dの基本的な初期状態、設定、取得、nil代入、`removeAll()`。
- 2D〜4Dが返すViewによる親storageの変更。
- 所有4型とView 3型の`indices`。
- 参照型要素の上書き、nil代入、`removeAll()`、所有型deinitでの一回だけの破棄。
- 3D/4Dの`removeAll()`後のslot再利用。
- 1D所有型とView、および2D/3D Viewの一部境界違反。
- 所有4型の条件付き`Sendable`がcompileすること。

### 利用例

`EDPC-J.swift` と `EDPC-L.swift` は競技プログラミングでの実利用形状を示す。
アルゴリズムの期待値testとしては有用だが、公開宣言ごとの契約を閉じる仕様testとは区別する。

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
