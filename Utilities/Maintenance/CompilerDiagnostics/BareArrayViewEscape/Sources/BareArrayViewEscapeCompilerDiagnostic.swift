import BareArrayModule

@_lifetime(immortal)
func escapeOwned2DView() -> BareArray1DView<Int> {
  let array = BareArray2D<Int>(repeating: 0, width: 2, height: 2)
  return array[0]
}

@_lifetime(immortal)
func escapeOwned3DView() -> BareArray2DView<Int> {
  let array = BareArray3D<Int>(repeating: 0, width: 2, height: 2, depth: 2)
  return array[0]
}

@_lifetime(immortal)
func escapeOwned4DView() -> BareArray3DView<Int> {
  let array = BareArray4D<Int>(repeating: 0, size0: 2, size1: 2, size2: 2, size3: 2)
  return array[0]
}
