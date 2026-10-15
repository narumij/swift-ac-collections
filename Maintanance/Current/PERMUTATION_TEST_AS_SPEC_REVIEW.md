# Permutation Test as Spec 仕様レビュー

作成者：Astra。2026-10-15。基準：`4f8c9aef`。レビュー・依頼準備：`PERM-077`。

## 結論と範囲

新主入口NextPermutationModuleの通常runtime-check版とSwift 6.4借用版について、公開コメントと現行Test as Specを静的照合した。列挙順、開始順、重複、空・単要素・降順、非Int Index、通常Viewの失効、通常ownerの破棄には既存検査がある。全面的な書き直しは不要。以下は検証の不足であり、製品実装の不具合を確認したという報告ではない。

今回テスト・compiler fixtureは追加／実行していない。移行時の成功記録は再実行結果として流用しない。AtCoder 2025互換modeの既存仕様5件は読んだが、旧API全体の網羅レビューは今回の結論に含めない。無効化された旧COWテストは現行仕様として数えない。

## A：借用寿命の再実行可能なcompiler検査（既知の残件）

根拠：`Sources/NextPermutationModule/BorrowedNextPermutations.swift`のnext()は、Spanがowner寿命を越えず、次のmutating accessと重ならないと約束する。`Tests/PermutationTests/BorrowedNextPermutations/`は適法な使用のruntime検査を持つが、`Utilities/Maintenance/CompilerDiagnostics/PermutationPublicSurface/`と`VerifyPermutationCompilerDiagnostics.sh`の否定的検査は通常ownerの直接初期化・copy・Sequenceだけである。

`Maintanance/PermutationModule/BorrowedPermutationTestPlan.md`のPERM-051返却に、一時clientによる拒否結果が既にある。したがって「これまで未検証」ではなく「現行名・現行toolchainで再実行できるfixtureがない」が不足。RegistryのPERM-051はFROZENであり、今回のレビューから解除しない。新規反映taskへ同じ仕事を移して凍結を迂回しない。

再開時の確認案：適法な逐次利用をpositive controlとし、next後の旧Span使用、owner寿命外への持出し、Spanを後で使う間のowner消費、owner copy、非Sequenceを独立fixtureにする。単なる構文エラーや一般的なSpanの制約で落ちただけではownerへの寿命依存の証拠にならない。期待する原因の診断まで確認する。この案は未発注。

## B：終端失効Death Testの偽陽性を防ぐ（反映対象）

根拠：`Tests/PermutationTests/NextPermutations/NextPermutations_99_ViewInvalidationDeathTests.swift`の`subscriptTrapsAfterTerminalNextReturnsNil`と`startIndexTrapsAfterTerminalNextReturnsNil`は、期待signalを確認する子process内で、終端がnilであることをpreconditionで確認している。終端処理が壊れてnilでなくても、そのpreconditionが同じsignalで停止し、失効検査が成功したように見える。

必要な変更：setupの不成立は期待trap以外の終了として区別する。nilの成立自体は通常assertionでも確認し、失効したViewへのaccessだけが期待signalの原因となる構成にする。全組合せのDeath Test増設ではなく、既存2件の検証能力を直す。可能なら一時的なtest側の条件差し替えで、setup失敗が成功扱いにならないことも確認し、差し替えは戻す。

## C：借用版の未開始ownerの非空要素解放（反映対象）

根拠：`BorrowedNextPermutations_98_InternalTests.swift`は途中・完走後・空ownerの破棄を検証するが、一度もnext()を呼ばない非空ownerの解放を直接検証していない。通常版には`testNeverStartedOwnerReleasesEachElementOnce`がある。所有bufferは生成時から要素を保持するため、列挙開始の有無に関係なく解放が必要。

追加：参照型要素と局所counterを使い、非空ownerを未開始のまま破棄して全要素の解放を確認する。元配列の参照が残って解放を妨げないscopeにする。通常版の同じ検査を重複追加しない。

## D：借用版の生成時copyと元Collectionの独立（反映対象）

根拠：`BorrowedNextPermutations_1_EnumerationTests.testSourceIsNotModified`は列挙が元を変えないことを確認する。一方、owner生成後に元配列を変更しても生成時の並びを保持するという逆方向は直接assertしていない。公開コメントは生成時に一度owned bufferへcopyすると説明する。通常版には`NextPermutations_98_OwnershipTests.testLaterSourceChangesDoNotAlterTheCurrentPermutation`がある。

追加：借用版owner生成後、元のInt配列の要素置換と要素追加を行い、最初と次のSpanが生成時入力の後続順であることを確認する。これは配列storage／並びの独立であり、参照型要素のdeep copyを要求しない。

## 今回追加を求めないもの

- 通常版・借用版には短い列挙の期待値、重複要素、終了後nil、入力種別の検査がある。組合せ全展開や乱数試験を今回の完了条件にしない。
- 通常版のArrayへの保存は列挙helperが各Viewを有効期間中にcopyし、後から全結果を比較している。保存の検査が皆無とはしない。
- 通常版のsourceからの独立、未開始・途中・完走後の解放、失効Viewがstorageを保持しないことは既存テストが担当する。
- 性能の再測定、Sequence採用、benchmark名整理、旧COW契約の復活、互換入口の削除は含めない。

## 引渡し

B〜Dを`PERM-078`の未発注候補として[依頼案](PERMUTATION_TEST_AS_SPEC_CLAUDE_DRAFT.md)に整理した。ClaudeのOPT-074終了・占有返却とAstra受入を確認してから、現行状態を再照合し、CLAUDE_TASKへ固定ID付きで依頼を用意して渡す。現行のClaude依頼は変更しない。AはPERM-051の再開判断を別途必要とする。

## 検証と状態

静的レビューと依頼準備は完了。コード変更なし、テスト実行なし。2026-10-15、ユーザーがコミットを許可。レビュー・依頼準備をDONEとして対応記録と同じコミットへ保存する。後続候補の作成はClaudeへの実行委任ではない。
