import Testing
import BareArrayModule

@Test func writeBackOutsideOwned2DRange() async throws {
  await #expect(processExitsWith: .failure) {
    var array = BareArray2D<Int>(repeating: 0, width: 2, height: 2)
    array[2] = array[1]
  }
}

@Test func writeBackOutsideOwned3DRange() async throws {
  await #expect(processExitsWith: .failure) {
    var array = BareArray3D<Int>(repeating: 0, width: 2, height: 2, depth: 2)
    array[2] = array[1]
  }
}

@Test func writeBackOutsideOwned4DRange() async throws {
  await #expect(processExitsWith: .failure) {
    var array = BareArray4D<Int>(repeating: 0, size0: 2, size1: 2, size2: 2, size3: 2)
    array[2] = array[1]
  }
}
