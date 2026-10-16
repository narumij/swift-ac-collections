# 赤黒木4型ドキュメント独立レビュー依頼

2026-10-16、作成・受入担当Astra。ユーザーよりClaude（姫）へのレビュー委任。DOC-034配下の5件を一括依頼する。本書と入力は依頼票完成時に固定。未コミット作業ツリーが入力で、HEADだけを対象版とみなさない。

## 仕事と順序

| ID | 対象 | 返却先 |
| --- | --- | --- |
| DOC-040 | RedBlackTreeSet | [DOC-040_DOCUMENT_REVIEW_RETURN.md](DOC-040_DOCUMENT_REVIEW_RETURN.md) |
| DOC-041 | RedBlackTreeDictionary | [DOC-041_DOCUMENT_REVIEW_RETURN.md](DOC-041_DOCUMENT_REVIEW_RETURN.md) |
| DOC-042 | RedBlackTreeMultiSet | [DOC-042_DOCUMENT_REVIEW_RETURN.md](DOC-042_DOCUMENT_REVIEW_RETURN.md) |
| DOC-043 | RedBlackTreeMultiMap | [DOC-043_DOCUMENT_REVIEW_RETURN.md](DOC-043_DOCUMENT_REVIEW_RETURN.md) |
| DOC-044 | 4型横断 | [DOC-044_DOCUMENT_REVIEW_RETURN.md](DOC-044_DOCUMENT_REVIEW_RETURN.md) |

型別4件は独立。推奨順はSet→Dictionary→MultiSet→MultiMap。4件の返却記録を揃えたら、Astraやユーザーの中間返答を待たず最後の横断へ進んでよい。1型で疑義が出ても、他型の独立した照合は進められる。公開契約の決定が必要な箇所だけ未決として返す。5件を一括返却する。

## 固定入力と入口

[照合結果](RED_BLACK_TREE_OUTLINE_AUDIT.md)、[本文作業記録](RED_BLACK_TREE_DOCUMENT_COMPLETION.md)、[SHA-256一覧](Evidence/DOC-033-2026-10-16/review-inputs.sha256.json)。一覧はrepository直下基準のパス。開始前に照合し、不一致の入力を使って続行せず差分を返す。RegistryとRulesは作業状態・権限の確認用で固定入力ではない。

各型のoutline・日英本文・型コメントを読み、必要な実装と `Tests/RedBlackTreeTests/` のTest as Specへ直接照合する。過去アーカイブを一括で読む必要はない。検証証拠は `Evidence/DOC-033-2026-10-16/`。Astraの説明やテスト通過を正しさの代替にしない。

## 確認内容

1. outlineの全項目が説明されているか。整理で必要な内容を落としていないか。一般論を製品の契約として書いていないか。
2. Index・Bound・CoW・View・無関係index・削除後の世代・範囲終端が現行実装とTest as Specに合うか。Viewを別変数へ取り出す場合と直接subscript変更を区別できるか。
3. 型固有の点：Setの一意性と集合演算、Dictionaryのdefault/重複初期化/merge、MultiSetのupdate・多重度演算、MultiMapのhint/値View/pair View/erase(exactly:)。
4. 計算量の成立条件、CoW・比較・クロージャの追加費用が正確か。性能を測定済みと誤認する表現がないか。
5. 日英・公開型コメントの意味が一致するか。本文にしか元々ない例が型コメントにないこと自体は違反ではない。実行可能例と宣言・型制約断片の区別、例の文脈と期待値を確認。
6. 最後の横断では、同じ契約の表現差と意図した型差を分け、同じ指摘を重複増殖させず共通修正候補をまとめる。

必要な対象テストを追加実行してよいが、既存結果を理由なく全再実行しない。作業物はCOMMONSに従って記録する。新規テスト・製品コード変更は今回の範囲外。

## 編集範囲と停止点

編集できるのは自分の5返却ファイルのみ（任意のCLAUDE_OBSERVATIONS追記の常設委任は別途有効）。本文・outline・ソース・Registry・Rules・本依頼・証拠の原文は編集しない。誤りは根拠と最小修正案として返す。0.6.0の既存スニペット追加・削除禁止を維持する。拡充候補は0.8.0と区別する。公開契約、構成上の新方針、製品修正を独自に決めない。

この依頼ではcommitしない。ユーザーが後で明示許可した場合は、その許可対象と本制限の変更範囲を返却に一言記録してから従う。実施報告とAstraによる代理検収、DOC-037のユーザー受入は別。依頼票の完了だけで受入済みにはしない。

## 完了条件

各型について確認範囲・根拠・指摘（なければその旨）・最小修正案・未確認を返す。横断結果は公開阻害/技術訂正/任意改善を分ける。見た範囲だけを保証し、合意獲得を目的にしない。Astraが返却を検証し、DOC-034の修正・検証へ統合する。
