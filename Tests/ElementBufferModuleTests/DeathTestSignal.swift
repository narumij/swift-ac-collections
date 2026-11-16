#if DEATH_TEST
  #if canImport(Darwin)
    import Darwin
    let expectedSwiftTrapSignal = SIGTRAP
  #elseif canImport(Glibc)
    import Glibc
    let expectedSwiftTrapSignal = SIGILL
  #endif
#endif
