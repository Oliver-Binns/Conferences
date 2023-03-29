import CoreData
import CloudKit
import Model
import Persistence
import Service

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
    private let service: DataService
    private let store: DataStore

    public init(service: DataService,
                store: DataStore) {
        self.service = service
        self.store = store
    }

    func parse(userInfo: [AnyHashable: Any]) async throws -> (Conference, CDAttendance?) {
        guard let ck = userInfo["ck"] as? [String: Any],
              let query = ck["qry"] as? [String: Any],
              let objectID = query["rid"] as? String,
              let subscriptionID = query["sid"] as? String else {
            throw NotificationParseError.invalidUserInfo
        }

        // TODO: refactor these magic strings
        switch subscriptionID {
        case "editAttendance":
            let record = CKRecord.ID(recordName: objectID,
                                     zoneID: .coreData)
            guard let attendance = try await fetchAttendance(id: record),
                  let conferenceID = attendance.conferenceId
                      .flatMap(CKRecord.ID.init),
                  let conference = try await fetchConference(id: conferenceID) else {
                throw NotificationParseError.noConferenceFound
            }
            return (conference, attendance)
        case "editConference":
            let record = CKRecord.ID(recordName: objectID)
            guard let conference = try await fetchConference(id: record) else {
                throw NotificationParseError.noConferenceFound
            }
            return try await (conference, conference.fetchAttendance(context: store.context))
        default:
            throw NotificationParseError.invalidSubscriptionType
        }
    }

    private func fetchConference(id: CKRecord.ID) async throws -> Conference? {
        try await service.retrieve(id: id)
    }


    private func fetchAttendance(id: CKRecord.ID) async throws -> CDAttendance? {
        guard let roAttendance: Attendance = try await service.retrieve(id: id),
              let attendance = try await Conference.fetchAttendance(id: roAttendance.conferenceID,
                                                                    context: store.context) else {
            return nil
        }
        return attendance
    }
}

extension Conference {
    func fetchAttendance(context: NSManagedObjectContext) async throws -> CDAttendance? {
        try await Self.fetchAttendance(id: id, context: context)
    }

    static func fetchAttendance(id: UUID, context: NSManagedObjectContext) async throws -> CDAttendance? {
        let request = CDAttendance.fetchRequest()
        request.fetchLimit = 1
        request.predicate = .init(format: "conferenceId = %@", id as CVarArg)
        return try await context.perform({
            try request.execute().first
        })
    }
}
