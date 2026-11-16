// MARK: ── 低依存シンプル PRNG ──────────────────────────────────────────────

/// SplitMix64 ―― JDK の Random にも採用されている単純・高速な 64 bit PRNG。
struct SplitMix64: RandomNumberGenerator {
  private var state: UInt64
  init(seed: UInt64) { self.state = seed }
  mutating func next() -> UInt64 {
    state &+= 0x9E37_79B9_7F4A_7C15
    var z = state
    z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
    z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
    return z ^ (z >> 31)
  }
}
