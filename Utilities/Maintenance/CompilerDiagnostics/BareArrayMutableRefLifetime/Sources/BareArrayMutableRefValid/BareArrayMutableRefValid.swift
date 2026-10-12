import BareArrayModule

public func mutateWithinOwnerScope() -> Int {
  let array = BareArray2D<Int>(repeating: 0, width: 2, height: 2)
  let reference = array.reference(at: 1, 1)
  reference.pointee = 7
  return array.element(at: 1, 1)
}
