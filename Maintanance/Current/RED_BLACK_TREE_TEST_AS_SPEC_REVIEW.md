# RedBlackTree Test as Spec 仕様レビュー

作成者：Astra。2026-10-15。ユーザー指定の「4型をざっと横断 → 型順 → 最後に再横断」を記録する詳細正本。
状態と依存関係の正本は `Maintanance/ProgressV2/TASK_REGISTRY_V2.md`。初回横断の課題候補を以下に記録。型別レビューと最終横断は未実施。

## 目的と境界

現行の公開契約に対し、既存のTest as Specが何を保証し、何を保証できていないかを確認する。テスト件数ではなく、仕様の不足、境界条件、誤った実装でも通る検査を重視する。
担当はAstra。型順はSet → MultiSet → Dictionary → MultiMapとする。各段階を記録してから次へ進む。
今回の委任はレビューであり、production・既存test・公開契約の修正、Claudeへの追加発注、凍結taskの再開は含めない。必要な修正は結果から切り出す。

## 入力と確認方法

- `Sources/RedBlackTreeCollections/Documentation/API-Matrix.md`、`API-Matrix-View.md`、`Quality-Profile.md`と、関連するDesign文書・現行公開APIコメントを必要な範囲で読む。
- `Sources/RedBlackTreeCollections/RedBlackTreeSet/`、`RedBlackTreeMultiSet/`、`RedBlackTreeDictionary/`、`RedBlackTreeMultiMap/`と`Tests/RedBlackTreeTests/`を起点に、実際の契約・test・共通実装へたどる。資料間の食い違いは仕様の新規決定で埋めない。
- 順序・重複・検索境界・挿入削除・空状態・Index/Viewの有効範囲・CoWと値意味論・参照要素の寿命を、各型に実在する契約に応じて見る。全組合せの先行展開はしない。
- 静的照合を基本とし、成立が不明な点は必要な対象だけ実行・compilerで確かめる。実行時は関連のテスト手順を確認し、実行と未実行、対象構成を区別する。
- 各段階で基準commitと関係ファイルの未コミット差分を記録する。並行変更があれば影響する結論を再照合する。Permutationの作業範囲は編集しない。

## 工程と受入条件

| ID | 範囲 | 到達点 |
| --- | --- | --- |
| RBT-036 | 4型の初回横断 | 共通契約・型固有契約と既存testの配置を概観し、型別レビューの見取り図と未確認範囲を残す。初回だけで品質の合否を結論しない。 |
| RBT-037 | RedBlackTreeSet | 初回横断を入力に、Setの公開契約とtestを照合し、不足・偽陽性・境界条件を根拠付きで記録する。 |
| RBT-038 | RedBlackTreeMultiSet | Setレビューの共通論点を引き継ぎ、MultiSet固有の重複・順序・操作契約とtestを照合する。Setの結果をそのまま保証として転用しない。 |
| RBT-039 | RedBlackTreeDictionary | 先行レビューを入力に、Dictionaryのkey/value・更新・Viewを含む現行公開契約とtestを照合する。 |
| RBT-040 | RedBlackTreeMultiMap | 先行レビューを入力に、MultiMapの重複keyとvalue・更新・Viewを含む現行公開契約とtestを照合する。 |
| RBT-041 | 4型の最終横断 | 4型の個別結果を再照合し、型間の不整合・共通実装の未検証・重複指摘・個別レビューの見落としを整理し、修正候補と判断待ちを分ける。 |

各段階の受入条件は、対象契約と確認したtestへの経路、保証範囲、未確認事項、根拠付きの指摘を残すこと。問題がなければ確認範囲を明記して指摘なしとする。実装反映の完了や品質全体の合格まで意味を広げない。
新しい製品判断が必要なら、その論点を分離してユーザーへ返し、未決の答えをtest仕様として作らない。既存taskと重なる指摘は既存IDを示し、同じ仕事を重複登録しない。
最終横断は、個別レビューを単に連結するのでなく、共通契約の扱いと型固有の差を改めて照合する。

## レビュー結果

### 初回横断（RBT-036、2026-10-15、Astra）

