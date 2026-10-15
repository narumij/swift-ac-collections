# ワーカー3返却：文書・導入経路

固定ID：`PERM-075`。担当Worker Codex 3の返却。

## 調査結果

### 対象版・未コミット差分

- 観測開始時点は2026-10-15、branch `develop/misc/66`、HEAD
  `cd2dd7ad3ac594b84bccc3fe62dd45779d88fb82`。`git status --short --branch`では追跡対象の
  未コミット差分はなく、branchは`origin/develop/misc/66`より3 commit先行していた。
- 調査中に共有ファイルは変更していない。返却直前にも関係ファイルの差分を再確認する。

### 確認した事実と根拠

#### 現在の利用者向け入口

| 経路 | 現行事実と根拠 | 移行上の意味 |
| --- | --- | --- |
| package product | `Package.swift:126`で公開productは`AcCollections`だけである。`PermutationModule`自体を名前付きlibrary productとしては公開していない | 通常の導入説明は引き続き`AcCollections`を主経路にできる。新moduleを直接依存productとして案内できるとは、このmanifestからは言えない |
| facade import | `Sources/AcCollections/AcCollections.swift:2`が`@_exported import PermutationModule`。`Package.swift:193-203`で`AcCollections` targetも旧targetへ依存する | 新名を主入口にする段階で、依存先と再公開先を同じ段階で`NextPermutationModule`へ揃える必要がある。旧名互換targetを残すだけではfacadeの主入口は自動で新名にならない |
| README | `README.md:45`と`README.ja.md:47`の利用例は`import AcCollections`。両READMEにPermutation名・専用のimport例はない（既存調査記録にも`Maintanance/PermutationModule/ProductReadinessAssessment.md:12-13`として明記） | 現在の例はmodule改名だけでは壊れない。一方、新名の直接import、旧名互換、Swift 6.4要件を利用者へ知らせる導線は存在しない |
| module DocC入口 | `Sources/PermutationModule/PermutationModule.docc/PermutationModule.md:1`が`# ``PermutationModule```。例は同:13で`import AcCollections`、symbol linkは同:7、31-35、46-52にある | 新targetのDocC入口はcatalogの配置・名前・モジュール見出しを新名へ同期する必要がある。API型・member名は今回維持されるため、既存の相対symbol linkは名称上はそのまま候補だが、改名後のDocC生成で解決確認が必要 |
| source documentation comment | `Sources/PermutationModule/NextPermutations.swift`と`BorrowedNextPermutations.swift`の公開コメント・例はAPI型/memberへのsymbol linkを使い、module名の文字列や直接import例を持たない。module概要からこれらへリンクしている | sourceを新targetへ移す場合も本文の一括置換対象ではない。移動後の新module contextでsymbol linkが解決するかを確認する |
| 利用者向け本文ドラフト | `Maintanance/PermutationModule/UserDocumentationDraft.md:3-6`は内部レビュー用で公開媒体未決。本文は同:10で旧module名、例は同:20で`import AcCollections`、根拠pathは同:130-136 | 公開前には新名・現行pathへ合わせる必要があるが、module renameと同じcommitでなければbuildを壊すものではない。公開媒体の決定を今回の調査から先取りしない |

#### DocC生成・公開経路

| 経路 | 現行事実と根拠 | 保証範囲 |
| --- | --- | --- |
| PR target別DocC | `.github/workflows/ci.yml:74-92`の`public-target-documentation` matrixに`PermutationModule`があり、同:113-137でmatrix名を`--target`、output、diagnostic、artifact名へ使用する | target renameと同時にmatrix entryを新名へ替えないと、新targetの継続生成にならない。旧互換targetも生成対象に残すかは別の計画判断 |
| GitHub Pages | `.github/workflows/ci.yml:57-63`の既存公開生成は`RedBlackTreeCollections`だけを対象にし、base pathは`swift-ac-collections`。READMEの公開URLも`README.md:99-117`／`README.ja.md:104-`でRedBlackTreeのpageを指す | 現在Permutation固有のGitHub Pages URLはない。module renameに伴い既存Pages URLをrenameする対象は確認できなかった |
| API reference方針 | `Maintanance/Current/DOCUMENTATION_CI_PLAN.md:37-52`はtarget別API referenceの公開正本を将来のSwift Package Indexとし、GitHub Pagesは利用者向け入口と分離する。同:49-59ではSPI未登録のためmodule別URLを未確認とし、登録前にURLを推測して固定しない | `NextPermutationModule`の公開URLは現時点で確定できない。rename時は生成確認まで、SPI登録後に実在URLを確認してREADME／Pages導線を接続する |
| 継続生成の正本 | `DOCUMENTATION_CI_PLAN.md:10-27`は旧名で取得済みの2026-10-13の証拠、同:29-35は現行の継続対象、同:76-93は旧名matrixの実装・remote成功記録 | 取得済み証拠の旧名は履歴として維持する。継続対象の列挙と今後のcommandは新名へ更新する。過去runが新名で成功した証拠にはならない |

