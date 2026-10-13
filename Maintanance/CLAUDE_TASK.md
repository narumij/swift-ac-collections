# Codex-to-Claude Work Request

Status: Bounded assignments only. Temporary primary-user-support delegation ended 2026-10-08 by user direction.

Task selection and start authority are defined in the root `CLAUDE.md`. This document records the
current job and bounded-task execution constraints. Codex integrates the results, performs Registry
acceptance and state updates, and owns public-document completion.
Repository evidence establishes factual correctness; product decisions remain with the user.

## Current job status

**実行待ち: OptionalArray更新methodの`mutating`化によるsource影響棚卸し**

repository内の現行呼出側だけを検索し、機械的な`let`→`var`で済む箇所と、所有権または設計判断を要する
箇所を分離する。source・test・文書は変更しない。

**完了: OptionalArrayのdomain間移送と並行更新排除の独立検証**

Swift 6.4の一時probeで4候補を比較した。「更新methodの`mutating`化と`@unchecked Sendable`の維持」は、
移送を維持したまま、試した共有更新経路をすべて拒否した。判断が要る点はReturn節に分離した。

**完了: Permutation一般Swift利用Validation scenarioの限定レビュー**

2026-10-13 21:0x、ユーザーの「やって」で開始。指定入力だけを読み、必須修正5件・改善候補6件・製品判断4件を
下のReturn節へ記録した。scenario等の対象文書は変更していない。

**完了: Public API命名決定の最終整合監査**

採用済みのArray系公開名と、borrowed-reference propertyを命名判断対象から除外したscope訂正を、
候補・採点・統合報告・ユーザー判断・現行sourceへ独立に照合した。公開名の判断記録は整合した。
監査後の独立判断で、ユーザーは標準`MutableRef`の直接利用と旧環境向け互換型を提供しない境界を採用し、
Codexがsource・test・compiler fixture・benchmarkを検収した。
新たな採点や採用判断は行っていない。

**完了: Public API名の熟議採点第3巡**

Claudeが第2巡で残った5候補について、名前が利用者へ約束するbehavior・mental modelを明記して
再採点した。新候補、採用、統合は行っていない。

**完了: Public API名の熟議採点第2巡**

Claudeが第1巡のUser・Codex・Claude scoreと統合報告をすべて読み、未決4領域21候補を再採点した。
他者の理由による維持・変更を記録し、採用と統合は行っていない。

**完了: Public API名ballotのClaude独立採点**

ClaudeがUser・Codexの採点を読まず、固定済みArray命名ballot全29候補へ点数、理由、懸念を記録した。
Codexが件数、点数範囲、説明欄を検収した。候補生成、ballot修正、採用判断、統合は行っていない。

**完了: Array命名ballot draftの独立検査**

Claudeが候補網羅、意味分離、重複処理、契約変更の混入、現行sourceとの一致を独立検査した。
Codexは帰属、BareArray限定scope、後続候補の所在を修正した。review-informed Codex supplementを
独立提出と同じballotへ含めるかだけはユーザー判断として残す。

2026-10-13、ユーザーがreview-informed supplement 4件の包含を承認し、Codexがballotを固定した。
独立採点はまだ開始していない。

**完了: OptionalArray／BareArray deprecated公開面削除後の独立目視検査**

CodexがOptionalArrayとBareArrayの旧連鎖subscript・非所有Viewを削除し、現行の座標accessへtest・
benchmark・文書を移行した作業について、下記のbounded assignmentだけを独立に検査する。実装や文書を
修正せず、観測結果をこの文書のreturn節へ記録する。RedBlackTreeへは触れない。

- Claudeが旧公開面の残存と現行座標access・借用参照経路を横断確認した。
- 指摘されたQuality Profileの存在しない`mutable`表記をCodexが`reference(at:)`／`MutableRef.pointee`へ修正した。
- 追跡外の旧fixture空directoryを除去し、検査結果を受け入れた。

**凍結中: PERM-051 borrowed Span版PermutationのTest as Specification**

- runtime仕様test 25件はCodexが受け入れ、Xcode build-for-testingと対象25件成功を確認した。
- 借用寿命のcompiler診断証拠が未完了のため、task全体は完了扱いにしない。
- ユーザーが明示的に再開するまで着手しない。

この節だけでジョブの有無を判断する。Archived recordsを現行ジョブとして読み替えない。状態が変わった
ときは、assignment本文より先にこの節を更新する。

## Current assignment: OptionalArray更新methodの`mutating`化によるsource影響棚卸し

### Objective

`OptionalElementBuffer` 1D〜4Dの`setElement`と`removeAll()`を`mutating`にした場合のrepository内
source compatibility影響を、実装を変更せずに棚卸しする。

### Inputs and scope

- `Sources/OptionalArrayModule/OptionalElementBuffer.swift`の対象methodと全呼出し;
- `Sources/`、`Tests/`、`Benchmarks/`、`Snippets/`、公開documentation内の現行型名による呼出し;
- 必要なら一時directoryで、代表的な再帰closureまたは所有権形状の最小compiler probe。

Archived、RedBlackTree、Permutation、Git履歴、過去conversationは調査しない。

### Boundaries

- repositoryのsource、test、benchmark、documentation、Registryを変更しない。
- `mutating`化、`Sendable`維持・削除、公開契約、互換性を決めない。
- build、既存test、benchmark、commitを行わない。
- 結果は下のReturn節だけへ記録する。

### Completion

各影響箇所をpath、symbolまたは行、現在の宣言形、必要になる変更へ対応付ける。次を区別する。

- `let`→`var`だけで済む機械的影響;
- closure capture、ownership、generic制約等の追加確認が必要な影響;
- 既に`var`で影響しない箇所;
- repository外利用者にだけ残るsource compatibility影響。

### Return

未実施。

## Completed assignment: OptionalArrayのdomain間移送と並行更新排除の独立検証

### Objective

`OptionalElementBuffer` 1D〜4Dについて、TopLevelやMainActor等のconcurrency domain境界を越えて
所有値を扱える利便性を維持しながら、同一storageへの無同期な並行更新を型・所有権で排除できる候補が
あるか独立に調査する。

### Inputs

Read only:

- Registryの`OPT-061`と`OPT-066`行;
- `OptionalArrayModule/CurrentQualityAssessment.md`の`Sendable`契約節;
- `Sources/OptionalArrayModule/OptionalElementBuffer.swift`;
- `Tests/OptionalArrayModuleTests/OptionalArray_0_PublicSurfaceTests.swift`;
- Apple Swift 6.4の`Sendable`、`sending`、ownershipに関する公式文書とcompiler diagnostics。

