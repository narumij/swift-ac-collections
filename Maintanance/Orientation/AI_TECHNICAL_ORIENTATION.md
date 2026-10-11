# AI向け技術オリエンテーション

## この文書の目的

この文書は、このrepositoryで作業するAIが、一般的なSwift packageより技術判断を誤りやすい理由を理解し、
もっともらしい推測だけでsource、test、性能、互換性、releaseを扱わないための正本である。

製品APIの完全な説明、現在taskの一覧、個別契約の正本を兼ねない。変わり得る状態と具体的な判断は
Task Registryと選択taskの詳細正本で確認する。

## 作成task

- Registry task: `OPS-003`
- 状態: 本文作成・ユーザー確認完了
- 担当: Codex
- 独立性: 他taskの前提にも後続にも置かない独立した運用基盤task
- 完了条件: AI固有の誤認リスク、技術的難所、証拠経路、停止点を本文へまとめ、ユーザーが確認できる状態にする。

## 入力資料

- `../README.ja.md`
- `../Package.swift`
- `REFACTORING_FROM_ATCODER_2025.md`
- `StrictMemorySafetyReadiness.md`
- `PERFORMANCE_REGRESSION_BISECTION.md`
- `../Tests/TESTING.md`
- `RELEASE_CHECKLIST.md`
- module別の品質評価、監査、Test as Specification

## 最初に持つべき難易度の見取り図

このrepositoryは、通常のapplicationや便利helperを作るprojectではない。本来は言語処理系または標準ライブラリが
提供するはずの基盤collectionを、個人開発で利用可能な製品として成立させようとしている。そのため一般的なlibrary
では下層へ委ねられるmemory layout、allocation、値semantics、Index identity、iterator、計算量、protocol適合、
実行時検査、性能、platform・toolchain差まで、repository自身が直接引き受けている。

この位置づけでは、通常のSwift開発で有効な慣習をそのまま適用できるとは限らない。標準ライブラリなら実装側が保証する
前提を自分たちで定義・検証する必要があり、一般的な可読性、抽象化、重複排除、Swiftらしさより、原典との照合、
生成code、所有権、独立した証拠を優先する場面がある。個人開発であることは品質要求を下げる理由ではなく、限られた
保守能力で基盤品質を維持できるよう、変更範囲、正本、検証経路を慎重に設計する理由になる。

このrepositoryの難しさは、赤黒木algorithmの一箇所だけに閉じていない。原典との対応、Swiftの型system、raw memory、
CoW、Index寿命、四つのpublic facade、性能、互換mode、test、release境界が相互に接続し、それぞれの接点に異なる
不変条件がある。随所に難所があり、一つを局所的に整えても、別の層で正しさ、性能、互換性、検証可能性を失い得る。

したがって、変更行数、file数、見た目の単純さから難易度を推定しない。node field一つ、protocolの可視性一つ、空操作の
guard一つでも、memory layout、witness table、CoW、stale Index、四型、条件コンパイル、専用testへ波及し得る。
対象symbolだけでなく、それが接続する層と、各層で守る証拠を先に確認する。

現在の複雑さには、長期に育てた製品資産、性能上の選択、移植元との照合可能性、試行して採らなかった経路、段階的な
差し替えの足場が含まれる。すべてが必要とは限らないが、理解できないものを偶発的な散らかりと推定して掃除しない。
小さく安全だと証明できない変更ほど、影響範囲を狭く見積もらず、止まって調査する。

## このrepositoryでいう製品化

現在の製品化は、赤黒木やその性能をAIが新たに作る工程ではない。技術的な中核はユーザーがAI協業以前から育てて
きた。いま行っているのは、その価値へ第三者が安全に到達し、理解し、試し、採用を判断できる形を整えることである。

- 公開APIと利用者向け文書から、用途と契約を理解できるようにする。
- Test as Specification、独立比較、CI、benchmarkから、主張を追試できるようにする。
- main、互換版、release成果物の境界を明確にし、再現可能なreleaseを作る。
- 有利な証拠だけでなく、不利な結果、未計測範囲、未確定契約も同じ基準で示す。
- 個人開発の限られた保守能力でも、既存の中核品質を継続して守れる工程を作る。

組織名や権威による信用がなくても、製品として触れられる形と再実行可能な証拠があれば、第三者が中核の価値を発見
できる。目的は、競合を名指しして優位を宣伝することでも、未成熟な部分を隠すことでもない。製品としての成熟度には
ばらつきがあっても、既に成立しているalgorithmと性能まで過小評価させず、興味と検証の入口を用意する。