基準HEAD：`c98a0908`。赤黒木source・testに未コミット変更はなかった。並行してClaudeがPermutationのtest・返却・Tests/TESTING.mdを変更しているが、今回それらは編集していない。静的な概観のみ。テスト実行・mutation検証・全API網羅レビューは未実施。

4型とも番号付きの生成・走査・検索・挿入削除・範囲・protocol・値意味論と、内部CoW・Index・Death Test群が存在する。Viewには独立した共通test群がある。共通土台がない状況ではなく、検査の強さと構成別の保証範囲を次に詰める。

#### 課題候補（修正・発注はまだ行わない）

1. **Death Testの終了判定の強さ（4型、優先確認）**。各`*_99_DeathTests.swift`に正確なSwift trap signalを指定する例と、`.failure`を受けてSIGSEGV/SIGBUS/AddressSanitizerを除外する例が混在する。例はMultiSetの逆転範囲・削除済みIndex。後者は意図した契約検査以外の失敗も通し得る。個別レビューでは期待する停止契約とsetupを照合し、必要なものだけ判定強化・negative control候補にする。製品不具合や全Death Testの無効を意味しない。
2. **Map系CoWテストのvalue観測（Dictionary/MultiMap）**。両型の`*_13_ValueSemanticsTests.swift`の`test_copyOnWrite_mutatingCopyPreservesOriginal`は最終結果をkey列だけで比較している。このケース自身はvalueの取り違え・変更を検出しない。型別レビューで既存`*_98_CopyOnWriteTests.swift`、MappedValues View testによる補完を確認し、不足する公開操作経路だけを候補化する。内部のcopy回数の検査と公開valueの独立性は別の証拠として扱う。
3. **CoW・寿命の型間の対応（確認課題）**。Setの`*_15_ValueSemanticsTests.swift`には参照要素の共有・分岐・両コピー破棄後の解放を追うケースがある。他3型の`*_13_ValueSemanticsTests.swift`には同じケースはないが、各RemovalTestsには参照解放testがある。これだけで不足とは確定しない。型別レビューで共有中の保持、最後の所有者の解放、Mapのkey/value、重複要素を既存testがどこまで見ているか確認する。参照要素のdeep copyを要求しない。
4. **空の旧テストと現行証拠の説明（確認済みの文書上の問題）**。Dictionaryの`*_0_InitializationTests.swift`の`testInitWithDuplicateKeysShouldCauseFatalError`は本文がコメントだけで「実テスト不可」と記載するが、`*_99_DeathTests.swift`に`duplicateKeysInUniqueKeysInitializer_terminateProcess`が存在する。検証不足として新規testを増やすのでなく、旧説明と実行件数の読み違いを整理する候補。Setの空のremoveFirst/Last testにはDeath Testへの説明があり、同じ扱いで不足認定しない。

#### 次の型別レビューへ渡す見取り図

- Set：共通Index/Bound/View境界とDeath Test、値意味論の観測を起点にする。
- MultiSet：Setと共通する論点に加え、重複数・等価要素の更新と寿命を確認する。
- Dictionary：上記2・4を起点に、value更新・default subscript・重複統合closureの正常/失敗経路を確認する。例外時に原状回復する等の未記載契約は作らない。
- MultiMap：重複keyごとのvalue保持・更新・削除、MappedValues ViewとCoWを確認する。
- 最終横断：共通testで本当に保証される範囲と型固有差、構成条件を再照合する。

4型のclosure内CoW testは同じ変更を双方へ行うが、Set/Dictionaryでは戻り値の検査、Multi系では個数の変化も検出に寄与する。したがって「同じ最終結果だから独立性を検証できない」と一律に断定しない。途中の非変更側の観測を補う必要があるかを型別で確認する。
MappedValuesの範囲所属検査はAPI-Matrix-Viewの現行事前条件と既存RBT-026を尊重し、今回の課題出しで契約変更・凍結解除しない。内部CoWは`AC_COLLECTIONS_INTERNAL_CHECKS`、Death Testは`DEATH_TEST && !COMPATIBLE_ATCODER_2025`等の条件があるため、testの存在と各構成での実行保証は区別する。

