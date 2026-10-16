import RedBlackTreeCollections
print("RedBlackTreeSet.ja.md:2")
do {
let numbers: RedBlackTreeSet = [5, 2, 4, 1, 3]

print(numbers)
// [1, 2, 3, 4, 5]

}
print("RedBlackTreeSet.ja.md:3")
do {
var set: RedBlackTreeSet<Int> = []

set.insert(3) // -> [3]
set.insert(1) // -> [1, 3]
set.insert(4) // -> [1, 3, 4]
set.insert(1) // -> [1, 3, 4]
set.insert(5) // -> [1, 3, 4, 5]

}
print("RedBlackTreeSet.ja.md:4")
do {
let numbers: RedBlackTreeSet = [3, 1, 2, 3, 2, 1]

print(numbers)
// [1, 2, 3]

}
print("RedBlackTreeSet.ja.md:5")
do {
let numbers: RedBlackTreeSet = [7, 2, 9, 1, 5]

for number in numbers {
  print(number)
}

}
print("RedBlackTreeSet.ja.md:6")
do {
var numbers: RedBlackTreeSet = [1, 3, 5]

numbers.insert(4)
// [1, 3, 4, 5]

numbers.remove(3)
// [1, 4, 5]

}
print("RedBlackTreeSet.ja.md:7")
do {
var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]

set.remove(3)
// [1, 4, 5]

}
print("RedBlackTreeSet.ja.md:8")
do {
var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]

set[.lowerBound(4) ..< .end].erase()
// [1, 3]

}
print("RedBlackTreeSet.ja.md:9")
do {
var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]

set.erase(.lowerBound(4) ..< .end)
// [1, 3]

}
print("RedBlackTreeSet.ja.md:10")
do {
var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]

var i = set.startIndex
while i != set.endIndex {
  i = set.erase(i)
}

}
print("RedBlackTreeSet.ja.md:11")
do {
var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]

print(set[.start.advanced(by: 1)])
// Optional(3)

}
print("RedBlackTreeSet.ja.md:12")
do {
var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]

print(set[.lowerBound(5)])
// Optional(5)

print(set[.upperBound(5)])
// nil (equivalent to end)

