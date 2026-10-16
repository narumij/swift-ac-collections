import Testing
import Darwin
@Suite(.serialized)
struct ProbeTests {
 init() {
  print("DYLD_INSERT_LIBRARIES at suite init:", getenv("DYLD_INSERT_LIBRARIES").map { String(cString: $0) } ?? "<unset>")
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
