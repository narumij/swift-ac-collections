# Registry V3 運用手順

## TL;DR
DBを正本にし、Markdownのtask表・採番表・構造一覧は読取用に生成する。編集保存と正式反映は別。調整担当がbackup・反映・生成・確認・commitを担当する。OPS-167の切替手順。

## 保存場所
- DB：`Maintanance/RegistryApp/Data/registry.sqlite3`（Git対象外、Cacheではない）
- 編集保存：`Maintanance/RegistryApp/Inbox/`（旧保存を削除/自動変換しない）
- backup：`/Users/narumij/Documents/RegistryStudioBackups/swift-ac-collections/`
- 生成構造：`Maintanance/ProgressV2/STRUCTURE.generated.md`

## 起動
リポジトリ直下でユーザーが実行する。切替後は引数なしの旧モードを使わない。
```sh
python3 Maintanance/RegistryApp/serve.py --v3-db Maintanance/RegistryApp/Data/registry.sqlite3 --v3-saves Maintanance/RegistryApp/Inbox
```
旧モードで作った保存をMarkdown手編集経路で反映しない。旧保存は個別照合する。

## 正式反映の一巡
1. 対象save・選択変更群・基準値・権限を確認する。同時writerを置かない。
2. `registry_v3_recovery.backup(conn, new_path)`と`validate(new_path)`で反映前backupを作る。世代・revision・時刻を名前にし、上書きしない。
3. `registry_v3_cli.py apply-groups --db <DB> --save <保存> --selection <選択JSON>`。新規cardの正本確認には`--document-root <repo>`を明示する。個別操作は`apply --db <DB> --op <固有ID> --request <JSON>`。応答不明時は同じopと本文で照会/再送する。
4. `registry_v3_views.replace_in_place(repo, conn, 'Maintanance/ProgressV2/STRUCTURE.generated.md')`でviewを生成し、equalと差分を確認する。DB管理表を手で変更しない。ViewPartial時は公開済み/未公開を記録し、再生成が完了するまで次の正式反映を止める。
5. 必要な文書更新は`sync.py --v3-db <DB>`で行う。これはCacheへ書く操作であり、読取専用検査ではない。V3の`--check`併用は禁止。
6. 反映後backupを検証し、許可された範囲をcommitする。作業終了時にもbackupを取る。自動削除はしない。

新しいtaskの直接登録は`register_task`を上記CLIの`apply`で実行する。採番・再送の契約は[実装READMEの更新契約](../RegistryApp/v3/README.md#区切り2更新契約registry_v3_writepy)を参照する。

## 位置と完了
`set_focus`は既存版への読取境界変更であり到達事実ではない。`set_recorded_done`は実cardのbooleanだけを更新する。いずれもgeneration/actor/evidence/baseを含む既存CLI apply契約を使う。詳細例は[実装README](../RegistryApp/v3/README.md)。HEAD.mdや旧cardのチェックボックスをDBへ再取込しない。

## 復旧と停止
DBがない/壊れた場合はMarkdownから再取込しない。元データとbackupを保持して停止する。backup復元は新DB・新世代へ行い、書込を閉じたままにする。最新の発行済み番号境界が実証されるまで採番を再開しない。backupは同じMac上なので端末全損を防ぐものではない。

## 正本の範囲
制度・判断理由・仕様本文は引き続き各Markdown文書。DBの構造とその説明を混同しない。生成viewは最新反映時の読取用で、DB更新途中には古くなる。DBとviewが不一致ならDBを確認し、表を手編集して合わせない。
