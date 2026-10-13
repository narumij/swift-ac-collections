import BareArrayModule

@available(macOS 27.0, *)
public func mutateWithinOwnerScope() -> Int {
  var array = ElementBuffer2D<Int>(repeating: 0, width: 2, height: 2)
  var reference = array.reference(at: 1, 1)
  reference.value = 7
  return array.element(at: 1, 1)
}
