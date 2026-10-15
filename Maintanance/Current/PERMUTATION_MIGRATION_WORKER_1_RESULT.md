# ワーカー1返却：構成・互換入口

固定ID：`PERM-073`。未返却。担当Worker Codex 1の記入領域。

## 調査結果

### 対象版・未コミット差分

- 観測対象はbranch `develop/misc/66`、HEAD `cd2dd7ad3ac594b84bccc3fe62dd45779d88fb82`。
- 開始時に `Package.swift`、`Sources`、`Tests`、`.github`、本依頼書、本返却先の `git status --short` を確認し、未コミット差分はなかった。
- 調査終了前にも関係ファイルの状態を再確認し、返却先以外の差分がないことを確認した。以下は上記HEADの静的調査結果であり、build・test・CIの成功を意味しない。

### 確認した事実と根拠

#### 現行のtarget・product・module経路

| 区分 | 現行事実 | 根拠 | 移行との関係 |
| --- | --- | --- | --- |
| 公開product | packageが宣言するlibrary productは `AcCollections` 一つで、target `AcCollections`だけをproductの直接構成targetにしている | `Package.swift:121-126` | `PermutationModule`は独立productではない。旧名・新名を外部clientから直接import可能とする範囲は、productのtarget依存グラフとclient compileで確認が要る |
| facade target | `AcCollections` targetは `PermutationModule`へ直接依存する | `Package.swift:193-207` | rename時は依存先の切替または旧・新両targetへの依存を設計する箇所 |
| 再公開 | facade sourceは `@_exported import PermutationModule` を無条件に行う | `Sources/AcCollections/AcCollections.swift:1-6` | `import AcCollections`だけの利用者へどちらを主入口として見せるかを決める箇所。現行の再公開testはこの経路を固定する |
| 実装target | `PermutationModule` targetは依存なし、既定path `Sources/PermutationModule`、`Documentation`を除外し、Lifetimesとstrict memory safetyを有効にする | `Package.swift:336-346` | 新targetへ実装を移す場合もsettings・exclude・条件付きsource一式を落とさず移す必要がある |
| test target | `PermutationTests`は `PermutationModule`とAlgorithms productへ依存し、Lifetimesを有効にする | `Package.swift:347-356` | testのimportと依存を新主入口へ切り替える対象。旧入口の専用互換検査は別に残す必要がある |
| 通常版実装 | `NextPermutations`、その入れ子 `Permutation`、`nextPermutations()`は `Sources/PermutationModule/NextPermutations.swift` に定義される。`BorrowedNextPermutations`と`borrowedNextPermutations()`は同directoryの別fileで `#if compiler(>=6.4)` 配下 | `Sources/PermutationModule/NextPermutations.swift:15-66`、`Sources/PermutationModule/BorrowedNextPermutations.swift:1-56` | 宣言を一つのcanonical moduleでだけcompileしないと、同名でもmodule-qualifiedな別型・別extensionになる |
| 2025互換実装 | `Permutations`群と旧method群は同じtarget directory内だが `#if COMPATIBLE_ATCODER_2025` でのみ有効 | `Sources/PermutationModule/Compatibility/AtCoder2025/PermutationsAtCoder2025.swift:1-35`、`NextPermutationProtocol.swift:1-2,100-101` | target renameだけでなくbranch defineによる排他的surfaceも新canonical targetへそのまま載る必要がある。互換sourceを旧module shim側へ分離すると「同じ実装」にならない |

#### 現行の検査入口