他module、Archived資料、過去conversation、Codexの一時probe fileは読まない。必要なprobeは独立に
最小構成で作る。

### Questions

1. 現行4型の条件付き`@unchecked Sendable`は、どの公開操作とstorage構造についてcompiler検査を
   実装側へ移しているか。
2. actor method等へのconsuming transferは、現行適合で成立するか。
3. 同じinstanceを複数child taskへborrowし、`setElement`または`removeAll()`を並行に呼ぶ形を、
   Swift 6.4 strict concurrencyが拒否するか。
4. 更新methodの`mutating`化だけで、consuming transferを維持しつつ上の共有更新を拒否できるか。
5. 型を`Sendable`にせず`consuming sending` parameterで移送する候補は成立するか。その場合、呼出側や
   public APIに必要な条件と、なお拒否できない共有経路は何か。
6. 上記以外に、thread-safe storageへ変更せず「移送は可能、同一storageの無同期並行更新は不可」を
   型で表す候補があるか。

### Boundaries

- production source、test、文書、Registryを変更しない。
- `Sendable`適合の維持・削除、API変更、互換性、対応toolchainを決めない。
- thread-safe container化を要件として追加しない。
- compilerが受理したことを意味上の安全性の証明にしない。
- probeは一時directoryだけで実施し、repositoryへ追加しない。
- build、既存test、benchmark、commitは行わない。
- 結果は下のReturn節だけへ記録する。

### Completion

各候補について、domain間移送、共有borrow、並行更新拒否、現行呼出側への影響を表で返す。確認した
compiler behaviorと公式契約からの解釈を分離し、判断が必要な選択肢と、技術的に成立しない候補を示す。

### Return

2026-10-13 Claude（Opus 5.5）。Apple Swift 6.4（swiftlang-6.4.0.34.1、arm64 macOS）。
`-swift-version 6 -strict-concurrency=complete -wmo -emit-sil`を使った。一時directoryは削除済み。
probe型は、現行1Dと同じ形の最小模型（`~Copyable`、`let`のraw pointer、nonmutatingな`set`／`removeAll`）。
2D〜4Dは同じstorage構造とmethod形なので同じ結果になると推定するが、個別には試していない。

**注意（再現時）:** `-typecheck`では全probeが通った。ownership検査とregion isolationはSIL段階の診断で、
`-typecheck`では出ない。拒否の確認には`-emit-sil`以上が必要。

#### Q1 `@unchecked`が実装側へ移している検査

- 確認済み: `@unchecked`を外して`Sendable where E: Sendable`にすると、「stored property 'p' has non-Sendable type
  'UnsafeMutablePointer<E?>'」で拒否された。省略されている検査は、stored propertyのSendable性だけ。
- 解釈: その結果、raw pointerの先のstorageへ、共有borrowから書き込めるnonmutating method（`setElement`、`removeAll`）が
  あっても、compilerは検出しない。`element(at:)`の読み取りだけなら、共有されても競合は起きない。

#### 候補比較

V0は現行、V1は更新を`mutating`化して`@unchecked Sendable`を維持、V2は現行methodで`Sendable`なし、V3は`mutating`化して`Sendable`なし。

| 経路 | V0 | V1 | V2 | V3 |
| --- | --- | --- | --- | --- |
| actorへconsuming transfer（`sending`の有無とも） | 通る | 通る | 通る | 通る |
| MainActor関数へ渡す・worker経由で受け取り直す | 通る | 通る | 通る | 通る |
| actorのstored propertyから取り出して`sending`で返す | 通る | 通る | **拒否** | **拒否** |
| 同じlocalを2つの`async let`で更新 | **通る（反証）** | 拒否 | 拒否 | 拒否 |
| 1つの`async let`で読み、親が更新 | **通る（反証）** | 拒否 | 拒否 | 拒否 |
| 同じlocalを2つの`Task {}`がcaptureして更新 | **通る（反証）** | 拒否 | 拒否 | 拒否 |
| 同じlocalを2つの`async let`で読むだけ | 通る | 通る | 拒否 | 拒否 |
| actorが所有して、actor methodから更新 | 通る | 通る | 通る | 通る |
| `let`宣言の呼出側から更新 | 通る | 拒否（要`var`） | 通る | 拒否（要`var`） |
| local関数がcaptureしてメモ化再帰 | 通る | 通る（`var`） | 未確認 | 未確認 |

#### Q2〜Q6

- **Q2:** 現行の適合で、actorやMainActorへのconsuming transferは成立する。
- **Q3:** 拒否しない。localの`let`を`async let`や`Task {}`で共有し、`setElement`／`removeAll`を並行に呼ぶ形は、診断なしで通る。
  Codexの反証と一致し、`Task {}`経路も追加で確認した。一方、borrowed parameterは`async let`や`addTask`にcaptureできず、
  どの候補でも拒否された（「cannot be captured by an escaping closure since it is a borrowed parameter」）。
- **Q4:** `mutating`化だけで成立する（V1）。移送はすべて維持され、試した共有更新3経路は拒否された。並行読み取りは引き続き通る。
  inout parameterを`async let`へcaptureする形は拒否されるが、その診断は「usage of a noncopyable type that compiler can't verify.
  This is a compiler bug」だった。意図された診断ではなく、compiler実装に依存する拒否なので、根拠として弱い。
- **Q5:** 成立する（V2）。`sending`なしのconsuming parameterでもregion推論で移送が通った。ただし、actorやMainActorの
  stored propertyに入れた後は、取り出して他のdomainへ送れなくなる。並行読み取りも拒否される。
  public APIへ`sending`を付ける必要はないが、呼出側の型にSendable制約を課すgeneric API（`Sendable & ~Copyable`）
  へは渡せなくなる。現行のpublic surface testはこの制約を使っている。
- **Q6:** 試した範囲では、V1以外に、thread-safe storageへ変えずに「移送は可能、無同期の並行更新は不可」を表せる候補は見つからなかった。
  V3はV2より拒否が増えるだけで、利点は追加されない。

#### 判断が必要な選択肢

- V1を採るかどうか: 更新の`mutating`化はsource互換を壊す（`let`で宣言して更新している呼出側は`var`が必要）。
  影響を受ける呼出側の数は数えていない（入力外のため）。
- V2を採るかどうか: `Sendable`の削除は、actor内に保持した値の持ち出しと、並行読み取りを失う。
- 現行のまま（V0）: 上記の反証3経路が残る。

#### 残余リスク

- compilerが受理したことは、意味上の安全性の証明ではない。V1の妥当性は、「pointeeへの書き込みは`mutating`とdeinitだけ、
  pointerは非公開」という不変条件に依存する。この不変条件はprobe型では成り立つが、実sourceの全methodは照合していない
  （1D〜4Dの公開methodを目視した範囲では成り立つ）。
