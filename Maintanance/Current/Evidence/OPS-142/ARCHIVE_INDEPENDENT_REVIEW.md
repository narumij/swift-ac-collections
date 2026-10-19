# Luna19件の独立レビュー

## TL;DR（人間向け）

重点2件の説明全文を対訳し、意味・条件・確度・経緯を変える実質的不一致は認めなかった。19件の構造照合では、日本語TLDR未追加1件、原著者区間の一部英訳2件、返却hash不整合1件を確認した。全19件の意味保証ではない。対象正本は修正していない。

## 範囲と方法

2026-10-19 / Sol A。再開割当R-20261019-01。原文は `/private/tmp/ops142-luna-archives-original-20261019/<repo-relative-path>`。ARCHIVE_TRANSLATION_RETURN.md、archive-completed.json、RESUME_20261019_HASHES.jsonと現在ファイルを照合した。

重点はElementBufferModule/CurrentQualityAssessment.mdとPermutationModule/RuntimeCheckedPermutationTestPlan.md。前者は全説明・表・結果・条件を原文と比較。後者は既に英語だった部分の原文保持、全翻訳差分、4原Returnの完全一致を確認した。他17件は構造・原文保存区間・参照の検査であり、説明全文の対訳ではない。検証のためにコードや製品テストを実行していない。新規一時控えは作らず既存原文控えを読み取り利用した。

## 指摘

### (A) 原著者Returnの一部が英訳されている

**Maintanance/Archived/Reviews/ELEMENTBUFFER_TEST_AS_SPEC_REVIEW.md:128–143**。原文99行から151行の `## 返却欄（Claudeが記入）` は、101行でClaude本人が署名した一つのReturn。現在は前半を保持する一方、元134–150行の `### 実行環境と結果` と `### 未実施・残る判断点` が英訳されている。原文の作業環境・実行報告・未実施・他者差分の申告もReturnの一部なので、本文説明とは分けて原文を保持する必要がある。ARCHIVE_TRANSLATION_RETURNの「explicitly attributed Claude return retained verbatim」と不整合。原文からの該当区間復元を提案する。今回修正なし。

### (B) Claude署名付き証拠台帳と返却記録の保全が不整合

**Maintanance/Quality/0.6.0-1/PermutationModule/DocumentationHandoffAudit.md:53–145**。原文 `## Public API ledger`（60行）、`## Test evidence matrix`（94行）、`## Naming and contract history`（132行）はそれぞれClaude署名付き成果。現状は導入・表・評価説明の一部を英訳し一部だけ原文保持している。著者名だけを理由に全書を除外する指摘ではない。Luna返却自身がこの3台帳を原文保存区間としているのに、実物が一致しない点を指摘する。明示生回答として区間を確定し、該当区間を原文保持するか調整担当が判断する必要がある。Codex intake/acceptance等の説明英訳はこの指摘と分ける。

付随して現在76–77行は `NextPermutationsSequence: Sendable where Base: Sendable` の後、次行に余分な先頭backtickがあり、以後のinline-code区切りを壊す。83行の原記号 `F<n>:<行>` も `F<n>:<line>` へ変わった。92行の “all six results for two elements, an ascending three-element input...” は2要素で6結果とも読める。原文は「2要素・昇順3要素の全6件・途中開始...4件」であり、6件は昇順3要素に係る。原区間を戻す場合は併せて解消される。重点2件外で偶然発見した局所指摘であり、本書全文の対訳レビューではない。

### (C) 日本語TLDRが未追加

**Maintanance/Archived/Canonical/RELEASE_0_5_3.md:1–6**。原題・生成日・Source template・起動方法から始まり、日本語TLDRも短い日本語要約もない。返却表の「Japanese TL;DR added」と不整合。task/checklistを保全しつつ、当時の結論と現在効力のない境界を日本語で追加する必要がある。

### (D) 返却表のafter hashが1件実物と異なる

DocumentationHandoffAuditの返却afterは `38b119b5faf93ce3326e1e9bc0e3b2fb9ce3bdd37c89817b570c6763687df959`、現在は `8f0858f7ba68066b1ed707de7f7523eb8c1a3139ab143be652dd7d03b37a339e`。現在hashはRESUME_20261019_HASHESの固定値と一致するため、停止後の他者変更とは断定しない。Lunaに納品記録を現状へ対応づけてもらう必要がある。原文beforeは一致。

## 重点対訳の確認内容

### ElementBufferModule/CurrentQualityAssessment

供用区分訂正と過去の除外判断、deprecated公開面削除、標準MutableRef移行、旧Viewと座標accessの証拠境界、BARE-036の当時不足と037/038受入後の解消を区別している。34+26、35+39、40+51等の異なる時点の件数を維持し、Swift6.4実行から6.2成功を推定していない。QR-01〜06の確認済み/未検証/部分確認、外部性能と一般利用Validationの不足、strict memory safetyと並行安全性の差を保持。性能測定の内外、exact-product shape、CI回帰と外部assessment、暫定chartと正式判定の差を保持。ユーザー介入時停止、分割・凍結・再開、7型@safe分類と個別member未決、最終Verificationの限定範囲も保持。上記説明対訳に実質的不一致は認めなかった。日本語taskカード・checklistは保全対象として区別した。

