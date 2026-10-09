# BareArray documentation handoff audit

最終更新: 2026-10-09 / Codex

## 目的

BareArrayの公開契約をsource、test、git履歴、OptionalArrayとの対応に照らして整理し、Codexの
ユーザードキュメント作業フェーズへ渡せるかを判定する。引き渡し前に、確定した公開契約と仕様testを
入力にISO/IEC 25010観点の品質評価初版まで揃える。利用者向け本文とコメントドック全件整備はこの監査に
含めない。

## 現在の対象

- source: `Sources/BareArrayModule/BareArray.swift` 1ファイル、450行
- 公開型: 所有型1D〜4DとView 1D〜3Dの7型
- 公開宣言: 型7、所有型initializer 8、subscript 7、`indices` 7の計29件
- 公開適合: 所有型4型の`@unchecked Sendable`
- test: `Tests/BareArrayModuleTests`の3ファイル、38件
- 比較資料: `Maintanance/OptionalArrayModule/OptionalArrayAudit.md`
- safety資料: `Maintanance/StrictMemorySafetyReadiness.md`

2026-10-09の再開時点で、strict memory safetyの段階対応、境界Death Test、参照型寿命、clone所有権の
証拠は存在する。一方、BareArray固有の公開宣言ledgerはまだ作成されていない。`BARE-002`の「途中成果」は
完成済みledgerではなく、これらの周辺証拠を指すものとして扱う。

## `BARE-002` — 公開7型の契約棚卸し

### 調査する契約

- 各initializerの寸法・個数、空・負値・積のoverflowに関する前提
- subscriptの境界、軸順、offset計算、返すViewの範囲
- 所有型の初期化、変更、破棄、cloneの所有責任
- Viewの非所有性、元の所有型との変更共有、寿命上の制約
- `indices`が表す軸と範囲
- `@unchecked Sendable`の既存根拠と制約
- 2D・3Dの`width` / `height` / `depth`と4Dの`size0...size3`、1D所有型とViewの名称差
- 多次元subscript setterのNOPが成立した経緯と現在の契約

### 成果物

この文書へ次を追記する。

1. 公開29宣言と公開適合4件を一度ずつ収録したledger
2. 宣言ごとの境界、寿命、所有、破棄、変更、軸・offset契約
3. 対応する既存test、git履歴、OptionalArrayの比較箇所
4. `事実`、`過去の決定`、`現在の推論`、`未確認`の区別
5. 新しい判断が必要な場合の、一判断ごとの`DECISION`候補

### 停止条件

- 公開継続、命名、性能、安全性などの製品判断が必要になった場合は結論を補わず停止する。
- OptionalArrayとの類似だけでは同一契約と認定しない。
- source、test、コメントドック、Registryを変更しない。
- Test as Specificationのファイル再編は`BARE-005`へ残す。
- 性能基準、Viewが所有者より長く生きる問題、strict memory safetyの恒久適用は後続の1.0判断側へ残す。

### Codex受入条件

- 公開29宣言と4適合に欠落・重複がない。
- testが証明する範囲と、文書または呼び出し側前提だけの契約が分離されている。
- OptionalArrayとの差異が、同一視せず比較根拠付きで示されている。
- 新しい判断点が実装へ混入せず、一判断ごとの候補として止まっている。
- 各発見事項が、`BARE-005`より前に閉じる前提、Test as Specification整理で扱う事項、
  ユーザードキュメント作業で扱う事項、文書作業後の1.0判断へ送る事項のいずれかに分類されている。
- 親監査、条件付き判断、Test as Specification整理の次状態をCodexが判定できる。

### Test as Specification着手前の再計算

`BARE-002`の受入時に、Codexは契約棚卸しで見つかった不足を次の順で振り分ける。

1. 現行公開契約を確定するための事実確認、ユーザー判断、または不足testなら、必要なものだけを
   個別taskへ分け、`BARE-005`より先に置く。
2. 契約は確定済みで、既存testの配置・名称・対応付けだけの問題なら`BARE-005`へ渡す。
3. 契約を変えず説明だけを補う事項は、ユーザードキュメント作業へ渡す。
4. View寿命、storage再設計、strict memory safety、性能基準のように1.0採否へ関わる事項は、
   現行仕様へ暗黙に固定せず、後続の1.0判断へ送る。

後続候補は棚卸し結果が出る前に追加採番しない。`BARE-005`は、1に該当する前提が残っていないことを
Codexが確認してから再開する。

