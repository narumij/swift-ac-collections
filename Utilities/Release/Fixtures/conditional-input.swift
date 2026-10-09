#if COMPATIBLE_ATCODER_2025
let compatibilityOnly = true
#else
let normalOnly = true
#endif

#if !COMPATIBLE_ATCODER_2025
let unwrappedNormal = true
#endif

#if COMPATIBLE_ATCODER_2025 || ENABLE_LEGACY
let legacy = true
#endif

#if canImport(Testing)
  #if COMPATIBLE_ATCODER_2025
  let nestedCompatibility = true
  #elseif !COMPATIBLE_ATCODER_2025 && ENABLE_DEATH_TESTS
  let nestedNormal = true
  #else
  let nestedFallback = true
  #endif
#endif

#if DEBUG && !COMPATIBLE_ATCODER_2025
let debugNormal = true
#elseif COMPATIBLE_ATCODER_2025
let compatibilityFallback = true
#else
let releaseNormal = true
#endif
