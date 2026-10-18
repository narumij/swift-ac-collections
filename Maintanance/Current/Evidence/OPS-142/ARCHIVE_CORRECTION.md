# Luna返却の限定補正

## 一時作業物:

- パス・実体パス: `/private/tmp/OPS-142-ARCHIVE-CORRECTION-SOLA-20261019`
- 作成: Sol A / 2026-10-19
- 用途: R-20261019-02補正直前の3ファイル全文控えとhash。状態: 使用中。
- 保持条件: Astra調整の受入まで継続保持。証拠は本返却へ保存。

## 開始照合

再開固定hashと3現在ファイルの一致を確認し、補正前の未commit全文を上記へ保存する。翻訳前控えは `/private/tmp/ops142-luna-archives-original-20261019` を読み取り利用。Luna元返却・独立レビューは変更しない。

## 補正結果

R-20261019-02 / Sol A。3件のみ補正。RELEASE_0_5_3へ2段落の日本語TLDRを追加。起動時表と終了結果を区別し、過去の手順を現在の許可にしない境界を明記した。ELEMENTBUFFERは `## 返却欄（Claudeが記入）` 全区間を原文控えへ一致させた。Handoffは `## Public API ledger`、`## Test evidence matrix`、`## Naming and contract history` を署名込みで原文へ復元し、壊れたinline-code・略号・列挙件数の曖昧さを同時に解消した。Codex説明中の `partial` だけは元inline-code `部分` へ戻した。その他の説明英訳は保持。

## 機械照合

補正直前控えと現在ファイルの原文復元区間を同じplaceholderへ置換して比較し、区間外の説明本文は完全不変（Handoffの明示inline-code1語補正のみ許容）を確認。RELEASEは追加TLDRを除く全文が補正前控えと完全一致。復元した4区間は翻訳前原文控えと完全一致。旧見出しの文字列・回数・出現順とリンク先を維持し、複数段落TLDRを追加した。製品test・外部リンク疎通は実行していない。

## 文書別hashと控え

```json
[
  {
    "path": "Maintanance/Archived/Canonical/RELEASE_0_5_3.md",
    "source_snapshot": "/private/tmp/ops142-luna-archives-original-20261019/Maintanance/Archived/Canonical/RELEASE_0_5_3.md",
    "correction_before_snapshot": "/private/tmp/OPS-142-ARCHIVE-CORRECTION-SOLA-20261019/before/Maintanance/Archived/Canonical/RELEASE_0_5_3.md",
    "source_sha256": "19591246f2b9d7c991404ae5ecdfbd30c1851d7477bdc7e71f27953076e9cbe9",
    "before_sha256": "f55e1a92dd906bd38f5c4b9e9b4be37db9ad960a47713fd12ede0f2e6de3efde",
    "after_sha256": "08e55b94693e0e58a74dcb5ae412e4098456314c8f597a494331d9f0e0ac419f",
    "restored_sections": [],
    "checks": {
      "other_explanatory_prose_unchanged": true,
      "headings_links_preserved": true,
      "raw_sections_exact": true
    }
  },
  {
    "path": "Maintanance/Archived/Reviews/ELEMENTBUFFER_TEST_AS_SPEC_REVIEW.md",
    "source_snapshot": "/private/tmp/ops142-luna-archives-original-20261019/Maintanance/Archived/Reviews/ELEMENTBUFFER_TEST_AS_SPEC_REVIEW.md",
    "correction_before_snapshot": "/private/tmp/OPS-142-ARCHIVE-CORRECTION-SOLA-20261019/before/Maintanance/Archived/Reviews/ELEMENTBUFFER_TEST_AS_SPEC_REVIEW.md",
    "source_sha256": "5f5d30bc9adaa000ee28c9b18d5182844dda84ce4e9da8489846166bce0f660d",
    "before_sha256": "2b7ca70795c53765aa9866d3b56ef2c7c29a057ad829f2e7d349cb724ba79257",
    "after_sha256": "2a0798c5cf25a3082130a6028c8a2e92c7c657e6e0045f42b72d623deed4f14e",
    "restored_sections": [
      "## 返却欄（Claudeが記入）"
    ],
    "checks": {
      "other_explanatory_prose_unchanged": true,
      "headings_links_preserved": true,
      "raw_sections_exact": true
    }
  },
  {
    "path": "Maintanance/Quality/0.6.0-1/PermutationModule/DocumentationHandoffAudit.md",
    "source_snapshot": "/private/tmp/ops142-luna-archives-original-20261019/Maintanance/Quality/0.6.0-1/PermutationModule/DocumentationHandoffAudit.md",
    "correction_before_snapshot": "/private/tmp/OPS-142-ARCHIVE-CORRECTION-SOLA-20261019/before/Maintanance/Quality/0.6.0-1/PermutationModule/DocumentationHandoffAudit.md",
    "source_sha256": "cd4627a2f3ac370040ff8de2d245b5c6132767f525f791670a88ab7eb1408c80",
    "before_sha256": "8f0858f7ba68066b1ed707de7f7523eb8c1a3139ab143be652dd7d03b37a339e",
    "after_sha256": "8dc1e55a2becf1ce9d4b79ab87f6f9994423b1ab77ac3f39f8e5fea5192ead55",
    "restored_sections": [
      "## Public API ledger",
      "## Test evidence matrix",
      "## Naming and contract history"
    ],
    "checks": {
      "other_explanatory_prose_unchanged": true,
      "headings_links_preserved": true,
      "raw_sections_exact": true
    }
  }
]
```

## 返却

3件補正完了。Luna元返却・独立レビュー・他正本は未変更。元Luna返却hashに対する不整合は本補正記録のbefore/afterで解決し、元返却を書き換えていない。stage/commitなし。上記一時控えは使用終了、受入まで継続保持。
