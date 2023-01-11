extension Collection {
    func sorted<C: Comparable>(by keyPath: KeyPath<Element, C>) -> [Element] {
        self.sorted { lhs, rhs in
            lhs[keyPath: keyPath] < rhs[keyPath: keyPath]
        }
    }
}
