import Foundation

struct TreeHeader {
    var begin_ptr: BasePtr = .end
    var end_left_ptr: BasePtr = .none
    var size: Int = 0
}
