# Registry V3 隔離DB読取実験（OPS-160）

## TL;DR（人間向け）

明示順のfixtureを、メモリ内のSQLiteへ読み込み、構造・順序・現在位置での読取範囲を取り出す、隔離の実験。現行のRegistry・Milestones・Studio・実DB・サーバーには触れない。更新と採番のAPIはない。正本は[TASK_REGISTRY_V3_READ_EXPERIMENT.md](../../../Current/TASK_REGISTRY_V3_READ_EXPERIMENT.md)。

## 実行

```sh
python3 -B Maintanance/RegistryApp/Experiments/registry_v3_read/test_registry_v3_read.py -v
python3 -B Maintanance/RegistryApp/Experiments/registry_v3_read/registry_v3_read.py Maintanance/RegistryApp/Experiments/registry_v3_read/fixtures/base.json [current|all]
```

Pythonの標準ライブラリだけを使う。DBはメモリ内に作る。現行の読取（`sync.py`の`build()`）との比較では、一時ディレクトリにRegistryとMilestonesの写しを書く。`sync.py`はモジュールとして読み込み、パスを差し替えて使う。`sync.py`そのものは変えない。

## ファイル

| ファイル | 内容 |
| --- | --- |
| `registry_v3_read.py` | 読み込み（`load`、1つのトランザクションで、拒否すると全部を取り消す）、派生の骨格（`skeleton`）、読取（`read`、`current`か`all`） |
| `fixtures/base.json` | 版A・B・C（0.1.0〜0.3.0）を明示順に並べたfixture。カード・ゲート・タスク5件と、管理・進捗・到達点の3つのグラフ |
| `test_registry_v3_read.py` | 期待値は、原型仕様と設計の表から手で書いた。共通の部分は、現行の読取とも比べる |

## モデル

- **ID**：`nodes`に、すべての種類（task・card・gate・start・end）のIDを1つの空間で置く。START-とEND-は、版から読み込み側が作る。fixtureからは書けない。
- **順序**：版の位置と、版の中のカードの順は、fixtureの並びのとおり。フォルダを比べる一般の規則は作らない。
- **派生の骨格**：保存しない。次のように導く。
  - 各版で、START→カード→END。
  - END→ゲート。ゲート→次の版のSTART。
  - ゲートのIDは識別子にすぎず、行き先を表さない。
  - ゲートのない版は、次の版につながらない。最後の版のゲートは、そこで終わる。
- **グラフ**：`management`（親→子）、`progress`（タスク→タスク）、`milestone`（タスクと到達点）を分けて持つ。循環は、管理の中と、作業の順（progress・milestone・骨格を合わせたもの）の中で拒否する。管理と進捗をまたぐ循環は、循環として扱わない。
- **focus**：読取の範囲を選ぶだけ。到達（DONE）は導かない。マイルストーンの状態は保存しない。
- **出典**：`provenance`に、fixtureのどこから来たかを記録する。読取では、構造とは別に返す。

## 期待値の出どころ

- 原型仕様（`Milestones/DESIGN.md`）と、設計の「隔離読取試行へ渡す期待値」の表から、手で書いた。
- 共通部分（基本の構造、カードの並べ替え）は、現行の読取とも一致することを確かめる。対象：ID、タスクの欄、3つのグラフ、骨格、カードの順、ゲート。
- **既知の差**：次の3つは原型仕様を期待値にする。現行の読取の拒否は「KNOWN DEVIATION」として記録するだけで、成功の条件にはしない。
  - 任意の名前のゲート
  - ゲートの欠落
  - 末尾のゲート

## 限界

- タスクの位置は、つながっている到達点の版から決める。どこにもつながらないタスクは、`all`の読取にだけ出る。
- ゲートは、それを置いた版の範囲に入れる。focusの版より前の版のゲートは、境界の参照として返す。
- 現行の読取との比較で除いたもの：状態の派生（HEADによるDONE）、`raw`、`sourceLine`、`source`、条件文、正本のリンク。
- これは構造の実験で、すべてを写す移行ではない。
  - `read`の`sources`は、`current`でも出典表の全部を返す。
  - 辺の`flow`と条件文は保存するが、返さず、比べもしない。
- 読み込みは、BEGINのあとに起きたどの失敗でも全部を取り消し、トランザクションを閉じる。
  - 構造の拒否は`Refused`、整合性の違反も`Refused`にする。
  - 欄の欠落などの不正な入力は、元の例外のまま返す。
  - 未知の読取範囲は`ValueError`で拒否する。
- 書込・採番・競合・再送・同時実行は扱わない（次の区切り）。
