import SwiftUI

struct CommonIssuesTipView: View {

    var onDismiss: () -> Void
    
    var body: some View {
        
        Section {
            HStack(spacing: 15) {
                
                Image(systemName: "exclamationmark.bubble")
                    .font(.title)
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 3) {
                    
                    VStack(alignment: .leading) {
                        Text("Having Trouble?")
                            .font(.headline)
                    }
                    
                    Link(
                        destination: URL(string: "https://github.com/whoeevee/EeveeSpotify/blob/swift/common_issues.md")!,
                        label: {
                            VStack {
                                Text("If you are facing an issue, such as being unable to play any songs, check out ")
                                    .foregroundColor(.white)
                                
                                + Text("Common Issues")
                                    .foregroundColor(.blue)
                                
                                + Text(".")
                                    .foregroundColor(.white)
                            }
                            .font(.subheadline)
                        }
                    )
                }
                
                Spacer()
                
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundColor(Color(UIColor.systemGray2))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.vertical, 5)
        }
    }
}
