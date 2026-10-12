# Release Quality Requirements — Codex Draft

作成日: 2026-10-10

## 位置づけ

この文書は`CONCEPT_DEFINITION.md`から導いた独立ドラフトであり、品質要求の確定版ではない。
対象は、開発treeを掃除して作るrelease treeと、そのrelease treeから公開するtagである。
実装方法や人間向け工程表は定めず、releaseを受け入れるために観測可能であるべき性質を定める。

## 品質要求候補

### QR-01 利用者経路で取得・buildできる

release tagを依存先に指定した新しいSwift Packageが、公開product `AcCollections`を解決、import、buildできること。
repository内部のtest成功だけで代替しない。

証拠候補:

- cleanな一時directoryで作成した最小consumer packageのdependency解決とbuild成功
- 使用したtag、解決commit、Swift version、platformの記録

### QR-02 公開契約と振る舞いを保持する

通常版の公開APIと、Test as Specificationで確定した振る舞いをrelease treeが保持すること。DebugとReleaseの
双方で、通常版に適用される全testとDeath Testが成功すること。

掃除後のtest成功だけでは受け入れない。掃除前後のtest inventoryを比較し、削除されたtestは互換mode専用、
内部開発補助、または明示した対象外であることを説明できなければならない。

証拠候補:

- 掃除前後のtest target・test case inventoryと、意図した除外一覧
- Debug全test
- Release全test
- 対応platformで有効化したDeath Test
- 公開surfaceを固定するtest

### QR-03 値semantics・所有・不変条件を壊さない

copy-on-write、iterator copyの独立性、要素寿命、View共有、Indexの有効性、木の不変条件など、各データ構造が
既存のTest as Specificationで保証している性質を保持すること。単に代表的なAPIが動くことでは代替しない。

証拠候補:

- value semantics、reference lifetime、invariant、stress、fuzz、Death Testの該当test成功
- 検査を構成上skipした場合の対象、理由、代替証拠

### QR-04 直前releaseに対する重大な性能回帰がない

candidateと、その履歴に含まれる直前の正式SemVer release tagを、candidate側で固定した同じbenchmark定義、
同じrunner、同じjobで比較すること。主要benchmarkは2M件まで実行し、30%以上遅い結果をrelease停止候補とする。

これは相対的な回帰防止要求であり、コンセプトの「CやC++標準に匹敵する性能」を満たすことの証明ではない。
C/C++との絶対的・用途別比較はValidation側の別証拠とし、比較対象、操作、入力分布、許容差を定義するまでは
適合を断定しない。

証拠候補:

- baseline tagとcandidate commit
- runner CPU、OS、Swift version
- 両者の生resultとcomparison
- failure時のbinary、symbol、assembly

### QR-05 利用者向け文書が公開surfaceと一致する

release treeに残す利用者向け文書が、実際に含まれるmoduleと公開APIを説明し、除外した互換modeや内部開発用
surfaceを現行機能として示さないこと。DocCをRelease構成・warning-as-errorで生成できること。

証拠候補:

- DocC build成功
- release treeへ残す文書と除外する内部文書の分類差分
- Test as Specificationと重要な契約記述の照合

### QR-06 掃除の境界を説明できる

release treeへの変換が、製品source、適用されるtest、利用者向け文書、benchmark再実行手段を意図せず失わせて
いないこと。削除をfile数やdirectory名だけで正当化せず、各削除群が製品コンセプトとrelease品質へ不要である
理由を説明できること。

証拠候補:

- 掃除前後のdiffを、製品、test、文書、benchmark、内部管理、履歴結果、utilityへ分類した記録
- Package manifestが参照するpath、target、resourceの存在確認
- release treeからのclean build

### QR-07 release対象の同一性と由来を追跡できる

検証したcandidate、正式tag、公開文書の生成元をcommit SHAで追跡できること。検証後に製品内容が変化した
commitへ、同じ検証結果を流用しないこと。

証拠候補:

- candidate tag、正式tag、commit SHAの対応
- CI artifact名と生成元SHA
- 文書deploy元の正式tag commit

### QR-08 異常時に品質判定を保留できる

検証失敗、証拠欠落、対象commit不一致、説明できないtest削除、未説明の性能差、掃除範囲の不明確化が起きた
場合、release可と推定せず停止すること。停止後は新しい変更を重ねず、事実、影響範囲、実害、未確定事項を
整理できること。