- `nonisolated(unsafe)`のglobalなど、明示的にunsafeな経路は試していない。

## Completed assignment: Permutation一般Swift利用Validation scenarioの限定レビュー

### Objective

`PermutationModule/GeneralSwiftValidationScenario.md`が、一般Swift利用のValidation設計として、答えを
課題文へ埋め込みすぎず、実際に実行でき、既存Verificationを実利用成功へ読み替えず、必要な観測を
取りこぼしていないか独立にレビューする。

### Start condition

- 2026-10-13 21:00以降に、ユーザーがClaudeへこのassignmentの実行を指示した場合だけ開始する。
- それ以前は待機し、ファイルを変更しない。

### Inputs

Read only:

- Registryの`PERM-041`、`PERM-061`、`PERM-062`行;
- `PermutationModule/GeneralSwiftValidationScenario.md`;
- `PermutationModule/UserDocumentationDraft.md`;
- `PermutationModule/NextPermutationsSequenceExperiment.md`;
- `Sources/PermutationModule/Documentation/Quality-Profile.md`のQR-04・QR-05とValidation境界。

source、tests、Git履歴、他module、Archived資料は再調査しない。上記文書内の事実に重大な疑義があり、
レビュー不能な場合は、その疑義と必要な最小入力だけを返して停止する。

### Review questions

1. participantへ渡す情報または課題文が、確認したい答えを過剰に教えていないか。
2. ACL志向利用者と一般Swift Algorithms利用者の分離は、異なる誤認を観測するために機能するか。
3. 独立consumer Verificationと人間またはAI proxyによる理解Validationが混同されていないか。
4. 各taskは、外部参加者、非公開情報、未確定製品判断へ暗黙に依存せず実行可能か。
5. 成功だけでなく、誤選択、View保持、copy誤認、助言要求、観測不能を記録できるか。
6. `Array(sequence)`でViewを収集するtests-only実験を、現行公開APIの誤用事実として誇張していないか。
7. scenario実行前に修正しなければ観測を歪める欠落があるか。

### Boundaries

- scenario、利用者向け文書、Sequence実験記録、Quality Profile、Registry、source、testを変更しない。
- scenarioを実行せず、participant役を演じない。
- `NextPermutations`のSequence採用・不採用を判断しない。`PERM-060`は凍結のまま扱う。
- public documentation媒体、API変更、性能水準、対応platformを決めない。
- 網羅的なsource・test再監査、build、test、benchmark、commitを行わない。
- 結果は下のReturn節だけへ記録する。

### Completion

指摘を次の三分類で返す。

- **必須修正:** このまま実行するとValidation結果を歪める、実行不能になる、または証拠境界を誤る事項。
- **改善候補:** 実行可能性を失わないが、観測の質を上げる事項。
- **製品判断:** scenarioレビューでは決めず、ユーザーへ残す事項。

各指摘には対象節、問題、理由、最小修正方向を含める。必須修正がなければ、その範囲を明示して
「限定試行へ進める」と返す。

### Return

2026-10-13 Claude（Opus 5.5）。指定入力5点の文書照合だけ。source・test・Git履歴は見ていない。build、test、scenario実行なし。
結論: **必須修正があるため、このままでは限定試行へ進めない。** いずれも文言・手順の小修正で済み、設計の骨格（3 path、
Verification／Validation分離、結果分類）は維持できる。

#### 必須修正

- **M-1 Path 2 task 1〜3の課題文が答えを含む（Q1）。** task 1の「each distinct value order at or after the current order」は、
  利用者文書が二つのAPIを区別する基準（重複除去・現在位置から）そのもので、選択が文言照合で済む。task 2の
  「without retaining Views」はView寿命の答え、task 3の「explain where the element copy occurs」はelement copyが要ることを先に教える。
  分類表のSimilar-API selection、Immediate View use、Persistent resultsが誘導下の成功になる。
  最小修正: 課題は目的だけにする（例: 「`[0, 0, 1]`から始めて、題意に合う並びを全部処理する」「全結果を`[[Int]]`で返して後で使う」）。
  copy位置の説明は、回答を記録した後の追問へ移す。
- **M-2 participantへ渡す資料が特定されていない（Q1・Q4）。** `UserDocumentationDraft.md`をそのまま渡すと、
  「ユーザーレビューで確認する点」（113行が`Array(permutation)`による保存へ注意を向ける）と、`Tests/`・Quality Profileを
  指す「根拠」節が含まれる。これはPath 2の「Tests/やQuality Profileを渡さない」と矛盾する。「public package surface」も
  documentation comment、生成interface、source本文のどれかが決まっておらず、source本文なら実装まで見える。
  最小修正: 渡す範囲を「概要〜提供境界」節と、指定した形の公開interfaceに固定し、試行記録へ添付する。
- **M-3 participantの区分（User A／B）を記録する欄がない（Q2）。** 45〜46行は「AとBの結果を相互に流用しない」としているが、
  観測項目と分類表に区分の欄がなく、結果を分けられない。最小修正: 試行ごとに、想定区分、`std::next_permutation`や
  swift-algorithmsの経験の有無、資料の言語を記録する。
- **M-4 「補助後の成功」を分類できない（Q5）。** 分類表の列はConfirmed／Needs revision／Not observedの3つだけで、
  94行は助言要求を合否にしないとしている。この形だと、助言や明確化を受けた後の成功がConfirmedに入る。
  最小修正: 領域ごとに「無補助／補助後」と補助の内容を記録する。または`Confirmed after assistance`の列を足す。
- **M-5 AI proxyに非参加の条件がない（Q3）。** 155〜157行はAI proxyの使用を許しているが、
  repositoryや会話の文脈を持つAI（Codex、Claudeを含む）が担当すると、「設計非参加者」の前提が崩れる。
  最小修正: proxyはM-2の資料だけを持つ新しい文脈で動かすことを条件にし、modelと文脈条件を記録する。
  分類表とは別に、human／AI proxyの区別を結果へ必ず付ける。

#### 改善候補

- **I-1 owner破棄による失効を引き出すtaskがない（Q5）。** 観測項目（92行）と分類表のFailure understandingは
  「owner破棄」を含むが、task 4はnext()による失効だけを示している。owner破棄の変種を足すか、その点は自発的に述べた場合だけ記録すると明記する。
- **I-2 User A固有の誤認を測るprobeがない（Q2）。** 36行の「in-place・Bool返却を期待する」は、どのtaskでも観測されない。
  User Bの「全順列と誤認する」は、`permutations()`が正解になる対照課題（位置の全順列が要る例）を一つ足すと、
  名前だけで選んでいないかを判別できる。
