# OPS-076 第4区切り：候補12件への追記（入力版 `1175e583b1857819e9e0b07b83a1cb5fc8be657a`）

2026-10-17 / 姫（Opus 5.5）。ROUND3の候補12件（#2、#9〜13、#17、#23、#33、#35、#36、#41）。着手時、12文書は入力版から変更がない（`git diff --stat <版> -- <12文書>`が空）。Registryの行から占有中・ユーザー確定と分かるものはなかった。保留は0件。

## 確かめ方の区別

- 固定treeで確かめたもの：`git show <版>:…`・`git diff <base> <版>`・blobのSHA-256・`Package.swift`／workflow／`sync.py`の行。
- ref集合や作業環境に依存するもの（固定版の事実として扱わない）：tag`0.5.3`の指す先、`git check-ignore`の判定、ローカル成果物、GitHub CIの実走。

## 再実行

```sh
S=1175e583b1857819e9e0b07b83a1cb5fc8be657a
git show $S:.github/workflows/ci.yml | sed -n 384p; git show $S:.github/workflows/candidate.yml | sed -n '145p;152,153p'
git diff --numstat 3780fb907c1c1107582eec233b22439faa9cb872 $S -- Maintanance/UserDocuments/RedBlackTreeCollections/Head Sources
git log --format='%H %s' 3780fb90..$S -- Maintanance/UserDocuments/RedBlackTreeCollections/Head Sources
git diff --stat 1dc613ffa45dd9475f2270a2409f71506d860d25 $S -- Maintanance/UserDocuments/RedBlackTreeCollections/Head Sources
for n in RedBlackTreeMultiSet/RedBlackTreeMultiSet.swift RedBlackTreeMultiMap/RedBlackTreeMultiMap.swift 'RedBlackTreeMultiMap/RedBlackTreeMultiMap+Deprecated.swift'; do git show "$S:Sources/RedBlackTreeCollections/$n" | shasum -a 256; done
git diff --name-only f6e181b2ab31dcd17c51c11236a6b5dd4b1024b8 $S -- Sources Package.swift
git show $S:Package.swift | sed -n '335p;346,348p'
git show $S:Maintanance/RegistryApp/sync.py | sed -n 492p
git rev-parse --verify a5a39d124eb4c63fa3fe3539f2024bedc367d1e9^{commit} 139ffef8db3eb75d118dbaecc8a1ec05d2e9894f^{commit}
git ls-tree --name-only $S Maintanance/RegistryApp/; git show $S:.gitignore | sed -n 21p
```
