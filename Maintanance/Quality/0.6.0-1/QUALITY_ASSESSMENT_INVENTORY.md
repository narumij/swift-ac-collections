# 品質評価棚卸し

2026-10-15、ユーザーの依頼により、四対象の品質課題の抽出結果を本書へまとめ、品質評価棚卸しtaskの詳細正本とした。

## 今回の記録として保持（2026-10-16）

ユーザー判断により、本書を最新状態へ追従させ続ける仕事は整理し、QUALITY-004をEXCLUDEDとした。以下は初期棚卸しの記録であり、現行task状態や新しい対象版の品質判定として使わない。次の品質試験で、その時点の実装・提供方針・証拠から改めて棚卸しする。個別課題はそれぞれの現行正本で扱う。[整理前の行と依存辺](../../Archived/QUALITY-004_EXCLUDED_2026-10-16.md)を保存した。

本文には後発判断が未反映の箇所がある。特に「最速80msのunsafe枝は製品候補から除外」はユーザーから誤りを指摘された記述であり、現行の製品判断の根拠に使わない。ASan調査や旧taskの除外・引継ぎも、本文の初期記録から現在状態を推定しない。今回の整理は、それらの技術課題の再検証・解消ではない。

## Taskと本書の役割

- Task: `QUALITY-004`
- 種別: `DISCOVERY`
- 担当: Codex
- 今回の目的: 評価を一巡した四対象について、現在残る品質課題、証拠の不足、契約の未確定、記録の不整合を区別し、既存taskとの対応と未充当部分を明らかにする。
- 状態・委任・開始条件の正本: [Task Registry](../../ProgressV2/TASK_REGISTRY_V2.md)。本書に状態表を複製しない。

本書は棚卸しの範囲、初期結果、根拠、完了条件を管理する。上位の[品質要求](../QUALITY_REQUIREMENTS.md)、
各moduleの契約・品質評価、既存taskの状態を置き換えない。本書の正本化は、個々の品質課題の解決方式、
実行順、許容するリスク、1.0採用を決めるものではない。

## 対象と基準

初期結果は2026-10-15、HEAD `209ebefaf5c040fc2789c81f7052ff3a65ec621f`の記録と現物を照合して作成した。
赤黒木の直近評価は`fa1f3718`に保存され、検証対象commitは`36f821a4`である。他の対象の証拠時点は、
それぞれの評価記録に従う。異なる時点の評価を、全対象の同一版に対する適合証明とは扱わない。

| 対象 | 現行の提供区分 | 評価の起点 |
| --- | --- | --- |
| RedBlackTreeCollections | 1.0提供対象 | [現行品質評価](RedBlackTreeModule/CurrentQualityAssessment.md) / [品質プロファイル](../Profiles/RedBlackTreeCollections.md) |
| NextPermutationModule（旧PermutationModule互換入口あり） | Swift 6.4以降の1.0提供対象 | [現行品質評価](PermutationModule/CurrentQualityAssessment.md) / [品質プロファイル](../Profiles/NextPermutationModule.md) |
| OptionalElementBufferModule | traitで明示的に有効化する、留保付きの実験的提供 | [現行品質評価](OptionalElementBufferModule/CurrentQualityAssessment.md) / [品質プロファイル](../Profiles/OptionalElementBufferModule.md) |
| ElementBufferModule | 1.0提供対象。Swift 6.2は1.0競技供用、Swift 6.4は1.0一般供用（2026-10-15ユーザー訂正） | [現行品質評価](ElementBufferModule/CurrentQualityAssessment.md) / [品質プロファイル](../Profiles/ElementBufferModule.md) |

品質評価の一巡は、確認済みと不足を整理した到達点である。全品質要求の充足や公開可能な文書の完成を意味しない。
実験提供・保守対象にも、実際に利用する範囲の正確性、メモリ安全性、要素寿命、build・test可能性は必要である。

## 棚卸しの進め方と範囲

1. 開始時の対象版と提供方針を確認し、上記の評価、品質プロファイル、実装・test・CI・受入記録を必要な範囲で照合する。
2. QR-01〜QR-06について、確認済みの範囲、未達、未検証、契約未確定、記録不整合を区別する。反証は、その成立条件と実際に示した範囲を残す。
3. 各課題を既存taskへ照合し、既存taskで扱うもの、記録の同期が必要なもの、対象外・不要となったもの、既存taskで扱う範囲が未確認のものへ整理する。
4. 記録不整合は、決定の根拠と訂正先を示す。追加の調査・実行・ユーザー判断が必要な場合は、何を閉じる仕事かを分けて返す。

棚卸しでは、文書・コード・保存された証拠の照合を行う。新しい測定やtest実行が必要と分かった場合は、
必要な対象と理由を残す。個別製品の修正、公開契約・提供方針・性能水準の採用、利用者への接触、
競技提出、凍結解除、他の正本の一括修正は含めない。全protocol・構成の組合せを先に展開しない。

