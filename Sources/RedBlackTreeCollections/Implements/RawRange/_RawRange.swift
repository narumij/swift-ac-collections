//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
// This implementation includes code derived from LLVM libc++'s red-black tree
// implementation, originally distributed under the Apache License v2.0 with
// LLVM Exceptions.
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by
// narumij.
//
//===----------------------------------------------------------------------===//

public struct _RawRange<Bound> {

  @usableFromInline
  internal var lowerBound: Bound

  @usableFromInline
  internal var upperBound: Bound

  @inlinable
  internal init(lowerBound: Bound, upperBound: Bound) {
    self.lowerBound = lowerBound
    self.upperBound = upperBound
  }
}

extension _RawRange {

  @inlinable
  func map<T>(_ f: (Bound) -> T) -> _RawRange<T> {
    .init(lowerBound: f(lowerBound), upperBound: f(upperBound))
  }

  @inlinable
  func fold<T>(_ f: (Bound, Bound) -> T) -> T {
    f(lowerBound, upperBound)
  }
}

@inlinable
func sequence<T, E>(
  _ range: _RawRange<Result<T, E>>
) -> Result<_RawRange<T>, E> {
  range.fold {
    liftA2($0, $1) {
      _RawRange(lowerBound: $0, upperBound: $1)
    }
  }
}

@inlinable
func traverse<T, S, E>(
  _ range: _RawRange<T>,
  _ f: (T) -> Result<S, E>
) -> Result<_RawRange<S>, E> {
  range
    .map(f)
    .fold {
      liftA2($0, $1) {
        _RawRange(lowerBound: $0, upperBound: $1)
      }
    }
}

extension _RawRange where Bound == UnsafeMutablePointer<UnsafeNode> {

  @inlinable
  var unchecked: _RawRange<_SafePtr> {
    .init(
      lowerBound: lowerBound.unchecked,
      upperBound: upperBound.unchecked)
  }
}

@inlinable
func liftA2<T, S, E>(_ a: Result<T, E>, _ b: Result<T, E>, _ f: (T, T) -> S) -> Result<S, E> {
  switch (a, b) {
  case (.success(let a), .success(let b)):
    return .success(f(a, b))
  case (.failure(let e), _):
    return .failure(e)
  case (_, .failure(let e)):
    return .failure(e)
  }
}

@inlinable
func liftM2<T, S, E>(_ a: Result<T, E>, _ b: Result<T, E>, _ f: (T, T) -> Result<S, E>) -> Result<
  S, E
> {
  switch (a, b) {
  case (.success(let a), .success(let b)):
    return f(a, b)
  case (.failure(let e), _):
    return .failure(e)
  case (_, .failure(let e)):
    return .failure(e)
  }
}

public typealias _NodeRange = _RawRange<UnsafeMutablePointer<UnsafeNode>>
// _SafeNodeRangeがいいという説がある
public typealias _SafeRange = Result<_NodeRange, SealError>

extension _RawRange where Bound == _SafePtr {
  
  @inlinable
  var safeRange: _SafeRange { sequence(self) }
}
