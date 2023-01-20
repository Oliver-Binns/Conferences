import CoreLocation
import CloudKit
import Foundation

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
            
            
            var confs: [T] = []
            for try await item in group {
                if let item {
                    confs.append(item)
                }
            }
            return confs
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

extension Venue: Queryable {
    init?(record: CKRecord, database: PublicDatabase) async {
        guard
            let id = UUID(uuidString: record.recordID.recordName),
            let name = record["name"] as? String,
            let city = record["city"] as? String,
            let country = record["country"] as? String,
            let location = record["location"] as? CLLocation else {
            return nil
        }
        self.id = id
        self.name = name
        self.city = city
        self.country = country
        self.location = location.coordinate
    }
}

extension Conference: Queryable {
    init?(record: CKRecord, database: PublicDatabase) async throws {
        guard
            let id = UUID(uuidString: record.recordID.recordName),
            let name = record["name"] as? String,
            
            let venueRef = record["venue"] as? CKRecord.Reference,
            let venue: Venue = try await database.retrieve(id: venueRef.recordID, ofType: .venue),
                
            let dates = record["dates"] as? [Date],
            let startDate = dates.first,
            let endDate = dates.last else {
            return nil
        }
        self.id = id
        self.name = name
        self.website = record["website"].flatMap(URL.init)
        self.twitter = record["twitter"].flatMap(URL.init)
        self.venue = venue
        self.cfpSubmission = .init(dates: record["cfpSubmission"] as? [Date])
        self.dates = startDate...endDate
    }
}

extension CFPSubmission {
    init?(dates: [Date]?) {
        guard let dates,
              let opens = dates.first else { return nil }
        self.opens = opens
        self.closes = dates.count > 1 ? dates[1] : nil
    }
}
