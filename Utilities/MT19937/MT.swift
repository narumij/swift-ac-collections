import _MT19937

@usableFromInline
class _MT19937_64 {
  @usableFromInline
  var rng: UnsafeMutablePointer<_MT19937.mt19937_64>
  @inlinable
  public init(seed: UInt32) {
    rng = mt19937_64_create(seed)
  }
  deinit {
    mt19937_64_destroy(rng)
  }
  @inlinable
  public func next() -> UInt64 {
    mt19937_64_next_u64(rng)
  }
  @inlinable
  public func discard(_ z: UInt64) {
    mt19937_64_discard(rng, z)
  }
}

public struct mt19937_64: RandomNumberGenerator {
  @usableFromInline
  var rng: _MT19937_64
  @inlinable
  public init(seed: UInt32) {
    rng = .init(seed: seed)
  }
  @inlinable
  public mutating func next() -> UInt64 {
    rng.next()
  }
  @inlinable
  public mutating func discard(_ z: UInt64) {
    rng.discard(z)
  }
}

extension mt19937_64: @unchecked Sendable { }