- 通常版public surface testは `import PermutationModule` を直接使う。該当する有効な入口は `Tests/PermutationTests/NextPermutations/NextPermutations_0_PublicSurfaceTests.swift:15-24` と `Tests/PermutationTests/BorrowedNextPermutations/BorrowedNextPermutations_0_PublicSurfaceTests.swift:15-20`。`NextPermutationsSequence`のsurface testはfile全体の対象部分が `#if false` で、現行保証には使えない（`Tests/PermutationTests/NextPermutationsSequence/NextPermutationsSequence_0_PublicSurfaceTests.swift:21-23,77-78`）。
- facade経路は `Tests/AcCollectionsTests/AcCollections_NextPermutationsReexportTests.swift:6-22` が `import AcCollections`だけで `NextPermutations`を使い、再公開を検査する。
- AtCoder 2025互換testは `#if COMPATIBLE_ATCODER_2025` の下で `import PermutationModule` を直接使う（`Tests/PermutationTests/AtCoder2025Compatibility/AtCoder2025Compatibility_0_SpecificationTests.swift:1-7`）。facade経路も `Tests/AcCollectionsTests/AcCollectionsTests.swift:79-89` にある。
- compiler fixtureはroot packageへのpath dependencyとproduct `AcCollections`だけを依存宣言しつつ、4 client targetすべてが `import PermutationModule` を使う（`Utilities/Maintenance/CompilerDiagnostics/PermutationPublicSurface/Package.swift:12-29`、各 `Sources/*/*.swift:1`）。実行scriptはcompile-pass 1件とcompile-fail 3件を期待する（`Utilities/Maintenance/VerifyPermutationCompilerDiagnostics.sh:3-7,17-43`）。これは旧module名を直接使うclient fixtureなので、新主入口用への更新だけで置換せず、旧入口互換の検査を残す対象である。
- 同repositoryには「新実装targetを旧名targetが再公開する」構造の実例がある。`RedBlackTreeModule` targetは `RedBlackTreeCollections`に依存し、pathを `Sources/_RedBlackTreeModule`へ明示する（`Package.swift:225-243`）。shim sourceは `@_exported import RedBlackTreeCollections` 一行だけ（`Sources/_RedBlackTreeModule/RedBlackTreeModule.swift:1`）。Permutation移行の方式決定では参考にできるが、この実例だけではPermutationの両modeや外部client互換の成立までは証明しない。

### 変更候補・維持対象・工程の制約

#### 変更候補

| 対象 | 必要になり得る変更 | 根拠・制約 |
| --- | --- | --- |
| `Package.swift` | canonical実装target `NextPermutationModule`を宣言し、旧 `PermutationModule`を互換targetとして残す。`AcCollections`と`PermutationTests`の依存先を整理する | 新旧を同じ型・実装へ接続するには、実装宣言を一度だけcompileするtargetと、それを再公開するshim targetに分けるのが構造上の候補。両targetへ同じsourceを複製・別compileすると型identityがmoduleごとに分かれるため要件を満たさない |
| source配置 | 現 `Sources/PermutationModule`を新targetのcanonical source pathとし、旧名用に別の小さいshim pathを置く候補 | SwiftPM targetはmodule境界であり、旧target sourceから `@_exported import NextPermutationModule`する形なら宣言本体を複製しない。directory renameの要否・時期は未決 |
| `Sources/AcCollections/AcCollections.swift` | 主入口として `@_exported import NextPermutationModule`へ切り替える候補 | 旧名互換targetをproductの依存グラフに残す必要があるかはclient fixtureで確認する。新旧両方をfacadeから再公開するかも方式判断 |
| tests・compiler fixture | 通常版の直接importを新名へ移し、旧名専用fixtureを残す。facade testも維持する | 新主入口、旧直接入口、facade入口は異なる経路なので、どれか一つの成功で代用できない |
| DocC target名・directory | canonical moduleに対応するDocC catalogの名称・リンクを後続担当と同期する | 本担当では編集しない。module renameでDocCのmodule identityやURLが変わる可能性がある |

#### 維持対象

- 公開型・method・実装はcanonical `NextPermutationModule`に一組だけ置き、旧 `PermutationModule`から同じ宣言を再公開すること。型aliasを個別に並べる方式は、extension method、入れ子型、今後の宣言追加、互換mode surfaceの漏れを招くため、少なくとも現行surface全体の等価性を自動的には保証しない。
- `AcCollections`だけをimportする既存入口と、その再公開test。
- `COMPATIBLE_ATCODER_2025`による通常版／2025互換版の排他、および両modeのtest入口。今回のmodule名互換と、source surfaceのmode互換は別の軸である。
- target settingsのLifetimes、strict memory safety、共通 `_settings`、test側Lifetimes設定。
- compiler fixtureが固定する直接初期化不可、noncopyable、非`Sequence`という通常版契約。module import名の移行で契約検査を失わない。

#### 履歴だけで、今回の変更根拠にしないもの

- disabledの `NextPermutationsSequence` public-surface test（`#if false`）は現行production surfaceの検査ではない。
- Archivedの旧名称候補・旧互換未決記述は今回の存続方針より古く、方式決定の正本にはしない。

#### 工程の制約

1. 依頼書に指定されたとおり、名前互換を先にmergeしてgreenを確認し、その後にcanonical target/sourceのrenameへ進む。各段階のgreenを次段階の前提とし、一括renameで原因を混ぜない。
2. 先行互換段階では、現在の `PermutationModule` 実装targetから新名targetへ再公開する向きと、最終形（新名が実装、旧名がshim）の向きが逆になり得る。中間形を作るなら、次段階で依存cycleを作らず反転できるmanifest構成を計画時に具体化する必要がある。
3. SwiftPM target間に相互依存は作れないため、新旧moduleが互いを再公開する形は不可。各段階でcanonical実装targetを一つに定める。
4. baselineへcurrent sourceを移植せず、性能比較のbaseline側module名・task名互換は指定のCI順序に従う。本担当ではworkflow・benchmarkを変更も実行もしない。