- **I-3 Path 3の文言はtests-only adapterに限定して書く（Q6）。** 109〜110行の「not safely recoverable from `Array(...)` syntax alone」は、
  文脈がないと現行APIの誤用事実と読める。adapterでは`Array(sequence)`がViewを集め、現行APIでは`Array(permutation)`が要素を集める、
  という対比として書き直す。137行の「rejected-or-deferred」も、未決（`PERM-060`凍結）と書く。
  なお、101行「`Array(owner)`はcompileしない」は、利用者文書の「Sequenceではない」と整合している。誇張はない。
- **I-4 Path 3は二択を並べて聞くこと自体が区別を示唆する。** Path 2の回答を記録した後に行う、と順序を明記する。
- **I-5 Path 1の期待値と実行条件を補う。** step 5の期待出力（`[2,1,3]`、`[2,3,1]`、`[3,1,2]`、`[3,2,1]`）を明記する。
  swift-algorithmsの取得にnetworkが必要なこと、未pushのrevisionを使う場合の参照方法（local git URLなど）、
  `PERM-059`で記録されたSwiftPM `sandbox-exec`の拒否が起きたときは環境失敗として別記録にすること、を実行前提に書く。
- **I-6 「Not observed」を二つに分ける。** 未実施と、実施したが回答が曖昧・途中放棄で判定できないものを、同じ列に入れない。

#### 製品判断（ユーザーへ残す）

- 参加者の選定、人数、外部接触（`PERM-062`の記録どおりユーザーの権限）。
- 渡す資料の言語。草案は日本語なので、非日本語話者向けに翻訳するかどうかは文書判断になる。
- AI proxyの結果を、公開前の参考としてどこまで扱うか。
- 試行で失敗が出たときに、文書の修正、命名、API契約のどれへ振り分けるか（scenarioは区別の手順だけを定めている。`PERM-060`は凍結のまま）。


## Completed assignment: Public API命名決定の最終整合監査

### Objective

`PUBLIC_API_NAMING_DECISIONS.md`に記録されたArray系命名判断について、候補、三者の採点、統合報告、
ユーザー判断、現行sourceとの間に、実装反映を妨げる矛盾、未決事項の誤確定、対象外事項の混入が
ないか独立に監査する。

特に、borrowed-reference propertyの`pointee`／`value`は、Swift標準ライブラリの`MutableRef`が
`value`を定義するためproject-owned naming decisionではない、というscope訂正を確認する。
これは標準APIの採用判断でも、旧toolchain互換実装の変更判断でもない。

### Inputs

Read:

- Registryの`API-010`行;
- `PUBLIC_API_NAMING_BALLOT.md`;
- `PUBLIC_API_NAMING_SCORE_REPORT.md`;
- `PUBLIC_API_NAMING_ROUND2_REPORT.md`;
- `PUBLIC_API_NAMING_ROUND3_REPORT.md`;
- `PUBLIC_API_NAMING_DECISIONS.md`;
- 必要な場合だけ、各roundのUser・Codex・Claude raw score;
- 現行公開面の照合に必要な範囲の`Sources/BareArrayModule/BareArray.swift`と
  `Sources/OptionalArrayModule/OptionalArray.swift`。

### Boundaries

- 監査対象文書、source、test、Registryを変更しない。
- 新候補、再採点、採用判断、実装方針、互換性方針を追加しない。
- Apple標準APIとの一致を、旧toolchain互換実装の変更承認へ読み替えない。
- build、test、benchmark、commitを行わない。
- 結果は下のreturn節だけへ記録する。

### Completion

次を区別して記録する。

- 採用済み各判断と根拠・ユーザー判断の対応;
- 未決、対象外、別taskへ残る事項;
- 実装反映前に修正必須の矛盾;
- 修正必須ではない観測または将来の互換性論点。

必須修正がなければ、その範囲を明示して「命名判断記録は実装反映の入力として整合」と返す。

### Return

2026-10-13 Claude（Opus 5.5）。文書照合と、Swift 6.4での型検査1件（一時directory、削除済み）だけ。

#### 採用済み判断と根拠の対応（整合）

- Always-initialized owner `ElementBuffer`: round-2報告の収束（User 5、Codex 7、Claude 7）とUserの`BareArray`等の明示拒否に一致。
- Presence-tracked owner `OptionalElementBuffer`: round-3報告の収束（User 5、Codex 5、Claude 6）と一致。DECISIONSの理由
  （cache policyを約束しない、family一貫性）もround-3の「promise」記述と一致。
- 1D suffix（unsuffixed）: score reportの`DS-01`（Codex 9、Claude 8）と、意味確認後のUser受諾に一致。
- Copied access `element`／`setElement`: score report（Codex 9、Claude 8）とUser受諾に一致。現行sourceも両familyでこの名前。
- Method `reference(at:)`: round-2報告の収束（User 5、Codex 8、Claude 7）と一致。現行sourceに存在。
- Result type `MutableRef` directly: score reportで3者とも`RT-03`がresult type節の最高点。DECISIONSの記述と一致。

#### 未決・対象外・別task

- 未決: Permutation normal／borrowed family（DECISIONSで`Not decided`のまま、誤確定なし）。
- 対象外: borrowed-reference property（`Excluded`。scoreは履歴として保持）。
- 別task: `Reference` aliasの即時削除か移行期間か（DECISIONSで実装・release判断と明記）、旧toolchain互換実装と標準APIの関係。

#### 実装反映前に修正必須の矛盾

- **property除外の前提と、現行の自前`MutableRef`が食い違う。** Swift 6.4で`Swift.MutableRef<Int>`を型検査すると、
  `value`は存在し、`pointee`は「has no member」になる（標準APIが`value`を持つという訂正の事実自体は確認できた）。
  一方、現行の`Sources/BareArrayModule/BareArray.swift:426`は、条件なしで自前の`public struct MutableRef<Element>`を宣言し、
  property名は`pointee`（438行）。つまり現在の公開型は標準の型ではなく、projectが所有する同名の型で、その値propertyの
  名前もprojectが決めている。DECISIONSの「`MutableRef` directly」が、(a) 自前型の名前を`MutableRef`のまま正式名にする
  のか、(b) 標準の`Swift.MutableRef`へ寄せる（自前型は旧toolchain互換だけにする）のかが書かれていない。(a)なら、自前型の
  propertyは「標準が持つから対象外」とはならず、命名判断が残る。(b)なら、property除外は正しいが、result typeの採用記録が
  標準型への移行という実装方針を含むことになる。どちらかを一文で明示しないと、実装者が`pointee`を残すべきか判断できない。
  （修正には、result typeの採用がどちらを意味するかをUserが確認する境界が要る。互換方針そのものは決めなくてよい）

