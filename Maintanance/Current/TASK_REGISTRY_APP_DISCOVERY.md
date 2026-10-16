# Registryアプリ：既存graph試験の知見と再利用範囲の調査

2026-10-16、Astra記録。OPS-049。親は恒久task [OPS-048](TASK_REGISTRY_APP.md)。ユーザーの調査指示を受け、共有資料・実装とfixtureを確認した。調査受入済み・ユーザーcommit指示によりDONE。

## 目的・範囲

既存graph試験の共有文書・公開済み成果・fixtureと現行Registryの表現を照合し、閲覧編集アプリに再利用できる知見、足りない表現、読み取り専用試作の最小範囲を整理する。方式や製品方針を確定しないDISCOVERYとする。

起点は[独立試験の記録](../Graph/TASK_GRAPH_DB_EXPERIMENT.md)、[Registry](../ProgressV2/TASK_REGISTRY_V2.md)、[Rules](../ProgressV2/TASK_RULES_V2.md)、[マイルストーン](../MILESTONES.md)。参照資料の当時の状態と現行状態を区別する。

## 返却・受入条件

- 再利用できる知見・共有成果と、使えないもの・未確認事項を出典付きで整理する。
- task属性、依存のFlow、自由記述条件、判断者、マイルストーンとの関係、出典・版情報について、既存表現で保持できる範囲と不足を示す。
- 読み取り専用試作の入力範囲・表示対象・原文との照合方法を提案する。往復編集に進む際の情報損失・競合検知の論点も残す。
- 次に実装できる限定範囲と、ユーザー判断が必要な点を分けて返す。調査成果の受入後はcommit待ちとし、試作開始を自動許可しない。

## 境界

Claude専用DB・非公開schema・query・metadataは閲覧・複製しない。既存試験の共有境界を守り、公開されていない設計の開示を求めない。再利用候補は共有済み知見・成果の範囲で評価する。

終了済みのCodex graph DB独立試験や、取り下げたDB統合を再開しない。本件はユーザー向け閲覧編集アプリの新しい調査であり、旧運用方針の復活ではない。DB・Registry書戻し・アプリ実装は対象外。成果記録以外の既存資料は変更しない。

親子関係は所属を示す。恒久taskの完了依存にはせず、GRAPH-001の完了も待ち条件にしない。

## 調査結果（2026-10-16 / Astra）

### 結論と再利用範囲

共有済みの構造lint・fixtureと、出典と意味確認を分ける考え方は再利用できる。完成した閲覧編集アプリや、原文を保持して書き戻す実装は今回確認した共有成果にはない。既存SQL schemaをそのまま中間形式に採用する根拠はなく、現行Markdownを損失なく読む層を別に設計する必要がある。

| 共有成果 | 確認したこと | アプリへの利用と限界 |
| --- | --- | --- |
| [TaskGraphLint](../Graph/TASK_GRAPH_LINT.md)・[実装](../Graph/TaskGraphLint/run.sh) | 現行Registryを読み、孤立した参照、自己依存、重複辺、Flow値、循環を検査 | 構造検査の規則・正常異常fixtureを使える。意味や実行権限の判定器ではない |
| [共有schema](../Graph/AI_GRAPH_SHARED_SCHEMA.md)・[DDL](../Graph/InMemoryFixture/schema.sql) | node/edge、provenance、confidence、観測時点、根拠、導出元の有無を表現 | 出典と推定の区別、0件と未観測の区別を引き継げる。task状態・担当・Flow・マイルストーンを備えたアプリ用schemaではない |
| [共有fixture](../Graph/AI_GRAPH_IN_MEMORY_FIXTURE.md)・[replay](../Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md) | 過去の固定データで関係・不足・陳腐化等を検査。START/COMPLETEから現行Flowへ変えた経緯を保持 | 回帰試験の観点を利用できる。fixture成功は現行sourceの品質や現行task対応の正しさを証明しない |
| [独立試験記録](../Graph/TASK_GRAPH_DB_EXPERIMENT.md) | 読み取り先の陳腐化、FROZENと待ち条件、常設ACTIVEの違い、ローカル可視化PoCの報告 | 誤読防止と版照合の要件に使える。専用DB・非公開script・画像は調べておらず移植可能性は未確認 |

