# Studioの説明表示と恒久分類の小補正

## TL;DR（人間向け）

作業カードの色の説明を常時表示から折りたたみにし、恒久研究OPS-103が独立欄へ出る分類漏れを直します。研究や承認の意味は変えません。

<a id="依頼原因変更"></a>
## Assignment, cause and change

OPS-134 / 2026-10-19 / Astra. The user pointed out the always-visible legend and OPS-103 in the independent section.

- Move the legend into closed details, opened only when needed from 「作業カードの色の説明」.
- Registry and canonical details already designate OPS-103 permanent, but it was absent from the standing-ID list in TASK_RULES_V2 read by sync.py. Add it without changing the decision and generate permanent=true. Children appear in the permanent diagram through existing parent links.
- HTML/classification correction of existing decisions only; no changes to research content, approval authority, states or dependency lines.

<a id="検証受入"></a>
## Verification and acceptance

Check generation together with summary work. This is separate from the previous approved UI commit.

2026-10-19, Astra acceptance. Legend is initially hidden in closed details. Existing UI tests PASS. Generated JSON has OPS-103 permanent=true; the actual independentGroups function excludes it from general independent items and includes it in permanent items. Existing permanent-diagram coverage also PASS. No real screen operations.
