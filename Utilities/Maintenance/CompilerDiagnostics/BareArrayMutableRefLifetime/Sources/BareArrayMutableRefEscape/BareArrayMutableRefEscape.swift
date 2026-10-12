import BareArrayModule

@_lifetime(immortal)
func escapeOwned1DReference() -> BareArray<Int>.Reference {
  let array = BareArray<Int>(repeating: 0, count: 1)
  return array.reference(at: 0)
}

@_lifetime(immortal)
func escapeOwned2DReference() -> BareArray2D<Int>.Reference {
  let array = BareArray2D<Int>(repeating: 0, width: 1, height: 1)
  return array.reference(at: 0, 0)
}

@_lifetime(immortal)
func escapeOwned3DReference() -> BareArray3D<Int>.Reference {
  let array = BareArray3D<Int>(repeating: 0, width: 1, height: 1, depth: 1)
  return array.reference(at: 0, 0, 0)
}

@_lifetime(immortal)
func escapeOwned4DReference() -> BareArray4D<Int>.Reference {
  let array = BareArray4D<Int>(repeating: 0, size0: 1, size1: 1, size2: 1, size3: 1)
  return array.reference(at: 0, 0, 0, 0)
}
