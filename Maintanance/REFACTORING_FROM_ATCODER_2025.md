# Refactoring from `release/AtCoder/2025`

この文書は、`release/AtCoder/2025`で稼働した赤黒木実装から現在の構成へ移行した際の
手法と段階を、後から追跡できるように記録する。

## 証拠の扱いについて

各記述には次のいずれかの性質を付す。

- **[事実]** `git show` / `git diff` / `git log --follow` 等で直接確認した内容。
- **[証言]** `Maintanance/MAINTENANCE.md` 等にあるユーザー自身の説明。
- **[解釈]** 事実からの推測。リネーム類似度(`-M`のパーセンテージ)は「同一ファイルだと
  判定されたかどうか」という事実としてのみ扱い、そこから契約が変わっていない、または
  作者の意図がこうだった、という結論を直接導かない。

## Keystone test

移行の要石として保存しているテストは次のファイルである。

`Tests/RedBlackTreeTests/UnsafeTreeV2/Instance/___RedBlackTreeContainerTests_unsafe.swift`

このファイルは固定したノード配置を直接構築し、木の不変条件、最小・最大ノード、回転、
挿入後の平衡化、探索位置、削除時の`begin`更新を個別に確認する。通常の公開APIテストより
下の層で、コンテナと木アルゴリズムの接続を検証していた。

**[事実]** 下記「テスト側の移行」で詳述する通り、このファイルは`release/AtCoder/2025`時点の
原本を直接改名し続けたものではなく、2026-01-03に作られた分岐コピーが約9か月かけて
改名・移動・大幅書き換えを経て現在の姿になった、派生・再構成版である。原本そのものは
2026-09-29に別途削除されている。

現在はファイル全体を`#if false`で囲み、コンパイル対象外の保存資料としている。現行APIへ
追従させることより、移行当時の構造、命名、テスト手法を残すことを優先する。

## 前提となる事実: Test as Specificationは移行の産物ではない

**[事実]** コミット`f4e9f69e`(2025-05-25)で、`RedBlackTreeSet`の番号付きTest as
Specification(`RedBlackTreeSet_0_InitializationTests.swift`〜`_9_ProtocolConformanceTests.swift`、
計11ファイル)が既に導入されている。これは`remotes/origin/release/AtCoder/2025`の
先端コミット`b2580703`(2025-09-03、`git merge-base b2580703 HEAD`が`b2580703`自身と一致する
ことで現在の履歴の直線上の祖先と確認済み)より**4か月近く前**であり、
`git ls-tree remotes/origin/release/AtCoder/2025`でも同じ11ファイルが release 時点に既に
存在することを確認した。

なお`b2580703`には同時にタグ`0.1.44`も付与されているが、本書では一貫して
「`release/AtCoder/2025`ブランチの先端コミット」として参照し、タグそのものを移行史の
基準点として扱わない。

**[事実]** keystone testとして保存している
`Tests/RedBlackTreeTests/UnsafeTreeV2/Instance/___RedBlackTreeContainerTests_unsafe.swift`の
直接の前身である`Tests/RedBlackTreeTests/tree/___RedBlackTreeContainerTests.swift`は
`git log --follow`で2024-12-07のコミット`63b5699a`(`moved from tree`)まで遡れ、
AtCoder2025版よりさらに前に遡る。

**[解釈]** 「Test as Specification」や原木テストという手法自体は、AtCoder 2025版からの移行で
新規に持ち込まれたものではなく、それ以前から存在した開発手法が、移行後も一貫して
受け継がれ、他の型へ横展開されたと考えられる。**[事実]** 一方、`RedBlackTreeMultiSet`/
`RedBlackTreeDictionary`/`RedBlackTreeMultiMap`はrelease時点では`_0_`/`_1_`の2ファイルのみ
(`git ls-tree`で確認)で、現在はそれぞれ22〜24ファイルまで分解されている。どの時点の
どのコミットで各ファイルへ分解したかは個別追跡していないため、ここでは「releaseの時点では
未分解だった」という確認済みの差分として記録するに留める。

