import OptionalElementBufferModule

// Expected: four compile errors, one per function below. Assignment moves a `~Copyable` buffer,
// so the original binding cannot be used afterwards. A Copyable buffer would compile here.

func useAfterConsume1D() {
  let original = OptionalElementBuffer<Int>(capacity: 1)
  let copy = original
  _ = original.element(at: 0)
  _ = copy.element(at: 0)
}

func useAfterConsume2D() {
  let original = OptionalElementBuffer2D<Int>(width: 1, height: 1)
  let copy = original
  _ = original.element(at: 0, 0)
  _ = copy.element(at: 0, 0)
}

func useAfterConsume3D() {
  let original = OptionalElementBuffer3D<Int>(width: 1, height: 1, depth: 1)
  let copy = original
  _ = original.element(at: 0, 0, 0)
  _ = copy.element(at: 0, 0, 0)
}

func useAfterConsume4D() {
  let original = OptionalElementBuffer4D<Int>(size0: 1, size1: 1, size2: 1, size3: 1)
  let copy = original
  _ = original.element(at: 0, 0, 0, 0)
  _ = copy.element(at: 0, 0, 0, 0)
}