初回横断の到達点である見取り図・課題候補・未確認範囲の記録は完了。型別詳細レビュー・修正は未着手。コミット許可待ちとしてRBT-036をWAITING_USERとする。

2026-10-15、ユーザーがコミットを許可。初回横断の記録を保存し、RBT-036をDONEとする。型別レビューは未着手。

### Set仕様レビュー（RBT-037、2026-10-15、Astra）

基準HEAD：`eb1d5d69`、開始時作業ツリーはclean。今回も課題出しのみで、production/test変更・test実行・mutation試験・Claudeへの発注はしていない。型別レビューは公開仕様と検査内容の静的照合であり、全構成の合格認定ではない。

確認範囲：Setの番号付きtest一覧を確認し、Insertion、Removal、Search、RangeView、ValueSemantics、SetAlgebra、Codable、DeathTests/AdditionalDeathTestsの本文、および内部SetAlgebraStress/Fuzzを照合した。公開Set本体・Combining・SetAlgebra・SequenceとAPI-Matrixを契約の根拠とした。Index/Bound/走査/protocol群はテスト配置・既存ケースの確認を中心とし、全assertionや全trait組合せの網羅検証はしていない。

#### S1：ヒント付き挿入・置換を、等価だが別の参照で区別する（優先）

根拠：`Tests/RedBlackTreeTests/RedBlackTreeSet/RedBlackTreeSet_5_InsertionTests.swift`の`test_insert_withHint`（202行目）、`test_update_withHint`（222行目）はIntだけを使用する。`Sources/RedBlackTreeCollections/RedBlackTreeSet/RedBlackTreeSet.swift`の268〜318行付近はinsertが既存要素を返し、updateが置換して旧要素を返す契約。ヒントなしにはComparableReferenceを用いたidentity検査がある。

不足：ヒント付きupdateが旧要素を返すだけで置換を省略しても、同じIntのままなので当該testは通る。insertが既存参照を同キーの新参照へ置き換えても当該testは区別しない。

反映候補：既存ComparableReferenceを使い、insertの重複では既存参照保持、updateでは旧参照返却と格納参照の置換を`===`で確認する。有効だが位置の悪いhintとendIndexも扱い、共有コピーを残した場合に元の格納参照が変わらないことを確認する。新規fixture/APIや不正hint契約は作らない。
受入：置換を省略する誤実装を検出できるassertion、要素数・順序・戻り値、Debug/Releaseの実行証拠。

#### S2：throwするpredicateの失敗経路（優先）

根拠：Setの`filter`（`RedBlackTreeSet+Sequence.swift`）と`erase(where:)`、IndexRange/Bound範囲のeraseはthrowing closureを受ける。Set/View testをthrow・XCTAssertThrowsError等で検索した範囲では、実際に独自エラーを投げて伝播を検証するケースを確認できなかった（コメント化されたtrap検査とXCTSkipは別）。

反映候補：通常構成のSet.filterとSet.erase(where:)を最小対象に、固有エラーを投げ、そのエラーが呼出元へ届くこと、投げた後にpredicateを継続しないことを検査する。filterは元Set不変を確認し、一時生成された保持参照の解放も検査対象にする。eraseはコピーを残し、非変更側の内容保持を検査する。失敗した変更側に未規定の全巻戻しや特定の途中状態を要求しない。範囲版は同じ経路で担保されるかを反映時に確認し、異なる経路の必要分だけ補う。
受入：正常controlとthrowケース、期待したエラー識別、適用できる寿命検査、Debug/Release。製品不具合や例外保証の判断が必要なら再現を残して止める。

#### S3：集合演算のCoWで非変更側のコピーを直接観測する（中）

根拠：`RedBlackTreeSet_98_SetAlgebraStressTests.swift`の`testFormOperationsMutateReceiverOnly`（57行目）はlhsから各変更用コピーを作り、結果とrhsを照合するが、各操作直後の元lhsを参照モデルsLと直接比較していない。`assertEquiv(rhs, rhs)`は自己比較であり、その後のsR比較とは証拠として区別する。番号付き`_10_SetAlgebraTests.swift`には内容検査があるが、form系で共有元を明示的に保持した独立性のケースは見当たらなかった。

