import CloudKit

public protocol Queryable {
    static var recordType: RecordType { get }
    init?(record: CKRecord, database: DataService) async throws
}