### 他担当との接点・未確認・計画時の判断点

#### 他担当との接点

- 性能CI・benchmark担当へ：target/module renameでmangled symbol、library登録、build product path、benchmark importが変わり得る。canonical実装を一つにする案なら実装重複は避けられるが、旧shim経由と新module直接経由が同じbenchmark binary条件になるかは性能担当の確認対象。
- 文書・導入経路担当へ：公開productは現状 `AcCollections`だけで、通常利用のfacade経路と直接module import経路を分けて説明する必要がある。DocC catalogのmodule名・URL・source directory変更候補を共有する。
- 統合担当へ：RedBlackTreeの既存shimは構造上の前例だが、Permutationでは `COMPATIBLE_ATCODER_2025` とSwift 6.4限定surfaceが加わる。前例の存在だけで採用決定しない。

#### 未確認と、次に必要な最小検証

- **未確認**：library product `AcCollections`が新canonical targetと旧shim targetをどの依存形で含めれば、外部clientから `import NextPermutationModule` と `import PermutationModule` の両方が安定して通るか。現fixtureは旧名だけで、今回buildは禁止されている。**最小検証**：一時client packageを二targetに分け、product依存は `AcCollections`だけとして各moduleを直接import・同じ公開型を利用してcompileする。
- **未確認**：旧shimの `@_exported import NextPermutationModule` が、noncopyable型、入れ子 `Permutation`、Collection extension、`Span`借用API、`@inlinable`本体を新名直接import時と同一に見せること。**最小検証**：既存compiler fixtureを新名pass／旧名passの対で仮構成し、同一source内で旧経由の値を新module側の型注釈へ渡すcompile-passも追加する。
- **未確認**：通常modeと `COMPATIBLE_ATCODER_2025` modeの両方でshim再公開が同じsurfaceだけを見せ、通常版と旧互換版が混在しないこと。**最小検証**：両define条件で、新旧直接importと `AcCollections` importの三入口をそれぞれcompile/testする。
- **未確認**：`@_exported`はunderscored attributeであり、既存projectが採用済みでも、新しい公開互換契約として継続採用する方針が妥当か。**計画時の判断**：既存facade・RedBlackTree shimと同じ方式を採るか、公式に保証された別方式を要求するかをユーザー／統合担当が決める。
- **未確認**：先行互換mergeから最終renameまでの具体的manifest差分と、target依存の反転方法。**最小検証**：二段階それぞれのtarget graphを計画書に図示し、cycle・source overlapがないことをmanifest dumpまたはbuildで確認する。

#### 計画時に決める点（本調査では未決）

- 先行段階で新名shimを追加して旧名実装を再公開し、後段でcanonical実装を新名へ移して旧名shimへ反転するか。それとも別の、各段階で一実装を保つ工程にするか。
- `AcCollections`が新名だけを明示再公開し旧targetを通常dependencyとして含めるか、新旧両方を `@_exported import`するか。利用者に見せる主入口と旧moduleの直接import可能性を分けて決める。
- source directoryとDocC catalogをtarget renameと同時にrenameするか、manifestの明示 `path` で別工程にするか。
- 旧module互換を検査する期間・support範囲。旧名削除は今回の完了条件ではないため、削除時期をこの計画へ暗黙に入れない。

### 調査範囲と完了確認

- 調査した範囲：`Package.swift`のproduct・target・settings、`Sources/AcCollections`の再公開、`Sources/PermutationModule`の通常版・borrowed版・2025互換版の条件、Permutationの公開surface test、AcCollections再公開test、AtCoder 2025互換test、compiler-diagnostics scriptとfixture manifest/source import、既存 `RedBlackTreeModule` shim前例。
- 調査していない範囲：workflowとbenchmarkの詳細、DocC・README・導入文書の全リンク、生成単一file、remote package利用実績、binary／ABI互換、実build・test・benchmark・CI、SwiftPM／compilerの実験的試作。他担当の返却物は参照していない。
- 本返却で確定できるのは現行の静的なtarget／import／再公開経路と、同じ型identityを保つには宣言本体の二重compileを避ける必要があることまで。互換方式の採用、工程確定、実装完了、両mode green、性能同等は確定していない。