反映候補：formUnion/formIntersection/formSymmetricDifference/formDifferenceの各操作で変更用コピー・元の共有コピー・rhsを保持し、操作直後に三者の期待内容を比較する。各演算が実際に内容を変える入力を使う。既存stress全体の増量やcopy回数の新規契約は不要。
受入：結果だけでなく元コピーとrhsの保持を直接検査、Debug/Release。既存の集合演算の参照モデル比較・代数法則testは残す。

#### S4：削除済みIndexのDeath Testでsetup失敗を分離する（中）

根拠：`RedBlackTreeSet_99_AdditionalDeathTests.swift`の`removed index cannot be subscripted`（66行目）は子process内で`firstIndex(of: 2)!`を使う。検索がnilなら、目的の削除済みIndex参照に到達せずSwift trapとなり、`.failure`とメモリエラー除外を満たし得る。これは静的な検出経路の指摘で、negative controlは未実行。

反映候補：このケースのsetupを親側の正常controlなどで区別し、検索失敗・削除未成立を目的の停止の成功として数えない。`.failure`を維持するなら「exit(86)にするだけ」では同じく成功してしまうので不可。setupの特定終了codeを明示的に拒否する等、既存の広い停止契約を保った区別を行う。壊したsetupを使う一時negative controlが失敗することを確認し、復元する。
受入：通常ケース成功、setup故障時の確実なtest失敗、既存SIGSEGV/SIGBUS/ASan除外を保持。実装側のsignal契約を変更しない。

#### 今回追加課題にしないもの

- 初回候補の「広いDeath Test終了判定」は意図された契約がある。Tests/CLAUDE.mdとAdditionalDeathTestsの説明に従い、全件を特定signalへ統一しない。SetのstaleIndexケースには理由文字列の検査もある。
- Setの共有参照寿命は`_15_ValueSemanticsTests.swift`に具体的な検査がある。同じ内容を再追加しない。
- closure内で双方に同じinsertを行うケースは戻り値insertedも検査し、単純な共有破壊なら後段がfalseとなる。これを無効な検査とはしない。
- 集合演算は内容比較・固定seedの参照モデル・代数法則、基本変異はFuzzで補完されている。弱いsmoke testだけを根拠に「集合演算の検証がない」としない。
- 空のremoveFirst/LastテストはDeath Testへの明示参照があり、不足を重複計上しない。
- Indexの外部要件、MappedValues契約、性能再評価、凍結task、公開API変更は今回の反映候補に含めない。

S1〜S4はtest補完の依頼を具体化できる範囲として記録するが、まだ実装taskの採番・委任はしていない。担当者は現行差分と契約を再確認し、不具合ならproductionを修正せず返す。レビュー記録は完了し、RBT-037はコミット許可待ち。MultiSet以降は未実施。

2026-10-15、ユーザーがS1〜S4の発注後のコミットを許可。RBT-042を登録してCLAUDE_TASK.mdへ依頼を掲載した。RBT-037はDONEとして保存する。S1〜S4の依頼入力を固定し、今後の別型レビューは別節へ追記する。


### MultiSet仕様レビュー（RBT-038、2026-10-15、Astra）

基準HEAD：`2fc2dc66`。開始時と記録直前の作業ツリーはclean。公開MultiSet本体・Combining・SetAlgebra・Sequence・RangeExpression・BoundsExpressionと、MultiSetのInsertion、Removal、Search、Utility、SetAlgebra、ValueSemantics、RangeView、BoundExpression、Fuzz、Death Test、およびCppBehaviorReferenceTestsのMultiSet比較を静的に照合した。全assertion・全構成の網羅検証ではなく、テスト実行・mutation検証はしていない。以下はテスト補完候補であり、製品不具合の確認ではない。SetのS1〜S4とClaudeへの依頼入力は変更していない。

以下のtestファイル名は、特記しない限り`Tests/RedBlackTreeTests/RedBlackTreeMultiSet/`内の`RedBlackTreeMultiSet`に続くsuffixを示す。

#### M1：削除済みIndexへのupdateがnilを返す契約（優先）