#### 現行品質文書との接続

- `Sources/PermutationModule/Documentation/Quality-Profile.md:34-46`は、採用名、導入・import、再公開、
  DocC入口・symbol link・例を改名時に確認することを既に要求している。ただし同:42の「旧module名の
  互換targetを残すかは未決」は、今回の依頼書で確定した存続方針より古い。
- `Maintanance/PermutationModule/CurrentQualityAssessment.md:12-31`も、現行pathはまだ旧名であり、
  manifest・依存・再公開・source配置・import・公開文書、compiler fixture、CI、DocCを移行・検証対象に
  挙げる。同:214は旧名DocCの個別成功と、当時のCI不足を記録した履歴である。
- `Maintanance/Current/QUALITY_REQUIREMENTS.md:54-60`は新採用名と現行実装名を併記するが、同:60の
  「旧module名の互換方針は未決」は今回の前提より古い。`QUALITY_ASSESSMENT_INVENTORY.md:26`は現在も
  `PermutationModule`を対象名として表示する。
- `Maintanance/Current/PUBLIC_API_NAMING_DECISIONS.md:28`は新名採用と文書surface同時renameを決定済みだが、
  互換方式は後続計画事項としている。今回確定した「旧名を維持する」と、未決の「どう維持するか」を
  区別する必要がある。

### 変更候補・維持対象・工程の制約

#### 新名を主入口にする段階で同時変更が必要な候補

1. 新targetのmodule名、source配置、`AcCollections`のtarget依存・`@_exported import`、DocC catalogの
   module見出しを同じ利用可能な状態へ揃える。具体的なtarget構成はWorker 1の調査と統合して決める。
2. `.github/workflows/ci.yml:86`のtarget別DocC matrixを`NextPermutationModule`へ切り替え、改名後の
   catalogとsource commentを実際に生成してsymbol link diagnosticを確認する。これはPR CIの変更なので、
   依頼書にある名前互換の先行mergeとgreen確認後に行う。
3. 現行状態を説明する品質正本（Quality Profile、Current Quality Assessment、QUALITY_REQUIREMENTS、
   QUALITY_ASSESSMENT_INVENTORY）では、新名を現行主名、旧名を互換入口として区別する。過去の実行結果を
   新名で得た結果へ書き換えない。
4. `DOCUMENTATION_CI_PLAN.md`の「今後の継続対象」は新名へ替える。2026-10-13の生成・remote runの
   target名と結果は旧名の履歴として残す。

#### 維持するもの

- READMEとmodule DocCの通常利用例`import AcCollections`は、新名を再公開するfacadeが成立する限り維持できる。
- `nextPermutations()`、`borrowedNextPermutations()`、`NextPermutations`、
  `BorrowedNextPermutations`へのsymbol linkと、一時View・copy・失効の説明は名称決定上維持対象である。
- READMEの既存RedBlackTree向けGitHub Pages URLと、Pagesの`RedBlackTreeCollections`生成jobは、
  Permutation renameの対象ではない。
- 旧名targetを利用できる互換入口は到達像として維持する。ただし旧名から新名を再公開する薄いtarget、
  source共有等の方式は本調査では決めない。

#### 後で整えられる候補

- 内部レビュー用`UserDocumentationDraft.md`は公開前に新名・pathを更新すればよく、公開媒体・分割方法の
  判断と合わせられる。ただし移行後も現行説明として使う期間を長く置くなら早期更新が望ましい。
- README／PagesからSPIのmodule別API referenceへ張るリンクは、SPI登録と実在URL確認後に行う。
  登録前に新slugを推測して置かない。