したがってAIは、個人のSwift packageという外見から技術水準を推定しない。一方、好意的なbenchmarkだけを使って
全面的な優位を主張することもしない。確認済みの核、製品化途中の範囲、未確認事項を分け、証拠が示す範囲で説明する。

## 本文

### 1. 速いcollectionsであることが製品契約の一部

このrepositoryは、C++の`std::set`、`std::map`等を前提とした問題をSwiftでも実用的な性能で解くことを
目的にしている。APIが正しい値を返すだけでは不十分であり、性能回帰は製品価値の回帰になり得る。

比較対象は、単なる別の個人実装ではなく、長年実用され最適化されてきたLLVM libc++の標準collection実装である。
既存benchmarkでは、確認した操作と入力範囲において`std::set`／`std::map`と競合する水準へ達している。これは
「個人製Swift packageとしては速い」という相対評価ではなく、世界的に利用される標準実装を基準に成立している
性能資産である。ただし、個別benchmarkの一致を全操作、全型、全platformでの普遍的な性能同等性へ一般化しない。

AIが誤りやすい点:

- コンパイルと機能testの成功を「変更は中立」と解釈する。
- source上で局所的に小さい変更を、生成コード上でも小さいと仮定する。
- protocol visibility、generic境界、`@inlinable`、`@inline(__always)`等を通常の可視性整理として扱う。
- 単発benchmarkの赤を原因確定、緑を無影響の証明とみなす。

実際には、protocolの公開範囲変更だけで機能testを通過したまま30%以上の回帰が生じた事例がある。また、
hot loopの命令列が同じでもbinary内の配置が変わり、閾値をまたいだ事例がある。属性変更が速い命令を生成した
のではなく、周囲のcode sizeと配置を動かした可能性もある。

必要な行動:

- 性能に触れる変更は、同一toolchain、同一runner、同一baseline、同一benchmark定義でbaseとcandidateを比べる。
- 回帰原因を主張する前に、最後の緑、最初の赤、最小差分A/Bを揃える。
- 差が出たらsourceだけで結論せず、必要に応じてsymbol、assembly、hot loopの配置、CPU情報を見る。
- 局所benchmarkは診断に使えるが、正式な全benchmarkとCI gateを置き換えない。
- 一般化できない仮説は、確認済み事実と分けて記録する。

### 2. unsafeは局所的な例外ではなく、実装の中核にある

RedBlackTree、OptionalArray、BareArray、Permutationの一部は、生pointer、`ManagedBuffer`、手動初期化・破棄、
独自storageを使う。strict memory safetyの警告は、単純なannotation漏れではなく、所有権と公開境界を映している。

過去の調査では、strict memory safety下でRedBlackTree本体に数千件規模の警告が生じ、その大部分が意図された
低レベル層へ集中した。一方、小さいmoduleでも診断を宣言単位に分けることで、安全なAPIへの置換、局所的な
`unsafe`、前提条件の追加、公開判断が必要な箇所を区別できた。

AIが誤りやすい点:

- 警告件数を減らすこと自体を目的にして、広い`@unsafe`やannotationを機械的に付ける。
- pointer操作があることだけで不具合と判断する、または意図的な低レベル実装だから安全と判断する。
- build成功や警告0件を、所有・初期化・破棄・寿命が正しい証明とみなす。
- 内部storageの変更を、公開APIに影響しない実装詳細と決めつける。

必要な行動:

- pointerごとに、誰がallocateし、何個初期化し、誰が変更し、誰がdeinitializeし、誰がdeallocateするかを追う。
- 所有型、非所有View、iterator、Index、CoW共有storageを別々に扱う。
- compiler診断、通常test、Death Test、ASan、参照型のdeinit観測が示す範囲を分ける。
- 公開型への`@unsafe`伝播、storage再設計、寿命契約の変更が必要なら、局所修正で埋めず判断taskへ分ける。
- 既存のmodule別監査と品質評価を読み、似た実装だけを同一契約の根拠にしない。

### 3. CoWは値の一致だけでは検証できない

このpackageのcollectionsは値semanticsを提供しつつ、storageを共有する。正しい要素列を返していても、不要な
detach、変更前の共有破壊、空操作でのallocation、参照型payloadの過不足解放があれば不具合である。

特に注意するもの:

- 空コレクション用共有storageから、どの操作でdetachするか。
- mutation前にuniquenessを確保しているか。
- no-op、失敗する操作、空範囲でも不要なCoWを起こさないか。
- clone、reserve、removeAll、View経由の変更後にcapacityと初期化済み要素数が一致するか。
- 参照型要素の保持と解放がDebug、Releaseの両方で釣り合うか。

AIは出力値だけのtestを追加して完了しやすい。CoWを扱うtaskでは、storage identity、allocation、detach、参照寿命、
変更前後の別名参照を観測する仕様testが必要である。ただしDebug専用counterはprocess-globalであり、並列testや
Death Testと干渉し得る。counter検査を外した構成のgreenを、寿命釣り合いの証拠にしてはならない。

### 4. IndexとViewは整数位置ではない

公開Indexが整数に見える場合でも、意味は単なるoffsetとは限らない。tree identity、generation、detach、削除、
Viewの範囲、base collectionとの関係が契約へ入る。

AIが誤りやすい点:

- 同じ数値のIndexを、別treeやCoW前後でも同じ位置として扱う。
- 空範囲やno-opなら、範囲検査とidentity検査を省略できると考える。
- baseでは有効なIndexが、部分Viewでも当然有効だと仮定する。
- stale Indexの検出実装と、利用者へ約束する契約を混同する。
- Swift標準Collectionの一般知識から、未確定の公開契約を補う。

必要な行動:

- Indexの作成元、対象tree、generation、CoW前後、削除前後、View範囲をtest matrixに含める。
- 「結果が空」と「入力Indexが契約上有効」を別に検証する。
- cross-treeやstaleを許す／拒否する構成差を確認する。
- upstream要件や公開契約が未確定なら、内部実装から結論を作らず停止する。
- 現在状態は`RED_BLACK_TREE_REMAINING_TASKS.md`等の選択task正本で確認し、本書の一般説明から推定しない。

### 5. tree algorithmは局所修正が全体不変条件へ波及する

このRedBlackTreeは、AI協働や現在の製品化refactoringで新たに作り始めた実装ではない。ユーザーがそれ以前から
長期間にわたり、algorithm、性能、memory layout、APIを手塩にかけて育ててきた、このrepositoryの既存の中核資産で
ある。秋の連休頃からの差分は、その起源ではなく、既存の木を製品として磨き、四型、互換性、安全性、test、文書、
release工程へ展開してきた履歴として読む。

性能もAIが作った成果ではない。C++ STLと競合する性能は、ユーザーが実装と調整によって成立させていた製品資産で
ある。後から追加されたbenchmark、STL比較、回帰調査、CI gateは、その性能を新たに生み出したものではなく、
既存性能を測定し、説明し、回帰から保護するための証拠経路である。2026年前半にもAI利用は試されたが、技術的な
中核や性能の成立へ有効に寄与したとは扱わない。後のAI協業で測定や保守へ参加した部分があっても、それをalgorithm、
性能、または証拠体系そのものの作者性と混同しない。

したがってAIは、既存codeを自由に作り直せる試作、教材、一般的なrefactoring素材として扱わない。意図を十分に
追わない整形、もっともらしい書き換え、検証なしのalgorithm変更、一般論だけによる「改善」は受け入れられない。
変更前に原典、履歴、周辺層、性能上の理由、既存testを読み、必要性と証拠を示す。分からない複雑さを、品質の低さや
整理不足だと推定しない。

RedBlackTreeは、探索、rotation、挿入・削除後のbalance、header/root/end表現、node再利用、iterator、複数の
public facadeが同じ内部層へ接続する。局所的に見える条件分岐でも、色、親子関係、root、走査順、Index寿命、
計算量、生成コードへ影響する。

`Sources/RedBlackTreeCollections/Implements/__tree`は、単なる赤黒木algorithmの集積ではない。主に次の三つを
同時に維持する移植層である。

1. libc++原典の制御構造と命名へ戻って比較できること。
2. Swiftのprotocol、generic、所有権、非copyable型、raw pointerへ意味を移すこと。
3. 上位層のCoW、Index、node再利用、安全性、四つのpublic facadeへ接続できること。

この層では`nullptr`と`end`を実在nodeとして扱い、rootを`end`側から保持する。探索はnodeだけでなく、rootまたは
親nodeのleft/right slotを直接更新できるpointer-to-pointerを返す。unlink、payloadの破棄、nodeの回収も別の責務で
あり、局所的な「安全化」や共通化がallocation、初期化済み範囲、走査、寿命の境界を変え得る。

