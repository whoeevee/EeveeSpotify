import Foundation

extension Collection {
    func dropLast(while predicate: (Element) throws -> Bool) rethrows -> SubSequence {
        guard let index = try indices.reversed().first(where: { try !predicate(self[$0]) }) else {
            return self[startIndex..<startIndex]
        }
        return self[...index]
    }
}