import Foundation
import Model

extension CDIdea: Comparable {
    var unwrappedTitle: String {
        title ?? "Unknown Talk"
    }
    
    public static func < (lhs: CDIdea, rhs: CDIdea) -> Bool {
        lhs.unwrappedTitle < rhs.unwrappedTitle
    }
}
