import CloudKit

protocol Queryable {
    init?(record: CKRecord, database: PublicDatabase) async throws
}


struct PublicDatabase {
    private let container = CKContainer.default()
    
    func retrieve<T: Queryable>(type: RecordType) async throws -> [T] {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: RecordType.conference.rawValue, predicate: predicate)
        
        return try await container.publicCloudDatabase
            .run(query: query)
            .compactMap { try await T(record: $0, database: self) }
            .reduce(into: [T](), {
                $0.append($1)
            })
    }
    
    func retrieve<T: Queryable>(id: CKRecord.ID, ofType type: RecordType) async throws -> T? {
        guard let record = try await container.publicCloudDatabase
            .fetch(withRecordID: id) else { return nil }
        return try await T(record: record, database: self)
    }
    
    enum RecordType: String {
        case conference = "Conference"
        case venue = "Venue"
    }
}