protocolの継承graphも偶発的な複雑さとして扱わない。型関係、class-levelの`Base`、instance stateを持つ`Tree`、
比較器の注入、unique／multi、安全性の段階、原典との対応をSwiftの型system上で表現している。似たprotocol、
重複したfree function、古い実装経路、無効化された参照codeを、参照数や見た目だけで統合・削除しない。

とくにmulti型は、同じkeyを持つ複数nodeの木内位置を区別する必要がある。key比較だけでは足りず、祖先関係や
rootからのpathを使う比較へ遅延している箇所がある。また通常挿入とhint挿入では、同値要素群のどこへ入るかも
同一とは限らない。uniqueで成立した簡略化をmultiへ機械的に移さない。

#### 差し替えrefactoringではsymbolが二つの意味を持ち得る

このrepositoryでは実装を段階的に差し替えるため、同じsymbolが次を同時に担うことがある。

- 現在の構成から実際に呼ばれる、実行上の役割。
- 旧実装、原典、新実装の対応位置を保つ、移行上の座標。

したがってsymbol名、宣言位置、参照数だけから責務を一意に決めない。branch、path、compile condition、呼出経路、
差し替え段階、test、履歴と組にして読む。重複、到達不能、古い命名に見えるcodeも、移行の足場または比較対象で
ある可能性を除外してから変更する。同じsymbolでも、構成によって意味の重心が変わり得る。

ここでは情報のSSoTと知識のSSoTを混同しない。現sourceと有効なbuild構成は「いま何が実行されるか」の情報を
示す。libc++原典と移植上の対応はalgorithmの由来と意図を読み直す知識を保ち、Test as Specificationはこの
repositoryで観察可能な契約を固定する。どれか一つを他の代用品にせず、変更の問いに応じて接続する。

#### 目視でしか照合できないものは、なるべく似せる

このrepositoryの技術的な設計原則として、正しさをcompiler、test、型system等で十分に機械検証できず、最終的に
人間の目視照合へ依存するものは、信頼する参照対象へ構造、命名、制御の流れをなるべく似せる。似せること自体を
正しさの証明にはしないが、差分を本当に必要な翻訳箇所へ限定し、比較時の認知負荷と見落としの機会を減らす。

移植層では、この検証可能性を一般的な「Swiftらしさ」や重複排除より原則として優先する。有限のtestが通っても、
algorithmの未観測の状態遷移まで原典と同値であることは保証できない。libc++由来のtree algorithmでは、原典の
symbol、分岐順、局所的な重複を保つことが、目視で対応を追い、意図しないalgorithm改変を発見するための品質保証
経路になる。Swiftの型、所有権、安全性、性能上の理由で一致させられない箇所は、無理に似せたように見せず、
差異の理由と検証経路を明示する。

したがってrefactoringでは、見た目を独自に美しくする前に、その類似性が人間による品質保証の一部ではないかを
確認する。参照対象との差を増やす変更には、同等以上に強い機械的証拠または明確な必要性が要る。

必要な証拠は一種類ではない。

- 小さい決定的fixtureによるrotation・balance・境界条件。
- 操作ごとのtree invariant検査。
- reference modelと全要素を比較するfuzz test。
- Set、MultiSet、Dictionary、MultiMapと共有Viewへの横展開。
- C++参照実装との挙動比較。
- DebugとRelease、必要な条件コンパイル構成。
- hot pathに触れた場合のperformance。

一つのcontainerで通った修正を、型名だけ変えて横展開しない。unique／multi、key-only／key-value、owned／Viewの
差を確認する。逆に、同じ内部primitiveを共有する場合は、一型だけのtest成功で全利用側を閉じない。

構造を読んで最初の実装経路を作る段階と、成立した判断軸を四型へ横展開する段階も分ける。前者は継承graph、
原典対応、差し替え境界をまとめて判断できるCodexが主に担う。後者は境界付きの反復と横断確認に強いClaudeへ
委ね、Codexが差分と証拠を受け入れる。最初の一型が動いたことを、横展開の仕様が確定したことと同一視しない。

`RawBuffer`は`__tree`と対になるもう一つの核心である。`__tree`が論理的な木とalgorithmを担うのに対し、
`RawBuffer`は一次・二次bucketの物理layout、nodeとpayloadの隣接配置、alignment、初期化済み範囲、型消去した
deinitializer、fresh／recycle pool、CoW後のaddress解決、IndexやIteratorが関わるbuffer寿命を担う。同じpointer値でも、
未使用slot、生存node、unlink後、recycle待ち、generation更新後の再利用nodeでは意味が異なる。

