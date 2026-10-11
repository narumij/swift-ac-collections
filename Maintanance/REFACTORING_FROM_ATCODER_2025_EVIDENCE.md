# Evidence for refactoring from `release/AtCoder/2025`

## この別紙の責任

この別紙は、[本紙](REFACTORING_FROM_ATCODER_2025.md)が説明する移行史について、コミット、
旧新パス、中間形、短命な試行、未確定事項を保持する事実・証拠の正本である。

調査の途中経過を追記できることを優先し、読み物としての洗練は本紙が担う。本紙はここにある
詳細事実を独立に再定義しない。

各記述には次の性質を付す。

- **[事実]** `git show`、`git diff`、`git log --follow`等で直接確認した内容。
- **[証言]** `Maintanance/MAINTENANCE.md`等にあるユーザー自身の説明。
- **[解釈]** 事実からの推測。rename類似度はGitが同一ファイルと判定した事実としてのみ扱い、
  契約や作者意図の同一性を直接導かない。
- **[未確認]** 現在の証拠では確定していない内容。

## 調査基点

**[事実]** `release/AtCoder/2025`の先端は`b2580703`(2025-09-03)であり、
`git merge-base b2580703 HEAD`は`b2580703`自身と一致する。同commitにはタグ`0.1.44`もあるが、
本調査ではbranch先端commitを基点とする。

## Unsafe系統の移行表(2026-10-11)

標準ライブラリの`UnsafeMutablePointer`等は、それ自体を一系統として数えない。同じ型に対する
extensionや同じ責務の分割ファイルは一行へまとめる。名前の連続と責務の連続は同一とは限らない。

| 系統 | 誕生 | 消滅・変化 | 現行の到達点 | 判定 | 主な証拠 |
|---|---|---|---|---|---|
| `UnsafeTree` → `UnsafeTreeV2` | `add37b4b`で初代、`7964713d`でV2を別型として新設 | `55ccdb3d`で旧型の大半を削除。V2初版は旧HeaderとNodeを利用 | `Implements/UnsafeTreeV2/` | 並行新設後の責務吸収 | `add37b4b`、`7964713d`、`55ccdb3d` |
| `UnsafeIndex` → V2 → V3 | 無印`add37b4b`、V2`7964713d`、V3`357335f7` | 無印は`55ccdb3d`で削除。V2は`fd6559ac`からDeprecatedへ再配置 | V3は`_LazyTiedPtr`へのtypealias、V2は互換実装 | 世代交代と同名内部差し替え | `a53d9a5b`、`fd6559ac`、`005a7bb3` |
| `UnsafeNode` | `add37b4b`で新設 | V2側への移動、一時削除、`364c203d`の100% renameを経る | `__tree/unsafe_node/unsafe_node.swift` | 名称再出現を含む責務継承候補 | `1c745eef`、`364c203d` |
| `UnsafeIterator`系 | `add37b4b`で旧Tree用具象群、`5fd598b4`で現行namespace型 | 初期案を削除し、一部をDeprecatedへ隔離 | IteratorとDeprecatedの二層 | 具象型群からnamespace型への再構成 | `1c745eef`、`5fd598b4`、`14605f08` |
| `UnsafeSlice` → Slice V2 → sealed range | `add37b4b`、`7964713d` | `1c745eef`で旧Slice削除、V2移動。2026-02-05にrangeをprotocolへ分解 | Index Range / View、旧protocolはDeprecated | パス名からrange/Viewへの責務分解 | `a53d9a5b`、`c9bd428e`、`3c5f1aae` |
| Storage / Pair / FreshPool → Buffer | 2026-01-01以降に順次導入 | Storageは`55ccdb3d`、Pool V1/V2は`4dad3c9c`で削除 | Buffer/Header、Node、RawBuffer | allocation・header・payload責務への分解と統合 | `4a86c72d`、`4dad3c9c` |
| `_UnsafeNodePtrType`とUnsafe protocol群 | `aba7c6c0`以降 | V2・sealed range密着分をDeprecatedへ隔離 | 共通境界と互換protocol | 能力抽出後の分岐 | `2b7fea27`、`bf1350f4`、`dff90498` |
| `UnsafeMutableRawPointer+malloc` | `fddc804b` | Tree内部から共通RawBufferへ100% renameを反復 | `Implements/RawBuffer/` | 共通基盤化 | `e3f1eeb5`、`de3eff3e`、`974d21c4`、`28a1a5fb`、`0ada7b35` |
| debug access protocol | `090d7768`〜`9189f2c6` | `3b14a466`と`c7a6a8c5`で製品ソースからテストへ移管 | `DebugAdditionals/TransitionFromLegacy/` | test-only preservation | `git log --name-status -M -- '*UnsafeTreeAccessHandleBase*'` |