## 後続境界

- `BARE-003`: 公開継続が未決定と判明した場合だけ再開し、その時点で実際の必須依存を設定する。
- `BARE-004`: 公開継続時に命名体系が未決定と判明した場合だけ再開し、その時点で実際の必須依存を
  設定する。
- `BARE-003`と`BARE-004`は棚卸し結果まで凍結保持し、判断不要と判明したものは`EXCLUDED`へ送る。
- `BARE-005`: `BARE-002`受入後、Test as Specification着手前の再計算で先行前提がない、または
  先行前提が完了したことを確認してから、既存testを番号付き仕様へ整理する。
- `BARE-008`: `BARE-005`受入後、ClaudeがPermutation版とOptionalArray版の構成を参考に、source、
  仕様test、監査結果からISO/IEC 25010観点の証拠と不足を初稿化する。Codexは証拠との対応を検収し、
  新しい公開契約または品質水準の判断を本文へ埋めず、一判断ごとのtask候補へ分離して正本化する。
  完成条件は、ユーザードキュメント作業で参照できる品質評価初版をCodexが受け入れることとする。
- `BARE-006` / `BARE-007` / `ARRAY-001`: 文書作業後の1.0判断側として凍結を維持する。

2026-10-09、`BARE-005`受入後にユーザーが`BARE-008`の再開とClaudeへの割当を承認した。品質評価は
ユーザードキュメント作業の入力を作るDISCOVERYとし、性能基準、View寿命、storage再設計、strict memory
safety、`let`所有者からのView変更は文書作業後の1.0判断側へ残す。

2026-10-09、すべての先行前提の完了を確認し、ユーザー指示で`BARE-005`を再開した。Codexが番号付き
仕様群への整理と棚卸しで不足していたtestを整備・検証し、その後ClaudeがTest as Specificationとしての
名称、配置、契約対応をポリッシングする。Claudeへの割当は一時使用制限に従い、Codexの土台完成後まで
開始しない。最終受入とRegistry更新はCodexが行う。

Codex acceptance（2026-10-09）: 公開surface、初期化、要素access、View、indices、参照寿命、internal
`clone()`、trap契約の8個の番号付き仕様群を受け入れた。Claudeは既存testを契約単位へ再配置し、名称と
説明を整え、決定済み契約の不足Death Test 6件を追加した。Debug通常35件（clone 7件を含む）、Release
通常28件、Death Testは両構成42件が成功した。CodexもXcode build-for-testingと通常test全体1451件成功・
失敗0件を独立確認した。LinuxとDeath Testの独立再実行はCodex未確認で、Claudeの両構成成功記録を採用する。

`let`所有者からView経由で変更する既存testは現行挙動の証拠として残したが、公開契約化の判断は行って
いない。文書作業後の1.0判断で、`var`を使うtestへ変えるか契約として認めるかを再評価する。同一pointer・
別shapeのViewは公開APIから構成不能であり、shape不一致trapは未証明のまま公開契約へ含めない。

## 品質評価初版の位置づけ

品質評価初版は、コメントドックまたは利用者向け本文そのものではない。Test as Specificationで確定した
契約と証拠を品質特性へ対応付け、文書作業で説明すべき制約と、文書作業後の1.0判断へ送る不足を区別する
入力である。

初版では未計測の性能、View寿命、storage再設計、strict memory safetyについて結論を補わない。現状の
証拠、未確認範囲、後続taskとの境界を明記し、ユーザードキュメント作業後に再評価できる状態を作る。

## `BARE-002` 結果 — 公開29宣言・4適合のledger（2026-10-09）

2026-10-09 11:44 JST / Claude Opus 5.5（`claude-opus-5-5`）。HEAD `3b58769c`。source・test・コメントドック・Registryは変更していない。
`B:L<n>`は`Sources/BareArrayModule/BareArray.swift`の行。testは`BT`=`BareArrayTests.swift`、`DT`=`BareArrayDeathTests.swift`
（`DEATH_TEST`時のみ）、`IT`=`BareArrayInternalTests.swift`（`DEBUG`時のみ、`@testable`）。OptionalArrayとの対応は
`OptionalArrayModule/OptionalArrayAudit.md`の`OPT-028`表を参照し、ここでは同一視しない。

区分の記号: **事**=事実（source・testで確認）、**決**=過去の決定（記録あり）、**推**=現在の推論（読んだだけで実行していない）、
**未**=未確認。

### 共通の事実