根拠：`Sources/RedBlackTreeCollections/RedBlackTreeMultiSet/RedBlackTreeMultiSet.swift`の`update(_:at:)`は、無効なIndexまたは非等価要素ならnilを返す。`_5_InsertionTests.swift`は等価な別参照への置換、endIndex・非等価要素の拒否、共有コピー保持を検査しているが、削除済みIndexへのupdateは確認できなかった。

反映候補：重複群の一要素を削除し、そのIndexが無効になったことを確認してから、等価な別参照でupdateする。nil返却と残存要素・個数の不変を確認する。他の木のIndexの扱いや、拒否時の内部コピー回数を新しい契約にしない。

#### M2：位置指定削除が、指定した等価要素そのものを取り除く（優先）

根拠：`_6_RemovalTests.swift`の`test_removeAt_removesOnlyTheSelectedDuplicate`と`test_erase_returnsTheFollowingIndex`はIntで内容・戻り値を検査する。`Tests/CppBehaviorReferenceTests/MultiSetBehaviorComparisonTests.swift`にも位置指定削除の比較があるが、Int64の等価要素には個体の区別がない。`_5_InsertionTests.swift`には参照を用いた`erase(exactly:)`の検査があるものの、別APIかつ構成条件付きである。

反映候補：同値だが別個体の参照を三つ並べ、中央のIndexに対するremove(at:)で返る参照と残る参照を`===`で確認する。eraseでは削除対象と返却された後続の参照を区別する。キー指定のeraseUniqueがどの個体を選ぶかという未記載の保証は追加しない。

#### M3：Boundの公開動作をReleaseでも検査する（中）

根拠：`_16_BoundExpressionTests.swift`の主要部分は`DEBUG && !COMPATIBLE_ATCODER_2025`で囲まれ、未解決Boundのnil、逆転範囲の空結果・predicate非呼出し、重複範囲などの公開動作もDebugに限定されている。distanceの一部は別条件でReleaseでも対象になる。`_8_RangeViewTests.swift`にはIndex範囲・equalRangeの検査があり、範囲検査全体が欠けているわけではない。

反映候補：公開結果だけで検査できるBoundケースをReleaseでもコンパイル・実行できる部分へ分ける。内部copy countやDebug専用の有効性検査は元の条件を維持し、DEBUGを一括削除しない。重複範囲、未解決Bound、逆転範囲でpredicateを呼ばないことを中心に、実際のRelease実行対象を確認する。

#### M4：throwするpredicateの失敗経路（優先）

根拠：MultiSetのfilterとerase(where:)、範囲eraseはthrowing closureを受けるが、調査したMultiSet testでは意図的に独自エラーを投げるケースを確認できなかった。SetのS2を補完しても、MultiSetの公開入口まで自動的に検証済みとはならない。

反映候補：固有エラーの伝播、throw後のpredicate非呼出し、filterの元コンテナ保持、変更操作の共有元保持を検査する。重複要素を含め、一時的な参照保持が残らないことも必要な範囲で確認する。throwした変更側の全巻戻しや特定の途中状態は要求しない。範囲版は実装経路を照合し、共通経路と異なる部分だけを補う。

#### M5：重複を持つ共有コピーの保持と参照寿命（中）

根拠：`_10_SetAlgebraTests.swift`にはunionの重複数a+b、intersectionのmin、differenceのmax(a-b,0)、symmetricDifferenceの絶対差について内容検査があるが、form系の操作直後に共有元を直接確認するケースは見当たらなかった。`_6_RemovalTests.swift`には別個体の参照の解放検査があるが、同一参照を複数回格納し、共有コピーを分岐させた場合の保持・最終解放は確認できなかった。

反映候補：form系は変更用コピー・共有元・rhsを保持して三者の期待内容を確認する。寿命は同じ参照を複数回格納した小さなケースで、一部の出現を削除しても残る出現や共有コピーが保持すること、最後の保持がなくなれば解放されることを検査する。参照要素のdeep copyや内部コピー回数は要求しない。

#### 追加課題にしないものと反映範囲