### 今回の検証

[実行証拠](Evidence/RegistryAppDiscovery20261016/)へlogと入力hashを保存した。HEADは76c08138、未commitのOPS-048/049登録を含む作業ツリーで実施。受入状態更新前のRegistry SHA-256はc2e2e6a6f0d0827e0b3aed7039611f984ac3108f0e7662010429bda8326119f1。

- 現行lint：36 task、11辺、warning 0、error 0、exit 0。
- 正常・異常lint fixture：PASS、exit 0。
- 共有インメモリfixture：6/6 PASS、exit 0。
- 別途表を数え、36 task、ID重複なし。状態はACTIVE 22、DONE 4、USER_ONLY 3、PROPOSED 3、WAITING_EXTERNAL 2、FROZEN 1、WAITING_USER 1。

既存lintはawkで縦棒分割し、backtickを除去して5列だけを読み、詳細正本列・分野・原文位置を保持しない。したがってこの出力から元文書を再生成すると情報が失われる。escaped pipe等のMarkdown境界も専用parserとして検証されていない。現行fixtureのPASSを往復編集の保証にはしない。

### 表現上の不足と提案

| 項目 | 最小試作での扱い |
| --- | --- |
| task・担当・種別・常設区分 | 6列の原文、分野、行位置を保持。担当は原文文字列とし個人IDへ勝手に正規化しない。常設区分はRulesの明示リストと出典を表示 |
| 必須依存 | predecessor→successorを表示し、元表はsuccessor/prerequisite順であることを対応付ける。SEQUENCEとPARALLEL_JOINを別表示 |
| 条件・判断者 | 条件原文を詳細欄へ。未解析を明示し、ACTIVEや前提完了だけで「実行可能」にしない。担当欄から判断権者を推定しない |
| 親子・マイルストーン | 完了依存と異なる関係として扱う。現在は本文や版別正本へ分散。初版ではMILESTONESの表とリンクを併記し、推定の辺を生成しない |
| 出典・読み込み版 | 文書path、位置、原文、ファイル全体hash、Git HEADと未commit差分を識別。行番号だけを永続キーにしない |
| 履歴 | 初版では現行のみ。過去に同一ID再利用があったため、将来履歴を取り込む際はIDだけで結合せず文書・版を含める |

### 次に実装できる限定範囲（提案、未着手）

現行Registry・Rulesの状態定義と常設リスト・MILESTONESの到達点表を読み取り、一覧、11本の明示依存グラフ、選択taskの条件原文と詳細正本リンクを表示する。詳細正本・Archivedの再帰探索、ready自動判定、AIによる条件抽出、編集・書戻しは初版に含めない。マイルストーンに接続できないtaskも一覧から消さない。

アプリ共通の中間表現は、原文と出典を持つJSON snapshotから始める案が小さい。SQLiteは後に検索・履歴が必要なら派生cacheとして検討できる。これは提案であり、JSON/SQLiteの採用やネイティブ/Webの決定ではない。

初版の検証はtask全6列・ID・状態別件数・Flow/制約を含む全辺の一致、出典への到達、未解釈条件の表示、未知状態や不正行を黙って捨てないことを確認する。独立fixtureでエスケープ、リンク、backtick、未知列を扱う。原文に反してreadyを断定しないことも確認する。

編集段階では元ファイルを保持し、対象セルだけのpatchを生成する。無編集往復でbyte一致、未編集箇所の保持、読み込み後の変更検知、競合時の停止、適用後の構造lintが必要。複数文書にまたがる変更は全対象を事前照合し、途中失敗から復旧できる単位で扱う。まだ実装・検証していない。

### 残る判断と受入

次の判断は試作をWebとネイティブのどちらで始めるか。中間形式案とともに選定し、読み取り専用試作を別の実行範囲として登録する。編集方式・公開/配布・履歴DBは今決める必要がない。

再利用範囲・不足・最小試作・検証方法を出典と実行証拠付きで返し、調査の受入条件を満たした。OPS-049はユーザーcommit指示によりDONE。アプリは未実装で、既存DB・試験資料は変更していない。

