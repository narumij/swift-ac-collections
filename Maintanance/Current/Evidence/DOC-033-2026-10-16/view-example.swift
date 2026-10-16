import RedBlackTreeCollections
var map: RedBlackTreeMultiMap<Int, String> = [1: "red", 1: "green", 1: "blue", 2: "orange"]
let key = 1
let elements = map[map.equalRange(key)]
for key in elements.keys { _ = key }
for value in elements.values { _ = value }
let i = map.lowerBound(key)
let j = map.index(after: i)
map[key].swapAt(i, j)
precondition(Array(map[key]) == ["green", "red", "blue"])
var detached = map[key]
detached.erase()
precondition(map.count(forKey: key) == 3)
map[key].popFirst()
map[key].erase()
precondition(map.count(forKey: key) == 0)