既存taskとの対応は参照関係であり、すべてが本taskの必須前提になるわけではない。個別課題を解決せずに、
未解決の理由と根拠を棚卸しできる。現時点で追加すべき必須依存辺は確認していない。

## 初期棚卸し結果

以下は今回抽出した主要課題であり、品質全体の網羅性を確定した一覧ではない。固定task IDを新設する
単位でもない。関連taskの現在の状態はRegistryを参照する。

### (A) 安全性と公開契約

| 参照 | 対象・課題 | 現在の根拠と区分 | 棚卸しで明らかにすること | 関連する既存task・根拠 |
| --- | --- | --- | --- | --- |
| (A-1) | OptionalElementBufferの`Sendable`と並行更新の整合 | 同一instanceを共有borrowして並行更新するコードをcompilerが拒否しない反証がある。実際のdata raceを実行確認した証拠とは区別する。適合の成立根拠は未確定 | 現行opt-in提供で認める利用と、安全性を支える根拠の対応。一般提供方式の将来調査へ送る部分との境界 | `OPT-072`は一般提供方式の調査であり、現行実験提供の論点をすべて引き受けるとは限らない。[Sendable調査・提供方針](OptionalElementBufferModule/CurrentQualityAssessment.md) |
| (A-2) | 赤黒木のIndexと公開APIの最終範囲 | 公開Index表現・`Comparable`採否は外部条件待ち。Debug限定の比較宣言・診断用APIの処遇も未確定 | 現在の保証、外部条件に依存する判断、構成間の公開面の差を分ける。完了済みの`Result`整理を復活させない | `RBT-001`・`RBT-010`・`RBT-011`・`RBT-004`。[外部所有型Extension監査](../../Current/EXTERNAL_TYPE_EXTENSION_AUDIT.md) / [API Matrix](../../../Sources/RedBlackTreeCollections/Documentation/API-Matrix.md) |
| (A-3) | 赤黒木・両Bufferの構成別安全性保証 | 赤黒木のstrict memory safety全面適用は保留。両Bufferの並行利用と`-Ounchecked`に未検証範囲がある。赤黒木の並行利用は既に外部同期を要求する契約 | 既に保証対象外とした操作と、保証対象なのに証拠がない操作を分ける。未適用だけで製品不具合とは判定しない | `RBT-007`・`RBT-008`・`RBT-009`。両Bufferについては既存taskの対象範囲との対応を確認する。[strict適用記録](../../Current/StrictMemorySafetyReadiness.md) / [赤黒木の検査契約](../../../Sources/RedBlackTreeCollections/Documentation/Design/Design-RuntimeChecks.md) / [ElementBuffer評価](ElementBufferModule/CurrentQualityAssessment.md) |

### (B) 検証証拠

| 参照 | 対象・課題 | 現在の根拠と区分 | 棚卸しで明らかにすること | 関連する既存task・根拠 |
| --- | --- | --- | --- | --- |
| (B-1) | 赤黒木のASan下の停止契約 | 通常Death Testと、process-exit系2 suiteを除いたASanは成功。両者を組み合わせる経路は子プロセスのruntime注入で失敗しており、当該構成は未検証 | 製品不具合と検証経路不成立を分け、未検証の契約・構成と必要な切り分けを特定する | `RBT-033`。[評価と反証](RedBlackTreeModule/CurrentQualityAssessment.md) / [保存された証拠](RedBlackTreeModule/Evidence/RBT-032-2026-10-15/README.md) |
| (B-2) | Permutation借用版の寿命検証を継続実行する証拠 | runtime test 25件は成功。compile-pass／compile-failは一時clientの結果で、repository内の再実行可能なfixtureが不足 | 既存結果を保ったまま、寿命契約のどの検証を再実行できる形にする必要があるかを特定する。通常版G0〜G5の未完成とは扱わない | `PERM-051`。[借用版の計画と返却](PermutationModule/BorrowedPermutationTestPlan.md) / [現行証拠の区分](PermutationModule/CurrentQualityAssessment.md) |
| (B-3) | 赤黒木・Permutationの外部性能主張 | 回帰証拠や比較測定はある。Permutationには特定workloadでC++比約1.08〜1.12倍の測定があるが、製品の外部性能判定は未完 | 対象操作・入力・構成・現行契約・比較相手・受入水準と既存証拠を対応づけ、不足だけを特定する。C++との挙動比較を性能証拠にしない | Permutationは`PERM-043`・`PERM-044`。赤黒木は対応する評価範囲を確認する。[Permutationの測定記録](PermutationModule/CurrentQualityAssessment.md) / [赤黒木の性能証拠境界](../Profiles/RedBlackTreeCollections.md) |
| (B-4) | 提供対象の環境宣言と実証 | 暫定方針はApple platforms 27以降・64-bit Linux。現行manifestのplatform宣言はmacOS 15で、方針反映と環境別証拠は別taskに残る | 提供区分ごとに、宣言・導入・build・実行の確認済み範囲と不足を分ける。Linux CIの既存成功を「未実施」へ戻さず、要求する証拠との差を示す | `QUALITY-002`・`QUALITY-003`。[提供環境の方針](../QUALITY_REQUIREMENTS.md) / [manifest](../../../Package.swift) / [candidate CI](../../../.github/workflows/candidate.yml) |