## ソース本体の移行(時系列)

ソース本体(`Sources/RedBlackTreeModule` → `Sources/RedBlackTreeCollections`)の移行は、
テスト側の移行と時系列が大きく異なるため、節を分けて記録する。

### S1. AtCoder 2025 implementation(〜2025-09-03 `b2580703`)

**[事実]** `remotes/origin/release/AtCoder/2025`では、本体は`Sources/RedBlackTreeModule`直下に
`RedBlackTreeSet.swift`等4型の公開ファイルが直接置かれ、内部実装は`_Tree/`配下へ
`Tree_IndexProtocol`等のprotocol指向設計、`___Tree+CopyOnWrite.swift`のような三連アンダースコア
命名で収められていた(`git ls-tree`で確認)。テストは次の場所にあった。

`Tests/RedBlackTreeTests/tree/___RedBlackTreeContainerTests.swift`

`RedBlackTreeModule`を`@testable import`し、`RedBlackTreeSet`へデバッグ用の操作を直接追加して、
整数ベースのノード表現を組み立てていた。

### S2. 内部層の`Implements/`への集約(`28a1a5fb`、2026-05-04)

**[事実]** コミット`28a1a5fb`(2026-05-04、`file layout`)の直前の親コミットの時点では
`Sources/RedBlackTreeModule`直下に`Implements/`ディレクトリは存在しない。`28a1a5fb`自身が
`git show -M --name-status`上で次の14個の最上位ディレクトリ・ファイルを一括して
`Implements/`配下へ移すリネームである(類似度100%のR行として記録、内容は不変)。

`BoundsExpression` / `Deprecated` / `Index` / `Iterator` / `Memoize` / `Misc` / `Protocol` /
`RangeExpression` / `RawBuffer` / `Test` / `UnsafeTreeV2` / `View` / `__tree` / および
4型の直下`.swift`ファイル群。

**[解釈]** つまり`__tree`・`UnsafeTreeV2`・`BoundsExpression`・`Deprecated`といった概念的な
内部層自体はこのコミットより前から独立ディレクトリとして存在していたが、それらを
`Implements/`という単一の親ディレクトリへ集約する行為そのものは`28a1a5fb`が行った。
「内部層分離が2026-05-04時点で既に存在した」ではなく、「`Implements/`への集約が
2026-05-04に行われた」と記録するのがより正確である。

### S3. モジュール名の変更: `RedBlackTreeModule` → `RedBlackTreeCollections`

**[事実]** 3段階で行われたことを`git show --name-status -M`と`Package.swift`の差分で確認した。

1. `0ada7b35`(2026-05-14、`folder name`): ディレクトリのみ
   `Sources/RedBlackTreeModule` → `Sources/RedBlackTreeCollections`へ100%一致のリネーム
   (240ファイル)。`Package.swift`のターゲット名はまだ`RedBlackTreeModule`のまま、
   `path:`だけが新ディレクトリを指す。
2. `e91c01ff`(2026-06-01 03:17、`RedBlackTreeCollections`): `Package.swift`のターゲット名を
   `RedBlackTreeModule`から`RedBlackTreeCollections`へ変更。同時に、互換用の薄い新ターゲット
   `RedBlackTreeModule`を追加し、中身を`@_exported import RedBlackTreeCollections`のみとした
   (現在の`Sources/_RedBlackTreeModule/RedBlackTreeModule.swift`と同一内容であることを確認)。
   `Tests/RedBlackTreeTests`等の`@testable import`対象もこのコミットで
   `RedBlackTreeCollections`へ切り替わっている。
