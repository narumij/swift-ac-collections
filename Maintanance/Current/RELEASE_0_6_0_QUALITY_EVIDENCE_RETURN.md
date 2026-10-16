# 0.6.0品質証拠の適用範囲 — Claude返却欄

RELEASE-081 / 返却済み。依頼本文はCLAUDE_TASK.mdのRELEASE-081節。

2026-10-16夜 / Claude（姫）。比較は`0.5.3`（`139ffef8`）..`8a0c8769`をGitから読んだ。作業ツリーの並行変更は混ぜていない。固定入力3件のSHA-256は依頼記載と一致した（`853ad5c8…`・`cb1046aa…`・`0d6fb9e5…`）。テスト実行、`.build`操作、製品・Tests・CI・Registryの変更、commitはしていない。

## 要点（事実）

1. **全体を通したCI証拠はPR #196 head `4cd0ebc2`（2026-10-15）が最後。**
   - 記録はAstraのPermutation移行受入（`Archived/PermutationMigration_2026-10-16/PERMUTATION_MODULE_MIGRATION_ACCEPTANCE.md`）。
   - Linux（ubuntu-24.04）で、debug・release・address-sanitizer・performance・documentationと対象別DocC 6件の、全11 jobがsuccess。
   - `ci.yml`は既定traitで、death test・Optional trait・互換構成のいずれも含まない。Linuxでは`DEATH_TEST`は`ENABLE_DEATH_TESTS` traitがないと無効（`Package.swift`）。
2. **`4cd0ebc2`..`8a0c8769`の製品コード差分（コメント・文書を除く）は2件だけ。**
   - a. `31aa2f07`：赤黒木4型の範囲`erase(_:where:)`で、predicateのエラーを`fatalError`にせず呼出元へ伝える修正。範囲の検証失敗だけが停止する。
   - b. `35a27b30`：`Package.swift`から`exclude: ["Fixtures.md"]`を削除。`Fixtures.md`は`Maintanance/Testing/`へ移動済みで、`8a0c8769`のTests配下にはない。
   - ほかは、文書コメント、DocC、test追加（RBT-043〜046、RBT-047の調査test）、`.github`（`2d32f71c`の候補コメントCI追加）。
3. **ElementBuffer・OptionalElementBuffer・NextPermutationは、`4cd0ebc2`以後に製品コードが変わっていない**（コメントとDocCだけ）。PR #196のCIは、3moduleの現行コードをLinuxの既定構成で通したと言える。

## module別

