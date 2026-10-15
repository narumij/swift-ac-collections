import Testing
import Darwin
@Suite(.serialized)
struct ProbeTests {
 init() {
  print("Before restoration:", getenv("DYLD_INSERT_LIBRARIES").map { String(cString: $0) } ?? "<unset>")
  setenv("DYLD_INSERT_LIBRARIES", "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/21/lib/darwin/libclang_rt.asan_osx_dynamic.dylib", 1)
 }
 @Test func cleanChild() async {
  await #expect(processExitsWith: .success) { exit(0) }
 }
 @Test func trapChild() async {
  await #expect(processExitsWith: .signal(SIGTRAP)) { fatalError("expected trap") }
 }
}
extension ProbeTests {
 @Test func sanitizerStillDetectsOverflow() async {
  let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
   let p = UnsafeMutablePointer<Int>.allocate(capacity: 1)
   p[8] = 42
   p.deallocate()
  }
  let output = String(decoding: result?.standardErrorContent ?? [], as: UTF8.self)
  #expect(output.contains("AddressSanitizer: heap-buffer-overflow"))
 }
}