- ヒント付き挿入の重複群内の位置と等価な別参照へのupdateは、既に具体的な検査がある。SetのS1をそのまま転記しない。
- meld/meldingには共有元lhsの保持検査がある。M5で同じ検査を追加しない。
- 位置指定削除、重複数、基本操作の参照モデルFuzzは既存の証拠として残す。「MultiSetの重複処理が未検証」とはしない。
- SetのS4と同じsetup偽陽性をMultiSetで確認したわけではない。Death Testの広い失敗判定を一律変更しない。

M1〜M5の補完時は関連ケースのDebug/Release実行を確認し、構成限定の理由を残す。不具合や未決の仕様が現れた場合はproductionを変更せず根拠を返す。現段階ではtest修正・新規採番・Claudeへの発注は行っていない。レビュー記録は完了し、RBT-038はコミット許可待ちのWAITING_USERとする。

2026-10-15、ユーザーがレビュー記録のコミットを許可。RBT-038をDONEとして保存する。M1〜M5の補完作業は未発注。


### Dictionary仕様レビュー（RBT-039、2026-10-15、Astra）

基準HEAD：`926271e1`。Setの5つのtestファイルにはClaudeの作業中差分があり、変更していない。DictionaryのInitialize・Subscript・Combining・Sequenceの公開契約と、番号付きInitialization・Insertion・Removal・Utility・ValueSemantics・RangeView、内部CopyOnWrite・Fuzz、共通MappedValuesViewの本文を照合した。BoundExpressionの構成条件とケース、Death Testの重複初期化検査、Cpp比較の対象操作も確認した。静的レビューであり、test実行・mutation検証・全API/全構成の網羅確認は未実施。以下は検査の補完候補で、製品不具合を認定するものではない。

testのsuffixは、特記しない限り`Tests/RedBlackTreeTests/RedBlackTreeDictionary/RedBlackTreeDictionary`に続くファイル名を示す。

#### D1：default付きsubscriptの遅延評価と共有元保持（優先）

`+Subscript.swift`は未登録キーの読み出しでdefaultを評価するが挿入せず、変更時には挿入する契約を持つ。`_5_InsertionTests.swift`には読み出し・append・左右の単回転/二重回転が既にある。一方、default生成の副作用による評価回数と、共有コピーを残した既存/未登録キーの変更は確認できなかった。Cpp比較にもdefault加算はあるが、この二点の代替にはならない。

補完候補：カウンタ付きdefaultで、既存キーでは不要な評価をしないこと、未登録キーの読み出しは評価しても登録しないこと、初回変更で一度生成することを検査する。値型Valueを使って共有元を残し、既存キーと未登録キーへの変更後に双方のkey/valueを確認する。内部コピー回数や参照型Valueのdeep copyは要求しない。既存の回転ケースは増やさない。

#### D2：throwing closureの伝播と途中生成物の寿命（優先）

`+Initialize.swift`の重複統合・grouping、`+Combining.swift`のmerge/merging、`+Sequence.swift`のmapValues/compactMapValues/filterはthrowを受ける。Dictionaryのtest検索では、これらへ独自エラーを投げるケースを確認できなかった。テスト関数のthrows指定やCpp実行器のエラーは、対象closureの伝播検査ではない。

補完候補：まずDictionary固有の重複統合と値変換を対象に、エラー識別とthrow後のclosure非呼出し、元入力のkey/value保持を確認する。途中で生成した参照値が解放されることも検査する。mergeでは共有元を保持するが、変更側の全巻戻しは要求しない。Sequence版とDictionary版のmerge、grouping、filter/eraseの共通・相違経路を確認して必要分を補う。全組合せを展開せず、Set/MultiSetのthrow検査で代替できる範囲とDictionary入口固有の範囲を分ける。

#### D3：Optional Valueのnilとキー不在を区別する（中）

`subscript(key:)`はValue?を返し、外側のnil代入を削除とする。既存Insertion/Utility/Fuzzは主にInt・String・配列であり、Value自体がOptionalであるケースを検索した範囲では確認できなかった。

