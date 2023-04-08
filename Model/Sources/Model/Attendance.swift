import CloudKit
import Foundation
import Service

public struct Attendance {
    public let conferenceID: UUID

    public init(conferenceID: UUID) {
        self.conferenceID = conferenceID
    }
}

extension Attendance: Queryable {
    public static var recordType: RecordType {
        CloudKitRecordType.attendance
    }

    public init?(record: CKRecord, database: DataService) async throws {
        guard let conferenceID = record["CD_conferenceId"] as? String,
              let conferenceUUID = UUID(uuidString: conferenceID) else {
            return nil
        }
        self.init(conferenceID: conferenceUUID)
    }
}
