import ElementBufferModule

// Each function keeps a borrowed reference alive across a conflicting access to its owner.
// Every function must be rejected with exactly one exclusivity diagnostic; the matching
// sequential functions in BareArrayMutableRefValid perform the same access after the last use.

@available(macOS 27.0, *)
func conflictingRead1D() {
  var array = ElementBuffer<Int>(repeating: 0, count: 2)
  var reference = array.reference(at: 1)
  let observed = array.element(at: 0)
  reference.value = 2
  _ = observed
}

@available(macOS 27.0, *)
func conflictingSet1D() {
  var array = ElementBuffer<Int>(repeating: 0, count: 2)
  var reference = array.reference(at: 1)
  array.setElement(1, at: 0)
  reference.value = 2
}

@available(macOS 27.0, *)
func conflictingSecondReference1D() {
  var array = ElementBuffer<Int>(repeating: 0, count: 2)
  var reference = array.reference(at: 1)
  var other = array.reference(at: 0)
  other.value = 1
  reference.value = 2
}

@available(macOS 27.0, *)
func conflictingConsume1D() {
  var array = ElementBuffer<Int>(repeating: 0, count: 2)
  var reference = array.reference(at: 1)
  let moved = consume array
  reference.value = 2
  _ = moved
}

@available(macOS 27.0, *)
func conflictingReplace1D() {
  var array = ElementBuffer<Int>(repeating: 0, count: 2)
  var reference = array.reference(at: 1)
  array = ElementBuffer<Int>(repeating: 9, count: 2)
  reference.value = 2
  _ = array.element(at: 0)
}

@available(macOS 27.0, *)
func conflictingRead2D() {
  var array = ElementBuffer2D<Int>(repeating: 0, width: 2, height: 2)
  var reference = array.reference(at: 1, 1)
  let observed = array.element(at: 0, 0)
  reference.value = 2
  _ = observed
}

@available(macOS 27.0, *)
func conflictingSet2D() {
  var array = ElementBuffer2D<Int>(repeating: 0, width: 2, height: 2)
  var reference = array.reference(at: 1, 1)
  array.setElement(1, at: 0, 0)
  reference.value = 2
}

@available(macOS 27.0, *)
func conflictingSecondReference2D() {
  var array = ElementBuffer2D<Int>(repeating: 0, width: 2, height: 2)
  var reference = array.reference(at: 1, 1)
  var other = array.reference(at: 0, 0)
  other.value = 1
  reference.value = 2
}

@available(macOS 27.0, *)
func conflictingConsume2D() {
  var array = ElementBuffer2D<Int>(repeating: 0, width: 2, height: 2)
  var reference = array.reference(at: 1, 1)
  let moved = consume array
  reference.value = 2
  _ = moved
}

@available(macOS 27.0, *)
func conflictingReplace2D() {
  var array = ElementBuffer2D<Int>(repeating: 0, width: 2, height: 2)
  var reference = array.reference(at: 1, 1)
  array = ElementBuffer2D<Int>(repeating: 9, width: 2, height: 2)
  reference.value = 2
  _ = array.element(at: 0, 0)
}

@available(macOS 27.0, *)
func conflictingRead3D() {
  var array = ElementBuffer3D<Int>(repeating: 0, width: 2, height: 2, depth: 2)
  var reference = array.reference(at: 1, 1, 1)
  let observed = array.element(at: 0, 0, 0)
  reference.value = 2
  _ = observed
}

@available(macOS 27.0, *)
func conflictingSet3D() {
  var array = ElementBuffer3D<Int>(repeating: 0, width: 2, height: 2, depth: 2)
  var reference = array.reference(at: 1, 1, 1)
  array.setElement(1, at: 0, 0, 0)
  reference.value = 2
}

@available(macOS 27.0, *)
func conflictingSecondReference3D() {
  var array = ElementBuffer3D<Int>(repeating: 0, width: 2, height: 2, depth: 2)
  var reference = array.reference(at: 1, 1, 1)
  var other = array.reference(at: 0, 0, 0)
  other.value = 1
  reference.value = 2
}

@available(macOS 27.0, *)
func conflictingConsume3D() {
  var array = ElementBuffer3D<Int>(repeating: 0, width: 2, height: 2, depth: 2)
  var reference = array.reference(at: 1, 1, 1)
  let moved = consume array
  reference.value = 2
  _ = moved
}

@available(macOS 27.0, *)
func conflictingReplace3D() {
  var array = ElementBuffer3D<Int>(repeating: 0, width: 2, height: 2, depth: 2)
  var reference = array.reference(at: 1, 1, 1)
  array = ElementBuffer3D<Int>(repeating: 9, width: 2, height: 2, depth: 2)
  reference.value = 2
  _ = array.element(at: 0, 0, 0)
}

@available(macOS 27.0, *)
func conflictingRead4D() {
  var array = ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 2, size2: 2, size3: 2)
  var reference = array.reference(at: 1, 1, 1, 1)
  let observed = array.element(at: 0, 0, 0, 0)
  reference.value = 2
  _ = observed
}

@available(macOS 27.0, *)
func conflictingSet4D() {
  var array = ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 2, size2: 2, size3: 2)
  var reference = array.reference(at: 1, 1, 1, 1)
  array.setElement(1, at: 0, 0, 0, 0)
  reference.value = 2
}

@available(macOS 27.0, *)
func conflictingSecondReference4D() {
  var array = ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 2, size2: 2, size3: 2)
  var reference = array.reference(at: 1, 1, 1, 1)
  var other = array.reference(at: 0, 0, 0, 0)
  other.value = 1
  reference.value = 2
}

@available(macOS 27.0, *)
func conflictingConsume4D() {
  var array = ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 2, size2: 2, size3: 2)
  var reference = array.reference(at: 1, 1, 1, 1)
  let moved = consume array
  reference.value = 2
  _ = moved
}

@available(macOS 27.0, *)
func conflictingReplace4D() {
  var array = ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 2, size2: 2, size3: 2)
  var reference = array.reference(at: 1, 1, 1, 1)
  array = ElementBuffer4D<Int>(repeating: 9, size0: 2, size1: 2, size2: 2, size3: 2)
  reference.value = 2
  _ = array.element(at: 0, 0, 0, 0)
}
