# BareArrayModule 品質評価（ISO/IEC 25000シリーズ観点）

> 状態: 初版（2026-10-09 / Claude Opus 5.5、`claude-opus-5-5`）。Codex受入済み。
> 評価対象: `Sources/BareArrayModule/BareArray.swift`の公開7型・公開宣言29件と公開適合4件。

## 1. 目的・評価時点・根拠・対象外

BareArrayを競技プログラミング向けの低レベル公開部品（`BARE-003`の決定）としてユーザードキュメント作業へ
渡す時点で、ISO/IEC 25010:2023の製品品質9特性ごとに、確認済みの証拠、制約、不足、未確認を区別して記録する。
本書は品質特性の評価語（満たす・部分など）、公開採用、1.0採用、品質水準を決めない。評価欄はCodexへ残す。

- 評価時点: HEAD `8900ba15`（branch `develop/misc/52`）。本書のための新しいbuild・test・計測はしていない。
- 根拠source: `BareArray.swift`（502行）。以下`L<n>`は同fileの現行行。
- 根拠test: `Tests/BareArrayModuleTests`の番号付き8 file。実行結果は`BARE-005`のCodex受入記録
  （通常test Debug 35件〔internal `clone()`の7件を含む〕・Release 28件、Death Test両構成42件、macOS）を使う。
- 根拠監査: `Maintanance/BareArrayModule/BareArrayAudit.md`（以下Audit）の`BARE-002` ledger、
  `BARE-009`〜`BARE-015`の決定と受入、`BARE-005`受入。strict memory safetyは
  `Maintanance/StrictMemorySafetyReadiness.md` §10。
- 評価対象外: 性能の計測（`BARE-006` / `BARE-007`、凍結）、View寿命・storage再設計・strict memory safetyの
  方針（`ARRAY-001`、凍結）、`let`所有者からのView変更の契約化（文書作業後の1.0判断）、利用者向け本文と
  コメントドックの作成、他moduleの品質。

## 2. 公開契約と番号付きtestの対応

testが証明する範囲だけを書く。「なし」は契約がsourceにあってもtestで固定していないことを示す。

| 公開契約（Audit ledgerの#） | 証明するtest file | 証明の範囲と限界 |
| --- | --- | --- |
| 所有1D〜4Dの`Sendable`適合（C1〜C4） | `0_PublicSurface` | compileだけ。並行実行、Viewとの同時accessは証明しない |
| `init(repeating:...)` 1D〜4D（#2、7、12、17） | `1_Initialization` | 全要素が同じ値。1D・2D・3D・4Dとも非対称寸法を含む |
| `init(...) { }` 1D〜4D（#3、8、13、18） | `1_Initialization`、`2_ElementAccess` | 返り値がstorageへ順に格納されること。非対称寸法の全位置照合は`2_`の2D〜4D |
| 不正寸法の事前条件（BARE-015） | `1_Initialization`（zero）、`99_Death`（負値・積overflow 14件） | zero次元でclosure未呼出し、途中積overflowでも最終積zeroは許可。trapは`.failure`で停止理由を区別しない |
| 要素subscript 1D・View 1D（#4、22） | `2_ElementAccess`、`99_Death` | 読み書き、上下限の読み・書きtrap（1D 4件、View 1D 4件） |
| 外側subscript 所有2D〜4D・View 2D〜3D（#9、14、19、25、28） | `2_ElementAccess`、`3_View`、`99_Death` | 連鎖書き込み、非対称寸法でのoffset・stride、上下限trap、別storageのView代入trap 5件、範囲外positionへの書き戻しtrap 5件 |
| 検査付きwriteback setter（BARE-014） | `2_ElementAccess`（成功側）、`99_Death`（拒否側） | 同一pointer・別shapeは公開APIから作れず、shape不一致trapは未証明（Audit `BARE-005`受入） |
| `indices` 7件（#5、10、15、20、23、26、29） | `4_Indices` | 各型の外側の軸`0..<長さ`と空の1D |
| Viewの非所有・共有（#21、24、27） | `3_View` | View経由の書き込みが所有者へ反映され、面・立方体の外へはみ出さない。testは`let`所有者から書き換える（契約化は未決定） |
| 所有と破棄（#1、6、11、16） | `5_ReferenceLifetime` | 上書き・再代入・2D〜4D破棄・View経由上書きで参照型要素がちょうど1回解放される |
| internal `clone()`（公開外） | `98_Clone`（DEBUGだけ） | 実装test。公開契約の証拠には数えない |

## 3. 品質特性ごとの証拠