| 対象差分（0.5.3..8a0c8769） | 証拠と版 | 再利用範囲 | 追加確認案 | 残る判断 |
| --- | --- | --- | --- | --- |
| **RedBlackTreeCollections**：<br>実装は`31aa2f07`の1件だけ（4型×範囲erase）。<br>ほかは型コメント・文書（DOC-034）とtest追加。 | ①36f821a4（10-15、macOS、Swift 6.4）：Debug・Release全体、通常death test、ASan本体（DeathTests除外）、DocC。<br>②`31aa2f07`後、Astraがローカル実行（macOS）：Debug XCTest 944＋Swift Testing 133、Release 747＋120、修正前に8件失敗→修正後に成功。<br>③DOC-034/035：78例compile/run、Release DocC（f6e181b2・8a0c8769）。<br>④PR #196 CI（`31aa2f07`より前）。 | ①④は`31aa2f07`の前なので、範囲eraseの新しい挙動は保証しない。<br>②はmacOSのDebug・Releaseで、修正と既存testを保証。<br>Linux・ASanでの`31aa2f07`は未確認。 | ・`8a0c8769`の既定Linux CI（debug/release/ASan）を1回。<br>・互換構成のbuild（`31aa2f07`の変更は互換では条件付きで除外される）。 | ASan＋death testの併用は検証経路が未成立（RBT-033の調査結果）。0.6.0の必須にするかはユーザー判断。 |
| **NextPermutationModule**（旧PermutationModuleは互換入口）：<br>`1f87e37a`でmodule移行。実装はgeneric名`Value`→`Element`とtypealias整理のみ（Astra照合）。 | ①PERM-076受入（macOS）：通常61・death 17、compiler診断fixture、互換構成で4正常target build、新旧module同時import、両moduleのDocC。<br>②PR #196 CI（11 job success）。<br>③DOC-035：Release DocC、例4出力一致。 | 製品コードは`4cd0ebc2`以後変わっていないので、①②をそのまま再利用できる。 | なし（`8a0c8769`のCI 1回で、他moduleの確認と兼ねればよい）。 | candidate CIの経路は未実行（PERM-076記録）。 |
| **ElementBufferModule**（BareArrayから改名）：<br>旧View面の削除、MutableRef契約、`reference(at:)`をSwift 6.4以降に限定（`1a096818`）。 | ①CurrentQualityAssessment：BareArray名の時点でDebug・Release・death test・ASan・compiler fixture、外部consumer（`693b1bab`）。改名後の記録は「移行後に対象7件、compile-pass／fail」。<br>②PR #196 CI。<br>③DOC-035：Release DocC、値アクセス・借用更新の例を実行。 | 改名・`1a096818`後の製品コードは②③で通っている。<br>①の多くは旧名・旧面の記録。 | ・**Swift 6.2でのbuild**。供用区分では「Swift 6.2は1.0競技供用」だが、manifestは6.4必須（`swift-tools-version: 6.4`）。`#if swift(>=6.4)`分岐の6.2側を通した証拠は見つからなかった。<br>・座標access APIの直接仕様test不足（Assessmentの「未検証」4行）は、0.6.0の範囲かどうか判断が要る。 | 6.2供用の扱い：manifest 6.4必須のまま0.6.0を出すなら、6.2はこのpackageでは使えない。どう書くかはユーザーとAstraの判断。 |
| **OptionalElementBufferModule**（OptionalArrayから改名）：<br>trait opt-in（`314f45e0`）、文書整備。 | ①CurrentQualityAssessment：Debug・Release・ASanで通常35／death 26、DocC、外部consumer（`215be94b`）。<br>②PR #196 CI（既定構成）。<br>③DOC-035：trait有効の`AcCollections` build、例の実行。 | 製品コードは`4cd0ebc2`以後変わっていない。<br>ただしCIは既定構成なので、traitを有効にした再公開経路はCIで通っていない。③はmacOSのローカル。 | ・`--traits ENABLE_OPTIONAL_ELEMENT_BUFFER`でのbuildとfacade test（Linuxで1回あればよい）。 | 実験提供・留保付きの区分はそのまま。 |

## CIの保存証拠（依頼3）

- 直近の候補SHA（`8a0c8769`）のCI成功は**未確認**。保存された証拠がない。
- 候補コメントCI（`2d32f71c`で追加）の過去runは、performanceとreportが失敗（run 38765855176、`RELEASE_CANDIDATE_COMMENT_CI.md`）。ユーザーが解決済みと確認し、RELEASE-080はEXCLUDEDになった。ただし、新しい成功runの保存証拠は見つからなかった。**未確認**とする。

## 追加確認案（提案、最小）

1. `8a0c8769`（または採用する候補SHA）で既定CIを1回通す（debug・release・ASan・documentation）。`31aa2f07`をLinuxで通す唯一の手段で、他3moduleの再確認も兼ねる。
2. 互換構成（`-Xswiftc -DCOMPATIBLE_ATCODER_2025`）でbuildとtestを1回。参考までに、姫がRBT-047（`f6e181b2`＋同じ調査test、ソースは`8a0c8769`と文書コメント以外同一）で互換構成のbuildに成功している。ただし実行したのは調査test 3件だけで、全体suiteではない。
3. `ENABLE_OPTIONAL_ELEMENT_BUFFER` trait付きでbuildとfacade test。
4. Linuxで`ENABLE_DEATH_TESTS` trait付きのdeath test。`31aa2f07`でdeath testが4型×60行増えたが、Linuxで走った記録はない。必須にするかは判断事項（下記）。

## 昇格させないもの（依頼4）

- RBT-048（失敗時CoWの修正方針、ユーザー預かり）、凍結中の並行初期化、0.7/0.8/1.0の課題は、ここでは必須条件にしていない。
- 対象版を止める根拠になる事実は見つからなかった。ElementBufferのSwift 6.2供用の書き方だけは、release前に表記を決める必要があると考える（提案）。

## 未確認・限界

- performanceの結果（PR #196ではsuccess）を、性能水準の合格としては扱っていない。
- Quality/0.6.0-1は前回一周の資料で、対象版の合格証明ではない（RELEASE-078の記載どおり）。
- 証拠は依頼の入口から辿れた範囲だけ。個々のtest追加の受入記録（RBT-043〜046）までは、件数を照合していない。
- ASan＋death testの併用は、macOSでもLinuxでも成立した証拠がない。

作業終了。範囲を解放する。