- READMEへ新名の直接import例を追加するかは、直接moduleをどのproduct経路で利用者へ約束するかと
  合わせて決める。現行productが`AcCollections`だけであるため、文言だけを先行させない。

#### 履歴として旧名を保つもの

- `DocumentationHandoffAudit.md`、`ImplementationPlan.md`、`ProductReadinessAssessment.md`の過去調査・実施記録。
- `CurrentQualityAssessment.md`内の旧名で実施したbuild、test、DocC、CI結果、および
  `DOCUMENTATION_CI_PLAN.md:10-27,76-93`の2026-10-13の証拠。
- AtCoder 2025互換計画中の基準ref・当時の構成を述べる旧名。ただし今後実行するcommand/pathの部分は、
  Worker 1の互換方式確定後に現行手順と履歴を分けて扱う。

### 他担当との接点・未確認・計画時の判断点

#### 他担当との接点

- Worker 1：新旧targetの構成、sourceの所有先、旧targetからの再公開方式、`AcCollections`の依存・再公開、
  test／compiler fixtureのimport境界が、本結果のDocC catalog配置と直接import説明を決める。
- Worker 2：`.github/workflows/ci.yml`は性能CIとDocC matrixの共有ファイルである。CI順序の制約を守り、
  同じworkflowを触る変更のmerge単位・競合を計画時に調整する。
- Astra：現行品質正本の更新と履歴保存の境界、および返却結果の統合を担当する。本返却だけで方式決定や
  Registry更新は行わない。

#### 計画時に決める点

1. 旧`PermutationModule`互換targetにDocC catalogを持たせるか、新moduleへの再公開だけとするか。
   旧名利用者へdeprecated案内や新名へのリンクを出す場合、その公開契約と終了方針が別途必要になる。
2. PR DocC matrixで新旧両targetを検証するか、新targetだけを継続対象にするか。旧名をmainに維持する以上、
   少なくとも旧importがbuildできる証拠は必要だが、それをDocC jobが担うとは限らない。
3. `AcCollections`だけをREADMEの推奨importにするか、`NextPermutationModule`直接importも公開導線として
   約束するか。package product構成と一致させる必要がある。
4. 内部ドラフトをどの公開媒体へ昇格するか。現行正本は媒体未決としており、renameはこの判断を自動では
   解決しない。

#### 追加検証が必要な点

- 新targetが成立した版で`swift package ... generate-documentation --target NextPermutationModule`を実行し、
  module page、Topics、source内symbol linkの解決、diagnostic、生成archive内の実際の識別子を確認する。
- 旧互換targetにDocCを持たせる場合は、そのmodule pageから新名へ正しく案内でき、同名symbolの重複・
  曖昧linkがないことを別targetとして確認する。
- SPI登録後にpackage pageとmodule別documentation URLを実在確認する。現時点ではURL未確定である。
- facade利用、直接新名import、直接旧名importの各経路が何を公開するかは、Worker 1の構成を受けて
  compiler/buildで確認する。静的調査だけではtransitive importと公開productの将来挙動を保証しない。

### 調査範囲と完了確認

- 調査した範囲：`README.md`、`README.ja.md`、`Package.swift`、`Sources/AcCollections`、
  `Sources/PermutationModule`のDocC・公開コメント・品質プロファイル、`.github/workflows/ci.yml`の
  documentation経路、`Maintanance/Current`の名称決定・品質・文書CI資料、およびそれらから直接参照された
  Permutationの利用者文書・品質評価・履歴境界。
- 検索ヒットだけでなく、上記の実在pathと該当行を読んで分類した。READMEの既存リンク先はrepository内の
  `# Usage`見出しへの参照であり、Permutation DocCからのリンク表記は存在する。外部SPI module URLは
  正本自身が未確認としているため、実在を推定していない。
- 調査していない範囲：source／test／manifestの具体的な互換実装方式、benchmark名対応、remote CIの再実行、
  DocC生成物の実行確認、SPI登録後の外部ページ。build・benchmark・試作・CI起動は依頼境界どおり行っていない。
- 本結果は静的な移行入力であり、方式決定、実装完了、新旧importの成立、DocC green、公開URL成立を
  確定するものではない。
