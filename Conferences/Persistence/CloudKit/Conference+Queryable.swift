import CloudKit

extension Conference: Queryable {
    init?(record: CKRecord, database: CloudKitService) async throws {
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
