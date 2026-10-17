# OPS-076 第2区切りの確認手順（入力版 `56005d06d1ad97ed544cda914e12ee725692dc58`）

2026-10-17 / 姫（Opus 5.5）。6文書の追記で使ったコマンド。`S`は入力版。どれも読み取りだけ。作業ツリーではなく`git show $S:…`で読んだ。

```sh
S=56005d06d1ad97ed544cda914e12ee725692dc58; C=Maintanance/Current
# 証拠commitの解決
for c in 25518fdd1 9ddb150f 46d50288 7a092b72 039b2141 1401a28ff34b04a4f6f0f2fec19d3e15903ae76f e2dd63d62 1f87e37a fec74691; do git rev-parse --verify -q $c^{commit}; done
# OPS-066試行の冒頭ブロック（4件の3行目）
for f in REGISTRY_STUDIO_MILESTONE_CONNECT REGISTRY_STUDIO_SINGLE_LINE_KIND ASAN_STRIP_ENV_FIXED_REVISION_VALIDATION RED_BLACK_TREE_DOCC_PREVIEW_REVIEW; do git show $S:$C/$f.md | sed -n 3p; done
git cat-file -e $S:$C/Evidence/RBT-049
# OPS-072受入の補正2・3
git show --stat e2dd63d62 -- $C/DOCUMENTATION_MILESTONES.md
git ls-tree -d --name-only $S Sources/
# OPS-072試行の対象3文書：入力版fec74691から削除行がないこと
for f in ASAN_DEATH_TEST_INVESTIGATION EXTERNAL_TYPE_EXTENSION_AUDIT PERMUTATION_SEQUENCE_INVALID_VIEW_ISSUE; do git diff fec74691 $S -- $C/$f.md | grep -c '^-[^-]'; done
# DocCレビュー：レビュー版から製品ソースの差分
git diff --stat 1401a28ff34b04a4f6f0f2fec19d3e15903ae76f $S -- Sources Package.swift
# Studio
git show -M --stat bbddb7ff3   # index.html -> index.template.html
git show $S:Maintanance/RegistryApp/index.template.html | grep -n '版ゲートへはタスクをつなげません\|旧形式（線の種類あり）のJSONは読み込めません\|function addMilestoneRelation\|isMilestoneLink'
git show $S:Maintanance/RegistryApp/sync.py | grep -n 'expected 3 columns'
git show $S:Maintanance/ProgressV2/TASK_REGISTRY_V2.md | sed -n '331,360p'   # 3列・28行、制約文の書き出し
```

結果は各文書の追記表に記した。食い違い（実施時の事実が変わったもの）は2件で、どちらも判断は変わらない：`index.html`→`index.template.html`の改名（`bbddb7ff3`）、マイルストーン接続15行→28行。