- 所有型4型（`BareArray`、`BareArray2D`〜`4D`）は`~Copyable`のstruct。1つの`UnsafeMutablePointer<Element>`を所有し、`deinit`で
  `deinitialize(count:)`のあと`deallocate()`する（B:L64、L141、L225、L308）。**事**
- View 3型（`BareArray1DView`〜`3DView`）はCopyableなstructで、所有者のpointerを非所有で持つ。`deinit`は無い。**事**
- 要素は所有型の`payload`に連続して並ぶ。最も外側の軸が最も大きなstrideを持ち、最も内側の軸（1D View）が連続する。**事**
- 境界は全subscriptで`precondition(0 <= position && position < 上限)`。Releaseでも検査し、`-Ounchecked`では消える。**事**
- 下限`0 <=`は`dcb3d428`（2026-10-02）で追加された。それまでは`position < 上限`だけだった。**決**（`DT`冒頭コメントは
  「書き込み側の下限チェックが抜けていた（2026-10-03発見）」と記す）
- `clone()`は4所有型にあるが`internal`で、公開宣言ではない（B:L70、L147、L231、L314）。ledgerから除外し、所有の項で触れる。**事**
- View 2D / 3Dの`capacity`は代入されるだけで読まれない（B:L373 / L379、B:L415 / L422）。View 3Dでは`height * width`で、
  3D全体の大きさではない。**事**（実害は無い。storage整理側の事項）
- 型のコメントドック: 所有1D〜3Dは同文の説明あり、4Dは無し。Viewは「参照型の挙動をする」。**事**

### ledger（公開宣言29件）

