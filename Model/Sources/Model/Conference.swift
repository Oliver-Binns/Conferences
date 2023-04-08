import CloudKit
import Foundation
import Service

public struct Conference: Codable, Identifiable {
    public let id: UUID
    public let name: String
    public let website: URL?
    public let twitter: URL?
    public let venue: Venue

    public let cfpSubmission: CFPSubmission?
    public let dates: ClosedRange<Date>

    public var location: String {
        "\(venue.city), \(venue.country)"
    }

    public init(id: UUID = UUID(),
                name: String,
                website: URL?,
                twitter: URL?,
                venue: Venue,
                cfpSubmission: CFPSubmission?,
                dates: ClosedRange<Date>) {
        self.id = id
        self.name = name
        self.website = website
        self.twitter = twitter
        self.venue = venue
        self.cfpSubmission = cfpSubmission
        self.dates = dates
    }
}

extension Conference: Queryable {
    public static var recordType: RecordType {
        CloudKitRecordType.conference
    }

    public init?(record: CKRecord, database: DataService) async throws {
        guard
            let id = UUID(uuidString: record.recordID.recordName),
            let name = record["name"] as? String,

            let venueRef = record["venue"] as? CKRecord.Reference,
            let venue: Venue = try await database.retrieve(id: venueRef.recordID),

            let dates = record["dates"] as? [Date],
            let startDate = dates.first,
            let endDate = dates.last else {
            return nil
        }
        self.init(id: id,
                  name: name,
                  website: record["website"].flatMap(URL.init),
                  twitter: record["twitter"].flatMap(URL.init),
                  venue: venue,
                  cfpSubmission: .init(dates: record["cfpSubmission"] as? [Date]),
                  dates: startDate...endDate)
    }
}
