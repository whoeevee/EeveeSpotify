import Foundation

extension UcsResponse {
    
    var assignedValues: [AssignedValue] {
        get {
            self.resolve.configuration.assignedValues
        }
        set(assignedValues) {
            self.resolve.configuration.assignedValues = assignedValues
        }
    }
}