`_BucketAccessor`、`_BucketQueue`、`_BucketTraverser`のような類似実装も、address解決、slot払出し、copy・破棄走査の
hot pathを個別に調整するため分離されている。共通化、layout変更、field追加、初期化・破棄順の変更は、機能だけでなく
生成code、性能、所有権、Indexの有効性へ波及する。RawBufferを一般的なallocator utilityとして局所的に変更しない。

### 6. build構成が多く、同じsourceでも検証対象が変わる

`Package.swift`にはDebug限定の内部検査、Release側のperformance testing、Death Test、strict memory safety、
低レベル実装や診断用のtraits、AtCoder互換条件などがある。test frameworkもXCTestとSwift Testingを併用する。

代表的な違い:

- Debugにはallocation、node、payload、tree invariant等の内部検査が入る。
- Releaseは最適化後の挙動を見るが、Debug専用検査は存在しない。
- macOSではDeath Testが既定で有効だが、他platformでは明示traitを要する。
- `SKIP_DEBUG_LIFETIME_BALANCE_CHECKS`はprocess-globalな寿命釣り合い検査を外すが、寿命が正しい証拠にはならない。
- `-Ounchecked`では通常の`precondition`停止を期待できず、通常Releaseと同じ契約testをそのまま解釈できない。
- `COMPATIBLE_ATCODER_2025`はAPI、source、test、facadeの選択を変える。

「全test成功」と書く前に、configuration、trait、platform、filter、実際に実行されたtestを記録する。一部suiteや
件数だけから全体成功を推定しない。長時間またはprocess終了を検証するtestは、並列実行、子process、sanitizer
との相互作用も確認する。

### 7. Test as Specificationは数を増やす活動ではない

このrepositoryではtestを、観察可能な公開契約を番号付きの実行可能仕様として整理している。目的はcoverageや
件数を増やすことではなく、公開宣言、契約、実装、履歴上の判断、testを対応付け、不足と重複を発見することにある。

AIが誤りやすい点:

- 現在の実装結果をそのまま期待値にして、誤った挙動を仕様化する。
- production helperとtestの期待値計算を共有し、同じ誤りで両辺を一致させる。
- 類似moduleの契約をコピーし、独立した公開契約確認を省く。
- test名や件数だけで、公開API全体が覆われたと判断する。
- Death Testのprocess終了だけを見て、どの事前条件が働いたかを過大評価する。

必要な行動:

- 公開宣言ledgerを作り、各契約をtest、source、履歴上の決定へ対応付ける。
- 期待値は可能な限りreference modelや独立計算から得る。
- 仕様化前に、現行挙動が意図された契約か確認する。
- `確認済み`、`過去に決定済み`、`現在の推論`、`未確認`を分ける。
- 新しい公開判断が出たら、testで既成事実化せずDECISION taskへ分ける。

#### 外側を優先し、核心は内側からも密に固定する

testは、実装詳細ではなく利用者から観察可能な契約をなるべく外側から検証する。公開四型やViewを通るtestを中心に
置くことで、内部構造を変更しても維持すべき結果、計算量、停止条件、CoW、Index契約を仕様として残す。

内部も一様には扱わない。現行の実装木である生木`UnsafeTreeV2`への直接testは、変更コストとの均衡を取り、fixture、
assertion、debug用の観測を許容する比較的ゆるい層である。配置やhelperの完全な統一、網羅的な形状固定を目的にしない。

一方、移植algorithmの原木`__tree`は専用test targetを持ち、rotation、balance、親子関係、色、root／end、比較注入、
所有と停止条件、到達可能な分岐を強く固定する。RawBufferとUnsafeNodeの根幹も、layout、alignment、capacityとcount、
初期化・破棄、fresh／recycle、pointer再利用、寿命を重点的に検証する。期待値算術をproduction helperと共有せず、
単層の独立計算と層間cross-checkを分け、同じ誤りで両辺が一致することを避ける。

これは内部testだけで製品契約を代用する方針ではない。外側の仕様testは統合後の契約を示し、生木testは現行内部木を
観測・診断し、原木とRawBuffer根幹のtestは勝手なalgorithm改変やmemory管理の破損を強く止める。変更時は対象層の
強度を取り違えず、影響する内部testと外側のtestを組にして選ぶ。どちらか一方のgreenだけで全体を閉じない。

