import CloudKit

extension CKDatabase {
    func fetch(withRecordID id: CKRecord.ID) async throws -> CKRecord? {
        try await withCheckedThrowingContinuation { continuation in
            fetch(withRecordID: id) { record, error in
                if let error {
                    continuation.resume(with: .failure(error))
                } else {
                    continuation.resume(with: .success(record))
                }
            }
        }
    }
    
    func run(query: CKQuery, priority: QualityOfService = .userInteractive) -> AsyncThrowingStream<CKRecord, Error> {
        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = priority
        
        return AsyncThrowingStream<CKRecord, Error> { continuation in
            operation.recordMatchedBlock = { recordID, result in
                switch result {
                case .success(let record):
                    continuation.yield(record)
                case .failure(let error):
                    continuation.finish(throwing: error)
                }
            }
            
            operation.queryResultBlock = { result in
                continuation.finish()
            }
            
            add(operation)
        }
        
    }
}
