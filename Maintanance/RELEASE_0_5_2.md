# Release 0.5.2

最終更新: 2026-10-09 / Codex

## 状態

release検討開始条件待ち。現時点ではrelease候補commit、到達範囲、必須gate、tag位置を決定しない。

0.5.2は、製品上の到達範囲とは別に、`prepare/release/0`からrelease用branchを作成し、mainをmergeして
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

## 条件到達後の流れ

1. 前versionからの差分を確認し、0.5.2へ含める変更と後続へ残す変更を分ける。
2. ユーザーが製品上の到達範囲とrelease検討開始を判断する。
3. 採用時だけ[`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md)に従い、候補commit、必須CI、文書、性能、
   独立チェックを設計する。
4. tag作成、push、release page、後続branch統合は、それぞれ対象を示して別途承認を得る。

この文書とtaskの登録は、release、tag、pushを許可しない。
