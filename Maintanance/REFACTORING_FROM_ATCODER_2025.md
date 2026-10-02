# Refactoring from `release/AtCoder/2025`

この文書は、`release/AtCoder/2025`で稼働した赤黒木実装から現在の構成へ移行した際の
手法と段階を、後から追跡できるように記録する。

## Keystone test

移行の要石は次の保存テストである。

`Tests/RedBlackTreeTests/UnsafeTreeV2/Instance/___RedBlackTreeContainerTests_unsafe.swift`

このファイルは固定したノード配置を直接構築し、木の不変条件、最小・最大ノード、回転、
挿入後の平衡化、探索位置、削除時の`begin`更新を個別に確認する。通常の公開APIテストより
下の層で、コンテナと木アルゴリズムの接続を検証していた。

現在はファイル全体を`#if false`で囲み、コンパイル対象外の保存資料としている。現行APIへ
追従させることより、移行当時の構造、命名、テスト手法を残すことを優先する。

## 前提となる事実: Test as Specificationは移行の産物ではない

コミット`f4e9f69e`(2025-05-25)で、`RedBlackTreeSet`の番号付きTest as Specification
(`RedBlackTreeSet_0_InitializationTests.swift`〜`_9_ProtocolConformanceTests.swift`、計11ファイル)
が既に導入されている。これは`release/AtCoder/2025`のタグ付けコミット`b2580703`(2025-09-03、
`git merge-base`で確認済み、このブランチは現在の履歴の直線上の祖先)より**4か月近く前**であり、
`git ls-tree remotes/origin/release/AtCoder/2025`でも同じ11ファイルが release 時点に既に
存在することを確認した。

同様に、keystone testとして保存している
`Tests/RedBlackTreeTests/UnsafeTreeV2/Instance/___RedBlackTreeContainerTests_unsafe.swift`の
ファイル内コメント(`Created by narumij on 2024/09/17`)は、AtCoder2025版よりさらに前に遡る。

つまり「Test as Specification」や原木テストという手法自体は、AtCoder 2025版からの移行で
新規に持ち込まれたものではなく、それ以前から存在した開発手法が、移行後も一貫して
受け継がれ、他の型へ横展開されたものである。一方、`RedBlackTreeMultiSet`/
`RedBlackTreeDictionary`/`RedBlackTreeMultiMap`はrelease時点では`_0_`/`_1_`の2ファイルのみ
(`git ls-tree`で確認)で、現在はそれぞれ22〜24ファイルまで分解されている。どの時点の
どのコミットで各ファイルへ分解したかは個別追跡していないため、ここでは「releaseの時点では
未分解だった」という確認済みの差分として記録するに留める。

## Confirmed stages

### 1. AtCoder 2025 implementation

`remotes/origin/release/AtCoder/2025`では、本体は`Sources/RedBlackTreeModule`直下に
`RedBlackTreeSet.swift`等4型の公開ファイルが直接置かれ、内部実装は`_Tree/`配下へ
`Tree_IndexProtocol`等のprotocol指向設計、`___Tree+CopyOnWrite.swift`のような三連アンダースコア
命名で収められていた(`git ls-tree`で確認)。テストは次の場所にあった。

`Tests/RedBlackTreeTests/tree/___RedBlackTreeContainerTests.swift`

`RedBlackTreeModule`を`@testable import`し、`RedBlackTreeSet`へデバッグ用の操作を直接追加して、
整数ベースのノード表現を組み立てていた。

### 2. UnsafeTreeV2 extraction

2026-09-30のコミット`ecb3085d`で、テストは次の名前へ移された。

`Tests/RedBlackTreeTests/UnsafeTreeV2/Instance/___RedBlackTreeContainerTests_unsafe.swift`

この段階で、比較・ポインタ操作・デバッグ補助などが個別ファイルとFixtureへ分解され始めた。
元のコンテナ直結テストを残しながら、同じ契約をUnsafeTreeV2以下の小さな層で検証できる
構成へ移す方法が採られた。

### 3. Bootstrap naming

直後のコミット`438af006`(同日 2026-09-30)で`UnsafeTreeV2BootstrapTests.swift`へ改名された。
テスト内容の98%はそのままで、木の開発を開始するためのブートストラップだったことが明示された。

この一般名では旧`RedBlackTreeContainer`からの移行資料であることが見えにくいため、現在は
第2段階の名前へ戻している。`Bootstrap`という役割はファイル内コメントと本書で保持する。

### 4. 内部層分離(`Implements/`への集約)