列の意味: 「確認済み」はsource・test・記録で確かめた事実、「制約」は契約または設計上の前提、「不足」は
契約がありながらtestまたは記述が無いもの、「未確認」は調べていないか確かめられないもの。

### 3.1 機能適合性

| 副特性 | 確認済み | 制約 | 不足 | 未確認 |
| --- | --- | --- | --- | --- |
| 機能完全性 | 公開29宣言・4適合がledgerに一度ずつ対応（Audit `BARE-002`）。公開面は初期化、要素・Viewのsubscript、`indices`だけ | 位置づけは競技プログラミング向け低レベル部品（`BARE-003`） | — | `count`、列挙、`Equatable`など公開面に無い操作の需要は記録が無い |
| 機能正確性 | 成功側の全公開契約に番号付きtestがある（§2）。非対称寸法の全位置照合で所有2D〜4D・View 2D〜3Dのstrideを固定（BARE-009） | 4Dは`size0`が最内、`size3`が最外（L338〜L346）。initializerの引数順と連鎖subscriptの順は逆 | — | Linuxでの実行（Audit `BARE-009`・`BARE-015`受入でLinux未確認） |
| 機能適切性 | 型コメントは用途を「動的計画法などで利用する大きな配列」とする（L15〜L20） | — | BareArrayの利用例（EDPC等）は無い。`Tests/AcCollectionsTests`の1件（`test_importAcCollections_exposesBareArray`）だけ | 実利用形状での適切性 |

### 3.2 性能効率性

| 副特性 | 確認済み | 制約 | 不足 | 未確認 |
| --- | --- | --- | --- | --- |
| 時間効率性 | BareArrayのbenchmarkは`Benchmarks/`に無く、CI libraryにも無い（`git grep BareArray -- Benchmarks`は0件） | 要素subscriptはoffset計算と`precondition`だけ（L52〜L64、L394〜L406）。外側setterは比較だけでO(1)（L143〜L148ほか） | 型コメントの「C言語の配列に近いアクセス性能を持ちます」（L20ほか）を裏づける測定が無い | 実行時間全般。`BARE-014`・`BARE-015`で追加した検査の性能影響と最適化での除去可否（Audit `BARE-014`受入で未確認） |
| 資源効率性 | 所有型は要素数分の領域を1つ確保する（L27、L101、L191、L288）。View 2D・3Dは未使用の`capacity`を持つ（L428、L473） | storage再設計は`ARRAY-001`（凍結） | — | 確保量の測定 |
| 最適化属性 | 公開APIは`@inlinable`、storageは`@usableFromInline`、accessorは`@inline(__always)` | 属性の意図は導入時期で判断する運用がある | — | 属性ごとの効果 |

### 3.3 互換性

| 副特性 | 確認済み | 制約 | 不足 | 未確認 |
| --- | --- | --- | --- | --- |
| 共存性 | `AcCollections`が`@_exported import BareArrayModule`で再公開し（`Sources/AcCollections/AcCollections.swift:4`）、facade経由の利用をtestで確認（`AcCollectionsTests.swift:96`） | 名称は現行体系を維持（`BARE-004`）。命名検討で標準・`swift-collections`との衝突は確認済み（`ARRAY_NAMING_REVIEW.md`） | — | 外部packageと同時importした場合の実際の名前解決 |
| 相互運用性 | 標準protocol（`Sequence`、`Collection`）へ適合しない。`indices`は`Range<Int>`（Audit ledger、適合は`Sendable`の4件だけ） | — | — | — |

### 3.4 インタラクション能力

| 副特性 | 確認済み | 制約 | 不足 | 未確認 |
| --- | --- | --- | --- | --- |
| 自己記述性 | コメントドックは29件中6件（所有1D〜3Dの型、View 3型）。4D型、initializer 8件、subscript 7件、`indices` 7件には無い。所有型の3件は同じ4文で次元・軸順を述べない。Viewは「参照型の挙動をする」だけで寿命を述べない（L380〜L382ほか） | コメントドック全件整備は本監査の範囲外（Audit 目的） | コメントドック不足: 上記。仕様不足とは別 | — |
| 誤り防止 | 所有型は`~Copyable`で暗黙copyがcompile errorになる。寸法・位置・writebackの契約違反は`precondition`で停止する。View全体代入はcompileされるが、別Viewは実行時にtrapする（BARE-014） | Viewは`Copyable`なstructで、所有者より長く保持することを型で防げない（L383、L418、L460） | Viewの寿命制約は契約としてもtestとしても無い | 所有者より長く生きたViewの挙動（未定義の可能性があり実行していない） |
| 学習性 | 利用者向け文書は無い。CHANGELOGに追加の記録だけがある（`CHANGELOG.md:109`） | 文書形式は未決定（Registryの除外判断） | 利用例 | — |

