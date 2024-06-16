import SwiftUI

struct ListRowSeparatorHidden: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .listRowSeparator(.hidden)
        }
        else {
            content
        }
    }
}
