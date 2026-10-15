import OptionalElementBufferModule

// Expected: compiles. Each buffer can be borrowed, passed by `consume` to a new owner, and used
// through the new owner. These are the normal controls for the compile-fail targets.

func read1D(_ array: borrowing OptionalElementBuffer<Int>) -> Int? { array.element(at: 0) }
func take1D(_ array: consuming OptionalElementBuffer<Int>) -> Int? { array.element(at: 0) }

public func transfer1D() -> Int? {
  let array = OptionalElementBuffer<Int>(capacity: 1)
  array.setElement(1, at: 0)
  _ = read1D(array)
  let moved = consume array
  return take1D(moved)
}

func read2D(_ array: borrowing OptionalElementBuffer2D<Int>) -> Int? { array.element(at: 0, 0) }
func take2D(_ array: consuming OptionalElementBuffer2D<Int>) -> Int? { array.element(at: 0, 0) }

public func transfer2D() -> Int? {
  let array = OptionalElementBuffer2D<Int>(width: 1, height: 1)
  array.setElement(1, at: 0, 0)
  _ = read2D(array)
  let moved = consume array
  return take2D(moved)
}

func read3D(_ array: borrowing OptionalElementBuffer3D<Int>) -> Int? { array.element(at: 0, 0, 0) }
func take3D(_ array: consuming OptionalElementBuffer3D<Int>) -> Int? { array.element(at: 0, 0, 0) }

public func transfer3D() -> Int? {
  let array = OptionalElementBuffer3D<Int>(width: 1, height: 1, depth: 1)
  array.setElement(1, at: 0, 0, 0)
  _ = read3D(array)
  let moved = consume array
  return take3D(moved)
}

func read4D(_ array: borrowing OptionalElementBuffer4D<Int>) -> Int? {
  array.element(at: 0, 0, 0, 0)
}
func take4D(_ array: consuming OptionalElementBuffer4D<Int>) -> Int? {
  array.element(at: 0, 0, 0, 0)
}

public func transfer4D() -> Int? {
  let array = OptionalElementBuffer4D<Int>(size0: 1, size1: 1, size2: 1, size3: 1)
  array.setElement(1, at: 0, 0, 0, 0)
  _ = read4D(array)
  let moved = consume array
  return take4D(moved)
}