**[事実]** 基点には上表の型名としての`UnsafeTree`、`UnsafeIndexV2/V3`、`UnsafeNode`はない。
一方、`___Tree`、整数`_NodePtr`、`__left_unsafe`等のunsafe責務は既に存在する。

**[事実]** `UnsafeIndexV4`追加commit`77095c38`等は`git log --all`では見つかるが、現行`HEAD`の
祖先ではない。現行系譜へ直列に接続せず、非採用または未統合の試作として扱う。

## `UnsafeTree`内部構造の転換点

| 段階 | Index | Node | Storage / `ManagedBuffer` | CoW | 主な証拠 |
|---|---|---|---|---|---|
| AtCoder 2025 (`b2580703`) | `rawValue: Int`、Indexが`___Tree`を保持 | 連続要素、整数リンク | `ManagedBuffer<Header, Node>` | 非一意または容量不足で全体copy | `_Tree/___Tree*.swift` |
| 初代`UnsafeTree` (`add37b4b`) | pointer＋`___node_id_` | pointerリンク、Node直後にpayload | `ManagedBuffer<Header, UnsafeNode>`、Headerのpool | 共有時copy、一意ならpool成長 | 初代Tree、Node、Index、CoW各ファイル |
| V2並行導入 (`7964713d`) | `UnsafeIndexV2` | 初代Nodeを共有 | 値型V2が旧Headerを持つ`ManagedBufferPointer`を包む | Nodeとリンクを新bufferへ再構築 | V2初版 |
| 専用Buffer・bucket (`4a86c72d`〜`4591b20f`) | pointerとNode番号を維持 | Node＋payloadをbucketへ配置 | Node element→end専用→Origin→`Void`。実Nodeはraw bucket所有 | bucket追加、refCount/strong uniqueness試行と撤去 | `f86dbd3b`、`c6cd93a6`、`c55c951c`、`246ec1be` |
| identity・安全柵 (2026-01-22〜02-11) | tied、sealed、V3 | tracking tag＋recycle count | Headerがbucket、allocator、tied bufferを接続 | tagから新pointerを解決し、世代で再利用検査 | `1dc91bf1`、`86ab5952`、`b9b70ada`、`357335f7` |
| 現行 (2026-05〜) | `UnsafeIndexV3 = _LazyTiedPtr` | tag、recycle count、payload有無 | `ManagedBufferPointer<Header, Void>`＋raw bucket＋tie | buffer一意性を入口に共有時だけ再構築 | `fa3f3fb0`、`ff5d0bfc`、`005a7bb3`、`09ea07bd` |

**[事実]** 基点の`_NodePtr`とIndexの`rawValue`は整数だった。`add37b4b`ではNodeリンクとIndexが
実ポインタへ変わり、NodeへCoW再構築専用の`___node_id_`が追加された。

**[事実]** V2初版は初代TreeのHeaderを利用した。専用Buffer導入後、ManagedBuffer element領域は
Node本体の連続格納からend/Originだけを置く段階を経て`Void`となり、実Nodeとpayloadはraw bucketへ
移った。