#### 修正必須ではない観測・将来の互換性論点

- 自前の`BareArrayModule.MutableRef`は標準の`Swift.MutableRef`（macOS 27以降）と同名。現行で名前解決が問題になるかは
  確認していない（`UNVERIFIED`）が、両方が見える文脈では利用者が別の型と気づきにくい。上の(a)／(b)の判断に関わる。
- Inputsの`Sources/OptionalArrayModule/OptionalArray.swift`は、実際のfile名が`OptinalArray.swift`（綴り違い）。照合には支障なし。
- round-3報告でClaudeは`pointee`→`value`へ考えを改めたと要約されており、Claudeのround-3 raw score（4／6）と一致する。

上の1件を除き、Array系の命名判断記録は実装反映の入力として整合している。

追記（2026-10-13、ユーザー回答）: 自前の`MutableRef`宣言は削除対象とのこと（「それは削除対象だわ」）。
上の(a)／(b)は(b)側、つまり自前型を正式名として残す意図はない、と読める。削除の実施、`reference(at:)`の
返り値・test・compiler fixture・benchmarkの扱い、旧toolchain対応はClaudeでは決めず、Codexの実装task側で扱う。

追記（2026-10-13、後続ユーザー確認）: 標準型を直接使うかは、availability、対応toolchain、現在の寿命契約を
現物で再確認するため未確定へ戻した。上のユーザー回答を、標準型への即時置換または自前宣言の無条件削除承認とは
扱わない。公開名の監査完了と実装方式の未決を分離する。


## Completed assignment: Public API名の熟議採点第3巡

### Objective

presence-tracked ownerの`OptionalCache`、`OptionalElementBuffer`、`MemoizationTable`と、
borrowed-reference propertyの`pointee`、`value`だけを、公開promiseを明記して再採点する。

### Inputs

Read:

- Registryの`API-009`行;
- 三者の`PUBLIC_API_NAMING_ROUND2_*.md`;
- `PUBLIC_API_NAMING_ROUND2_REPORT.md`;
- `PUBLIC_API_NAMING_DECISIONS.md`;
- `PUBLIC_API_NAMING_ROUND3_CLAUDE.md`。

### Boundaries

- 変更できるのは`PUBLIC_API_NAMING_ROUND3_CLAUDE.md`だけ。
- 新候補、採用判断、統合、source・test・Registry変更を行わない。
- build、test、benchmark、commitは行わない。

### Completion

5候補へ1〜10の整数点と、利用者へ約束するbehavior・mental model、round-2 User responseをどう評価へ
反映したかを記録し、statusを完了へ変更する。受入と統合はCodexが行う。

## Current assignment: Public API名の熟議採点第2巡

### Objective

相互に公開された第1巡のscoreと理由を検討し、未決のalways-initialized owner、presence-tracked owner、
borrowed-reference method、borrowed-reference propertyを再採点する。

### Inputs

Read:

- Registryの`API-008`行;
- `PUBLIC_API_NAMING_SCORE_USER.md`、`PUBLIC_API_NAMING_SCORE_CODEX.md`、
  `PUBLIC_API_NAMING_SCORE_CLAUDE.md`;
- `PUBLIC_API_NAMING_SCORE_REPORT.md`;
- `PUBLIC_API_NAMING_DECISIONS.md`;
- `PUBLIC_API_NAMING_ROUND2_CLAUDE.md`。

### Boundaries

- 変更できるのは`PUBLIC_API_NAMING_ROUND2_CLAUDE.md`だけ。
- 採用済みのcopied access、1D suffix、`MutableRef`を再採点しない。
- 新候補、採用判断、統合報告、source・test・Registry変更を行わない。
- build、test、benchmark、commitは行わない。

### Completion

全21候補へ1〜10の整数点と、相互閲覧で何を維持・変更したか分かる短い理由を記録し、statusを完了へ
変更する。受入と統合はCodexが行う。

## Current assignment: Public API名ballotのClaude独立採点

### Objective

`PUBLIC_API_NAMING_BALLOT.md`の全候補を独立に評価し、`PUBLIC_API_NAMING_SCORE_CLAUDE.md`へ
1〜10の整数点、短い理由、重要な懸念を記録する。

### Inputs

Read only:

- Registryの`API-006`行;
- `Maintanance/PUBLIC_API_NAMING_BALLOT.md`;
- 現行の`Sources/BareArrayModule/BareArray.swift`;
- 現行の`Sources/OptionalArrayModule/OptinalArray.swift`;
- 両moduleの公開Quality Profile。

`PUBLIC_API_NAMING_SCORE_USER.md`と`PUBLIC_API_NAMING_SCORE_CODEX.md`は読まない。

### Evaluation

role accuracy、call-site readability、family coherence、necessary distinction、migration cost、
promise accuracy、Validation fitnessを総合的な観点として使う。機械的な加算は行わない。
各候補を同じsection内の代替案として評価し、他sectionの選択を勝手に確定しない。

### Boundaries

- 変更できるのは`Maintanance/PUBLIC_API_NAMING_SCORE_CLAUDE.md`だけ。
- 候補、ballot、source、test、Registry、User・Codex scoreを変更しない。
- 推奨winner、採用、平均、統合結果を作らない。
- build、test、benchmark、commitは行わない。

### Completion

全29候補のscore、reason、material concernを埋め、statusを完了へ変更する。結果の受入と統合はCodexが行う。

## Current assignment: Array命名ballot draftの独立検査

### Objective

`PUBLIC_API_NAMING_BALLOT.md`のArray部分が、現行公開面について一つの採点項目へ一つの命名判断だけを
置き、三者の候補を失わず、削除済み表面や契約変更を候補へ混入させていないか確認する。

### Inputs

Read only:

- Registryの`ARRAY-008`と`API-002`の行;
- `Maintanance/PUBLIC_API_NAMING_BALLOT.md`;
- `Maintanance/ArrayObjectAndAPINamingDraft.md`;
- 三者の`PUBLIC_API_NAMING_CANDIDATES_*.md`;
- `Sources/BareArrayModule/BareArray.swift`;
- `Sources/OptionalArrayModule/OptinalArray.swift`;
- 両moduleの公開Quality Profile。

### Inspection questions

- submit済みの命名だけの候補が、意味を変えず対応するballot sectionへ入っているか。
- exact duplicateが票数を増やさず、異なる意味が黙って統合されていないか。
- owner二family、1D suffix、copied value access、borrowed referenceのmethod・result・propertyが
  互いを不必要に決めない単位へ分かれているか。
