import Foundation

enum PatchType: Int {
    case notSet
    case disabled
    case offlineBnk
    case requests
    
    var isPatching: Bool {
        self == .requests || self == .offlineBnk
    }
}
