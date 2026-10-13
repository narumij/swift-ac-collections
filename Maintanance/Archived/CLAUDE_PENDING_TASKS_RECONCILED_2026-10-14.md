# Claude採番待ちqueue — reconciled 2026-10-14

## `CP-20261014-001` — 現行Registryの`FROZEN`二義性によるgraph smell試験

- queue状態: `RECONCILED`
- 発見元・ユーザー指示: 2026-10-14、`Orientation/TASK_REGISTRY_COMMON_STATE_USAGE.md`で確認された
  `FROZEN`の二義性からClaudeがgraph smell試験を提案し、ユーザーが境界付きの実行を許可した。
- 種別: `DISCOVERY`
- 対象範囲: 2026-10-14時点のTask RegistryとTask precedenceにある`FROZEN` 32行。
- 対象外: 調査中のRegistry変更、過去172 snapshotの再投影、状態モデルの改訂提案。
- 担当・受入: 姫（Claude）が調査し、Codexが現行Registryと照合して受け入れた。
- 成果・検証: 待機対象による32行の分類と、次の4種類のsmell候補が根拠つきで返却された。read-only調査のため
  build・testは不要であり、ClaudeがRegistryを変更していないことを確認した。
  - S-1: 完了済み前提を持つ`OPT-053`と`BARE-032`が`FROZEN`のまま。
  - S-2: `OPT-064`本文が`OPT-072`を開始条件にする一方、precedence辺がない。
  - S-3: `RBT-004`のOR条件がAND専用のprecedenceでは表現されない。
  - S-4: `RBT-005`は外部consumer移行待ち、`RBT-007`は将来のユーザー承認待ちだが、ともに`FROZEN`。
- Codex reconciliation:
  - 新規stable IDは作らず、補助観測を常設node `GRAPH-001`の詳細正本
    `Graph/TASK_GRAPH_DB_EXPERIMENT.md`へ統合した。
  - S-2は必須依存の欠落と認定し、`OPT-064 ← OPT-072`の`SEQUENCE`辺を追加した。
  - S-3は現行規則どおりであり、OR条件をprecedenceへ追加しなかった。
  - S-4のうち`RBT-005`は`WAITING_EXTERNAL`へ修正した。`RBT-007`は後続phaseの判断を現在へ
    表面化させないため`FROZEN`を維持した。
  - S-1は前提充足を確認したが、`FROZEN`には明示再開境界があり、現在の中間ゴールからも遠いため自動昇格
    しなかった。ユーザーの「taskとして消滅しそう」は判断ではなく見通しとして保持し、taskの採否を変更しなかった。
