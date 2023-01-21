import CloudKit

extension Venue: Queryable {
    init?(record: CKRecord, database: CloudKitService) async {
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