コミット`28a1a5fb`(2026-05-04、`file layout`)の時点で、`Sources/RedBlackTreeModule`配下に
既に`Implements/__tree/`・`Implements/UnsafeTreeV2/`・`Implements/Deprecated/`という
内部層ディレクトリ構成が存在する(このコミット自体は`__tree/unsafe_tree/unsafe_tree.swift`等を
`Implements/`配下へ移す純粋なリネームであることを`git show --name-status -M`で確認)。
つまりコンテナ直結設計から内部層(原木`__tree`・`UnsafeTreeV2`・非推奨コード置き場)への分離は、
このリネームより前の時点で既に相応に進んでいた。分離の最初のコミットそのものは個別追跡して
いないため、「2026-05-04時点で既に内部層構成が存在した」という確認済みの下限として記録する。

### 5. モジュール名の変更: `RedBlackTreeModule` → `RedBlackTreeCollections`

3段階で行われたことを`git show --name-status -M`と`Package.swift`の差分で確認した。

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

この結果、現行コードベースの「本体は`RedBlackTreeCollections`、`RedBlackTreeModule`は
`@_exported import`のみの互換レイヤー」という構造は、実装を書き直したのではなく、
**ターゲット名とディレクトリ名の交換 + 旧名での薄い再公開シムの新設**によって成立したことが
確認できる。

### 6. Fixtureと原木(`__tree`)の専用ターゲット化

2026-10-02の2コミットで、テスト側の構造がさらに分解された。

- `29f43bb3`(08:34、`fixture target`): `RedBlackTreeFixture`ターゲットを`Package.swift`へ追加
  (`Tests/RedBlackTreeFixture`配下、`RedBlackTreeCollections`に依存する独立ターゲット)。
- `60604ff6`(13:32、`genboku test target`): `RedBlackTreeTreeTests`ターゲットを追加し、
  `RedBlackTreeFixture`を含む依存関係を整理(`Package.swift`の差分で確認)。これが
  `Tests/TESTING.md`に記録のある「`__tree`: 専用ターゲット化」に対応する。

## Test migration(テストの移行について)

ソース本体の移行と同じ重みで記録すべき点として、ユーザーが明言した設計上の判断がある:
**既存のテスト群をゼロから構築し直すのではなく、そのまま活用することをブートストラップの
前提とした**(`Maintanance/MAINTENANCE.md`「REFACTORING_FROM_ATCODER_2025 について」の
ユーザー要望に明記)。これは上記の各段階にも一貫して表れている。

- 段階1→2(UnsafeTreeV2 extraction)は、コンテナ直結テストを**削除せず改名**して始まっている
  (`ecb3085d`は新規作成ではなくリネーム)。
- 段階3(Bootstrap naming)でも「テスト内容の98%はそのまま」で、契約を変えずに役割名だけを
  明示している。
- keystoneファイル(`___RedBlackTreeContainerTests_unsafe.swift`)は現在も`#if false`で
  コンパイル対象外のまま**削除されず保存**されている。
- 段階5のモジュール名変更では、`Tests/RedBlackTreeTests`等の`@testable import`対象の切り替えが
  実装側のリネームと同一コミット(`e91c01ff`)内で行われており、テストを後回しにせず
  本体と同時に移行している。
- 一方で、`RedBlackTreeSet`の番号付きTest as Specification(2025-05-25時点で既に11ファイル)に対し、
  `RedBlackTreeMultiSet`/`RedBlackTreeDictionary`/`RedBlackTreeMultiMap`はrelease時点で
  `_0_`/`_1_`の2ファイルのみだった。公開4型のTest as Specificationが足並みを揃えるまでの
  horizontal expansion(各型への横展開)は、本調査ではコミット単位の追跡を行っていない
  (個別のファイル分解コミットは多数に及ぶため、現状のファイル数の差分という確認済みの事実のみを
  記録し、経緯の解釈は含めない)。

## Refactoring method

履歴から確認できる基本方針は次のとおり。

1. 旧コンテナを直接操作する固定Fixtureテストを基準として残す。
2. ノード表現、ポインタ操作、比較、メモリ配置、allocationを個別の内部層へ分解する。
3. 分解した各層へ専用Fixtureと単体テストを設ける。
4. 赤黒木の不変条件を、操作結果とは別の検証軸として維持する。
5. 公開4型のTest as Specificationと、原木・UnsafeTreeV2の内部契約を分離する。
6. 移行済みの旧テストは削除せず、コンパイル対象外の一次資料として温存する。

今後、移行段階を追記するときは、コミット、旧パス、新パス、移した契約、代替テストを
セットで記録する。推測による経緯は確定事項へ混ぜない。
