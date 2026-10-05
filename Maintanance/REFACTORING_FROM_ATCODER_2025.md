# Refactoring from `release/AtCoder/2025`

> 状態(2026-10-06): 移行史の主要記録は完了。末尾の未追跡事項と、P10で必要になる
> Index統合前の残存記述確認があるため、現時点では継続文書として保持する。

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

**[事実]** このファイルは`release/AtCoder/2025`時点の原本そのものではなく、移行中に作った
分岐コピーを新しい内部構造へ追従させた派生・再構成版である。

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

## テスト側の移行

テスト側では、旧実装を直接操作する固定Fixtureテストを捨てず、移行用の分岐コピーとして
利用した。

**[事実]** 2026-01-03の`cc0ca3ad`で、既存の
`Tests/RedBlackTreeTests/tree/___RedBlackTreeContainerTests.swift`を残したまま、unsafe実装向けの
派生ファイルを追加した。分岐直後の両者は、条件コンパイルや内部名に差があるものの、全体構成は
ほぼ同じだった。これにより、旧実装と新しいunsafe実装を並行して検証できる期間を設けている。

**[事実]** その後、移行先のテストは内部構造の変化に合わせて改稿され、現在の
`Tests/RedBlackTreeTests/UnsafeTreeV2/Instance/___RedBlackTreeContainerTests_unsafe.swift`へ至った。
旧系列との対応が分かる名前へ戻し、現在はコンパイル対象外の一次資料として保存している。

**[事実]** 原木(`__tree`)のメモリ配置、ポインタ、比較、mutation、不変条件などのテストは、
最終的に公開コレクションのテストから`RedBlackTreeTreeTests`へ分離された。Fixtureも専用ターゲットへ
分けられ、公開APIの仕様検証と内部ノード契約の検証を別々に実行できる構成になった。

## Test migration(テストの移行について)

ソース本体の移行と同じ重みで記録すべき点として、ユーザーが明言した設計上の判断がある:
**[証言]** 既存のテスト群をゼロから構築し直すのではなく、そのまま活用することをブートストラップの
前提とした(`Maintanance/MAINTENANCE.md`「REFACTORING_FROM_ATCODER_2025 について」の
ユーザー要望に明記)。これは上記の各段階にも一貫して表れている。

- **[事実]** まず分岐コピーを作り、旧系列とkeystone系列を並行して保持した。
  **[解釈]** 新実装側の検証手段を確立してから旧系列を整理したと読め、「作り直すのではなく
  そのまま活用する」という方針と整合する。旧系列を整理した正確な時期は本書では追跡していない。
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

## 現行ノード格納方式と結合処理の性能観察(2026-10-03)

**[事実]** 現行実装を対象とした`Maintanance/Archived/CombiningAPIPerformanceEvidence.md`の計測では、
1k〜256k要素の範囲で、既存ツリーへ逐次挿入する`merge`/`insert(contentsOf:)`経路が、
新しい結果ツリーを構築する`formUnion`/`meld`経路より一貫して高速だった。Setのdisjoint入力では
前者が後者のおよそ2倍速く、MultiSetでも同様の傾向を確認した。

**[事実]** Setの`___meld_unique`について、結果バッファの初期容量を`2`から
`count + other.count`へ変える可逆的なPoCを行ったが、変化は対照ケースと同程度の計測ノイズ内
(0.96〜1.04倍)だった。現行のbucket式ノード格納では、容量拡張時に既存ノードを移動せず、
bucketを末尾へ追加する。そのため、この範囲の遅さを単純な再確保不足だけでは説明できない。

**[解釈]** ポインタ・ノード主体の現行格納方式では、逐次挿入側が既存ツリーと既存ノードを
活用できる一方、meld側は結果ツリー全体を新しく構築する。この定数コストの差が、理論計算量では
有利なmeld経路の優位を256k要素まで観測できなかった一因である可能性がある。ただし、
`release/AtCoder/2025`版と同一条件で比較した記録はまだないため、「ポインタ版への移行が性能差を
生んだ」と因果関係を確定することはできない。現時点で確定できるのは、**現行ノード格納方式では、
計測範囲内でmeldの漸近的な利点が実測上現れていない**という点までである。

この仮説を移行史として確定するには、`release/AtCoder/2025`版と現行版で、同じ要素型、入力順、
重複率、storage共有条件、最適化設定を揃えた比較計測が必要になる。

## 拡張から収束へ: 核を磨く段階(2026-10-04〜)

