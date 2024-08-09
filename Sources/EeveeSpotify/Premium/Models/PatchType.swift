import Foundation

enum PatchType: Int {
    case notSet
    case disabled
    case requests
    
    var isPatching: Bool { self == .requests }
}
