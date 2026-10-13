import BareArrayModule

@_lifetime(immortal)
@available(macOS 27.0, *)
func escapeOwned1DReference() -> MutableRef<Int> {
  var array = BareArray<Int>(repeating: 0, count: 1)
  return array.reference(at: 0)
}

@_lifetime(immortal)
@available(macOS 27.0, *)
func escapeOwned2DReference() -> MutableRef<Int> {
  var array = BareArray2D<Int>(repeating: 0, width: 1, height: 1)
  return array.reference(at: 0, 0)
}

@_lifetime(immortal)
@available(macOS 27.0, *)
func escapeOwned3DReference() -> MutableRef<Int> {
  var array = BareArray3D<Int>(repeating: 0, width: 1, height: 1, depth: 1)
  return array.reference(at: 0, 0, 0)
}

@_lifetime(immortal)
@available(macOS 27.0, *)
func escapeOwned4DReference() -> MutableRef<Int> {
  var array = BareArray4D<Int>(repeating: 0, size0: 1, size1: 1, size2: 1, size3: 1)
  return array.reference(at: 0, 0, 0, 0)
}