## 0.5.xで受容可能な残余risk候補

次は自動的な受容ではなく、ユーザーが実験releaseごとに把握して受容できる候補である。

- GitHub-hosted runnerの揺らぎにより、性能比較に偽陽性・偽陰性が残る。
- 30% regression gateは重大な相対回帰を捕捉するが、C/C++級性能そのものは保証しない。
- candidateではASanを実行しない。既存のlifetime、invariant、Death Testを代替証拠とする範囲には限界がある。
- 2M回帰testはrelease前gateだが、16M chartは正式release後の観測であり、releaseを阻止しない。
- CIのLinux環境だけでは、Swift packageが対応すると主張する全platform・toolchainの適合を保証しない。
- 内部資料と過去benchmark結果をrelease treeから除外するため、開発過程の説明可能性はmainとGit履歴へ依存する。

## Release停止候補

- clean consumer packageから取得・buildできない。
- 適用対象のDebug、Release、Death Testのいずれかが失敗する。
- Test as Specificationが理由不明のまま削除またはskipされている。
- DocCがwarning-as-errorで生成できない、または公開surfaceと説明が一致しない。
- 直前release比30%以上の回帰、または閾値未満でも原因不明の大きな性能差がある。
- candidate、正式tag、CI artifact、文書deployのcommit同一性を追跡できない。
- 掃除差分に、意図を説明できない製品source・test・利用者向け文書の変更がある。
- ミス発覚後の状態変化によって、何を検証した結果なのか特定できない。

## Verification候補

Verificationでは「定義したrelease treeと工程が、品質要求どおり作られたか」を確認する。

- QR-01: clean consumerによるdependency解決・build
- QR-02〜03: test inventory照合とDebug／Release／Death Test
- QR-04: 同条件のprevious release比較
- QR-05: DocC warning-as-errorと文書分類
- QR-06: 掃除diff分類、manifest参照、clean build
- QR-07: ref、SHA、artifact、deploy元の照合
- QR-08: 故障を検知したrehearsalで停止・整理・再開境界を確認

## Validation候補

Validationでは「検証済みreleaseが製品コンセプトの用途に適合するか」を確認する。

- 競技プログラミング: 制約の大きい代表問題または既存採用例で、必要なデータ構造を現実的な時間・memoryで使える。
- 性能: 対応するC/C++標準libraryまたは同等実装との用途別benchmarkで、比較条件と差を説明できる。
- 一般Swift開発: SwiftPMから自然に導入でき、公開API、値semantics、文書、failure条件を利用者が理解できる。
- 継続利用: release tagから同じsource、文書、benchmark定義へ到達でき、後続releaseで回帰を比較できる。

## 不足仕様候補

次は品質要求の確定または後続の不足仕様充当で判断が必要である。

1. 「CやC++標準に匹敵する性能」の比較対象にCを含める意味と、対象library・操作・入力分布。
2. 対応するSwift version、OS、architectureの最低保証範囲。
3. test inventoryでrelease treeから除外してよいtestの分類規則。
4. 30%未満でも停止する「原因不明の大きな差」をどう扱うか。
5. ASanをcandidateから外した状態で、どのmemory safety証拠を必須とするか。
6. clean consumer smoke testで実行する最小APIと、単なるbuild成功を越えて何を確認するか。
7. 競技プログラミング用途と一般Swift用途を代表するValidation scenario。
8. 0.5.xで受容する残余riskを、0.6.x開始までにどこまで閉じるか。

## Codex所見

現在のrepositoryは、Test as Specification、Debug／Release test、Death Test、DocC、performance comparisonという
強い証拠経路を既に持つ。一方、release掃除の品質で最も危険なのは、製品コードのcompile errorより、testや
文書を一緒に削除した結果として検証が緑になることである。したがって、掃除後のtest実行だけでなく、掃除前後の
検査能力が保存されたことを独立した品質要求にする必要がある。

また、30% regression gateと「C/C++標準級性能」は別の問いである。前者はrelease間の劣化を防ぐVerification、
後者は製品コンセプトへの適合を確認するValidationとして扱うことで、現行CIが保証する範囲を過大表示せずに済む。