- View、subscript、closure mutation、operation追加、BareArray製品除外、Permutationが正しく対象外か。
- 現行sourceに存在しないsurfaceや、現在の所有権・寿命契約を変える候補が命名だけの候補として
  紛れ込んでいないか。
- 候補不足があるなら、既存提出から機械的に導ける不足か、新しい候補提出を要する不足かを区別する。

### Boundaries

- ballot、候補文書、source、test、Registryを変更しない。
- 候補を採点、順位付け、推奨、採用しない。
- 新しい公開契約または製品範囲を決めない。
- PermutationとRedBlackTreeを調査しない。

### Validation and return

検索と目視照合だけを行い、build、test、commitは行わない。問題があればballot IDまたはsection、元の提出、
問題の種類、修正に必要な境界を列挙する。問題がなければ確認した範囲と残る限界を短く記録する。

結果はこのassignment末尾の`Claude return`へ追記する。受入と修正はCodexが行う。

### Claude return

2026-10-13 Claude（Opus 5.5）。検索と目視照合だけ。採点・推奨はしていない。

#### 指摘

- **RP-01（帰属の誤り）:** Sourceが「Current, Claude retention」だが、Claudeは`pointee`の維持を提出していない。
  `PUBLIC_API_NAMING_CANDIDATES_CLAUDE.md`のB表は「`MutableRef`を維持、`pointee`を`value`へ」で、Claudeの案はRP-02だけ。
  RP-01のSourceは「Current」だけにするのが正しい。
- **RT-03（帰属の欠落）:** Sourceが「Codex supplement, current concrete type」だが、Claudeも同じB表で`MutableRef`の
  維持を提出している。exact duplicateとしてClaudeを加えるべき（票数は増やさない）。
- **C節（帰属の欠落）:** DS-01〜DS-03にSource列がない。DS-01／DS-02はClaudeの`ARRAY_NAMING_CANDIDATES_CLAUDE.md`
  C-1a／C-1b（両方suffixなし／両方suffixあり）と同じ意味で、他者の提出にもあるかは未確認。提出元を残すと他節と揃う。
- **Codex supplementの扱い:** PO-09、PO-10、BR-03、RT-03は、Codex候補文書のF節で「review-informed supplement、
  他の候補とdeprecated削除の後に追加」と明記されている。ballotでも「Codex supplement」と表示されており隠れてはいない。
  ただし`ArrayObjectAndAPINamingDraft.md`の「候補生成は相互レビュー前に終える」という手順とは時点が違うので、
  独立提出の候補と同列に採点してよいかはユーザー判断（修正には候補の採否を決める境界が要る）。
- **E〜G節の適用範囲が書かれていない:** 借用参照（`reference(at:)`、`Reference`／`MutableRef`、`pointee`）は
  現行sourceでBareArrayにだけ存在し、OptionalArrayにはない。BareArrayは製品除外の判断が別にあるが、E〜Gがどちらのfamilyに
  適用されるかballotに一言ない。命名判断としての独立性は保たれているので、適用範囲の注記だけで足りる。

#### 候補不足（既存提出から機械的に導ける）

- Claudeの`OptionalArray1D.init(capacity:)`→`init(count:)`、`removeAll()`の`resetAll()`／`clear()`は命名だけの候補だが、
  Excluded表の「Initializer, `removeAll`, `indices`, shape labels — 後の命名scope」で一括除外されている。除外理由自体は
  妥当（owner名と要素accessの判断に不要）。後のscopeで拾えるよう、どこで扱うかの行き先があると取りこぼしにならない。
  新しい候補提出は要らない。

#### 問題なし（確認した範囲）

- 網羅: Userの`BareElements`／`OptionalCache`／現行4語、Codexの`ElementBuffer`系・`FixedShapeElements`系・現行・
  `mutableElement`／`MutableElementReference`、Claudeの`FixedArray`・`HeapArray`・`SlotArray`・`MemoTable`・現行・
  `value`／`setValue`・`value`（property）が、いずれかの行に意味を変えずに入っている。
- 重複: `element`／`setElement`、`reference`、`Reference`、`BareArray`、`OptionalArray`は1行に統合され、Sourceの併記で
  票数を増やしていない。
- 意味の分離: owner二family（A／B）、1D suffix（C）、copied value access（D）、借用参照のmethod・result・property（E〜G）が
  互いを決めない単位に分かれている。ClaudeのA-2は`value`／`setValue`（D）とclosure案（Excluded）に正しく分けられている。
- 対象外: View型名、多引数subscript（取り下げ済み）、`withMutableValue`、`removeElement`、参照resultの削除、BareArray製品除外、
  Permutationが、それぞれ理由付きでExcludedにある。
- 現行sourceとの一致: `element(at:)`、`setElement(_:at:)`（両family）、`reference(at:)`、`typealias Reference = MutableRef`、
  `MutableRef.pointee`（BareArrayだけ）が存在し、View型と`subscript`は存在しない。所有権・寿命契約を変える候補が
  命名候補の行に紛れ込んではいない（E節冒頭で`~Escapable`の寿命は変えないと明記）。

#### 限界

- `ARRAY_NAMING_CANDIDATES_USER.md`／`_CODEX.md`（object名の初回提出）はInputs外のため照合していない。DS節の提出元は未確認。

## Current assignment: OptionalArray／BareArray deprecated公開面削除後の独立目視検査

### Objective

OptionalArrayとBareArrayについて、削除された旧連鎖subscript・非所有Viewが現行公開面、test、benchmark、
利用例、および現在性を主張する文書へ残っていないかを横断的に検査する。同時に、削除後も残る座標value
accessとBareArrayのSwift 6.4向け借用参照APIが、誤って削除・旧扱いされていないかを確認する。

### Inputs

Read only:

- Registryの`OPT-060`と`BARE-036`の行;
- `Sources/OptionalArrayModule/`と`Sources/BareArrayModule/`;
- 対応する`Tests/`、`Benchmarks/Sources/Benchmarks/`、`Tests/AcCollectionsTests/`;
- `Sources/OptionalArrayModule/Documentation/Quality-Profile.md`;
- `Sources/BareArrayModule/Documentation/Quality-Profile.md`;
- `Maintanance/OptionalArrayModule/OptionalArrayAudit.md`と`CurrentQualityAssessment.md`;
- `Maintanance/BareArrayModule/BareArrayAudit.md`と`CurrentQualityAssessment.md`。

### Inspection questions

- 削除済み`OptionalArray*View`／`BareArray*View`型または所有型の旧連鎖subscriptが、production source、
  実行対象test、benchmark、利用例、facade testへ残っていないか。