3. `76328122`(2026-06-01 03:29、同日12分後、`rename`): 新設した互換ターゲットの物理フォルダを
   `Sources/RedBlackTreeModule` → `Sources/_RedBlackTreeModule`へリネーム。これにより現行の
   `Sources/_RedBlackTreeModule/RedBlackTreeModule.swift`が確定した。

**[解釈]** この結果、現行コードベースの「本体は`RedBlackTreeCollections`、`RedBlackTreeModule`は
`@_exported import`のみの互換レイヤー」という構造は、実装を書き直したのではなく、
ターゲット名とディレクトリ名の交換 + 旧名での薄い再公開シムの新設によって成立したと考えられる。

## テスト側の移行(時系列)

テスト側、特にkeystone testの移行は、上記ソース側の移行とは独立した時系列を持つ。
また、単純な改名ではなく「分岐→並行運用→原本削除→分岐側の大幅改稿」という経過をたどる。

### T1. 分岐点(`cc0ca3ad`、2026-01-03)

**[事実]** コミット`cc0ca3ad`(`test`)は単一コミットで次の2つを同時に行っている。

- `M  Tests/RedBlackTreeTests/tree/___RedBlackTreeContainerTests.swift`(原本を編集)
- `A  Tests/RedBlackTreeTests/unsafeTree/old/___RedBlackTreeContainerTests_unsafe.swift`(新規追加)

分岐直後の両ファイルを`diff`で比較すると、`#if DEBUG && !USE_UNSAFE_TREE` /
`#if DEBUG && USE_UNSAFE_TREE`のような条件コンパイルの反転や、`___header.__begin_node` /
`___header.__begin_node_`といった細部の差はあるが、全体構成はほぼ同一であり、新ファイルは
原本からの意図的な分岐コピーであると判断できる。この時点から、同じ役割を持つ2つのファイルが
並行して存在するようになった。

### T2. 分岐先ファイルの改名・移動(2026-01〜2026-09、個別コミット追跡なし)

**[事実]** `git log --follow`で分岐先ファイル(最終的に現行のkeystoneファイルへ繋がる系列)を
追うと、`cc0ca3ad`から現在までの間に以下のパスを経由している(いずれも内容を伴わない
リネームのみの移動かどうかは全コミットを個別検証していないため、パスの遷移という
確認済みの事実のみを記録する)。

`unsafeTree/old/` → (複数回の中間移動) →
`DebugAdditionals/TransitionFromLegacy/___RedBlackTreeContainerTests_unsafe.swift`

### T3. 原本の削除(`1357bd3c`、2026-09-29)

**[事実]** コミット`1357bd3c`(`sesson half, hand edit`)で、分岐元の原本
`Tests/RedBlackTreeTests/tree/___RedBlackTreeContainerTests.swift`(337行)が、対応する追加なしに
削除されている。この時点で、2026-01-03に始まった2系統の並行状態が解消され、T2の系列
(`DebugAdditionals/TransitionFromLegacy/`配下のファイル)だけが残った。

### T4. 分岐先ファイルの大幅改稿と現行パスへの移動(`ecb3085d`、2026-09-30 07:36)

**[事実]** 原本削除の翌日、コミット`ecb3085d`(`refactoring tests?`)は`git show -M
--name-status`上で次のように記録される。

```
D  Tests/RedBlackTreeTests/DebugAdditionals/TransitionFromLegacy/___RedBlackTreeContainerTests_unsafe.swift
A  Tests/RedBlackTreeTests/UnsafeTreeV2/Instance/___RedBlackTreeContainerTests_unsafe.swift
```

`-M`のリネーム検出が働かず、削除・新規追加として記録されている。削除前(350行)と
追加後(347行)の内容を直接`diff`すると446行分の差分があり、ほぼ全面的な書き換えに近い
(同じディレクトリ移動コミットの中の他のファイル群は`R100`/`R098`等、素のリネームとして
検出されている点と対照的)。したがって、このコミットは「移動」に加えて「内容の大幅な
書き直し」を同時に行ったものであり、単純なリネームとして記録するのは不正確である。
現行のkeystoneファイルのパスはこの`ecb3085d`で初めて確定した。

