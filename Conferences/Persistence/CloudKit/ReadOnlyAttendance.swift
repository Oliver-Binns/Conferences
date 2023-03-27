import CloudKit

struct ReadOnlyAttendance: Queryable {
    let conferenceID: UUID

    init?(record: CKRecord, database: CloudKitService) async throws {
        guard let conferenceID = record["CD_conferenceId"] as? String,
              let conferenceUUID = UUID(uuidString: conferenceID) else {
            return nil
        }
        self.conferenceID = conferenceUUID
    }
}
