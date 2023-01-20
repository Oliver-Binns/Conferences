import CloudKit

protocol Queryable {
    init?(record: CKRecord, database: PublicDatabase) async throws
}


struct PublicDatabase {
    private let container = CKContainer.default()
    
    func retrieve<T: Queryable>(type: RecordType) async throws -> [T] {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: RecordType.conference.rawValue, predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInteractive
        
        return try await withThrowingTaskGroup(of: T?.self) { group in
            group.addTask {
                try await withCheckedThrowingContinuation { continuation in
                    operation.recordMatchedBlock = { recordID, result in
                        switch result {
                        case .success(let record):
                            Task {
                                let value = try await T(record: record, database: self)
                                continuation.resume(with: .success(value))
                            }
                        case .failure(let error):
                            continuation.resume(with: .failure(error))
                        }
                    }
                }
            }
            
            container.publicCloudDatabase.add(operation)
            
            return try await group
                .compactMap { $0 }
                .reduce(into: [T](), {
                    $0.append($1)
                })
        }
    }
    
    func retrieve<T: Queryable>(id: CKRecord.ID, ofType type: RecordType) async throws -> T? {
        try await withCheckedThrowingContinuation { continuation in
            container.publicCloudDatabase
                .fetch(withRecordID: id) { record, error in
                    Task {
                        if let record {
                            try await continuation.resume(with: .success(T(record: record, database: self)))
                        } else if let error {
                            continuation.resume(with: .failure(error))
                        }
                    }
                }
        }
    }
    
    enum RecordType: String {
        case conference = "Conference"
        case venue = "Venue"
    }
}
