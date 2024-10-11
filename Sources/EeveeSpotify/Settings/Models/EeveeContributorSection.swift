struct EeveeContributorSection: Decodable, Equatable {
    var title: String
    var shuffled: Bool
    var contributors: [EeveeContributor]
}
