import CloudKit
import CoreLocation
import Service

public struct Venue: Codable, Identifiable {
    public let id: UUID
    public let name: String
    public let city: String
    public let country: String
    public let location: CLLocationCoordinate2D

    public init(id: UUID = UUID(),
                name: String,
                city: String,
                country: String,
                location: CLLocationCoordinate2D) {
        self.id = id
        self.name = name
        self.city = city
        self.country = country
        self.location = location
    }
}

extension Venue: Queryable {
    public static var recordType: RecordType {
        CloudKitRecordType.venue
    }

    public init?(record: CKRecord, database: DataService) async {
        guard
            let id = UUID(uuidString: record.recordID.recordName),
            let name = record["name"] as? String,
            let city = record["city"] as? String,
            let country = record["country"] as? String,
            let location = record["location"] as? CLLocation else {
            return nil
        }
        self.init(id: id,
                  name: name,
                  city: city,
                  country: country,
                  location: location.coordinate)
    }
}
