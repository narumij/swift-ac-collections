import ElementBufferModule

@available(macOS 27.0, *)
public func mutateWithinOwnerScope() -> Int {
  var array = ElementBuffer2D<Int>(repeating: 0, width: 2, height: 2)
  var reference = array.reference(at: 1, 1)
  reference.value = 7
  return array.element(at: 1, 1)
}

// The same owner accesses as BareArrayMutableRefConflict, performed after the reference's last use.

@available(macOS 27.0, *)
public func sequentialRead1D() {
  var array = ElementBuffer<Int>(repeating: 0, count: 2)
  var reference = array.reference(at: 1)
  reference.value = 2
  let observed = array.element(at: 0)
  _ = observed
}

@available(macOS 27.0, *)
public func sequentialSet1D() {
  var array = ElementBuffer<Int>(repeating: 0, count: 2)
  var reference = array.reference(at: 1)
  reference.value = 2
  array.setElement(1, at: 0)
}

@available(macOS 27.0, *)
public func sequentialSecondReference1D() {
  var array = ElementBuffer<Int>(repeating: 0, count: 2)
  var reference = array.reference(at: 1)
  reference.value = 2
  var other = array.reference(at: 0)
  other.value = 1
}

@available(macOS 27.0, *)
public func sequentialConsume1D() {
  var array = ElementBuffer<Int>(repeating: 0, count: 2)
  var reference = array.reference(at: 1)
  reference.value = 2
  let moved = consume array
  _ = moved
}

@available(macOS 27.0, *)
public func sequentialReplace1D() {
  var array = ElementBuffer<Int>(repeating: 0, count: 2)
  var reference = array.reference(at: 1)
  reference.value = 2
  array = ElementBuffer<Int>(repeating: 9, count: 2)
  _ = array.element(at: 0)
}

@available(macOS 27.0, *)
public func sequentialRead2D() {
  var array = ElementBuffer2D<Int>(repeating: 0, width: 2, height: 2)
  var reference = array.reference(at: 1, 1)
  reference.value = 2
  let observed = array.element(at: 0, 0)
  _ = observed
}

@available(macOS 27.0, *)
public func sequentialSet2D() {
  var array = ElementBuffer2D<Int>(repeating: 0, width: 2, height: 2)
  var reference = array.reference(at: 1, 1)
  reference.value = 2
  array.setElement(1, at: 0, 0)
}

@available(macOS 27.0, *)
public func sequentialSecondReference2D() {
  var array = ElementBuffer2D<Int>(repeating: 0, width: 2, height: 2)
  var reference = array.reference(at: 1, 1)
  reference.value = 2
  var other = array.reference(at: 0, 0)
  other.value = 1
}

@available(macOS 27.0, *)
public func sequentialConsume2D() {
  var array = ElementBuffer2D<Int>(repeating: 0, width: 2, height: 2)
  var reference = array.reference(at: 1, 1)
  reference.value = 2
  let moved = consume array
  _ = moved
}

@available(macOS 27.0, *)
public func sequentialReplace2D() {
  var array = ElementBuffer2D<Int>(repeating: 0, width: 2, height: 2)
  var reference = array.reference(at: 1, 1)
  reference.value = 2
  array = ElementBuffer2D<Int>(repeating: 9, width: 2, height: 2)
  _ = array.element(at: 0, 0)
}

@available(macOS 27.0, *)
public func sequentialRead3D() {
  var array = ElementBuffer3D<Int>(repeating: 0, width: 2, height: 2, depth: 2)
  var reference = array.reference(at: 1, 1, 1)
  reference.value = 2
  let observed = array.element(at: 0, 0, 0)
  _ = observed
}

@available(macOS 27.0, *)
public func sequentialSet3D() {
  var array = ElementBuffer3D<Int>(repeating: 0, width: 2, height: 2, depth: 2)
  var reference = array.reference(at: 1, 1, 1)
  reference.value = 2
  array.setElement(1, at: 0, 0, 0)
}

@available(macOS 27.0, *)
public func sequentialSecondReference3D() {
  var array = ElementBuffer3D<Int>(repeating: 0, width: 2, height: 2, depth: 2)
  var reference = array.reference(at: 1, 1, 1)
  reference.value = 2
  var other = array.reference(at: 0, 0, 0)
  other.value = 1
}

@available(macOS 27.0, *)
public func sequentialConsume3D() {
  var array = ElementBuffer3D<Int>(repeating: 0, width: 2, height: 2, depth: 2)
  var reference = array.reference(at: 1, 1, 1)
  reference.value = 2
  let moved = consume array
  _ = moved
}

@available(macOS 27.0, *)
public func sequentialReplace3D() {
  var array = ElementBuffer3D<Int>(repeating: 0, width: 2, height: 2, depth: 2)
  var reference = array.reference(at: 1, 1, 1)
  reference.value = 2
  array = ElementBuffer3D<Int>(repeating: 9, width: 2, height: 2, depth: 2)
  _ = array.element(at: 0, 0, 0)
}

@available(macOS 27.0, *)
public func sequentialRead4D() {
  var array = ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 2, size2: 2, size3: 2)
  var reference = array.reference(at: 1, 1, 1, 1)
  reference.value = 2
  let observed = array.element(at: 0, 0, 0, 0)
  _ = observed
}

@available(macOS 27.0, *)
public func sequentialSet4D() {
  var array = ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 2, size2: 2, size3: 2)
  var reference = array.reference(at: 1, 1, 1, 1)
  reference.value = 2
  array.setElement(1, at: 0, 0, 0, 0)
}

@available(macOS 27.0, *)
public func sequentialSecondReference4D() {
  var array = ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 2, size2: 2, size3: 2)
  var reference = array.reference(at: 1, 1, 1, 1)
  reference.value = 2
  var other = array.reference(at: 0, 0, 0, 0)
  other.value = 1
}

@available(macOS 27.0, *)
public func sequentialConsume4D() {
  var array = ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 2, size2: 2, size3: 2)
  var reference = array.reference(at: 1, 1, 1, 1)
  reference.value = 2
  let moved = consume array
  _ = moved
}

@available(macOS 27.0, *)
public func sequentialReplace4D() {
  var array = ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 2, size2: 2, size3: 2)
  var reference = array.reference(at: 1, 1, 1, 1)
  reference.value = 2
  array = ElementBuffer4D<Int>(repeating: 9, size0: 2, size1: 2, size2: 2, size3: 2)
  _ = array.element(at: 0, 0, 0, 0)
}
