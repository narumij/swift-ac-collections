# 判断座標の草案 — 一時保管と参照の入口

ユーザーの見立てでは、これらは現在の`AGENTS.md`の原型となった資料である。Claude（姫）の持ち物ではなく、誰でも参照・手入れの提案をしてよい。本文の変更は、現在の委任と持ち主の判断に従う。

2026-10-16 / 回収・照合：Astra。ユーザーのサルベージ指示により、Archivedの原文を残したまま6文書をbyte単位で同一の写しとして回収した。中心は[判断の座標系](JUDGMENT_COORDINATES_DRAFT.md)。

`Maintanance/`直下のfolderを増やさないため、しばらくTestingで預かる。内容がテスト専用という意味ではない。テスト整備の恒久task TEST-005へ紐付け、個別の回収作業はTEST-007として記録する。将来の配置・OPS-046等への紐付け変更はユーザーが判断する。

## 資料の扱い

草案・当時の評価・参考資料として参照する。回収は、AGENTS.md・CLAUDE.md・Registryの現行規則や権限への昇格を意味しない。本文にある担当名・当時の状態・規則への提案は、現在の指示として読み替えない。本文は今回変更していない。

## 原文との対応

元の[アーカイブ案内](../../Archived/JudgmentCoordinates/README.md)も保持する。

| 回収した資料 | 保存した原文 |
| --- | --- |
| [AGENTS_MD_COORDINATE_REVIEW.md](AGENTS_MD_COORDINATE_REVIEW.md) | [原文](../../Archived/JudgmentCoordinates/AGENTS_MD_COORDINATE_REVIEW.md) |
| [CHANGE_KNOWLEDGE_LAG_DRAFT.md](CHANGE_KNOWLEDGE_LAG_DRAFT.md) | [原文](../../Archived/JudgmentCoordinates/CHANGE_KNOWLEDGE_LAG_DRAFT.md) |
| [EFFECT_GRADIENT_REFERENCE.md](EFFECT_GRADIENT_REFERENCE.md) | [原文](../../Archived/JudgmentCoordinates/EFFECT_GRADIENT_REFERENCE.md) |
| [JUDGMENT_COORDINATES_BUDDHISM_NOTE.md](JUDGMENT_COORDINATES_BUDDHISM_NOTE.md) | [原文](../../Archived/JudgmentCoordinates/JUDGMENT_COORDINATES_BUDDHISM_NOTE.md) |
| [JUDGMENT_COORDINATES_DRAFT.md](JUDGMENT_COORDINATES_DRAFT.md) | [原文](../../Archived/JudgmentCoordinates/JUDGMENT_COORDINATES_DRAFT.md) |
| [MINIMAL_ORIENTATION_DRAFT.md](MINIMAL_ORIENTATION_DRAFT.md) | [原文](../../Archived/JudgmentCoordinates/MINIMAL_ORIENTATION_DRAFT.md) |

## 姫の見直し所見（未採用）

以下は2026-10-16の依頼記録からそのまま転記した提案である。本文へ反映していない。件数や実施状況についての記述も姫の報告であり、今回独立に再調査して確定したものではない。採否はユーザーが決める。

- 戻すときの入力（姫の所見、2026-10-16。採否は持ち主が決める）:
  1. §3の持ち主の表は、人の名前ではなく役割で書く。文書の持ち主は、Registryの恒久taskと維持文書・紐付け資料を引く形に変え、表にはどちらにも書かれていないものだけを残す。
  2. §2の軸1に「repositoryの外」を足す。一時ファイルの扱いは効果からは導けず、持ち主の事実として扱う必要がある。
  3. §6のレスポンシビリティに「担当範囲を返すまで」を含める（OPT-074の返却漏れ）。
  4. §7の「判断点が出たら止める」の差に、「影響する項目だけ止める」という実地の形を足す（RBT-042の範囲eraseの不具合）。
  5. §8・§11の番号の使い回しとG-1の採番状態は、`TASK_RULES_V2.md`の「Task ID採番状態」で解消済みと書ける。
  6. §8・§11のcommitとtaskの結びつき：10-15以降のcommit 149件のうち、件名にtask番号があるのは2件。まだ未決。
  7. §9の検証案は未実施。代わりに、担当適性の面談と、型別補完の往復の観測がある。

## 作業の記録

[正式登録・受入記録](../../Current/CLAUDE_QUEUE_RECONCILIATION_2026-10-16.md)に今回の範囲と確認結果を残す。現在の状態は[Task Registry](../../ProgressV2/TASK_REGISTRY_V2.md)を参照する。

## 2026-10-16改訂草案の入口

ユーザーが姫へ依頼した7点の改訂版は [JUDGMENT_COORDINATES.md](JUDGMENT_COORDINATES.md)。原版の写しと区別して読む。Astraが差分と入口接続をTEST-008として確認した。

これは草案の受渡しであり、規則への昇格ではない。事例の未照合・旧表現などの留保は[確認記録](../../Current/JUDGMENT_COORDINATES_REVISION_RECEIPT.md)に残す。上の「姫の見直し所見」は改訂に至る経緯として保持する。
