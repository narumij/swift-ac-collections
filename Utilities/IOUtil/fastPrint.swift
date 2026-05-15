import Foundation
import _FastIO

@inlinable
@inline(__always)
public func fastPrint<I>(_ x: I, terminater: Int32? = 0x0A)
where I: FixedWidthInteger & SignedInteger {
  ___print_int(Int64(x))
  if let terminater {
    putchar_unlocked(terminater)
  }
}

@inlinable
@inline(__always)
public func fastPrint<I>(_ x: I, terminater: Int32? = 0x0A)
where I: FixedWidthInteger & UnsignedInteger {
  ___print_uint(UInt64(x))
  if let terminater {
    putchar_unlocked(terminater)
  }
}

/// 数字出力用です。文字列にはfastPrint(asciiValues:)をお使いください
@inlinable
@inline(__always)
public func fastPrint<C, I>(_ a: C, separator: Int32 = 0x20, terminater: Int32 = 0x0A)
where
  C: Collection, C.Element == I, C.Index == Int,
  I: FixedWidthInteger & SignedInteger
{
  for i in 0..<a.count {
    ___print_int(Int64(a[i]))
    putchar_unlocked(i == a.count - 1 ? terminater : separator)
  }
}

/// 数字出力用です。文字列にはfastPrint(asciiValues:)をお使いください
@inlinable
@inline(__always)
public func fastPrint<C, I>(_ a: C, separator: Int32 = 0x20, terminater: Int32 = 0x0A)
where
  C: Collection, C.Element == I, C.Index == Int,
  I: FixedWidthInteger & UnsignedInteger
{
  for i in 0..<a.count {
    ___print_uint(UInt64(a[i]))
    putchar_unlocked(i == a.count - 1 ? terminater : separator)
  }
}

/// 数字出力用です。文字列にはfastPrint(asciiValues:)をお使いください
@inlinable
@inline(__always)
public func fastPrint<C, I>(_ a: C,_ transform: (C.Element) -> I, separator: Int32 = 0x20, terminater: Int32 = 0x0A)
where
  C: Collection, C.Index == Int,
  I: FixedWidthInteger & SignedInteger
{
  for i in 0..<a.count {
    ___print_int(Int64(transform(a[i])))
    putchar_unlocked(i == a.count - 1 ? terminater : separator)
  }
}

/// 数字出力用です。文字列にはfastPrint(asciiValues:)をお使いください
@inlinable
@inline(__always)
public func fastPrint<C, I>(_ a: C,_ transform: (C.Element) -> I,  separator: Int32 = 0x20, terminater: Int32 = 0x0A)
where
  C: Collection, C.Index == Int,
  I: FixedWidthInteger & UnsignedInteger
{
  for i in 0..<a.count {
    ___print_uint(UInt64(transform(a[i])))
    putchar_unlocked(i == a.count - 1 ? terminater : separator)
  }
}

// MARK: -

@inlinable
@inline(__always)
public func fastPrint(asciiValues s: [Int8], terminater: Int32? = 0x0A) {
  for c in s where c != 0 {
    putchar_unlocked(c)
  }
  if let terminater {
    putchar_unlocked(terminater)
  }
}

@inlinable
@inline(__always)
public func fastPrint(asciiValues s: [UInt8], terminater: Int32? = 0x0A) {
  for c in s {
    putchar_unlocked(c)
  }
  if let terminater {
    putchar_unlocked(terminater)
  }
}

@inlinable
@inline(__always)
public func fastPrint(_ s: [Character], terminater: Int32? = 0x0A) {
  for c in s {
    putchar_unlocked(c)
  }
  if let terminater {
    putchar_unlocked(terminater)
  }
}

@inlinable
@inline(__always)
func putchar_unlocked(_ c: Int8) {
  putchar_unlocked(Int32(c))
}

@inlinable
@inline(__always)
func putchar_unlocked(_ c: UInt8) {
  putchar_unlocked(Int32(c))
}

@inlinable
@inline(__always)
public func putchar_unlocked(_ c: Character) {
  for b in c.unicodeScalars {
    putchar_unlocked(Int32(bitPattern: b.value))
  }
}