補完候補：`RedBlackTreeDictionary<Int, Int?>`で、未登録・登録済みnil・登録済み値ありを、外側Optionalのパターンとcount/キー存在で区別する。`.some(nil)`の代入で登録を保持し、外側nilで削除すること、default付き読み出しが登録済みnilを未登録と取り違えないことを確認する。曖昧なXCTAssertNilだけで三状態を同一視しない。

#### D4：共有した参照Valueの置換・削除後の寿命（中）

`_6_RemovalTests.swift`にはpop/removeAll/nil代入/上書きの参照解放検査があり、単独所有の基本解放は既に確認されている。一方、共有コピーを残した参照Valueの置換・削除と、旧値を戻り値として保持する期間の寿命は確認できなかった。

補完候補：小さな参照Valueの辞書を共有し、一方をupdateValueまたは削除して、他方の参照identityと内容を確認する。共有元や取り出した旧値が保持している間の生存と、最後の保持を解いた後の解放を分けて観測する。テスト自身のローカル変数による保持を制御し、deep copyを要求しない。

#### D5：Bound公開動作のRelease検査（中）

`_16_BoundExpressionTests.swift`の主要部分がDEBUG条件内で、未解決Boundや逆転範囲のpredicate非呼出しなどもDebug限定になる。distanceとIndexRangeの別検査はReleaseでも存在するため、「範囲検査が全くない」とはしない。

補完候補：MultiSetのM3と同じ方針で、公開結果だけの検査をDebug専用の内部観測から分離する。Dictionaryではkeyに加えて対応valueも確認する。共通化のための共有fixture変更はこのレビューだけでは発注しない。

#### D6：空の重複初期化testの説明整理（軽微）

`_0_InitializationTests.swift`の`testInitWithDuplicateKeysShouldCauseFatalError`はコメントだけで「実テスト不可」とするが、`_99_DeathTests.swift`の`duplicateKeysInUniqueKeysInitializer_terminateProcess`が実在する。空のtest関数を実行保証として数えず、実際のDeath Testと有効条件への参照に整理する。新しい重複初期化testを増やす必要はない。

#### 初回懸念の解消と追加しない課題

- `_13_ValueSemanticsTests.swift`単独ではkeyだけを見るが、`_7_UtilityTests.swift`に通常subscript更新後の元value/変更後valueの直接検査がある。初回横断の「DictionaryのCoWでvalue未観測」は一般的な不足としては解消する。
- `RedBlackTreeView/RedBlackTreeView_0_MappedValuesViewTests.swift`はvaluesの置換・swap・範囲操作・共有元のvalue保持を検査している。同じ検査を再追加しない。範囲所属の契約変更や凍結課題の再開はしない。
- mergingには非可換な文字列連結で旧値/新値の順序と双方入力保持を確かめるケースがある。統合順序の検査がないとはしない。
- FuzzはSwift Dictionaryとkey/valueを比較する。通常の代入・merge・mapValues・削除の内容検査を重複して増量しない。

反映時は必要なDebug/Releaseケースと構成条件を確認する。新たな仕様判断や不具合を見つけた場合はproductionを変更せず返す。今回はレビュー記録のみを更新し、test修正・採番・発注はしていない。RBT-039はコミット許可待ちのWAITING_USERとする。

2026-10-15、ユーザーがDictionaryレビュー記録のコミットと次段階への継続を許可。RBT-039をDONEとして保存する。補完作業は未発注。


### MultiMap仕様レビュー（RBT-040、2026-10-15、Astra）

基準HEAD：`7e9960d8`。ClaudeのSet作業中差分は編集していない。MultiMap本体のupdateValue、Combining・Sequenceの契約と、番号付きInsertion・Removal・Utility・RangeView・TransformingAndCombining・ValueSemantics・Fuzzの本文を照合した。BoundExpressionの構成条件と逆転範囲、Index検査・内部CoW・Cpp比較の関係箇所を補助確認した。静的レビューのみで、実行検証・mutation検証・全API/構成の網羅確認ではない。

以下のtest suffixは`Tests/RedBlackTreeTests/RedBlackTreeMultiMap/RedBlackTreeMultiMap`に続くファイルを示す。製品不具合ではなくテスト補完候補として記録する。

