mkdir -p ./MarriedSource

find ../../Sources/RedBlackTreeModule -name '*.swift' \
  | sort \
  | xargs cat \
  > ./MarriedSource/RedBlackTree.work.swift

sed '/^[[:space:]]*\/\//d' ./MarriedSource/RedBlackTree.work.swift \
> ./MarriedSource/RedBlackTree.swift_

rm ./MarriedSource/RedBlackTree.work.swift