### PermutationModule/RuntimeCheckedPermutationTestPlan

旧38関数の行先、RETIRED12と後継G0〜G5、通常runtime-checkと借用compiler寿命の区別、View失効・非Sequence・非copy・copy保存禁止を保持。元から英語の計画部分は保持され、変更されたCodex基準点/053〜056受入の全説明を対訳確認。scratch成功が後継完了を示さないこと、Xcode再実行とCLI起動失敗、本人実行とCodex独立実行、23+1/33/40/44件、別AcCollections1件、compiler正常1/拒否3、CI登録は対象外、他task差分除外を保持。4つのClaude Returnは見出しから次の同階層見出しまで原文完全一致。追加の実質的不一致は認めなかった。

## 全19件の構造照合

- 原文控えSHA：19/19がLuna返却beforeに一致。
- 現在SHA：18/19がLuna返却afterに一致、19/19が再開固定hashに一致。
- 元見出し：全て同じ文字列・出現順・回数を保持。追加は18件のTLDR見出しのみ。元の重複見出し（BASE/HEAD、完了条件、問い/判定境界、Test evidence matrix、Changed files/Coverage/Validation/Not done）も順序と回数が変わらず、重複slug番号を変える新同名見出しはない。Markdown rendererによる実表示検証ではない。
- 日本語TLDR：18/19に存在。原文控えに既存TLDR区間はなく、複数段落の旧TLDR欠落はなし。RELEASE_0_5_3は不足。
- 元Markdownリンク先・blockquote行・fenced code：全19件で原文値を保持、code fenceは閉じている。外部URLの疎通や内容の再検証は未実施。
- inline code：通常識別子・commandは保持。RELEASE_0_5_0の数値range `0.5〜2.024` は同じ両端値へ分割されており意味損失とは認定しない。Handoffの記号変更・壊れた区切りは(B)。
- 原文保存：ARRAY_NAMING_REVIEWのClaude調査結果、Permutation最終提案の6回答欄、RuntimeCheckedの4Returnは完全一致。ELEMENTBUFFERのReturnおよびHandoffの署名台帳は上記例外。単なるClaude名を含む依頼/受入説明をraw Returnと誤分類していない。
- かぎ括弧の用語強調は複数英訳されている。これだけを引用改変と一律認定していない。明示された回答/原Returnは区間比較で判定した。

## 照合時hash

原文は上記baseに各pathを付けた位置。現在hashはこのレビュー時点の値であり補正後は更新が必要。