### T5. Bootstrap命名への改名とその後の揺り戻し(`438af006`ほか、2026-09-30〜2026-10-03)

**[事実]** `ecb3085d`の3分後、同日のコミット`438af006`(`refactoring tests?`)で
`___RedBlackTreeContainerTests_unsafe.swift` → `UnsafeTreeV2BootstrapTests.swift`へ改名された
(`R099`)。この名前は2026-10-02の`64118cd6`時点まで維持され、翌2026-10-03のコミット
`0483012f`(`refactoring`)で`UnsafeTreeV2BootstrapTests.swift` → `___RedBlackTreeContainerTests_unsafe.swift`
(`R099`)へ戻され、現在の名前に至っている。

**[解釈]** この一般名(`Bootstrap`)では旧`RedBlackTreeContainerTests`からの移行資料であることが
見えにくいため、最終的に第1段階由来の名前へ戻したと考えられる。`Bootstrap`という役割は
ファイル内コメントと本書で保持する。

### T6. Fixtureと原木(`__tree`)の専用ターゲット化(2026-10-02)

**[事実]** `29f43bb3`(2026-10-02 08:34、`fixture target`)の`git show -M --name-status`:

```
M  Package.swift
R100  Tests/RedBlackTreeTests/Fixtures.md -> Tests/RedBlackTreeFixture/Fixtures.md
A  Tests/RedBlackTreeFixture/RedBlackTreeFixture.swift
D  Tests/RedBlackTreeTestSupport/___Node.swift
```

`RedBlackTreeCollections`に依存する独立ターゲット`RedBlackTreeFixture`を`Package.swift`へ
新設し、`Fixtures.md`をそこへ移し、`RedBlackTreeTestSupport/___Node.swift`を廃止している。

**[事実]** `60604ff6`(2026-10-02 13:32、`genboku test target`)の`git show -M --name-status`:

```
M  Package.swift
M  Sources/RedBlackTreeCollections/Implements/__tree/unsafe_node/unsafe_node+pointer.swift
M  Tests/RedBlackTreeFixture/Fixtures.md
D  Tests/RedBlackTreeFixture/RedBlackTreeFixture.swift
R072  .../Tree/Fixture/UnsafeNodeReferenceFixture.swift -> Tests/RedBlackTreeFixture/UnsafeNodeReferenceFixture.swift
M  Tests/RedBlackTreeTests/UnsafeTreeV2/Instance/RawBufferHeadFixture.swift
M  Tests/RedBlackTreeTests/UnsafeTreeV2/Instance/UnsafeNodeRawBufferCrossCheckTests.swift
R100  Tests/RedBlackTreeTests/Tree/Fixture/TreeNodeOnlyFixture.swift -> Tests/RedBlackTreeTreeTests/Fixture/TreeNodeOnlyFixture.swift
R100  Tests/RedBlackTreeTests/Tree/Fixture/TreeOwnedNodeFixture.swift -> Tests/RedBlackTreeTreeTests/Fixture/TreeOwnedNodeFixture.swift
A  Tests/RedBlackTreeTreeTests/Fixture/TreeTestCase.swift
R098/R099  Tests/RedBlackTreeTests/Tree/Foundamental/TreeFoundamental*.swift(10ファイル)
   -> Tests/RedBlackTreeTreeTests/Foundamental/TreeFoundamental*.swift
M  Tests/TESTING.md
```

