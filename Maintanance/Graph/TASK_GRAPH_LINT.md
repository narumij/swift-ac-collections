# Task graph lint

最終更新: 2026-10-09 / Codex

## 目的

Task RegistryとTask precedenceの構造上の疑義を、task判断の代行ではなくread-only lintとして検出する。
Registryの意味、goalへの必要性、taskの採否はCodexとユーザーが判断し、このlintは自動修正しない。

## 実行

repository rootから次を実行する。

```sh
sh Maintanance/Graph/TaskGraphLint/run.sh
sh Maintanance/Graph/TaskGraphLint/run_fixtures.sh
```

空のSQLiteインメモリDBへ現行Registryを読み込み、結果を標準出力へ表示する。`ERROR`が一件でもあれば
終了status 1、なければ0とする。`WARNING`は段階移行または意味確認を要する観測であり、失敗扱いしない。

## 初版の規則

| severity | rule | 意味 |
| --- | --- | --- |
| `ERROR` | `dangling_successor` / `dangling_prerequisite` | precedenceがRegistryにないtaskを参照している |
| `ERROR` | `self_dependency` | taskが自身を前提にしている |
| `ERROR` | `duplicate_edge` | 同じtask組のprecedenceが重複している |
| `ERROR` | `invalid_gate` | Gateが`START`、`COMPLETE`、`UNCLASSIFIED`以外である |
| `ERROR` | `dependency_cycle` | 必須依存にcycleがある |
| `WARNING` | `unclassified_gate` | 段階移行中のGateが残っている |
| `WARNING` | `conditional_prerequisite` | 「場合だけ／場合に限り」で再開するtaskが必須前提として使われている |

条件付き判定は自然言語による保守的なheuristicであり、0件でも意味上の健全性を証明しない。将来の規則は
既知の違反と反証を含むfixtureを先に作り、誤検出を確認してから追加する。

## GRAPH-019 完了記録

- 現行Markdownを直接入力にするため、local DBや手入力snapshotへ依存しない。
- SQLiteは`:memory:`だけを使い、repositoryへDB fileを作らない。
- lintはRegistryやprecedenceを書き換えない。
- 正常・異常fixtureでPASS/FAILと主要ERROR規則の検出を確認する。
- 現行Registryで実行し、構造ERROR 0件、既存`UNCLASSIFIED`のWARNING 8件を確認した。