#### MM1：削除済みIndexへのupdateValue（優先）

本体`updateValue(_:at:)`は無効Indexならnilを返す契約。`_5_InsertionTests.swift`には重複key群の中央の置換、endIndex拒否、共有元のvalue保持があるが、削除済みIndexによる更新は確認できなかった。Index自体の失効検査と、この公開操作のnil返却は別の観測である。

補完候補：同じkeyに異なるvalueを持つ群から中央を削除し、保存したIndexの失効を確認後、updateValueがnilを返し、残るkey/valueを変更しないことを検査する。別の木のIndexや互換モードに通常モードの契約を転用しない。

#### MM2：値変換・predicateがthrowする経路（優先）

`+Sequence.swift`のmapValues/compactMapValues/filterと本体・範囲eraseはthrowing closureを受ける。MultiMap testでは意図的なthrowのケースを検索した範囲で確認できなかった。Cpp比較実行器のthrowは代替ではない。

補完候補：重複keyの各valueを区別した入力で、固有エラーの伝播とthrow後のclosure非呼出しを確認する。非変更操作の元入力、変更操作の共有元のkey/value保持、一時生成した参照Valueの解放を必要な経路で検査する。変更側の全巻戻しは要求しない。D2/M4と実装経路を照合し、共通fixtureの複製や全組合せを増やさない。

#### MM3：重複エントリと共有コピーによる参照Valueの保持（中）

`_6_RemovalTests.swift`は重複keyに別々の参照Valueを入れて削除時の解放を確かめるが、同じ参照を複数エントリに入れた場合や、共有元・返却旧値による保持の寿命は確認できなかった。

補完候補：同一参照を複数エントリに格納して共有コピーを残し、一部を削除・置換しても必要な参照が生存すること、最後の保持を解いた時に解放されることを検査する。updateValueの旧値を保持する期間も区別する。参照のdeep copyや内部copy回数を契約にしない。通常の文字列による位置指定削除は既に別valueを区別できており、その検査を無効扱いしない。

#### MM4：Boundの公開動作をReleaseでも観測（中）

`_16_BoundExpressionTests.swift`の主要部分はDEBUG条件内にあり、重複key群の逆転範囲で無変更・predicate非呼出しという公開契約もDebug限定になる。IndexRange・equalRange・distanceには別の検査があり、範囲全体が未検査ではない。

補完候補：M3/D5と同様に公開結果の検査とDebug専用内部観測を分ける。重複keyのvalue列と個数を確認し、内部検査の条件を一括解除しない。

#### 既存の検査で足りる点

- 初回の「CoWでkeyしか見ていない」という懸念は、`_7_UtilityTests.swift`の挿入後value列保持、`_5_InsertionTests.swift`のupdateValue、`_8_RangeViewTests.swift`の同じkeyのvalues範囲swapによって一般的な不足としては解消する。
- 通常挿入順、hintによる同値群内への挿入、中央のremove(at:)、eraseの後続valueは異なる文字列で検査されている。MultiSetのM2を機械的に追加しない。
- `_11_TransformingAndCombiningTests.swift`は重複keyのmapValues/compactMapValues、inserting、meld/meldingのvalue保持を検査する。meldingは左右入力のvalueも直接確認している。
- Fuzzはkeyの多重度に加えてvalue==keyを確認する。任意の異なるvalueの順序を保証するものではないが、番号付きの具体例と合わせて評価し、単純に無効としない。
- 共有MappedValuesViewのDictionary検査に加え、MultiMap固有のkey指定範囲と重複valueのswap/CoW検査が存在する。範囲所属の契約変更は不要。

反映時は関連Debug/Releaseケースを確認し、不具合や未決仕様はproductionを変更せず返す。今回test修正・採番・発注は行っていない。レビュー記録は完了し、RBT-040をコミット許可待ちのWAITING_USERとする。最終横断ではM/D/MMの共通課題を照合し、別型の証拠で代替できる範囲と固有入口の確認を整理する。

2026-10-15、ユーザーがMultiMapレビュー記録のコミットを許可。RBT-040をDONEとして保存する。MM1〜MM4の補完作業は未発注。