### (C) 利用目的と記録の現在性

| 参照 | 対象・課題 | 現在の根拠と区分 | 棚卸しで明らかにすること | 関連する既存task・根拠 |
| --- | --- | --- | --- | --- |
| (C-1) | 主に赤黒木・Permutationの利用理解と公開文書 | 三対象の本文ドラフトは受入済み。公開可能な初版の完成や、設計非参加者が正しく使えることとは別。Permutationの一時View・失効・保存時のcopyの理解は未検証 | 作成済み本文、公開準備、契約との整合、利用理解の実証を分ける。赤黒木の文書準備とValidationの対応範囲も確認する | `PERM-062`・`RBT-014`・`RBT-026`。後二者は文書準備・契約判断であり、Validation全体の割当ではない。[Permutationの試行設計](PermutationModule/GeneralSwiftValidationScenario.md) / [赤黒木の文書workflow](../../Current/DOCUMENTATION_WORKFLOW.md) |
| (C-2) | OptionalElementBufferの競技用途への適合 | EDPC例のcompile証拠はあるが、正答・時間・memoryを含む利用結果の証拠が不足 | 現行実験提供の用途に対応する試行対象と証拠の不足を整理する。別moduleや別実装の提出結果を代用しない | `OPT-065`。[利用Validationの設計](OptionalElementBufferModule/GeneralSwiftValidationScenario.md) |
| (C-3) | 全体の評価表に残る古い未実施表現 | 本文ドラフト、DocC継続生成、Permutation実提出など、完了した仕事が一部の評価表では未実施に見える | 旧記述、後発の完了・判断の根拠、現在の適用範囲、訂正先を対応づける。歴史的な評価を消さず、現在の評価と分ける | 本taskの横断整理対象。[DocC継続検証](../../Current/DOCUMENTATION_CI_PLAN.md) / [10月13日の完了記録](../../Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-13.md) / 各moduleの現行品質評価 |

## 完了済み・対象外とするもの

- 赤黒木の0.6.0現行品質評価は完了し、環境・依存・選択条件・完全logを保存済み。ASan＋Death Testの未検証を理由に、この評価taskを未完了へ戻さない。
- 三対象の利用者向け内部本文ドラフトは2026-10-13に受入済み。公開可能な初版とは区別する。
- DocCのmodule別継続生成は実装され、remote実行結果もある。「生成経路がない」という課題へ戻さない。non-blockingからrequiredへの移行や公開品質の扱いは、[現行計画](../../Current/DOCUMENTATION_CI_PLAN.md)の境界に従う。
- PermutationのABC328E実提出探索は`PERM-002`として完了済み。最速80msのunsafe枝は製品候補から除外されており、現行安全契約の製品性能へ転用しない。
- OptionalElementBufferの固定外部性能比を決めて正式評価する旧taskは、実験提供への限定により除外済み。一般提供方式の再設計は別の凍結調査である。
- OptionalElementBufferの過去の`mutating`化による性能回帰を、nonmutatingへ戻した現行版の不具合としてそのまま計上しない。現在の性能保証とは別に、測定時点を保存する。
- ElementBufferの評価を「1.0提供対象外」のため不要とした整理は、2026-10-15のユーザー訂正で失効した。Swift 6.2の1.0競技供用とSwift 6.4の1.0一般供用を分け、用途ごとの証拠と未検証範囲を扱う。旧taskの除外・凍結を自動解除せず、評価済みとも扱わない。設計理由と定性的性能表現の判断は[品質プロファイル](../Profiles/ElementBufferModule.md#供用区分と設計判断)を参照する。
- 次元名体系の再判断、旧公開Viewの監査、完了済みのTest as Specification整理を、古い記述だけから復活させない。

## 完了条件と成果

1. 四対象のQR-01〜QR-06について、現在の提供区分と評価時点に照らした課題・不足が整理され、未確認の棚卸し範囲も明記されている。
2. 各課題から、品質上の主張、対象構成、根拠、反証・未検証の範囲、および関連する既存taskへ辿れる。
3. 対応済み・不要・対象外の事項と、現在残る課題が区別されている。記録不整合には訂正根拠と訂正先が示されている。
4. 既存taskへ対応するものと、対応範囲が不足・未確認のものが分かる。必要な後続候補は調査・実行・一つずつのユーザー判断を分け、無条件に採番・着手しない。
5. 本書の棚卸し結果と要点を返却し、Registryへ完了範囲を記録できる。個別課題の解消や1.0採用を、本棚卸しの完了条件に含めない。

成果の更新先は本書とする。他の正本への訂正は、根拠と変更範囲を明らかにしたうえで委任された範囲で行う。
実際の不足量と波及範囲を確認する前に、全課題の実行順や全後続taskを確定しない。