**[事実]** 2026-01-12〜13には明示的な参照count、pool deallocatorまで含むstrong uniqueness、
単純CoWへの強制と撤去が続いた。現行の非互換modeでは`_strongEnsureUnique()`は
`ensureUnique()`と同じで、Storage一意性は`ManagedBufferPointer.isUniqueReference()`で判定する。

**[解釈]** pointer IndexはNodeのアドレス安定性を必要とし、bucket化は一意なStorageの容量追加で
既存Nodeを動かさない構造を成立させた。CoWでは別Storageへ再構築するためpointerが変わり、その差を
node ID/tag、世代、seal、tieが段階的に担ったと読める。ただし作者の直接の目的までは断定しない。

## Keystone testとTest as Specification

### 保証範囲の縮退と再建

| 時期 | 実装側の変化 | テスト側の状態 | 保証上の意味 | 主な証拠 |
|---|---|---|---|---|
| AtCoder 2025以前 | 整数Index・配列型Nodeを前提とするTree | 公開Setの番号付き仕様テストと旧Fixtureテストが存在 | 公開挙動と旧内部表現の双方を検証 | `f4e9f69e`、`63b5699a` |
| 2026-01-03 | `UnsafeTreeV2`を旧系列と並行導入 | 旧Fixtureを残してunsafe版Keystoneを分岐コピー。ただし追加時点では`#if false` | 検証方法を保存したが、まだ実行保証には組み込まれていない | `cc0ca3ad` |
| 2026-01-05〜28 | pool、bucket、pointer Index、CoWを反復変更 | 多数の既存テストについて条件、期待値、CoW検査、共通TestCaseを変更。旧実装固有の検査も削減 | 全保証を固定せず、新構造へ追従できる範囲に検証面を調整 | `f4ef9301`、`928215c6`、`8c334f60`、`94d13f98` |
| 2026-09-29〜30 | 旧array treeと現行unsafe treeの責務を整理 | 旧Keystoneを削除し、unsafe版を現行Fixtureへ移して実行対象化 | 旧内部表現の保証を捨て、木の不変条件を新構造側へ架け替え | `1357bd3c`、`ecb3085d` |
| 2026-10-02〜03 | Fixtureを独立targetへ分離し、現行内部テスト群を整備 | Keystoneへ`#if false`を再導入。新しいFoundamental test群とFixture targetを成立させる | 深いブートストラップ検査を保存資料へ退け、日常の実行保証を新しい検証系へ移管 | `64118cd6`、`60604ff6`、`2b5ff728`、`0483012f` |
| 現行 | pointer identity、bucket Storage、CoW、公開4型が収束 | Keystoneは保存中。公開仕様、内部構造、互換性のテスト群は役割別に存在 | 一つの旧テストを復活させるのでなく、保証を公開契約と現行内部境界へ再配置 | 現行`Tests/RedBlackTreeTests/`、`Tests/TESTING.md` |

**[事実]** `cc0ca3ad`で追加されたunsafe版Keystoneの外側には`#if false`があり、当初は実行対象では
なかった。`ecb3085d`で現行の`UnsafeTreeV2/Instance/`へ再構成された版には外側の`#if false`がなく、
`#if DEBUG`下で実行可能だった。`64118cd6`で同じ系譜のファイルへ`#if false`が再導入され、現在まで残る。

**[事実]** 2026-01-05の`f4ef9301`は`USE_UNSAFE_TREE`切替を整理すると同時に、CoW testの一部と
旧実装固有のtest helperを削除し、旧TreeのContainer testを大幅に書き換えた。翌日の`928215c6`は
75 test fileを変更して共通TestCaseを導入した。これは内部交換中もtest集合が不変だった、という
説明とは両立しない。

**[事実]** 2026-09-29の`1357bd3c`は旧array-tree版Container testを削除した。翌日の
`ecb3085d`は移行用unsafe版を現行`UnsafeTreeV2`側へ移し、同時にdebug helper群を再配置した。
2026-10-02の`60604ff6`は内部Fixtureを独立targetへ移し、`2b5ff728`は新しいFoundamental testの
区切りを記録した。