AtCoder 2025版からの移行では、内部層の分離、公開4型への横展開、Test as Specification、
View、互換レイヤー、文書体系など、複数の不足を並行して埋める必要があった。そのため、
それまでの開発は新しい構造や検証手段を広く用意する性質を持っていた。

**[証言]** ユーザーは2026-10-04、雑多な方向へ広げる段階を終え、対象を絞って磨き、
Swift向け順序付きコレクションとしての品質と信憑性を高める段階へ移ったと説明した。
重視するのは機能数や自己評価ではなく、利用者やAIが採用判断を証拠によって正当化できる
状態である。

**[事実]** この方針の下で、次の検証軸が整備または計画されている。

- ルートパッケージの`CppBehaviorReference`/`CppBehaviorReferenceTests`で、同じ操作traceを
  Swift実装とC++標準コンテナへ適用し、戻り値、rank、範囲、各操作後の完全な順序内容を
  比較する。性能測定用の`CppBenchmarks`とは分離している。
- Setの比較を最初の動作見本とし、MultiSet、Dictionary、MultiMapへ同じ責務分離と
  mismatch reportを横展開する方式を採っている。
- MultiSetのC++差分比較は、非空コンテナへの`endIndex` hint挿入でSwift側だけが停止する
  不具合を発見した。最小trace、process-isolatedな修正前失敗、libc++との制御構造差、
  一条件の修正、start/end/空境界、共有経路を使うMultiMapまでを検証へ結び付けた。
- `Maintanance/Archived/AdoptionReadinessAssessment.md`と日本語版(表題「採用判断のための品質証拠」)は、
  順位付けの主張を行わず、有利・不利な証拠へ同じ水準を要求し、検証済みの証拠、限界・
  未計測の軸、採用拡大のゲートを分けている。
- `Maintanance/Archived/SORTED_COLLECTIONS_BENCHMARK_TASK.md`は、Apple
  `swift-collections`のB-treeベース`SortedSet`/`SortedDictionary`を外部比較対象とし、
  同条件の入力・storage状態・計測区間で勝敗と未計測軸を残す計画を定めている。

**[解釈]** これは実装方式を別物へ置き換えるリファクタリングではなく、開発対象と完成条件の
リファクタリングと捉えられる。新しいAPIや型を増やすこと自体を進捗とせず、既にある4型を
次の三つの外部化された証拠で磨く段階である。

1. **正しさ:** C++標準コンテナとの決定論的な挙動比較と最小再現可能な回帰テスト
2. **Swiftとしての価値:** CoW、値セマンティクス、Index寿命、Range/View、multi型を含む
   Test as Specification
3. **選択理由:** B-tree実装を含む外部候補との公平なベンチマークと能力差の明示

この段階では、比較で負ける結果や未検証領域も成果物に含める。目的は「優れているように
見せる」ことではなく、どの用途で選べるか、どの主張がまだできないかを第三者が再実行可能な
形で判断できるようにすることである。

**[解釈]** Test as Specificationを残して内部実装を移した従来の方法と、動作見本を先に作って
4型へ横展開する現在の方法には共通点がある。いずれも完成像を一度に作り直すのではなく、
先行する実行可能な証拠を要石とし、その証拠を保ったまま次の層・次の型へ進む。この意味で、
現在の収束フェーズはAtCoder 2025版から続くリファクタリング手法の延長上にある。

## Refactoring method

**[解釈]** 履歴から確認できる基本方針は次のとおり。

1. 旧コンテナを直接操作する固定Fixtureテストを、削除より先に分岐コピーして残す。
2. ノード表現、ポインタ操作、比較、メモリ配置、allocationを個別の内部層へ分解する。
3. 分解した各層へ専用Fixtureと単体テストを設ける。
4. 赤黒木の不変条件を、操作結果とは別の検証軸として維持する。
5. 公開4型のTest as Specificationと、原木・UnsafeTreeV2の内部契約を分離する。
6. 移行済みの旧テストは、必要に応じてコンパイル対象外の一次資料として温存する。

今後、移行段階を追記するときは、コミット、旧パス、新パス、移した契約、代替テストを
セットで記録する。推測による経緯は確定事実と分けて`[解釈]`として明示する。

## 未確認・今後の課題

- release時点の`RedBlackTreeMultiSet`/`Dictionary`/`MultiMap`がいつ・どのコミットで
  現在のファイル数まで分解されたかは未追跡。
