let normalOnly = true

let unwrappedNormal = true

#if ENABLE_LEGACY
let legacy = true
#endif

#if canImport(Testing)
  #if ENABLE_DEATH_TESTS
  let nestedNormal = true
  #else
  let nestedFallback = true
  #endif
#endif

#if DEBUG
let debugNormal = true
#else
let releaseNormal = true
#endif
