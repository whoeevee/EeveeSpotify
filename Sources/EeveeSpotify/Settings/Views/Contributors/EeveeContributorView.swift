import SwiftUI

struct EeveeContributorView: View {
    var contributor: EeveeContributor
    var githubUser: GitHubUser
    
    var body: some View {
        VStack {
            Link(destination: URL(string: githubUser.htmlUrl)!) {
                HStack(spacing: 10) {
                    ImageView(urlString: githubUser.avatarUrl)
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(contributor.username)
                            .foregroundColor(.white)
                            .font(.headline)
                        
                        ForEach(contributor.roles, id: \.self) { role in
                            Text(role)
                        }
                        .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    ChevronRightView()
                }
            }
        }
    }
}