### 3.5 信頼性

| 副特性 | 確認済み | 制約 | 不足 | 未確認 |
| --- | --- | --- | --- | --- |
| 無欠陥性 | Death Test 42件がDebug・Releaseで成功（境界18、writeback 10、寸法14。BARE-005受入）。修正履歴に下限検査（`dcb3d428`）、3D cloneの解放漏れ（`877eac14`）、writeback検査（`819901a7`）、寸法検査（`b409c50e`）がある | trapは`processExitsWith: .failure`で、停止理由を区別しない | shape不一致のwriteback trapは公開APIから構成できず未証明 | Linux（`DEATH_TEST`は`ENABLE_DEATH_TESTS` trait時だけ。`Package.swift:82-85`）。`-Ounchecked`での挙動 |
| 可用性・耐障害性・回復性 | 契約違反はprocess停止で、回復可能なerrorを返すAPIは無い | 低レベル部品として停止を選ぶ設計 | — | — |
| 寿命（参照型要素） | 上書き、再代入、2D〜4D破棄、View経由上書きで解放回数を固定（`5_ReferenceLifetime`）。clone後の独立保持も実装testで確認（`98_Clone`） | 単一threadでの検証だけ | 1D破棄単独、zero次元の破棄はtestが無い（実装上は`deinitialize(count: 0)`） | — |

### 3.6 セキュリティ

| 副特性 | 確認済み | 制約 | 不足 | 未確認 |
| --- | --- | --- | --- | --- |
| 完全性（範囲外access） | 全添字・外側subscript・writebackは`precondition`で検査する（§2） | `precondition`は`-Ounchecked`で消える。公開APIは`@inlinable`のため、検査の有無は利用側moduleの最適化設定にも依存する（**推**）。BareArrayModule target自体は`swiftSettings`を持たず（`Package.swift:300-302`）、`_O_UNCHECKED`の`-Ounchecked`は適用されない | — | `-Ounchecked`の実行（Audit `BARE-015`受入で未確認、文書作業後の安全性再評価へ残置） |
| 完全性（メモリ安全性） | storageは`UnsafeMutablePointer`。strict memory safetyは未適用で、一時適用時の残り診断は22箇所（unsafe型storage 7とその代入、`allocate` 8） | 恒久適用は公開7型への`@unsafe`伝播かstorage隔離が要る（§10）。`ARRAY-001`（凍結） | — | `BARE-014`・`BARE-015`後の診断数（§10は2026-10-03時点） |
| 完全性（並行利用） | 所有4型は`Element: Sendable`のとき`@unchecked Sendable`（L85、L170、L272、L376）。View 3型は適合しない | 所有者を送る前に取ったViewが残れば同じstorageへ同時に触れ得る（Audit ledger C1の**推**）。View寿命と同じ根 | 導入理由（`9b100953`）と許す並行利用の範囲の記録が無い | 並行実行のtest |
| 完全性（`let`所有者の変更） | `let`所有者から得たViewで要素を書き換えられ、testもこの形を使う（`3_View`） | 契約化は文書作業後の1.0判断（Audit 判断候補3） | — | — |
| 検知 | CIにAddress Sanitizer jobがあり（`.github/workflows/ci.yml`）、package全体の`swift test`でBareArrayのtestも走る | ASanが見るのはtestが通る経路だけ | — | このjobの直近結果は見ていない |

### 3.7 保守性

| 副特性 | 確認済み | 制約 | 不足 | 未確認 |
| --- | --- | --- | --- | --- |
| モジュール性・再利用性 | source 1 file、依存moduleなし。所有4型は確保・`deinit`・`clone()`・writeback検査をほぼ同形で各型に持つ | 共通化はstorage再設計（`ARRAY-001`）と関わる | — | — |
| 解析性・修正性 | 決定（BARE-010〜015）、調査（BARE-013）、修正commitがAuditに追跡可能。View 3Dの`capacity = height * width`（L466）は名前と値が合わないが未使用 | — | — | — |
| 試験性 | 番号付き仕様群8 file（`0_`〜`5_`、`98_`、`99_`）に契約単位で配置済み（BARE-005受入）。testは`BareArrayModule`だけに依存 | 通常testはXCTest、Death TestはSwift Testing | `let`所有者を使う既存testは契約未決定の性質に依存（§3.6） | — |

