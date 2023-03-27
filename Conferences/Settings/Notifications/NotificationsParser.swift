import CoreData
import CloudKit

extension CKRecordZone.ID {
    static var coreData: CKRecordZone.ID {
        CKRecordZone.ID(zoneName: "com.apple.coredata.cloudkit.zone")
    }
}

enum NotificationParseError: Error {
    case invalidUserInfo
    case noConferenceFound
    case invalidSubscriptionType
}

struct NotificationParser {
    let service: DataService
    let store = PersistenceController.shared

    init(service: DataService = CloudKitService()) {
        self.service = service
    }

    func parse(userInfo: [AnyHashable: Any]) async throws -> (Conference, Attendance?) {
        guard let ck = userInfo["ck"] as? [String: Any],
              let query = ck["qry"] as? [String: Any],
              let objectID = query["rid"] as? String,
              let subscriptionID = query["sid"] as? String,
              let subscriptionType = SubscriptionType(rawValue: subscriptionID) else {
            throw NotificationParseError.invalidUserInfo
        }

        switch subscriptionType {
        case .attendanceEdit:
            let record = CKRecord.ID(recordName: objectID,
                                     zoneID: .coreData)
            guard let attendance = try await fetchAttendance(id: record),
                  let conferenceID = attendance.conferenceId
                      .flatMap(CKRecord.ID.init),
                  let conference = try await fetchConference(id: conferenceID) else {
                throw NotificationParseError.noConferenceFound
            }
            return (conference, attendance)
        case .conferenceEdit:
            let record = CKRecord.ID(recordName: objectID)
            guard let conference = try await fetchConference(id: record) else {
                throw NotificationParseError.noConferenceFound
            }
            return try await (conference, fetchAttendance(conferenceID: conference.id))
        default:
            throw NotificationParseError.invalidSubscriptionType
        }
    }

    private func fetchConference(id: CKRecord.ID) async throws -> Conference? {
        try await service.retrieve(id: id, ofType: .conference)
    }

    private func fetchAttendance(conferenceID: UUID) async throws -> Attendance? {
        let request = Attendance.fetchRequest()
        request.fetchLimit = 1
        request.predicate = .init(format: "conferenceId = %@", conferenceID as CVarArg)
        return try await store.container.viewContext.perform({
            try request.execute().first
        })
    }

    private func fetchAttendance(id: CKRecord.ID) async throws -> Attendance? {
        guard let roAttendance: ReadOnlyAttendance = try await service
            .retrieve(id: id,
                      database: \.privateCloudDatabase,
                      ofType: .attendance),
              let attendance = try await fetchAttendance(conferenceID: roAttendance.conferenceID) else {
            return nil
        }
        return attendance
    }
}
