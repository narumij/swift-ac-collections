import AcCollections
do {


}
do {


var permutations = [2, 1, 3].nextPermutations()

while let permutation = permutations.next() {
    print(Array(permutation))
}
// [2, 1, 3]
// [2, 3, 1]
// [3, 1, 2]
// [3, 2, 1]

}
do {


let memo = OptionalElementBuffer2D<Int>(width: 4, height: 3)

if memo.element(at: 2, 1) == nil {
    memo.setElement(42, at: 2, 1)
}

let value = memo.element(at: 2, 1) // 42
precondition(value == 42)
memo.setElement(nil, at: 2, 1)     // Unset this position again.

}
do {


let table = ElementBuffer2D(repeating: 0, width: 4, height: 3)
table.setElement(42, at: 2, 1)
let value = table.element(at: 2, 1) // 42
precondition(value == 42)

}
do {
if #available(macOS 27.0, iOS 27.0, tvOS 27.0, watchOS 27.0, visionOS 27.0, *) {
  var table = ElementBuffer2D(repeating: 0, width: 4, height: 3)

  do {
    var cell = table.reference(at: 2, 1)
    cell.value += 1
    cell.value += 2
  }

  let value = table.element(at: 2, 1) // 3
precondition(value == 3)
}

}
do {
if #available(macOS 27.0, iOS 27.0, tvOS 27.0, watchOS 27.0, visionOS 27.0, *) {
  var table = ElementBuffer2D(repeating: 0, width: 4, height: 3)
  do {
    var cell = table.reference(at: 2, 1)
    cell.value += 1
    cell.value += 2
  }
  let value = table.element(at: 2, 1) // 3
precondition(value == 3)
}

}