### 3.8 柔軟性

| 副特性 | 確認済み | 制約 | 不足 | 未確認 |
| --- | --- | --- | --- | --- |
| 適応性 | `swift-tools-version: 6.2`、macOS 15以上（`Package.swift:1`、`:119`）。CIはubuntu-24.04 | `~Copyable`、`borrowing`、`unsafe`式を使う | — | macOS以外のApple platform、Windows、Swift 6.2未満。CI結果はこの調査で見ていない |
| 設置性・置換性 | 公開productは`AcCollections`経由。sourceは`import`を持たず、冒頭に「コピペで提出に使っていただいて構いません。提出の際のライセンス記載は不要です。」（L12〜L13） | copy & paste提出はSwiftPMとは別の配布経路 | — | 現行HEADでの単独copy build |
| 拡張性（scalability） | 次元積が`Int`で表せる範囲を上限とし、超えればtrap。zero次元は空配列（BARE-015） | 確保失敗は`allocate`の挙動で、BareArrayの契約ではない | — | 巨大capacityでの確保失敗時の挙動 |

### 3.9 安全性（危害の意味）

BareArrayは人命・財産・環境に作用する機能を持たないメモリ上の配列で、危害に関わる操作制約の記載は無い。
メモリ安全性は§3.6で扱い、ここに数えない。

### 3.10 利用時の品質

BareArrayの利用例・提出記録は見つからない（`git grep BareArray`はAcCollectionsのfacade test 1件だけ）。
利用時の品質を判断する証拠は無い。

## 4. 引き渡し事項

### 4.1 ユーザードキュメント作業で説明すべき事項

- 各型の用途、所有型と非所有Viewの違い、Viewを所有者より長く保持しないこと（責務は利用者側）。
- initializerの引数順と連鎖subscriptの順が逆であること、4Dの`size0`が最内・`size3`が最外であること（`BARE-004`の決定事項）。
- `indices`が外側の軸を表すこと、zero次元が有効なこと、不正寸法・範囲外位置・別View代入がtrapすること。
- `a[i] = view`は同じ位置から得たViewの書き戻しとしてだけ有効で、要素copyではないこと。
- 標準`Collection`ではないこと、主要操作の計算量（実装上はsubscriptがO(1)、初期化と破棄がO(要素数)）。
- `@unchecked Sendable`は並行共有の保証ではないこと、`-Ounchecked`では事前条件に依存できないこと。
- 型コメントの性能記述（「C言語の配列に近いアクセス性能」）を本文へ持ち込むかは、測定根拠が無い前提で扱う。
- 4D型とinitializer・subscript・`indices`のコメントドック不在（6/29）。

### 4.2 文書作業後の1.0判断へ送る事項

- 性能基準と計測: `BARE-006` → `BARE-007`（凍結）。検査追加後の最適化影響を含む。
- View寿命、Sendable所有者とViewの同時access、storage再設計、strict memory safety（残り22箇所の再計測を含む）:
  `ARRAY-001`（凍結）。
- `let`所有者からのView変更を契約として認めるか、testを`var`へ変えるか（Audit 判断候補3、`BARE-005`受入）。
- `-Ounchecked`での事前条件の位置づけ（Audit `BARE-015`受入）。
- Linuxでの通常test・Death Test、shape不一致trapの証明可否。

## 5. 新しい判断task候補

なし。§3で見つかった制約と不足は、すべて§4.1または§4.2の既存境界へ接続できた。

## 6. 所見（ユーザードキュメント作業の入力として）

公開29宣言・4適合の契約がledgerで確定し、成功側・停止側の契約が番号付きtestで固定され（§2）、説明すべき
事項（§4.1）と後続判断（§4.2）が分離できているため、本書はユーザードキュメント作業の入力として使えると考える。
ただし性能と利用時の品質には証拠が無く、セキュリティの主要論点（View寿命、`@unchecked Sendable`、
`-Ounchecked`、strict未適用）は未決定のまま文書で制約として説明する前提である。評価語と受入はCodexが行う。

## 7. Codex受入

2026-10-09、公開契約とtestの対応、品質特性ごとの証拠区分、文書作業と1.0判断の境界を検収し、
ユーザードキュメント作業の入力として受け入れた。性能や利用時品質に証拠がないこと、安全性の主要論点が
未決定であることは評価の欠陥ではなく、後続へ明示的に渡された制約である。新しい製品判断は本文へ混入
していない。品質評価文書をSwiftPMのbuild入力へ含めないため、BareArrayModule targetの`Documentation`を
`Package.swift`のexcludeへ追加した。