- 旧View・連鎖subscriptを現行契約または現在評価として説明する記述が、公開Quality Profileまたは
  Current Quality Assessmentへ残っていないか。
- audit内の過去の棚卸し・判断・履歴は、削除漏れと誤認せず、現在状態との境界が読めるかだけ確認する。
- OptionalArrayの`element`／`setElement`、BareArrayの`element`／`setElement`が現行経路として保たれているか。
- BareArrayの`MutableRef`と`reference(at:)`というSwift 6.4向け借用参照経路が、現行APIとして
  production source、Test as Specification、compiler fixture、benchmark、文書で矛盾なく扱われているか。
- 削除された契約だけを観測するtest、Death Test、compiler fixture、benchmarkが残っていないか。

### Boundaries

- source、test、benchmark、公開文書、Current Quality Assessment、audit、Registryを変更しない。
- public API、命名、性能、互換性、借用参照の採否を判断しない。
- RedBlackTree、Permutation、およびUser folderを調査・変更しない。
- Archived記録やauditの歴史記述を、現行契約へ残った旧記述として機械的に報告しない。
- agreementや検索0件を完全性の証明にしない。確認した範囲と未確認範囲を分ける。

### Validation and return

検索と目視照合だけを行い、build、test、benchmark、commit、Registry更新は行わない。問題があれば、
`path:line`、該当記述またはsymbol、現行契約と衝突する理由を列挙する。問題がなければ、確認した領域と
残る限界を短く記録する。

結果はこのassignment末尾の`Claude return`へ追記する。完了判定と修正はCodexが行う。

### Claude return

2026-10-13 Claude（Opus 5.5）。検索と目視照合だけで、build・testは実行していない。

#### 指摘

- `Sources/BareArrayModule/Documentation/Quality-Profile.md:83` — 「`element`、`setElement`、`reference`、`mutable`が
  指定座標だけを読み書きすること」。`mutable`という公開APIは現行`BareArray.swift`に存在しない（`func mutable`／
  `mutable(at:`の検索0件）。現行の借用参照経路は`reference(at:)`だけ。旧Viewのdeprecated messageが存在しない
  `mutable(at:...)`を案内していた件（CurrentQualityAssessment「付随して見つかった文書不整合」）と同根の残りと見られる。
- `Utilities/Maintenance/CompilerDiagnostics/BareArrayOwnedWriteback/`と`BareArrayViewEscape/`が、中身のない
  directory（`Tests`／`Sources`の空subdirectoryだけ）として作業treeに残っている。gitの追跡対象ではなく
  （`git ls-files`で0件）、検証scriptからも参照されていないので契約上の問題ではないが、旧fixtureが残っているように
  見える。（Inputs外の`Utilities/`だが、問いの「削除された契約だけを観測するcompiler fixture」に関わるので記録）

#### 問題なし（確認した範囲）

- production source: `Sources/OptionalArrayModule/`、`Sources/BareArrayModule/`に`*1DView`〜`*3DView`型と
  `subscript(`は残っていない。
- test: `Tests/OptionalArrayModuleTests/`、`Tests/BareArrayModuleTests/`、`Tests/AcCollectionsTests/`に旧View型・連鎖
  subscriptは残っていない。`EDPC-J.swift`／`EDPC-L.swift`の利用例も`element(at:)`／`setElement(_:at:)`へ移行済み。
- benchmark: `Benchmarks/Sources/Benchmarks/`の`[y][x]`形は、`OptionalArrayBenchmarks.swift`のRigidArray比較、
  `RigidArrayOptimizationBenchmarks.swift`、`StandardArrayMultidimensionalBenchmarks.swift`だけで、どれも比較対象の
  標準Array／RigidArrayのsubscript。OptionalArray／BareArrayへの連鎖subscriptではない。
- 公開Quality Profile: OptionalArray（23行）、BareArray（22行）とも「旧連鎖subscriptと非所有View 1D〜3Dは削除済みで
  現行契約に含めない」と明記。
- CurrentQualityAssessment: OptionalArrayは削除を現在状態として記述。BareArrayは冒頭の「Deprecated公開面の削除」節で
  現在状態を述べ、21行で「以下の旧View導入・監査・受入記録は履歴として保持」と境界を明示している。以降の旧View記述は
  履歴として読める。
- 現行経路: OptionalArray・BareArrayとも`element`／`setElement`が残り、`indices`も4型ずつ公開されたまま。
  BareArrayの`MutableRef`（`BareArray.swift:426`）と`reference(at:)`は、Test as Specification（`_7_BorrowedReferenceTests`、
  `_96_BorrowedReferenceDeathTests`）、compiler fixture（`BareArrayMutableRefLifetime`、検証scriptはこのfixtureだけを参照）、
  benchmark（`BareArrayBenchmarks.swift`）に揃って存在する。

#### 限界

- 検索pattern（View型名、`subscript(`、`][…]`、`writeback`、`連鎖`）に合わない書き方の旧記述は見落としうる。
- `Benchmarks/Libraries/*.json`のbenchmark名、DocC、README、`Documentation/`の利用者向け文書は見ていない。
- auditの歴史記述は、現在状態との境界が読めるかだけを見た。

## Last completed assignment: PERM-056 public surface, coexistence, and reexport tests

### Objective

Implement the accepted G0 public-surface and G5 coexistence／exposure requirements for the current
runtime-checked `NextPermutations` implementation.

### Inputs

Read only:

- the `PERM-056` Registry row;
- `Maintanance/PermutationModule/RuntimeCheckedPermutationTestPlan.md`;
- `Sources/PermutationModule/NextPermutations.swift` and `GateKeeper.swift`;
- legacy `_0_PublicSurfaceTests.swift` and `_4_CoexistenceTests.swift` under
  `Tests/PermutationTests/NextPermutationsSequence/` only for G0／G5 inputs;
- accepted borrowed coexistence tests only as a test-technique reference, not as the runtime-check
  contract;
- the current package targets and any existing repository-local compiler-surface fixture mechanism
  needed to test negative compile requirements;
- the task-relevant instructions in `Tests/CLAUDE.md` and sections of `Tests/TESTING.md`.

Use the G0／G5 boundaries in the plan. Do not revive retired `Sendable`、value-semantics、COW、
`Equatable`、`Hashable` or presentation guarantees.

### Required implementation

- Add numbered G0 and G5 tests under `Tests/PermutationTests/NextPermutations/`.
- Fix the current public owner and nested View type names and construction through
  `Collection.nextPermutations()` for Array、Range、nonzero-start Slice and non-`Int` indexed input.
- Verify with compiler-backed evidence that direct public initialization remains unavailable, the
  owner is noncopyable, and it does not conform to `Sequence`. Preserve the repository's existing
  fixture style if one exists; do not treat commented-out source as evidence.
