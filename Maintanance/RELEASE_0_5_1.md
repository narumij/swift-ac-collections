# Release 0.5.1

最終更新: 2026-10-09 / Codex

## 状態

release検討開始条件待ち。現時点ではrelease候補commit、到達範囲、必須gate、tag位置を決定しない。

## Release検討開始条件

次の三対象でTest as Specification整理が完了していることを、0.5.1のrelease検討を始める条件とする。

- Permutation: 完了済み
- OptionalArray: 完了済み
- BareArray: 公開契約棚卸し後の整理待ち

これはrelease完了条件ではない。条件到達後、ユーザーが0.5.1へ含める製品上の到達範囲と、release
checklistへ進むかを一つの判断として確定する。

## 条件到達後の流れ

1. 前versionからの差分を確認し、0.5.1へ含める変更と後続へ残す変更を分ける。
2. ユーザーが製品上の到達範囲とrelease検討開始を判断する。
3. 採用時だけ[`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md)に従い、候補commit、必須CI、文書、性能、
   独立チェックを設計する。
4. tag作成、push、release page、後続branch統合は、それぞれ対象を示して別途承認を得る。

この文書とtaskの登録は、release、tag、pushを許可しない。
