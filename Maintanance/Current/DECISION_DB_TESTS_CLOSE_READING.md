# 判断DBの試験の精読

CP-20261020-007。対象は`Maintanance/RegistryApp/decisions/test_decision_store.py`（17件。Lifecycle 2・Contracts 10・Daily 4・Cli 1）。突き合わせた実装は`decision_store.py`・`decision_cli.py`・`fixtures.py`・`README.md`。基準はHEAD `78afefa93`。

- 試験の一式は実行していない。
- 「確かめた」と書いたものは、`fold()`と`_check()`をメモリ上で直接呼んで確かめた。ファイルは作っていない。
- 本番のDB（`Data/decision-assist.sqlite3`）は開いていない。

## 指定の3点

### 1. AIの提案を、ユーザーの確定判断として扱わないか

- 守られていること：
  - 登録（register）と提案（propose）は、どちらも提案の版を作るだけで、採用にはならない。
  - 採用になるのは`record_adoption`だけ。`decided_by`（決めた人）と`source`（出典）が要る。
  - 試験：`test_proposal_is_not_adoption_and_old_revisions_stay`は、提案だけでは採用が動かないことを確かめている。
- 守られていないこと（確かめた）：
  - `decided_by`はただの文字列で、記録した人（`actor`）と同じでもよい。だから`actor='姫'`、`decided_by='姫'`の採用が通る。AIが自分の提案を自分で採用しても、照会では「採用済みの版」として返る。
  - `decided_by='user'`と書けば、ユーザーの判断として記録される。出典の中身は確かめない（README・docstringにも書いてある）。
  - 研究段階の案にあった判断の種類（user-policy／accepted-technical）は、実装にない。照会の結果から「ユーザーが決めたものか」を機械的に分けられるのは、`decided_by`の文字列だけ。
- 試験の抜け：
  - 決めた人と記録した人が同じ採用を、拒否もしないし、印も付けない。それを示す試験がない（意図どおりなら、限界として試験に書くべき）。
  - 登録した直後に採用されていないこと（`adopted`がNone）を、直接確かめた試験がない。提案（propose）の場合だけ確かめている。
  - fixtureの採用はAI（`Claude（姫…）`）が`decided_by: 'user'`で記録している。出典は「受け入れた試行の結果」と正本の行で、ユーザーの発言そのものではない。運用の形としては、AIがユーザーの判断を代わりに書く形になっている。

### 2. 改訂・失効した判断が、現行判断として返らないか

- 守られていること：
  - 一番上の`adopted`は正しく動く。新しい版を採用すれば新しい版になり、撤回すればNoneになる。
  - 撤回された版は、もう一度採用できない。採用済みの版より古い版も採用できない。
  - 試験：`test_withdrawal_is_recorded_and_never_readopted`、`test_adoption_records_an_external_fact_only`。
- 危ないこと（確かめた）：
  - 版1を採用し、版2で置き換えたあとも、版1の`adoption`の記録はそのまま残る。版1に「置き換えられた」という印は付かない（版2の`replaces: 1`から逆にたどるしかない）。
  - そのあと版2を撤回すると、照会の結果はこうなる。
    - 一番上：`adopted: None`、`withdrawn: 2`
    - 版1：`adoption`あり、`withdrawal`なし
    - 版2：`adoption`あり、`withdrawal`あり
  - 版ごとに「採用されていて、撤回されていない版」を探す読み方をすると、置き換えられた版1を現行の判断として拾ってしまう。
  - 照会は「今の本文」の欄を返さない。全部の版を返し、`adopted`の番号から本文を引くのは読む側に任せている。最新の版（max）を引けば未採用の提案を、版1を引けば古い版を読んでしまう。
- 試験の抜け：
  - 置き換えたあとの版1がどう見えるかを確かめた試験はない（版2の`replaces`だけを見ている）。
  - 置き換えたあとに撤回する組み合わせ（上の場面）の試験はない。
  - 提案を飛ばして採用する場合（版2と3があるときに3を採用し、そのあと2を採用しようとする）の試験はない。コードを読む限りは拒否される。
  - 「失効」のうち、出典の文書が変わって効力を失う場合は、仕組みがない（出典を見張らない。READMEに書いてある）。

### 3. 指定したスコープ外の判断が、適用対象として混ざらないか

- 守られていること：
  - スコープは登録のときに1つ決まり、変える操作はない。同じIDを別のスコープで登録し直すことはできない。
  - 見直しの候補（`review_candidates`）は、指定した判断の写しだけを返す。
  - 試験：`test_one_scope_per_id`、`test_selective_review_changes_nothing`（ほかの判断は候補にならない）。