| path | source SHA-256 | reviewed current SHA-256 | Luna返却afterとの照合 |
| --- | --- | --- | --- |
| `Maintanance/Archived/Canonical/ARRAY_NAMING_REVIEW.md` | `f46de23806e2c07cf982847e86e44c7cd4d530ec03a2003f30a9503c48e64a1a` | `9da61509027d3e80ea01065598ebd4116723002a7978f4b54d1a621bb9f5eaf4` | 一致 |
| `Maintanance/Archived/Canonical/CHATGPT_ARRAY_NAMING_REVIEW_REQUEST.md` | `1bb6177679911476020f30ba4c92f26df96b2b09a9c711970dd5010d35158fc8` | `5a384038138ec4f0ab8cfd36bf5df9f972029b7b06e74ebe0048c83dc2f7fdb3` | 一致 |
| `Maintanance/Archived/Canonical/CODE_SNIPPET_SURVEY.md` | `9ed14765569f436adf43953f9222e5832cb67a017f752069605a02de848fffa6` | `489a30381d7dcaac60dacd7e57774dc0207917d39a32ce5071bbbb7c0d6d28ab` | 一致 |
| `Maintanance/Archived/Canonical/NON_RBT_COMMENT_DOC_SELF_REVIEW.md` | `afdc709484fd3641870adca5deef06c2f3eb4d672f1eb5026b9fe566a54c23b5` | `ca0f2398b9659e86c3db1b73e01efcd49e7ed563bc444428577bb9343f831c3e` | 一致 |
| `Maintanance/Archived/Canonical/PERFORMANCE_REGRESSION_ASSEMBLY_ANALYSIS.md` | `c424a40b64df9ff4274db037e832123f68c53b7ccb7111039a134a84f2ae0cb4` | `df1ae2c561aff0e1f05e190bd2d1e3a78d8d3d5c9fb6017bd2bc5fa9532a1a9c` | 一致 |
| `Maintanance/Archived/Canonical/PUBLIC_API_CODE_SNIPPET_SURVEY_2.md` | `aa7771260c00bbb3ebd13c362ecec83d7c4568475d2f2ce55881581d560d30bb` | `3e4ed1cc4ec67fa6c95c6fc8a8bbd6e7b90f99fb2f09e1373f1683ba5b6f1780` | 一致 |
| `Maintanance/Archived/Canonical/RELEASE_0_5_0.md` | `e6fee066dd9d5cc0c1cde00eb4163d7f005302cfd2a4d1fb2a46d9877caa4e6c` | `ee5dd789f88960c297f53533b311aaa2c3f165e9a62cd1e0c137f0018253bf99` | 一致 |
| `Maintanance/Archived/Canonical/RELEASE_0_5_1.md` | `fe62f953e350328ad51897cc3b5afdba5660d8d345851c06c6c8917a0c34c292` | `96940d89938d0aa2b77523cdd3799ac9f0d78371981a325acad067cbf2b66b47` | 一致 |
| `Maintanance/Archived/Canonical/RELEASE_0_5_3.md` | `19591246f2b9d7c991404ae5ecdfbd30c1851d7477bdc7e71f27953076e9cbe9` | `f55e1a92dd906bd38f5c4b9e9b4be37db9ad960a47713fd12ede0f2e6de3efde` | 一致 |
| `Maintanance/Archived/PublicAPINaming/PUBLIC_API_NAMING_ROUND2_REPORT.md` | `27cf3358050ad90598b7d34a0f57625b7fc37edb578c517471906656bda6c14a` | `c5595a755422f612adfc2c4018689875bf790fe03f24d5ea29679d017f48698f` | 一致 |
| `Maintanance/Archived/PublicAPINaming/PUBLIC_API_NAMING_ROUND3_REPORT.md` | `a04639341e73f617269d4b855ffa450ec38614539910660e448552a8324189fc` | `1df853b80aa4e49e906d78790e44b9180604427c162a225b25936cb96a82ceaa` | 一致 |
| `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_FINAL_PROPOSAL.md` | `fae21d16659ba4e21ddeedcbc2177b596415577ac8d4427cd9929a7e627ae30b` | `fa56ad761c8581997d3fbaaea8f99dc0422954923fa393dcf31fe7d42895a669` | 一致 |
| `Maintanance/Archived/QUALITY-004_EXCLUDED_2026-10-16.md` | `c0c1713d3071c731820331ac9eeacd89a1dc5fc894ad356420405169e0514d7d` | `e5170104371b2defe1e351247431848556b6ee5ef7a6391a8dba7e18e229e5c3` | 一致 |
| `Maintanance/Archived/Reviews/ELEMENTBUFFER_TEST_AS_SPEC_REVIEW.md` | `5f5d30bc9adaa000ee28c9b18d5182844dda84ce4e9da8489846166bce0f660d` | `2b7ca70795c53765aa9866d3b56ef2c7c29a057ad829f2e7d349cb724ba79257` | 一致 |
| `Maintanance/Quality/0.6.0-1/ElementBufferModule/CurrentQualityAssessment.md` | `c9e66d9d4c2ae337f7bc5c8d006fd859fc43eb4cb7960b0b81fcb9a3e9073dbc` | `bc0d6905272e4c8ca741bc475f92b252d547280c91c32a1ecab8aa06b99644a3` | 一致 |
| `Maintanance/Quality/0.6.0-1/ElementBufferModule/GeneralSwiftValidationScenario.md` | `e32dcce75f1fe48e849d4078c5e9ebbaa298c131fd59c82b639ddd9c3451d108` | `4083d5a3a510f215e9210301f961dd781056a405cfea363b5bc4655dc9d9444d` | 一致 |
| `Maintanance/Quality/0.6.0-1/PermutationModule/DocumentationHandoffAudit.md` | `cd4627a2f3ac370040ff8de2d245b5c6132767f525f791670a88ab7eb1408c80` | `8f0858f7ba68066b1ed707de7f7523eb8c1a3139ab143be652dd7d03b37a339e` | 返却after不一致・再開固定hash一致 |
| `Maintanance/Quality/0.6.0-1/PermutationModule/RuntimeCheckedPermutationTestPlan.md` | `9c9969c2eb8b9b7856972e3b1d4f6c5ee23ac7d3af6642940fe948befb084e02` | `ab9859bee2f300d5cd9b8601f949fad7c74d094e4633b78cbd5357a4085ce0a0` | 一致 |
| `Maintanance/Quality/0.6.0-1/QUALITY_ASSESSMENT_INVENTORY.md` | `8a75634664e6e2935a866dec93d7d4ee5a202c95f0f8733bf82a3b1645b53128` | `6e5e670d4bc016832dc2c270c3489a200c93ad019c72b520bc8335cc07687147` | 一致 |

## 返却と制限

対象正本は未修正。19件全体の意味同等性・全過去事実の真偽・全品質の成功を保証しない。上記例外を調整担当へ返す。stage/commitなし。