### 8. branch、互換mode、release treeは同じ製品の単純な複製ではない

`main`、`compatible/AtCoder/2025`、`release/AtCoder/2025`、通常version releaseは目的が異なる。さらに通常releaseは、
mainの候補を専用工程で利用者向けtreeへ変換する。管理文書、内部設計、互換mode専用資産、workflow、benchmark
結果等の保持境界が異なる。

AIが誤りやすい点:

- 古いbranchの実装や文書を現在契約として読む。
- mainのgreenを、変換後release treeのgreenとして扱う。
- 互換modeで除外されるtestを、通常版でも不要と判断する。
- release branchだけで製品sourceを修正し、mainとの正本関係を壊す。
- 管理文書の削除を、taskや判断の完了と混同する。
- branch名、worktree、HEAD、remote ref、tag対象commitを取り違える。

branchを跨ぐ作業では、symbolをbranch、path、configuration、意味と組にして扱う。編集前、検証前、commit前に
現在branchと差分を確認する。release treeの境界は`RELEASE_CHECKLIST.md`とversion固有正本を読み、本書や古い
rehearsalから推定しない。

### 9. 文書にも正本と証拠の階層がある

`README.ja.md`が利用者向けREADMEの正本で、`README.md`は英訳コピーである。Task Registry、module監査、品質評価、
設計記録、利用者向け文書、過去ログは役割が異なる。古い文書が詳細だからといって、現在状態の正本ではない。

AIが誤りやすい点:

- Maintanance全体を走査し、古い未完了記録からtaskを復活させる。
- 過去の調査結果を、現在の採用判断と読み替える。
- 品質評価の「不足」を、即時修正の許可と解釈する。
- 英語READMEだけを直し、日本語正本との同期を壊す。
- 内部文書と利用者向け公開文書を同じ読者・同じrelease境界で扱う。

現在状態はTask Registry、選択taskの詳細正本、現sourceとtestの順に確かめる。履歴とArchivedは、現在の問いに
必要な証拠を得るときだけ読む。

### 10. AIが停止すべき条件

次のいずれかに当たる場合、もっともらしい実装で埋めず、現在taskを止めて境界を戻す。

- 公開契約、製品方針、互換性、名称、許容リスクを新たに決める必要がある。
- unsafe storageの所有権、View寿命、Index identityを既存正本とtestから確定できない。
- 性能差を再現できない、baselineや環境が一致しない、因果と相関を分けられない。
- testを通すために、検証対象そのものを弱める必要がある。
- 一つのtaskに複数のユーザー判断が現れた。
- branch、HEAD、未commit差分、検証対象commitが一致しない。
- 正本同士、または正本と現物が衝突する。
- 既存の凍結、外部待ち、USER_ONLY境界へ触れる必要がある。

停止時は、分からない部分を推測で埋めない。確認できた事実、足りない証拠、必要な一つの判断、影響する範囲を
分けて返す。

## AI向け最小チェック

作業開始前:

- 現在branch、HEAD、worktree、選択task、詳細正本を一致させたか。
- 対象は通常版、互換mode、release treeのどれか。
- 公開契約、内部表現、性能、管理文書のどの層を変更するか。
- 必要な構成と証拠は何か。

受入前:

- Debug、Release、Death Test、ASan、documentation、performanceのうち、必要なものを実際に確認したか。
- 値だけでなく、CoW、所有、寿命、Index identity、不変条件を必要な範囲で確認したか。
- baseとcandidate、localとremote、sourceと生成物が同じ対象を見ているか。
- AI同士の一致やtest件数を、証明可能な範囲以上に使っていないか。
- 未確認、後続判断、凍結事項を完了扱いしていないか。

## 詳しく読む場所

- `../README.ja.md`: 製品目的、公開上の位置づけ、branchの概略
- `../Package.swift`: target、trait、configuration、条件コンパイルの現在値
- `../Tests/TESTING.md`: testの現在地とTest as Specification
- `REFACTORING_FROM_ATCODER_2025.md`: 技術的な変遷と証拠の継承
- `StrictMemorySafetyReadiness.md`: unsafe、所有、strict memory safetyの調査と段階適用
- `PERFORMANCE_REGRESSION_BISECTION.md`: 性能回帰の再現、二分探索、生成コード調査
- `RELEASE_CHECKLIST.md`: release時の証拠と操作境界
- module別の監査・品質評価: 個別APIの契約と未確認事項