- 仕組みとしてないこと：
  - スコープで判断を引く照会がない。照会はIDで引くか、全部を出力するかの2つだけ。だから「このスコープに当たる判断」を選ぶのは、いつも人かAIの読み。混ざるかどうかは、DBでは防げないし、確かめもできない。
  - スコープはただの文字列で、決まった形がない（`registry-v3/version-order`と`Registry-v3/version-order`は別物になる）。上位・下位の関係もない。
- 危ないこと（確かめた）：
  - リクエストの知らない欄は、どの操作でも黙って受け付ける。たとえば`propose`や`record_adoption`に`scope: 'other'`を付けても、拒否されない。記録はされるが、状態には何も反映されない。送った側は「スコープを変えた」と思い込みうる。
  - 改訂で本文の意味を広げても、スコープはそのまま残る（意味の確かめは人がする、という設計どおり）。
- 試験の抜け：
  - 知らない欄（特に`scope`）を付けたリクエストの試験はない。
  - スコープを指定した照会の試験は、仕組みがないので、ない。

## そのほかの抜け

- `test_append_only`：UPDATEとDELETEしか試していない。`op_id`はUNIQUEなので、`INSERT OR REPLACE`で同じ`op_id`の行を置き換えられる（BEFORE DELETEのtriggerを通らない。連絡DBの精読で再現した性質と同じ）。`meta`表にはtriggerがなく、schema_versionも書き換えられる。
- `test_reading_is_read_only_with_the_authority_note`：読み取り専用で開いたときに書けないことは確かめている。読み取り専用でない普通の接続で照会しても、何も書かないかは、行数で確かめていない（`test_selective_review_changes_nothing`がevent数を見ているので、ほぼ足りている）。
- `test_two_writers_with_the_same_base`：鍵の待ちと、後から来た側の拒否を確かめている。抜けは小さい。
- 試験のdocstringのRun行は`Maintanance/Current/Evidence/OPS-158/durable/…`のまま。今の場所（`RegistryApp/decisions/`）と合っていない。

## 試験ごと（主張と、実際に確かめていること）

- `test_init_is_explicit_and_never_overwrites`：init（DBの新規作成）は既存のパスを拒否する。ないパスは作らない。別のSQLiteは拒否する。
- `test_fixture_matches_the_accepted_sample_and_survives_reopen`：D1〜D3が試行の結果と一致し、開き直しても残る。D3の出典は236行目。
- `test_replay_and_mismatch`：同じ`op_id`の再送ではeventが増えない。中身が違えば拒否する。
- `test_base_conflict_and_recorded_refusal`：古い版を前提にした提案は拒否し、拒否も記録する。再送すると同じ拒否が返る。
- `test_proposal_is_not_adoption_and_old_revisions_stay`：提案だけでは採用されない。版1の本文は残る。版2の`replaces`は1。
- `test_adoption_records_an_external_fact_only`：`decided_by`と`source`は空にできない。`replaces`は今の採用版でなければならない。ない版・閉じた版は拒否。同じ版の二重採用も拒否。
- `test_one_scope_per_id`：同じIDの登録し直しは拒否。別のIDなら別のスコープを持てる。
- `test_append_only`：eventsのUPDATEとDELETEは止まる。
- `test_reference_integrity`：知らない判断・ない版・知らない種類・重複したID・空の出典は拒否する。
- `test_selective_review_changes_nothing`：見直しの候補は、採用が進んだ判断の写しだけ。一覧を出しても何も変わらない。
- `test_review_only_counts_copies_older_than_the_adoption`：採用の前は候補なし。新しい提案の写しは古くない。置き換えられた版の写しだけが候補になる。
- `test_two_writers_with_the_same_base`：同じ前提での2つの書込みは、後の側が拒否される。鍵を持たれている間は書けず、何も半端に残らない。
- `test_superseding_a_checked_copy`：確かめた写しで置き換えると、候補から外れる。古い参照は残る。誤った置き換え5種類は拒否する。
- `test_withdrawal_is_recorded_and_never_readopted`：撤回には前提・決めた人・出典が要る。撤回後は採用なし、本文は残る、写しは候補になる、撤回された版は再採用できない、新しい提案は採用できる。
- `test_reading_is_read_only_with_the_authority_note`：読み取り専用の接続では書けない。照会には「補助の記録」という注記が付く。
- `test_backup_and_validate`：backupは既存のパスを拒否する。backupは読み取り専用で引ける。壊れたファイル・別のDB・DBでないファイルは、validateが拒否する。
- `test_roundtrip`（CLI）：init・apply・query・export・backup・validateのexit codeと、照会と出力では書き込まないこと。
