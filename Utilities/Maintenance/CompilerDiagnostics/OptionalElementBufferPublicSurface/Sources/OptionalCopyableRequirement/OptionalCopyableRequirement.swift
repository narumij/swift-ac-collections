import OptionalElementBufferModule

// Expected: four compile errors, one per call below. A generic parameter is implicitly
// `Copyable`, and every buffer type is `~Copyable`, so none of them satisfies the requirement.

func requiresCopyable<T>(_ value: T) {}

func copyable1D() {
  requiresCopyable(OptionalElementBuffer<Int>(capacity: 1))
}

func copyable2D() {
  requiresCopyable(OptionalElementBuffer2D<Int>(width: 1, height: 1))
}

func copyable3D() {
  requiresCopyable(OptionalElementBuffer3D<Int>(width: 1, height: 1, depth: 1))
}

func copyable4D() {
  requiresCopyable(OptionalElementBuffer4D<Int>(size0: 1, size1: 1, size2: 1, size3: 1))
}