print(set[.find(2)])
// nil (not found)

}
print("RedBlackTreeSet.md:2")
do {
let numbers: RedBlackTreeSet = [5, 2, 4, 1, 3]

print(numbers)
// [1, 2, 3, 4, 5]

}
print("RedBlackTreeSet.md:3")
do {
let numbers: RedBlackTreeSet = [3, 1, 2, 3, 2, 1]

print(numbers)
// [1, 2, 3]

}
print("RedBlackTreeSet.md:4")
do {
let numbers: RedBlackTreeSet = [7, 2, 9, 1, 5]

for number in numbers {
  print(number)
}

}
print("RedBlackTreeSet.md:5")
do {
var set: RedBlackTreeSet<Int> = []
set.insert(3) // -> [3]
set.insert(1) // -> [1, 3]
set.insert(4) // -> [1, 3, 4]
set.insert(1) // -> [1, 3, 4]
set.insert(5) // -> [1, 3, 4, 5]

}
print("RedBlackTreeSet.md:6")
do {
var numbers: RedBlackTreeSet = [1, 3, 5]

numbers.insert(4)
// [1, 3, 4, 5]

numbers.remove(3)
// [1, 4, 5]

}
print("RedBlackTreeSet.md:7")
do {
var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]
set.remove(3) // -> [1, 4, 5]

}
print("RedBlackTreeSet.md:8")
do {
var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]
set[.lowerBound(4) ..< .end].erase() // -> [1, 3]

}
print("RedBlackTreeSet.md:9")
do {
var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]
set.erase(.lowerBound(4) ..< .end) // -> [1, 3]

}
print("RedBlackTreeSet.md:10")
do {
var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]
var i = set.startIndex
while i != set.endIndex {
  i = set.erase(i)
}

}
print("RedBlackTreeSet.md:11")
do {
var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]
print(set[.start.advanced(by: 1)]) // Optional containing 3

}
print("RedBlackTreeSet.md:12")
do {
var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]
print(set[.lowerBound(5)]) // Optional containing 5
print(set[.upperBound(5)]) // -> nil (equivalent to end)
print(set[.find(2)]) // -> nil (not found)

}
print("RedBlackTreeDictionary.ja.md:1")
do {
var dict: RedBlackTreeDictionary<Int, String> = [:]
dict[3] = "c"   // -> [3: "c"]
dict[1] = "a"   // -> [1: "a", 3: "c"]
dict[4] = "d"   // -> [1: "a", 3: "c", 4: "d"]
dict[1] = "aa"  // -> [1: "aa", 3: "c", 4: "d"] (updated)

}
print("RedBlackTreeDictionary.ja.md:2")
do {
var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
dict.removeValue(forKey: 3) // -> [1: "a", 4: "d", 5: "e"]

}
print("RedBlackTreeDictionary.ja.md:3")
do {
var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
dict[dict.lowerBound(4)..<dict.endIndex].erase() // -> [1: "a", 3: "c"]

}
print("RedBlackTreeDictionary.ja.md:4")
do {
var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
dict.erase(dict.lowerBound(4)..<dict.endIndex) // -> [1: "a", 3: "c"]

}
print("RedBlackTreeDictionary.ja.md:5")
do {
var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
var i = dict.startIndex
while i != dict.endIndex {
  i = dict.erase(i)
}

}
print("RedBlackTreeDictionary.ja.md:6")
do {
var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
print(dict[.lowerBound(4)]) // Optional containing (4, "d")
print(dict[.upperBound(5)]) // -> nil (equivalent to end)
print(dict[.find(2)])       // -> nil (not found)

}
print("RedBlackTreeDictionary.md:1")
do {
var dict: RedBlackTreeDictionary<Int, String> = [:]
dict[3] = "c"   // -> [3: "c"]
dict[1] = "a"   // -> [1: "a", 3: "c"]
dict[4] = "d"   // -> [1: "a", 3: "c", 4: "d"]
dict[1] = "aa"  // -> [1: "aa", 3: "c", 4: "d"] (updated)

}
print("RedBlackTreeDictionary.md:2")
do {
var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
dict.removeValue(forKey: 3) // -> [1: "a", 4: "d", 5: "e"]

}
print("RedBlackTreeDictionary.md:3")
do {
var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
dict[dict.lowerBound(4)..<dict.endIndex].erase() // -> [1: "a", 3: "c"]

}
print("RedBlackTreeDictionary.md:4")
do {
var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
dict.erase(dict.lowerBound(4)..<dict.endIndex) // -> [1: "a", 3: "c"]

}
print("RedBlackTreeDictionary.md:5")
do {
var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
var i = dict.startIndex
while i != dict.endIndex {
  i = dict.erase(i)
}

}
print("RedBlackTreeDictionary.md:6")
do {
var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
print(dict[.lowerBound(4)]) // Optional containing (4, "d")
print(dict[.upperBound(5)]) // -> nil (equivalent to end)
print(dict[.find(2)])       // -> nil (not found)

}
print("RedBlackTreeMultiSet.ja.md:2")
do {
let numbers: RedBlackTreeMultiSet = [5, 2, 4, 2, 1, 3, 3]

print(numbers)
// [1, 2, 2, 3, 3, 4, 5]

}
print("RedBlackTreeMultiSet.ja.md:3")
do {
let numbers: RedBlackTreeMultiSet = [3, 1, 2, 3, 2, 1]

print(numbers)
// [1, 1, 2, 2, 3, 3]

}
print("RedBlackTreeMultiSet.ja.md:4")
do {
var set: RedBlackTreeMultiSet<Int> = []
set.insert(3) // -> [3]
set.insert(1) // -> [1, 3]
set.insert(4) // -> [1, 3, 4]
set.insert(1) // -> [1, 1, 3, 4]
set.insert(5) // -> [1, 1, 3, 4, 5]

}
print("RedBlackTreeMultiSet.ja.md:5")
do {
var numbers: RedBlackTreeMultiSet = [1, 3, 3, 5]

numbers.insert(3)
// [1, 3, 3, 3, 5]

numbers.insert(4)
// [1, 3, 3, 3, 4, 5]

}
print("RedBlackTreeMultiSet.ja.md:6")
do {
var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
set.eraseUnique(3) // -> [1, 1, 4, 5]

}
print("RedBlackTreeMultiSet.ja.md:7")
do {
var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
set[set.lowerBound(4)..<set.endIndex].erase() // -> [1, 1, 3]

}
print("RedBlackTreeMultiSet.ja.md:8")
do {
var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
set.erase(set.lowerBound(4)..<set.endIndex) // -> [1, 1, 3]

}
print("RedBlackTreeMultiSet.ja.md:9")
do {
var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
var i = set.startIndex
while i != set.endIndex {
  i = set.erase(i)
}

}
print("RedBlackTreeMultiSet.ja.md:10")
do {
let numbers: RedBlackTreeMultiSet = [7, 2, 9, 2, 1, 5]

for number in numbers {
  print(number)
}

}
print("RedBlackTreeMultiSet.ja.md:11")
do {
var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
print(set[.start.advanced(by: 1)]) // Optional containing 1

}
print("RedBlackTreeMultiSet.ja.md:12")
do {
var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
print(set[.lowerBound(5)]) // Optional containing 5
print(set[.upperBound(5)]) // -> nil (equivalent to end)
print(set[.find(2)]) // -> nil (not found)

}
print("RedBlackTreeMultiSet.md:2")
do {
let numbers: RedBlackTreeMultiSet = [5, 2, 4, 2, 1, 3, 3]

print(numbers)
// [1, 2, 2, 3, 3, 4, 5]

}
print("RedBlackTreeMultiSet.md:3")
do {
let numbers: RedBlackTreeMultiSet = [3, 1, 2, 3, 2, 1]

print(numbers)
// [1, 1, 2, 2, 3, 3]

}
print("RedBlackTreeMultiSet.md:4")
do {
var set: RedBlackTreeMultiSet<Int> = []
set.insert(3) // -> [3]
set.insert(1) // -> [1, 3]
set.insert(4) // -> [1, 3, 4]
set.insert(1) // -> [1, 1, 3, 4]
set.insert(5) // -> [1, 1, 3, 4, 5]

}
print("RedBlackTreeMultiSet.md:5")
do {
var numbers: RedBlackTreeMultiSet = [1, 3, 3, 5]

numbers.insert(3)
// [1, 3, 3, 3, 5]

numbers.insert(4)
// [1, 3, 3, 3, 4, 5]

}
print("RedBlackTreeMultiSet.md:6")
do {
var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
set.eraseUnique(3) // -> [1, 1, 4, 5]

}
print("RedBlackTreeMultiSet.md:7")
do {
var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
set[set.lowerBound(4)..<set.endIndex].erase() // -> [1, 1, 3]

}
print("RedBlackTreeMultiSet.md:8")
do {
var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
set.erase(set.lowerBound(4)..<set.endIndex) // -> [1, 1, 3]

}
print("RedBlackTreeMultiSet.md:9")
do {
var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
var i = set.startIndex
while i != set.endIndex {
  i = set.erase(i)
}

}
print("RedBlackTreeMultiSet.md:10")
do {
let numbers: RedBlackTreeMultiSet = [7, 2, 9, 2, 1, 5]

for number in numbers {
  print(number)
}

}
print("RedBlackTreeMultiSet.md:11")
do {
var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
print(set[.start.advanced(by: 1)]) // Optional containing 1

}
print("RedBlackTreeMultiSet.md:12")
do {
var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
print(set[.lowerBound(5)]) // Optional containing 5
print(set[.upperBound(5)]) // -> nil (equivalent to end)
print(set[.find(2)]) // -> nil (not found)

}
print("RedBlackTreeMultiMap.ja.md:2")
do {
var map: RedBlackTreeMultiMap<Int, String> = []
map.insert(key: 3, value: "a") // -> [3: "a"]
map.insert(key: 1, value: "b") // -> [1: "b", 3: "a"]
map.insert(key: 4, value: "c") // -> [1: "b", 3: "a", 4: "c"]
map.insert(key: 1, value: "d") // -> [1: "b", 1: "d", 3: "a", 4: "c"]
map.insert(key: 5, value: "e") // -> [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]

}
print("RedBlackTreeMultiMap.ja.md:3")
do {
var map: RedBlackTreeMultiMap<Int,String> = [1:"red",1:"green",1:"blue",2:"orange"]
let key=1
let i=map.lowerBound(key)
let j=map.index(after:i)
map[1]

}
print("RedBlackTreeMultiMap.ja.md:4")
do {
var map: RedBlackTreeMultiMap<Int,String> = [1:"red",1:"green",1:"blue",2:"orange"]
let key=1
let i=map.lowerBound(key)
let j=map.index(after:i)
let elements = map[map.equalRange(key)]

for key in elements.keys {
  // ...
}

for value in elements.values {
  // ...
}

}
print("RedBlackTreeMultiMap.ja.md:5")
do {
var map: RedBlackTreeMultiMap<Int,String> = [1:"red",1:"green",1:"blue",2:"orange"]
let key=1
let i=map.lowerBound(key)
let j=map.index(after:i)
map[key].popFirst()
map[key].erase()

}
print("RedBlackTreeMultiMap.ja.md:7")
do {
var map: RedBlackTreeMultiMap<Int,String> = [1:"red",1:"green",1:"blue",2:"orange"]
let key=1
let i=map.lowerBound(key)
let j=map.index(after:i)
map[key].swapAt(i, j)

}
print("RedBlackTreeMultiMap.ja.md:8")
do {
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
map.eraseUnique(3) // -> [1: "b", 1: "d", 4: "c", 5: "e"]

}
print("RedBlackTreeMultiMap.ja.md:9")
do {
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
map[map.lowerBound(4)..<map.endIndex].erase() // -> [1: "b", 1: "d", 3: "a"]

}
print("RedBlackTreeMultiMap.ja.md:10")
do {
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
map.erase(map.lowerBound(4)..<map.endIndex) // -> [1: "b", 1: "d", 3: "a"]

}
print("RedBlackTreeMultiMap.ja.md:11")
do {
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
var i = map.startIndex
while i != map.endIndex {
  i = map.erase(i)
}

}
print("RedBlackTreeMultiMap.ja.md:12")
do {
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
print(map[.start.advanced(by: 1)]) // Optional containing (1, "d")

}
print("RedBlackTreeMultiMap.ja.md:13")
do {
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
print(map[.lowerBound(5)]) // Optional containing (5, "e")
print(map[.upperBound(5)]) // -> nil (equivalent to end)
print(map[.find(2)])       // -> nil (not found)

}
print("RedBlackTreeMultiMap.md:2")
do {
var map: RedBlackTreeMultiMap<Int, String> = []
map.insert(key: 3, value: "a") // -> [3: "a"]
map.insert(key: 1, value: "b") // -> [1: "b", 3: "a"]
map.insert(key: 4, value: "c") // -> [1: "b", 3: "a", 4: "c"]
map.insert(key: 1, value: "d") // -> [1: "b", 1: "d", 3: "a", 4: "c"]
map.insert(key: 5, value: "e") // -> [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]

}
print("RedBlackTreeMultiMap.md:3")
do {
var map: RedBlackTreeMultiMap<Int,String> = [1:"red",1:"green",1:"blue",2:"orange"]
let key=1
let i=map.lowerBound(key)
let j=map.index(after:i)
map[1]

}
print("RedBlackTreeMultiMap.md:4")
do {
var map: RedBlackTreeMultiMap<Int,String> = [1:"red",1:"green",1:"blue",2:"orange"]
let key=1
let i=map.lowerBound(key)
let j=map.index(after:i)
let elements = map[map.equalRange(key)]

for key in elements.keys {
  // ...
}

for value in elements.values {
  // ...
}

}
print("RedBlackTreeMultiMap.md:5")
do {
var map: RedBlackTreeMultiMap<Int,String> = [1:"red",1:"green",1:"blue",2:"orange"]
let key=1
let i=map.lowerBound(key)
let j=map.index(after:i)
map[key].popFirst()
map[key].erase()

}
print("RedBlackTreeMultiMap.md:7")
do {
var map: RedBlackTreeMultiMap<Int,String> = [1:"red",1:"green",1:"blue",2:"orange"]
let key=1
let i=map.lowerBound(key)
let j=map.index(after:i)
map[key].swapAt(i, j)

}
print("RedBlackTreeMultiMap.md:8")
do {
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
map.eraseUnique(3) // -> [1: "b", 1: "d", 4: "c", 5: "e"]

}
print("RedBlackTreeMultiMap.md:9")
do {
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
map[map.lowerBound(4)..<map.endIndex].erase() // -> [1: "b", 1: "d", 3: "a"]

}
print("RedBlackTreeMultiMap.md:10")
do {
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
map.erase(map.lowerBound(4)..<map.endIndex) // -> [1: "b", 1: "d", 3: "a"]

}
print("RedBlackTreeMultiMap.md:11")
do {
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
var i = map.startIndex
while i != map.endIndex {
  i = map.erase(i)
}

}
print("RedBlackTreeMultiMap.md:12")
do {
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
print(map[.start.advanced(by: 1)]) // Optional containing (1, "d")

}
print("RedBlackTreeMultiMap.md:13")
do {
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
print(map[.lowerBound(5)]) // Optional containing (5, "e")
print(map[.upperBound(5)]) // -> nil (equivalent to end)
print(map[.find(2)])       // -> nil (not found)

}