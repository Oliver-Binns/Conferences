import Foundation

extension Idea: Comparable {
    var unwrappedTitle: String {
        title ?? "Unknown Talk"
    }
    
    public static func < (lhs: Idea, rhs: Idea) -> Bool {
        lhs.unwrappedTitle < rhs.unwrappedTitle
    }
}