新ターゲット`RedBlackTreeTreeTests`を`Package.swift`へ追加し、`Tests/RedBlackTreeTests/Tree/`
配下にあった`Fixture/`(2ファイル)と`Foundamental/`(10ファイル、Allocation・
ComparisonInjection・DeathTests・InvariantViolation・MemoryLayout・Multiplicity・
Mutation・NodeSealing・SafePtr・Seal・Tests・Valueの各テスト)を
`Tests/RedBlackTreeTreeTests/`へ全面移動している。`RedBlackTreeFixture.swift`自体は
`RedBlackTreeFixture`ターゲットから削除され、`UnsafeNodeReferenceFixture.swift`に
統合されている(類似度72%のリネームとして検出)。`Tests/TESTING.md`に記録のある
「`__tree`: 専用ターゲット化」はこの`60604ff6`に対応する。

## Test migration(テストの移行について)

ソース本体の移行と同じ重みで記録すべき点として、ユーザーが明言した設計上の判断がある:
**[証言]** 既存のテスト群をゼロから構築し直すのではなく、そのまま活用することをブートストラップの
前提とした(`Maintanance/MAINTENANCE.md`「REFACTORING_FROM_ATCODER_2025 について」の
ユーザー要望に明記)。これは上記の各段階にも一貫して表れている。

- **[事実]** T1(2026-01-03)でまず分岐コピーを作り、原本とkeystone系列を約9か月間並行して
  保持した上で、T3(2026-09-29)で原本を削除している。削除を急がず並行運用した点が、
  「作り直すのではなくそのまま活用する」という方針と整合する。
- **[事実]** T4(`ecb3085d`)はパスの移動と内容の大幅改稿を同時に行っているが、**削除ではなく
  新しいパスへの追加という形**を取っており、ファイル自体は一貫して保持され続けている。
- **[事実]** keystoneファイル(`___RedBlackTreeContainerTests_unsafe.swift`)は現在も`#if false`で
  コンパイル対象外のまま削除されずに保存されている。
- **[事実]** S3のモジュール名変更では、`Tests/RedBlackTreeTests`等の`@testable import`対象の
  切り替えが実装側のリネームと同一コミット(`e91c01ff`)内で行われており、テストを後回しにせず
  本体と同時に移行している。
- **[事実]** `RedBlackTreeSet`の番号付きTest as Specification(2025-05-25時点で既に11ファイル)に対し、
  `RedBlackTreeMultiSet`/`RedBlackTreeDictionary`/`RedBlackTreeMultiMap`はrelease時点で
  `_0_`/`_1_`の2ファイルのみだった。公開4型のTest as Specificationが足並みを揃えるまでの
  horizontal expansion(各型への横展開)は、本調査ではコミット単位の追跡を行っていない
  (個別のファイル分解コミットは多数に及ぶため、現状のファイル数の差分という確認済みの事実のみを
  記録し、経緯の解釈は含めない)。

## Refactoring method

**[解釈]** 履歴から確認できる基本方針は次のとおり。

1. 旧コンテナを直接操作する固定Fixtureテストを、削除より先に分岐コピーして残す。
2. ノード表現、ポインタ操作、比較、メモリ配置、allocationを個別の内部層へ分解する。
3. 分解した各層へ専用Fixtureと単体テストを設ける。
4. 赤黒木の不変条件を、操作結果とは別の検証軸として維持する。
5. 公開4型のTest as Specificationと、原木・UnsafeTreeV2の内部契約を分離する。
6. 移行済みの旧テストは削除せず、コンパイル対象外の一次資料として温存する(ただし
   T3のように、分岐コピーが確立した後であれば原本自体は削除されることがある)。

今後、移行段階を追記するときは、コミット、旧パス、新パス、移した契約、代替テストを
セットで記録する。推測による経緯は確定事実と分けて`[解釈]`として明示する。

## 未確認・今後の課題

- T2(`unsafeTree/old/` → `DebugAdditionals/TransitionFromLegacy/`)間の中間コミットは
  本調査でパスの最終到達点のみ確認しており、各中間リネームコミット個別の意図は未調査。
- release時点の`RedBlackTreeMultiSet`/`Dictionary`/`MultiMap`がいつ・どのコミットで
  現在のファイル数まで分解されたかは未追跡。
