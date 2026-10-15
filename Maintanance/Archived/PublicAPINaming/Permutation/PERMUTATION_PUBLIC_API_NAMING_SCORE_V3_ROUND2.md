# PermutationModule公開API名称採点 — V3 Round 2

## 状態

Round 2採点者: V3（Codex）。共通入力は`PERMUTATION_PUBLIC_API_NAMING_ROUND2_INPUT.md`。
Round 1の他者理由を読んだ後の再評価であり、初回票は上書きしない。採点は採用判断ではない。

## Round 2採点表

| 対象surface | 候補シンボル | Candidate ID | Round 1 | Round 2（1〜9） | 維持・変更の理由 | 他者理由への賛同・反証 |
| --- | --- | --- | --- | --- | --- | --- |
| Module名 | `PermutationModule` | `MN-01` | 7 | 8 | 上げる。通常利用は`AcCollections`経由でmodule名の細分化効果が小さく、rename費用と将来scopeをより重く見る | 姫の理由に賛同。Userのswift-algorithmsとの重なりは入口名で区別できる |
| Module名 | `NextPermutationModule` | `MN-03` | 8 | 7 | 下げる。検索性は高いが、module名より入口`nextPermutations()`で既に得られる | Userの好みは理解するが、単数名と複数結果、将来scopeの反証を重くした |
| 通常版owner | `NextPermutations` | `NO-01` | 6 | 8 | 上げる。入口からの予測性と既存familyの一貫性を再評価した | 姫の語幹整合とUserのCursorへの反証に賛同 |
| 通常版owner | `NextPermutationCursor` | `NO-06` | 8 | 5 | 下げる。役割説明は良いが、入口との語幹ずれと非標準語の費用が上回る | Userの「Swift側で意味的に凍結」の印象と姫の予測性懸念を採用 |
| 通常版一時view | `Permutation` | `NV-01` | 5 | 6 | 上げる。短さとcall siteでの自然さを再評価した | User・姫の支持に賛同。ただし所有値誤読は残る |
| 通常版一時view | `View` | `NV-02` | 7 | 7 | 維持。package内語彙と一時参照性を短く示す | 姫の指摘どおり順列性がowner文脈に依存する |
| 通常版一時view | `CurrentPermutation` | `NV-03` | 8 | 8 | 維持。順列性を失わず、現在bufferとの関係も示す妥協案 | `View`を明記しなくても失効条件はどの案も文書が必要 |
| 補助宣言名 | `Value` | `GP-01` | 4 | 6 | 上げる。現行実績とnested `Element`衝突回避は具体的な利点 | 姫の実装安全性重視に賛同 |
| 補助宣言名 | `Element` | `GP-02` | 8 | 7 | 下げる。語彙統一は望ましいが、実装可能性未確認のまま強く支持できない | Userの僅差支持は理解。compile・DocC確認後なら再評価可能 |

## 完了確認

- [x] 全9候補を再採点した。
- [x] Round 1からの変化または維持理由を記録した。
- [x] 採用・rename・公開契約変更を行っていない。
