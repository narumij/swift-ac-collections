# Release 0.5.2

最終更新: 2026-10-09 / Codex

## 状態

0.5.2を現在の中間ゴールとして、前提となるコメントドック作業を開始した。release検討開始条件は未達であり、
現時点ではrelease候補commit、到達範囲、必須gate、tag位置を決定しない。release rehearsal関連taskの凍結も
維持し、0.5.2の到達範囲判断時に採用するrelease工程を別途決める。

0.5.2は、製品上の到達範囲とは別に、`prepare/release/template`から`release/0.5.2`を作成し、mainをmergeして
専用工程を通すtemplate branch方式の初回rehearsal候補とする。実際の適用はrelease検討開始後に判断し、
この記録だけではbranch作成、merge、tag、pushを許可しない。

## Release検討開始条件

全公開対象のコメントドックについて、公開契約に接続され、ユーザーが内容をレビューできるドラフトが
揃っていることを、0.5.2のrelease検討を始める条件とする。

対象にはPermutation、OptionalArray、BareArray、RedBlackTreeの公開APIを含む。ドラフトは契約内容を
確認できる段階を指し、文章の最終校正、公開可能な初版への仕上げ、release noteの完成までは要求しない。

これはrelease完了条件ではない。条件到達後、ユーザーが0.5.2へ含める製品上の到達範囲と、release
checklistへ進むかを一つの判断として確定する。

## 依存の登録方針

各対象のコメントドック作業taskが具体化した時点で、この判断taskへ必須依存を接続する。未登録の作業を
推測でtask化したり、既存の利用者向け文書ドラフト中間ゴールをコメントドック完成と読み替えたりしない。

## コメントドック作業task

- `DOC-002`: 4対象の公開宣言、既存コメント、契約正本、test証拠、阻害判断を棚卸しする。これだけを最初の
  `ACTIVE` taskとし、sourceコメントは変更しない。
- `DOC-003`: Permutationのコメントドック・ドラフト作成と検証。棚卸し完了まで`PROPOSED`。
- `DOC-004`: OptionalArrayのコメントドック・ドラフト作成と検証。命名判断との境界を棚卸しで確定するまで
  `PROPOSED`。
- `DOC-005`: BareArrayのコメントドック・ドラフト作成と検証。受入済み監査を契約入力に使い、棚卸し完了まで
  `PROPOSED`。
- `DOC-006`: RedBlackTree 4公開型のコメントドック・ドラフト作成と検証。`DOC-002`と`RBT-014`を前提とし、
  必要な公開契約判断を棚卸しで確定するまで`PROPOSED`。

各実行taskの共通完了条件は、対象公開宣言にコメントが対応し、契約正本とTest as Specificationへ追跡でき、
documentation buildの結果と未確認事項が記録され、ユーザーが本文をレビューできることである。最終校正、
公開可能な初版への仕上げ、release実行は含めない。

## 中間ゴールとの距離

- `DOC-002`〜`DOC-006`は`NEAR`。0.5.2の到達範囲判断に必要な入力を揃えるが、それ自体は0.5.2の完成ではない。
- `RELEASE-006`は`DIRECT`。コメントドック完了後、0.5.2の製品上の到達範囲とrelease開始を決める。
- `RELEASE-022`は`DIRECT`。後から分解する準備・検収taskが証拠を揃えた後、固定候補を0.5.2として
  releaseしてよいか、ユーザーが一つだけ判断する。

準備・検収と可否決定後の公開操作は、採用するrelease工程が具体化した時点で別taskへ分解する。
早期に登録した`RELEASE-021`と`RELEASE-023`は未着手のまま`EXCLUDED`とし、IDを再利用しない。
`RELEASE-022`も現時点では`PROPOSED`であり、候補commit、gate、branch方式、tag、pushを許可しない。

## Release可否ゲート

`RELEASE-022`を0.5.2の明示的なgo/no-goゲートとする。これは到達範囲とrelease検討開始を決める
`RELEASE-006`とは別の判断である。`RELEASE-006`は「何を候補として検証するか」を決め、`RELEASE-022`は
「検証済みの固定候補を実際にreleaseしてよいか」を決める。

最低入力は、候補commitとtree、必須local gate、同じcommitに対するremote CI、documentation、必要な性能結果、
独立確認、release阻害・非阻害・後続へ分類した既知事項である。一つでも必須証拠が未確認または対象commitと
不一致なら、release可とは判断しない。可否決定はtag、push、release pageの承認を兼ねない。

## 条件到達後の流れ

1. 前versionからの差分を確認し、0.5.2へ含める変更と後続へ残す変更を分ける。
2. ユーザーが製品上の到達範囲とrelease検討開始を判断する。
3. 採用時だけ[`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md)に従い、候補commit、必須CI、文書、性能、
   独立チェックを設計する。
4. tag作成、push、release page、後続branch統合は、それぞれ対象を示して別途承認を得る。

この文書とtaskの登録は、release、tag、pushを許可しない。