- Verify that importing `PermutationModule` and `Algorithms` together is unambiguous and that
  `nextPermutations()` yields only the current order and its lexicographic successors while
  `permutations()` yields every positional ordering.
- Verify that importing `AcCollections` exposes the intended runtime-check entry point without a
  direct `PermutationModule` import.
- Keep AtCoder 2025 compatibility mode outside this evidence path; it has a separate API and tests.

### Boundaries

- Do not modify production source, Quality Profile, Current Quality Assessment, Package.swift, CI,
  Registry, public documentation, or disabled legacy test files.
- Do not change G1、G2、G3、G4.
- Do not decide new public API, `Sendable`, `Equatable`, `Hashable`, description, availability,
  compatibility, or lifetime policy.
- Do not revive COW, persistent-result, iterator-copy, `Sequence`, or borrowed-`Span` requirements.
- If the repository has no durable negative compiler-fixture mechanism, report the exact unmet G0
  checks and stop instead of inventing a claim from runtime reflection or comments.
- If a listed requirement cannot be implemented from the accepted contract, report that exact item
  and stop rather than deciding a new contract.

### Validation and return

- Run the new runtime tests and the already-accepted numbered runtime-check tests in Debug and
  Release. Run compiler fixtures through their actual repository execution path and record both
  expected-success and expected-failure outcomes.
- Report exact files changed, test counts, commands or Xcode actions, and results in
  `Maintanance/PermutationModule/RuntimeCheckedPermutationTestPlan.md` under a `PERM-056 return`
  section.
- Do not mark `PERM-056` complete and do not update Registry. Codex performs acceptance.

## Operating mode: bounded assignments only

Apply the task-selection and start-authority rule in the root `CLAUDE.md`. Codex integrates the
result, performs Registry acceptance and state changes, and owns public-document completion. These
coordination responsibilities do not make Codex's agreement evidence of factual correctness.

The rules below remain as bounded-task execution constraints. They do not grant authority to restart
frozen work or act on behalf of Codex.

Verify the current branch from the repository before editing; do not preserve a branch name here as
current state.

### Communication

- Respond directly when the user selects a Claude task. Codex is the active integrator; durable
  evidence belongs in the selected task's canonical document.
- Default to low-information reports. Give the outcome, any actual problem, and the next user
  decision or action only. Do not proactively explain background, commands, evidence, or every
  consideration; the user will ask when more detail is wanted.
- `完了` alone is preferred for a routine task whose requested outcome and validation are
  unambiguous. Expand without being asked only for a blocker, safety/correctness problem, failed
  validation, irreversible action, or a decision that only the user can make.
- A formal evaluation of the user, or a requested impression record, is a frozen Registry task and
  runs only when the user explicitly asks to record it. Merely discussing an evaluation or impression
  is not a request to append it. Write formal evaluations to `USER_MANAGEMENT_INTERVIEW_CLAUDE.md`
  and requested impressions to `CLAUDE_OBSERVATIONS.md`.
- Claude may still append its own optional, spontaneous observation to `CLAUDE_OBSERVATIONS.md` when
  genuinely useful. Do not manufacture an entry or delay the main task for it.
- If prior intent is unclear, ask the user rather than attributing an unstated decision to Codex.

### Authority

For an explicit user request, you may inspect, edit, build, test, benchmark, and update relevant
documentation within the repository. Use the smallest task boundary that satisfies the request.

The following still require explicit user direction:

- choosing or changing public API, compatibility policy, product positioning, or completion scope;
- restarting any item marked frozen, deferred, optional, or waiting for a user decision;
- changing the Index contract, `Comparable`, facade re-export policy, Permutation compatibility
  mode, or the unsafe-storage/concurrency items currently on hold;
- deleting material code or records;
- commit, push, merge, PR close/reopen, branch creation/deletion/switching, or history rewriting;
- publishing private performance-tuning knowledge.

Codex is the primary owner for public documentation. When public-document work is delegated to
Claude, keep it to explicitly named sections, factual verification, independent review, or a bounded
correction. Do not expand a Compatibility-document request into a four-document audit or rewrite.

When the user explicitly requests a commit, first verify the branch and complete diff. When it is
a good commit boundary, say `コミットおすすめです`. Never infer push permission from commit
permission.

### Performance-sensitive boundaries

- Non-`public` protocol declarations use `@usableFromInline` uniformly.
- Do not add, remove, or move `@inlinable`, and do not convert an existing `@usableFromInline` to
  `@inlinable`, without direct user review.
- Do not change a boundary that deliberately removes generic type variables, including the
  `RawBuffer` / `BufferHeader` family, without direct user review.
- Compile and functional tests do not prove performance neutrality. A performance-sensitive
  access or generic/protocol change is not complete until the relevant performance job is green.
- Keep the general tuning rationale private. Public incident records may describe reproduction and
  bisection, but follow the user's chosen level of detail for the mechanism.

### Task execution

- Establish current state from the Task Registry at the top of `Maintanance/PROGRESS_OVERVIEW.md`.
  After selecting a task, read only the detailed canonical document linked from that row. Do not
  scan all maintenance or Archived documents at session start.
- Read only the task-specific portions of maintenance documents needed for the current request.
  Do not turn backlog discovery into authorization to implement it.
- Preserve unrelated worktree changes. Never reset or discard user work to make a task clean.
- For broad inventories, repetitive cross-checks, or a high-risk conclusion, use an independent
  evidence-oriented second pass where available; otherwise tell the user what could not be
  independently reviewed. Agreement between agents is not evidence by itself.
- For performance work, fix the environment and baseline, reproduce first, and distinguish CI
  history from new local measurements.
- For cross-branch work, identify symbols by branch, path, configuration, and meaning. Verify the
  current branch before editing and again before committing.
- Update the relevant canonical record for durable decisions. Do not expose a private note merely
  to improve agent continuity.
- When actual use reveals a possible improvement to the conversation reference ID rule, Claude may
  append a concrete proposed diff to `Maintanance/CONVERSATION_REFERENCE_IDS.md` under
  `運用中の改訂候補` without waiting for a separate assignment. A proposal does not change the
  active rule; integrate it into the adopted text only after the user approves it or explicitly
  asks Claude to apply it.

### Bounded-task reporting

For a bounded assignment, record durable evidence in the selected task's canonical document and
report the outcome directly to the user. Do not maintain a general repository handoff or independently
curate the overall backlog. Registry acceptance and state changes remain Codex-owned.

If a task reveals a defect or decision point outside its boundary, report and stop. Do not turn the
finding into implementation authority.
