# スニペット候補アンケートのサルベージ

2026-10-16 / Astra。ユーザーの依頼で、2026-10-10のアンケート2回分を利用者文書の準備資料として回収した。
恒久task **DOC-030（文書整備）** に紐付ける。運用の入口は[DOCUMENT.md](../../DOCUMENT.md)。元task DOC-019・DOC-020は完了済みの調査であり、再開・再採番しない。

## 資料

| 回 | 統合結果 | 個別回答 | 当時の対象 |
| --- | --- | --- | --- |
| 第1弾 | [統合TOP10](CODE_SNIPPET_SURVEY.md) | [Codex](CODE_SNIPPET_SURVEY_CODEX.md)・[Claude](CODE_SNIPPET_SURVEY_CLAUDE.md) | BareArray・OptionalArray・Permutation |
| 第2弾 | [共通候補と相違](PUBLIC_API_CODE_SNIPPET_SURVEY_2.md) | [Codex](PUBLIC_API_CODE_SNIPPET_SURVEY_2_CODEX.md)・[Claude](PUBLIC_API_CODE_SNIPPET_SURVEY_2_CLAUDE.md) | 赤黒木を含む公開API全体 |

「どの公開APIに短い利用例を置くと理解や誤用防止に効くか」を調べた資料。実際の掲載箇所・順序・スニペット本文の最終決定ではない。第2弾では境界式、MultiMapの可変Values View、順列の開始位置、Optional slot、軸順が共通候補になった。赤黒木の削除・近傍探索・default subscript・meldingなどの個別候補もある。

## 読むときの境界

6文書は原文のままコピーした保存資料。文中の担当指定・書き込み制限・調査手順・「現在」は当時の記録であり、現在の指示や実行許可にはしない。資料の正誤や旧APIの存続を今回確認したものではない。

旧名、連鎖subscript、順列の値保持・Iterator等の当時の説明が含まれる。使う際は、利用者の疑問や例示の意図を取り出し、現行の公開実装・Test as Specificationへ照合する。旧コードや順位をそのまま採用しない。

第2弾にある境界式API名の修正はDOC-021として受入済みだが、その受入範囲を他の候補や現行版全体へ広げない。今後の例示作成・修正は、必要な範囲を具体化して行う。

## 原本と完了記録

原本は`Maintanance/Archived/Canonical/`に残す。下記は保存原本への参照であり、本フォルダを第二の進捗管理にはしない。

- [CODE_SNIPPET_SURVEY.md（原本）](../../Archived/Canonical/CODE_SNIPPET_SURVEY.md)
- [CODE_SNIPPET_SURVEY_CODEX.md（原本）](../../Archived/Canonical/CODE_SNIPPET_SURVEY_CODEX.md)
- [CODE_SNIPPET_SURVEY_CLAUDE.md（原本）](../../Archived/Canonical/CODE_SNIPPET_SURVEY_CLAUDE.md)
- [PUBLIC_API_CODE_SNIPPET_SURVEY_2.md（原本）](../../Archived/Canonical/PUBLIC_API_CODE_SNIPPET_SURVEY_2.md)
- [PUBLIC_API_CODE_SNIPPET_SURVEY_2_CODEX.md（原本）](../../Archived/Canonical/PUBLIC_API_CODE_SNIPPET_SURVEY_2_CODEX.md)
- [PUBLIC_API_CODE_SNIPPET_SURVEY_2_CLAUDE.md（原本）](../../Archived/Canonical/PUBLIC_API_CODE_SNIPPET_SURVEY_2_CLAUDE.md)

- [DOC-019・020・021の完了記録](../../Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-11.md)
