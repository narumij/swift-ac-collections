# Release 0.6.0

最終更新: 2026-10-09 / Codex

## 状態

release検討開始条件待ち。現時点ではrelease候補commit、到達範囲、必須gate、tag位置を決定しない。

## Release検討開始条件

全公開対象の利用者向けドキュメントが、公開可能な初版として揃っていることを、0.6.0のrelease検討を
始める条件とする。

対象にはPermutation、OptionalArray、BareArray、RedBlackTreeを含む。初版は公開契約と整合し、利用者が
主要な用途、基本操作、重要な制約を理解できる状態を指す。以後の加筆や改善余地がないことまでは要求しない。

これはrelease完了条件ではない。条件到達後、ユーザーが0.6.0へ含める製品上の到達範囲と、release
checklistへ進むかを一つの判断として確定する。

## 依存の登録方針

各対象の利用者向けドキュメント初版を完成させるtaskが具体化した時点で、この判断taskへ必須依存を
接続する。ドラフト作成taskを初版完成と読み替えず、レビューと公開可能性の確認を残す。

## 条件到達後の流れ

1. 前versionからの差分を確認し、0.6.0へ含める変更と後続へ残す変更を分ける。
2. ユーザーが製品上の到達範囲とrelease検討開始を判断する。
3. 採用時だけ[`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md)に従い、候補commit、必須CI、文書、性能、
   独立チェックを設計する。
4. tag作成、push、release page、後続branch統合は、それぞれ対象を示して別途承認を得る。

この文書とtaskの登録は、release、tag、pushを許可しない。