**[解釈]** Keystone testの役割は継続的なgreenを単独で保証することではなく、旧Fixtureが表していた
木の構築・不変条件・操作検査を、新しいpointer/bucket構造へ翻訳可能な形で保持することだったと読める。
実行対象から外れた期間は保証が同一のまま維持された証拠ではなく、その保証が薄くなった、または別の
test群へ移管された期間として区別する必要がある。

**[解釈]** この履歴では、旧テストへの適合と新構造の成立が常に同じ方向を向いていない。旧表現を
固定する検査を緩めなければ構造交換が進まず、すべてを緩めれば赤黒木としての同一性を失う。
公開Test as Specification、Keystone、現行内部testは、この緊張の異なる時期と境界を受け持った。

**[事実]** 保存中のkeystone testは
`Tests/RedBlackTreeTests/UnsafeTreeV2/Instance/___RedBlackTreeContainerTests_unsafe.swift`である。
これは基点の原本ではなく、2026-01-03の`cc0ca3ad`で旧Fixtureテストを残したまま追加した
unsafe実装向け分岐コピーを、内部構造へ追従させた派生・再構成版である。現在は`#if false`で保存する。

**[事実]** 直接の前身`Tests/RedBlackTreeTests/tree/___RedBlackTreeContainerTests.swift`は
`git log --follow`で`63b5699a`(2024-12-07)まで遡る。

**[事実]** `RedBlackTreeSet`の番号付きTest as Specification 11ファイルは`f4e9f69e`
(2025-05-25)で導入済みで、基点より前から存在する。MultiSet/Dictionary/MultiMapは基点では
各2ファイル、現行では各22〜24ファイルだが、個別の分解commitは未追跡である。

**[証言]** 既存テストをゼロから作り直さず、そのままブートストラップへ利用することが
`Maintanance/MAINTENANCE.md`のユーザー要望に明記されている。

## ソース配置とmodule境界

**[事実]** 基点では公開4型が`Sources/RedBlackTreeModule`直下、内部実装は`_Tree/`にあった。

**[事実]** `28a1a5fb`(2026-05-04)は、既存の内部層14区分を内容不変のrenameとして
`Implements/`へ集約した。

**[事実]** module名変更は三段階だった。

1. `0ada7b35`: 240ファイルのdirectoryを`RedBlackTreeCollections`へ100% rename。target名は旧名。
2. `e91c01ff`: target名とテストimportを変更し、旧名の再公開targetを追加。
3. `76328122`: 旧名互換targetの物理folderを`_RedBlackTreeModule`へrename。

## 現行Node格納方式の性能観察

**[事実]** `Archived/CombiningAPIPerformanceEvidence.md`では、1k〜256k要素で既存Treeへの逐次挿入が、
新しい結果Treeを構築するmeld系より一貫して高速だった。Setのdisjoint入力では約2倍だった。

**[事実]** 結果bufferの初期容量を`2`から`count + other.count`へ変えるPoCは0.96〜1.04倍の
計測noise内だった。現行bucket式格納は容量拡張で既存Nodeを移動せず、bucketを追加する。

**[解釈]** 逐次挿入は既存TreeとNodeを活用でき、meldは結果Tree全体を構築するため、定数cost差が
漸近的利点を覆った可能性がある。ただし基点と同条件の比較はなく、移行との因果は確定しない。

## 未確認・追加調査

- `UnsafeNode`の2026-01-18〜22の削除・再導入区間は責務の連続を確認したが、同一実装の継続範囲は未確定。
- 現行`HEAD`外のUnsafe系試作は網羅分類していない。
- MultiSet/Dictionary/MultiMapの仕様テストが現行の分割数へ至った個別commitは未追跡。
- 2026-01月の各commit時点で実行されたtest commandとgreen範囲は、commit messageだけでは確定しない。
- Keystoneから現行Foundamental test群へ、個々のassertionが一対一で移管されたかは未照合。
- 基点と現行の同条件性能比較は未実施。
