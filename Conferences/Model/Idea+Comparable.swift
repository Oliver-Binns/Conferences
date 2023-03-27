extension Idea: Comparable {
    var unwrappedTitle: String {
        title ?? "Unknown Talk"
    }
    
    public static func < (lhs: Idea, rhs: Idea) -> Bool {
        lhs.unwrappedTitle < rhs.unwrappedTitle
    }

    static func == (lhs: Idea, rhs: Idea) -> Bool {
        lhs.objectID == rhs.objectID
    }
}
