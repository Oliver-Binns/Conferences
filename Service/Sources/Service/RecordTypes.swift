import CloudKit

public protocol RecordType {
    var name: String { get }
    var database: KeyPath<CKContainer, CKDatabase> { get }
}

extension RecordType where Self: RawRepresentable,
                           Self.RawValue == String {
    public var name: String {
        rawValue
    }
}
