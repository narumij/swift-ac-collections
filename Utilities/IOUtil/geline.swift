import _FastIO

public
  enum IOUtilError: Swift.Error
{
  case unexpectedEmpty
}

@inlinable
public func getline<T>(_ transform: (UnsafePointer<UInt8>, Int) throws -> T) throws -> T {
  var utf8Start: UnsafeMutablePointer<UInt8>?
  let utf8Count = _readLine_stdin(&utf8Start)
  defer {
    _free(utf8Start)
  }
  guard utf8Count > 0, let utf8Start else {
    throw IOUtilError.unexpectedEmpty
  }
  return try transform(utf8Start, utf8Count)
}

// MARK: -

@inlinable
public func readIntLine<I>() -> [I]
where I: FixedWidthInteger & SignedInteger {
  try! getline { start, count in
    var pos = 0
    var nums: [I] = []
    while pos < count, start[pos] != 0x0A {
      nums.append(_parseSigned(start, count, &pos))
    }
    return nums
  }
}

@inlinable
public func readUIntLine<U>() -> [U]
where U: FixedWidthInteger & UnsignedInteger {
  try! getline { start, count in
    var pos = 0
    var nums: [U] = []
    while pos < count, start[pos] != 0x0A {
      nums.append(_parseUnsigned(start, count, &pos))
    }
    return nums
  }
}

@inlinable
func _parseSigned<I>(_ start: UnsafePointer<UInt8>,_ count: Int,_ pos: inout Int) -> I where I: FixedWidthInteger & SignedInteger {
  while pos < count, start[pos] == 0x20 {
    pos += 1
  }
  var num: I = 0
  var negative: Bool = false
  var c: I = I(start[pos])
  pos += 1
  if c == 0x2D {
    negative = true
  } else {
    num = c - 0x30
  }
  while true {
    c = I(start[pos])
    pos += 1
    if c == 0x0A || c == 0x20 {
      break
    }
    num = num * 10 + (negative ? -(c &- 0x30) : (c &- 0x30))
  }
  return num
}

@inlinable
func _parseUnsigned<U>(_ start: UnsafePointer<UInt8>,_ count: Int,_ pos: inout Int) -> U
where U: FixedWidthInteger & UnsignedInteger {
  while pos < count, start[pos] == 0x20 {
    pos += 1
  }
  var num: U = 0
  var c: U
  while true {
    c = U(start[pos])
    pos += 1
    if c == 0x0A || c == 0x20 {
      break
    }
    num = num * 10 + (c &- 0x30)
  }
  return num
}
