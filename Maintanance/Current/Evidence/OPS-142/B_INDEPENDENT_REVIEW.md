# Sol B 独立受入補助

## 対象と方法

2026-10-19 / Sol A。B_TRANSLATION_RETURN、原文控え `/private/tmp/OPS-142-CURRENT-B-SOL-20261019/original`、final_validation.jsonと現在ファイルを独立照合。ASAN_DEATH_TEST_INVESTIGATION、CANONICAL_EVIDENCE_ROLLOUT、REGISTRY_STUDIO_SAVE_CONTRACTの説明全文を原文対訳比較した。他25件は構造・保存検証であり、全28件の意味を保証しない。対象本文は修正していない。

全28件の原文・納品SHAは記録値に一致。原題、元リンク先・inline code・引用値の存在を確認。独立検出した原著者区間36ブロックは原文そのまま存在した。Bの44区間という検出数すべてを独立再算定したとはしない。重複表現の回数まで同一とは要求・認定していない。独立機械照合の中間記録は `/private/tmp/OPS-142-A-20261019/b-review-structural.json`。

## 指摘（補正前の行番号）

1. **SAVE_CONTRACT:83 / 意味** — 原文控え71行「部分反映と保留」が “partial/refused items” となる。保留は拒否ではない。`partial application and deferred items` 等へ補正が必要。
2. **PERMUTATION_PERFORMANCE_GAP_REVIEW:5 / 日本語要約の欠落** — 原文7行の第2段落「この完了は、調査を実施した・性能が改善したという認定ではありません。再び測るときは対象版・範囲・担当を定め直します。」が欠落。本文に英語の制限が残っても、日本語TLDR保存条件を満たさない。
3. **PERMUTATION_SEQUENCE_INVALID_VIEW_ISSUE:5 / 日本語要約の欠落** — 原文7行「通常公開型はSequence非準拠なので、製品全体のバグ確定や修正完了にはしません。実験アダプターの扱いはPERM-081へ引き継いでいます。」が欠落。
4. **Maintanance/Graph/AI_GRAPH_SHARED_SCHEMA.md:133,170 / 旧アンカー** — 原文の重複見出しによる `3-provenanceとconfidence-1`、`5-rbt-017最小fixture-1` が失われた。先行見出し英訳で自動slugの重複番号が変わるため、元見出し文字列の存在だけでは保持を証明できない。該当する保存原文見出し直前へ明示aliasを足す必要がある。

## 重点3件の意味照合結果

ASAN_DEATH_TEST_INVESTIGATIONは最小package3例、失敗対照、内部原因未確定、strip_env追加証拠と未再実行、Linux/製品全体未確定の境界を保持。追加の実質的不一致を認めなかった。

CANONICAL_EVIDENCE_ROLLOUTは4巡、76→77訂正、内訳合計、途中ACTIVEと最終DONE、優先レビューと全依存確認の差、J2/J9/J10/J12撤回と限定受入を保持。5つの独立原文区間も完全一致。追加の実質的不一致を認めなかった。

SAVE_CONTRACTは上記保留の誤訳を除き、S1〜S6、通常保存とcrash/networkの限界、保存/取込区別、部分処理と全体完了、固定証拠表と未確定範囲を保持。新たな実行検証や過去事実の実証はしていない。

## 返却

上記は補正前状態へのレビュー。修正はSol B/Astraへ委ねる。stage/commitなし。