| # | 宣言（行） | 契約（境界・寿命・所有・破棄・変更・軸） | 既存test | 履歴・OptionalArray | 区分 |
| --- | --- | --- | --- | --- | --- |
| 1 | `struct BareArray<Element>: ~Copyable`（B:L21） | 1D所有型。要素`count`個を所有し、破棄時に全要素を`deinitialize`する | BT 参照型寿命（上書き・再代入） | `6fd45542`導入。OptionalArrayは`OptionalArray1D`（OPT-028） | 事 |
| 2 | `init(repeating:count:)`（B:L24） | `count`個を確保し、`value`をcopyで埋める。`count == 0`は空 | BT Repeating、EmptyHasNoIndices | — | 事。`count < 0`の挙動は**未**（`allocate(capacity:)`へ負値が渡る） |
| 3 | `init(count:_:)`（B:L32） | `f`を`count`回、添字0から順に呼ぶ | BT InitializerClosure | — | 事。`count < 0`は**推**: `allocate`が先に走り、その後`0..<count`でtrap |
| 4 | `subscript(position:) -> Element`（B:L51） | `unsafeAddress` / `unsafeMutableAddress`。上書きで古い要素は解放される | BT Mutation、上書き寿命。DT 上下限の読み・書き4件 | 下限は`dcb3d428` | 事 |
| 5 | `var indices: Range<Int>`（B:L80） | `0..<count` | BT Indices、EmptyHasNoIndices | OptionalArrayと一致 | 事 |
| 6 | `struct BareArray2D<Element>: ~Copyable`（B:L91） | 2D所有型。`width * height`個を所有 | BT 多次元破棄寿命 | 次元名`width`/`height`はOptionalArrayと一致 | 事 |
| 7 | `init(repeating:width:height:)`（B:L94） | `height * width`個をcopyで埋める | BT 2DRepeating | — | 事。積のoverflowはSwiftの検査付き乗算でtrap（**推**）。負値どうしの積が正になる場合は**未** |
| 8 | `init(width:height:_:)`（B:L103） | `f`を`width * height`回呼び、返り値をstorageへ順に初期化する。連鎖subscriptでは内側の軸（`width`）が最速 | BT 2DInitializerClosure（2×2） | — | 事。非対称な寸法でのstorage対応testは無い |
| 9 | `subscript(position:) -> BareArray1DView`（B:L127） | 外側の軸`height`を選び、`payload + width * position`から`width`個のViewを返す。setterはNOP | BT 2DMutation、SliceReflects。境界のDeath Testは無い | NOP setterは`6fd45542`から。OptionalArrayでは連鎖writeback用と確定（2026-10-08） | 事。BareArrayでの位置づけは**未**（類似のみ） |
| 10 | `var indices`（B:L157） | `0..<height`（外側の軸） | BT Indices | 一致 | 事 |
| 11 | `struct BareArray3D<Element>: ~Copyable`（B:L168） | 3D所有型。`width * height * depth`個を所有 | BT 多次元破棄寿命 | — | 事 |
| 12 | `init(repeating:width:height:depth:)`（B:L171） | 同上をcopyで埋める | なし（Mutation・SliceReflectsが間接に使う） | — | 事。不正次元は2Dと同じく**推**/**未** |
| 13 | `init(width:height:depth:_:)`（B:L181） | `f`を`width * height * depth`回呼び、返り値をstorageへ順に初期化する。連鎖subscriptでは`width`が最速 | BT 3DInitializerClosure（2×2×2） | internal initのcapacityは`877eac14`で`width * height * depth`へ修正（3D cloneの解放漏れ） | 事 |
| 14 | `subscript(position:) -> BareArray2DView`（B:L210） | 外側の軸`depth`を選び、`payload + width * height * position`の面を返す。setterはNOP | BT 3DMutation、SliceReflects（2×2×2）。境界のDeath Testは無い | OptionalArrayでは非対称寸法testが3D Viewのstride不足を検出した（`b3570172`） | 事。BareArrayの非対称寸法でのoffset testは無い |
| 15 | `var indices`（B:L241） | `0..<depth` | BT Indices | 一致 | 事 |
| 16 | `struct BareArray4D<Element>: ~Copyable`（B:L246） | 4D所有型。`size0 * size1 * size2 * size3`個を所有。コメントドック無し | BT 多次元破棄寿命 | 次元名`size0`〜`size3`はOptionalArrayと一致（OPT-028） | 事 |
| 17 | `init(repeating:size0:size1:size2:size3:)`（B:L249） | 全要素をcopyで埋める | BT 4DMutation等が間接に使う | — | 事 |
| 18 | `init(size0:size1:size2:size3:_:)`（B:L260） | `f`を全要素数だけ呼び、返り値をstorageへ順に初期化する。連鎖subscriptでは`size0`が最速 | BT 4DInitializerClosure（2×2×2×2、先頭と末尾だけ確認） | — | 事 |
| 19 | `subscript(position:) -> BareArray3DView`（B:L292） | 外側の軸`size3`を選び、`size0 * size1 * size2 * position`の立方体を`width: size0, height: size1, depth: size2`のViewで返す。setterはNOP | BT 4DMutation、SliceReflects。境界のDeath Testは無い | — | 事。非対称寸法でのoffset testは無い |
| 20 | `var indices`（B:L324） | `0..<size3` | BT Indices（size3=4） | 一致 | 事 |
| 21 | `struct BareArray1DView<Element>`（B:L334） | 非所有。所有者のstorageを直接読み書きする | BT SliceReflects（2D） | `1b461564`で`*Slice`から改名 | 事 |
| 22 | `subscript(position:) -> Element`（B:L346） | `unsafeAddress` / `unsafeMutableAddress`、`0..<count` | BT View上書き寿命（4D経由）。DT View1Dの読み・書き3件 | — | 事 |
| 23 | `var indices`（B:L363） | `0..<count` | BT SliceIndices | 一致 | 事 |
| 24 | `struct BareArray2DView<Element>`（B:L369） | 非所有の面。`capacity`を持つが未使用 | BT 3DSliceReflects | OptionalArrayのViewは`capacity`を持たない（OPT-028） | 事 |
| 25 | `subscript(position:) -> BareArray1DView`（B:L385） | 軸`height`を選び`width * position`。setterはNOP | DT View2Dの下限・上限2件（3D経由）。BT 3DSliceReflects | — | 事 |
| 26 | `var indices`（B:L403） | `0..<height` | BT SliceIndices | 一致 | 事 |
| 27 | `struct BareArray3DView<Element>`（B:L409） | 非所有の立方体。`capacity = height * width`（未使用） | BT 4DSliceReflects | — | 事 |
| 28 | `subscript(position:) -> BareArray2DView`（B:L429） | 軸`depth`を選び`width * height * position`。setterはNOP | DT View3Dの下限・上限2件（4D経由）。BT 4DSliceReflects | OptionalArrayの同箇所は`b3570172`で修正された | 事。非対称寸法でのoffset testは無い |
| 29 | `var indices`（B:L448） | `0..<depth` | BT SliceIndices | 一致 | 事 |

### ledger（公開適合4件）

| # | 適合（行） | 根拠と制約 | 既存test | 区分 |
| --- | --- | --- | --- | --- |
| C1 | `BareArray: @unchecked Sendable where Element: Sendable`（B:L83） | `~Copyable`で所有者は1つ。送ると所有も移る。Viewは`Sendable`でない（publicなstructは暗黙に推論されない）ため送れない | BT `testSendable_compiles`（1Dのcompileだけ） | 事。導入`9b100953`（2026-06-10）。根拠の記録は**未** |
| C2 | `BareArray2D`（B:L160） | 同上 | なし | 事 |
| C3 | `BareArray3D`（B:L244） | 同上 | なし | 事 |
| C4 | `BareArray4D`（B:L327） | 同上 | なし | 事 |

制約（**推**）: 所有者を送る前に取ったViewが元のthreadに残っていれば、送り先と同じstorageへ同時に触れられる。Viewが所有者より
長く生きる問題と同じ根で、Sendable単独の問題ではない。

### 所有・寿命・変更の契約（ledger横断）

- **所有と破棄**: 所有型の破棄で全要素がちょうど1回`deinitialize`される（BT 多次元破棄寿命、IT clone 1D〜4D）。**事**
- **clone**: `internal`。新しいstorageへcopy初期化し、元と独立に要素を保持する（IT 7件）。**事**
- **Viewの非所有**: Viewからの書き込みは所有者のstorageへ反映される（BT SliceReflects 2D〜4D）。**事**
- **`let`の所有者もView経由で変更できる**: BT `testBareArray2DSliceReflectsOriginalStorage`は`let array`から得たViewで
  要素を書き換えている（testのコメント「標準ではこの挙動は許容できないのだとおもう」）。**事**。これを公開契約とするかは**未**
- **Viewの寿命**: Viewは所有者より長く生きられ、そのとき宙に浮いたpointerを持つ。検査もtestも無い。**推**
- **NOP setter**: `a[i][j] = v`は、外側subscriptのget → Viewの書き込み（pointer経由）→ NOPのsetで成立する。
  `a[i] = 別のView`もcompileされ、何も起きない。**推**（compile・実行での確認はしていない）。BareArrayのsourceには、
  OptionalArrayに追加されたwriteback目的のコメントが無い。**事**

### test範囲と、文書・前提だけの契約の分離

- testが証明している: 1D・View 1D・View 2D・View 3Dの上下限trap、全次元の要素変更とView経由の反映、`f`の呼び出し順
  （正方の寸法だけ）、`indices`の軸（非対称寸法あり）、参照型要素の上書き・破棄・cloneでの解放回数、1DのSendable compile。
- testが無い（呼び出し側の前提か、未検証）: 所有2D・3D・4Dの外側subscriptの境界trap、非対称寸法での要素位置（offset・stride）、
  負の寸法・積のoverflow・負どうしの積、`init(repeating:)`の3D・4D単独、2D〜4DのSendable、NOP setterへのView全体代入。

### 新しい判断点（一判断ごとの`DECISION`候補）

次は候補で、採番・登録しない。

1. BareArrayのNOP setterを、OptionalArrayと同じく「連鎖writeback用の実装手段で、View全体代入は公開契約ではない」と位置づけるか。
2. initializerの不正な寸法（負値、積のoverflow、負どうしの積が正になる場合）を`precondition`として明文化・検査するか
   （OptionalArrayにも同じ判断候補がある。両moduleで1判断にするかはCodexが決める）。
3. `let`の所有者からView経由で要素を変更できる性質を、公開契約として認めるか。

### 発見事項の振り分け案（Codexの再計算用）

| 発見事項 | 振り分け案 |
| --- | --- |
| 所有2D・3D・4D外側subscriptの境界Death Testが無い | `BARE-005`前に閉じる前提（現行契約の不足test） |
| 非対称寸法でのoffset・strideのtestが無い（2D〜4D、View 2D・3D） | `BARE-005`前に閉じる前提（OptionalArrayで同種の不具合が見つかった経路） |
| 判断候補1（NOP setter） | `BARE-005`前に閉じる前提（判断） |
| 判断候補2（不正寸法） | `BARE-005`前に閉じる前提（判断）。決定後に不足testが生じる |
| 判断候補3（`let`所有者のView経由変更） | 1.0判断（View設計と同じ根）。現行仕様へ暗黙に固定しない |
| 2D〜4DのSendable compile testが無い、`init(repeating:)`3D・4Dの単独testが無い | Test as Specification整理（`BARE-005`） |
| testが3ファイル（XCTest・Swift Testing・`@testable`）に分かれている | Test as Specification整理（`BARE-005`） |
| 軸の順（外側から選ぶ）、`indices`の軸、`f`の呼び出し順、Viewの非所有、4Dのコメントドック不在 | ユーザードキュメント作業 |
| 1D所有型の名前（`BareArray`）と4Dの`size0`〜`size3` | `BARE-004`（命名）。公開継続が前提なら判断要、`BARE-003`の結果次第 |
| Viewが所有者より長く生きる、Sendable所有者とViewの同時アクセス、View 2D / 3Dの未使用`capacity`、strict memory safety | 文書作業後の1.0判断 |

### 次状態の判定材料

- `BARE-003`（公開継続）: ledgerの範囲では、公開継続を前提にしない記述は見つからなかった。判断が既にあるかどうかの記録は
  この調査では確認していない（**未**）。
- `BARE-004`（命名）: 不揃い（1Dの`BareArray`、4Dの`size0`〜`size3`）は事実として残る。判断が要るかはCodexが決める。
- `BARE-005`: 上の表で「`BARE-005`前に閉じる前提」が4件ある。

停止事項: なし（製品判断は候補に止め、source・testは変更していない）。

### Codex受入（2026-10-09）

公開29宣言と4適合の欠落・重複、source、既存38 test、履歴根拠、OptionalArrayとの差異を照合して受け入れた。
closure initializerは添字を受け取らないため「軸順に呼ぶ」という表現を補正し、storageへの連続初期化と
連鎖subscript上の最内軸の対応を分けた。

Test as Specificationへ直行せず、まず公開継続の判断を行う。公開継続時だけ、命名、NOP setter、不正寸法、
不足testを必要な単位へ分ける。`let`所有者からのView経由変更、View寿命、Sendableとの交差は、現行仕様へ
固定せず文書作業後の1.0判断へ残す。

### 公開継続の決定（2026-10-09）

ユーザーは、BareArrayを競技プログラミング向けの低レベル公開部品として維持すると決定した。これにより、
命名、NOP setter、不正寸法の契約判断と、現行契約の不足testをTest as Specificationより前に進める。

不足testは、すでにsourceで成立している境界とoffset / strideを固定するもので、公開契約を変更しない。
一方、不正寸法のtestは契約判断後に必要範囲が決まるため、この不足test追加へ先取りしない。

## `BARE-009` — 既存契約の不足test追加

### 対象

- 所有2D、3D、4Dの外側subscriptについて、負のindexと上限indexがtrapすること。
- 非対称寸法を使い、2D、3D、4D所有型の連鎖subscriptが期待するstorage位置へ到達すること。
- 非対称寸法を使い、2D Viewと3D Viewのoffset / stride、およびView経由の変更共有が正しいこと。

### 境界

- source、公開契約、命名、NOP setter、不正寸法の扱いを変更しない。
- 既存の通常testとDeath Testの方式に従い、同じ事実を不要に重複させない。
- 不正寸法、View寿命、Sendable、性能のtestを追加しない。
- 別のdefectまたは新しい判断点を発見した場合は修正せず、再現条件と影響を返して停止する。

### Codex受入条件

- 所有2D〜4Dの外側subscriptについて、上下限のtrapが各次元で証明される。
- 正方形・立方体では隠れるstride誤りを、非対称寸法で検出できる。
- View 2D / 3Dを経由したoffsetと変更共有が証明される。
- 対象testがDebug構成とRelease構成で成功し、Death Testの実行条件が既存方式と一致する。

### Codex受入（2026-10-09）

所有2D〜4Dの外側subscript上下限6件と、非対称寸法による所有型・Viewの全位置照合5件を受け入れた。
Codex側でも`swift test --disable-sandbox --filter BareArrayModuleTests`をDebugとReleaseで実行し、Debugは
通常32件・Death Test 17件が成功、Releaseも終了コード0で成功した。Linuxは未確認だが、今回の受入範囲は
既存のplatform条件を変更していない。

initializerのtestコメントは、closure自体が軸添字を受け取らないことに合わせ、「軸順に呼ばれる」から
「返り値がstorageへ順に格納される」へ補正した。defectまたは新しい判断点は見つからなかった。

## `BARE-012` — 命名体系のAI間検討

ユーザー判断の前に、ClaudeとCodexが次を検討する。

- 所有1Dだけが`BareArray`で、Viewは`BareArray1DView`である非対称性。
- 2D・3Dの`width` / `height` / `depth`と、4Dの`size0`〜`size3`の非対称性。
- `OptionalArray1D`および同moduleの多次元型との一貫性。
- 現行名を維持する案、段階的に揃える案、1.0前に破壊的に揃える案の利用者価値と移行コスト。
- 競技プログラミングでの可読性、検索性、推測可能性と、source compatibilityのtrade-off。
- Swift標準ライブラリおよび`swift-collections`の公開型名・用語・命名規則と衝突しないこと。

BareArrayは正式公開前であるため、既存名の維持やsource compatibilityを最優先の制約とはしない。公開後も
長く維持でき、標準または`swift-collections`の型だと誤認されにくい名称であることを必須条件にする。

Claudeは候補、根拠、反証、影響する公開宣言を列挙する。Codexは同じ証拠を独立に評価し、単純な賛否では
なく、前提ごとに推奨が変わる箇所を統合する。両者は命名を決定せず、ユーザーが一つの命名体系を選べる
比較材料として`BARE-004`へ渡す。

`BARE-009`の実行中に命名検討を割り込ませない。Claudeの現行assignment完了後、境界付きの次assignment
として渡し、Codexの独立評価を経てからユーザー判断を起動する。

Codex acceptance（2026-10-09）: Claude初稿と第三者AIの補完調査を独立評価し、現行名、実質的な代替名、
標準の`RigidArray`・`Span`等との意味差、移行範囲、反証が揃ったため受け入れた。BareArrayについては
`BareArray` / `BareArray2D`〜`4D`、`BareArray1DView`〜`3DView`、現行の次元labelを維持する案を
Codex推奨として`BARE-004`へ渡す。名称の最終決定は行っていない。

User decision（2026-10-09）: Codex推奨を採用し、所有型の`BareArray` / `BareArray2D`〜`4D`、View型の
`BareArray1DView`〜`3DView`、2D・3Dの`width` / `height` / `depth`、4Dの`size0`〜`size3`を
維持する。命名変更、互換alias、軸契約の変更は行わない。Viewの非所有性と寿命責務、4Dの軸番号と
連鎖subscript順の関係は、後続の公開契約・ユーザードキュメントで明示する。

## `BARE-013` — NOP setter代替設計

現行の2D〜4D所有型と2D〜3D Viewの外側subscriptは、連鎖要素書き込みのwritebackを成立させるため、
受け取ったViewを捨てるNOP setterを持つ。このためView全体代入もcompileされ、観測可能な無効果操作になる。
ユーザーからは、言語上の必須要件というより実装を簡単にするために置かれた可能性が示された。

Codexはsourceを変更せず、次を確認する。

- NOP setterの導入commitと、その時点で記録された意図。
- 外側subscriptをget-onlyにし、返されたViewのpointer経由の変更だけで連鎖書き込みが成立するか。
- inner Viewの`unsafeMutableAddress`または`nonmutating set`が、一時値と`let`所有者の双方でどう働くか。
- `_modify`など別accessorを使う場合、View全体代入を再び許可しないか。
- 2D〜4D所有型とView 2D〜3Dへ同じ方式を適用できるか。
- compile可否だけでなく、変更共有、最適化可能性、公開API surfaceへの影響。

最小再現と現行型を使う一時的なtypecheckまたはtestだけを行う。source、test、公開契約は変更しない。
成立する最小案、成立しない案、過去の便宜的実装だった可能性、未確認事項を分け、`BARE-010`の
ユーザー判断へ渡す。

### Codex調査結果（2026-10-09）

- NOP setterは`6fd45542`でBareArrayの初版と同時に導入された。commit messageは`bare, optional`で、
  setterを選んだ理由の記録はない。後から追加された便宜実装ではなく初版構造だが、意図は未確認。
- 現行と同じpointerを持つ値型Viewをget-only outer subscriptから返す最小例では、inner subscriptが
  `unsafeMutableAddress`を持っていても、`a[0][0] = 42`は`subscript is get-only`でcompile拒否された。
- `get`と`_modify`、または`get`と`set`で外側をsettableにすれば連鎖代入は可能になるが、同じaccessorは
  View全体代入にも使われる。通常の値型subscriptの代入構文を保ったまま、全体代入だけをcompile時に
  禁止する構成は確認できなかった。
- setterで、戻されたViewのpointerとshapeが、そのpositionから返すViewと一致することを`precondition`で
  検査する最小例は成立した。`a[0][0] = 42`は成功し、値42が元storageへ反映された。
- この検査付きsetterなら、通常のwritebackは無効果のまま許し、別storageまたは別shapeのView全体代入は
  trapにできる。完全なNOPより誤用を早く検出でき、要素copyという新しいO(n)契約も導入しない。
- `_modify`でも終了時に同じ検査は可能だが、View全体代入の構文自体は許すため、setterより明確な利点は
  見つからなかった。

### 判断材料

1. **現行NOPを維持:** 実装が最小で、既存の連鎖書き込みを維持する。別View代入を黙って捨てる。
2. **検査付きsetterへ変更:** 同一pointer・shapeのwritebackだけを許し、別View代入はtrapする。連鎖構文と
   O(1)を維持し、無言の誤用を減らす。
3. **View全体をcopyするsetter:** 直接代入に意味を与えられるが、連鎖要素代入後のwritebackとの区別、
   overlap、O(n)化を新たに扱う必要があるため推奨しない。
4. **get-only化:** 現行の連鎖代入構文を失うため、現行APIを維持する案にはならない。

Codexの推奨は2。compile時の完全除外はできないが、現行の利用形状と計算量を維持しつつ、全体代入を
無言のNOPから契約違反として検出できる。

### ユーザー決定（2026-10-09）

検査付きsetterを採用する。2D〜4D所有型と2D〜3D Viewで、外側subscriptのsetterは同一positionから
返されたpointerとshapeを持つViewだけをwritebackとして受け入れる。別Viewの代入、範囲外position、
shape不一致は契約違反としてtrapさせる。View全体を要素copyする契約は導入しない。

## `BARE-014` — 検査付きView writeback setter

- 5つのNOP setterへ、position境界、pointer、次元またはcountの一致検査を追加する。
- 既存の連鎖要素書き込みがDebug・Releaseで成功することを維持する。
- 別storageの同shape Viewを全体代入するとtrapすることを5経路で固定する。
- source上の計算量はO(1)を維持し、要素copy、rename、View寿命対策を混ぜない。

### Codex受入（2026-10-09）

5つの外側subscript setterへ、position境界、pointer、countまたは次元の一致検査を追加した。既存の通常testに
より連鎖要素書き込みと変更共有が維持され、別storageの同shape Viewを代入するDeath Test 5件がすべて
trapすることを確認した。

`swift test --disable-sandbox --filter BareArrayModuleTests`をDebugとReleaseで実行した。Debugは通常32件と
Death Test 22件、Releaseは通常25件とDeath Test 22件が成功した。既存警告以外の新しいwarningはなく、
source上のsetterは要素を走査せずO(1)を維持する。Linuxと生成コード上での検査除去可否は未確認で、後続の
性能測定設計へ残す。

## `BARE-015` — 不正寸法事前条件

### ユーザー決定（2026-10-09）

OptionalArrayと同じく、各次元は0以上、zero次元は許可、全次元の数学的な積は`Int`で表現可能であることを
公開initializerの事前条件とする。負値と積overflowはtrapさせる。途中積だけがoverflowしても最終積がzeroに
なる入力を拒否しないよう、3D・4Dはzero次元を先に判定する。

### 実行範囲

- 1Dの2 initializerと、2D〜4Dの各2 initializerへ同じ事前条件を実装する。
- zero次元ではclosureを呼ばず、空storageを構築できることを通常testで固定する。
- 負値と積overflowがDebug・ReleaseでtrapすることをDeath Testで固定する。
- internal unsafe initializer、View、命名、storage設計、`-Ounchecked`方針は変更しない。

### Codex受入（2026-10-09）

1D〜4Dの公開initializer 8件へ非負検査を追加し、2D〜4Dは`multipliedReportingOverflow`で次元積を検査した。
3D・4Dはzero次元を積より先に判定し、途中積だけがoverflowするが数学的な最終積はzeroになる入力を許可する。

通常test 1件で、1D〜4Dのzero次元、closureが一度も呼ばれないこと、2Dの空row、巨大な内側次元とzeroの
組合せを確認した。Death Test 14件で、8 initializerの負値と2D〜4D両initializerの積overflowを確認した。

`swift test --disable-sandbox --filter BareArrayModuleTests`をDebugとReleaseで実行した。Debugは通常33件と
Death Test 36件、Releaseは通常26件とDeath Test 36件が成功した。Linuxと`-Ounchecked`は未確認で、
`-Ounchecked`における検査の位置づけは文書作業後の安全性再評価へ残す。
