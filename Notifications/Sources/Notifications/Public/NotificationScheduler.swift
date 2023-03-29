import Model
import Persistence
import Service
import UserNotifications

public struct NotificationScheduler {
    private let center: UNUserNotificationCenter
    private let settingsStore: SettingsStore

    private let parser: NotificationParser

    private let service: DataService
    private let store: DataStore

    public init(service: DataService, store: DataStore) {
        let parser = NotificationParser(service: service, store: store)
        self.init(center: .current(), settingsStore: UserDefaults.standard,
                  service: service, store: store,
                  parser: parser)
    }
    
    init(center: UNUserNotificationCenter,
         settingsStore: SettingsStore,
         service: DataService,
         store: DataStore,
         parser: NotificationParser) {
        self.center = center
        self.settingsStore = settingsStore
        self.service = service
        self.store = store
        self.parser = parser
    }
}

// MARK: - Received Notification
extension NotificationScheduler {
    public func receivedSilentNotification(userInfo: [AnyHashable: Any]) async throws {
        let (conference, attendance) = try await parser.parse(userInfo: userInfo)
        try await scheduleNotifications(for: attendance, at: conference)
    }

    func scheduleNotifications(for attendance: CDAttendance?, at conference: Conference) async throws {
        for notification in [
            remindCFPOpening(conference: conference),
            remindCFPClosing(conference: conference),
            remindTravel(for: attendance, at: conference)
        ].compactMap({ $0 }) {
            try await center.add(notification)
        }
    }
}
    
// MARK: - Add Notifications
extension NotificationScheduler {
    private var conferences: [Conference] {
        get async throws {
            try await service.retrieve()
        }
    }

    private var attendance: [(CDAttendance?, Conference)] {
        get async throws {
            try await withThrowingTaskGroup(of: (CDAttendance?, Conference).self) { group -> [(CDAttendance?, Conference)] in
                try await conferences.forEach { conference in
                    group.addTask {
                        let attendance = try await conference.fetchAttendance(context: store.context)
                        return (attendance, conference)
                    }
                }

                return try await group.reduce([]) { $0 + [$1] }
            }
        }
    }

    func scheduleCFPOpeningNotifications() async throws {
        try await conferences
            .compactMap(remindCFPOpening)
            .forEach {
                center.add($0)
            }
    }

    func scheduleCFPClosingNotifications() async throws {
        try await conferences
            .compactMap(remindCFPClosing)
            .forEach {
                center.add($0)
            }
    }

    func scheduleTravelNotifications() async throws {

    }


    private func remindCFPOpening(conference: Conference) -> UNNotificationRequest? {
        guard settingsStore.bool(for: .cfpOpenNotifications),
              let openingDate = conference.cfpSubmission?.opens,
              openingDate > .now else {
            return nil
        }
        
        let content = UNMutableNotificationContent()
        content.title = "CFP Now Open"
        content.body = "Submit a talk for \(conference.name) now."
        content.sound = .default
        
        let fireDate = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second],
                                                       from: openingDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: fireDate, repeats: false)
        return UNNotificationRequest(identifier: "\(conference.id)-cfpopen", content: content, trigger: trigger)
    }
    
    private func remindCFPClosing(conference: Conference) -> UNNotificationRequest? {
        guard settingsStore.bool(for: .cfpCloseNotifications),
              let closingDate = conference.cfpSubmission?.closes,
              closingDate > .now,
              let fireDate = Calendar.current.date(byAdding: .day, value: -3, to: closingDate) else {
            return nil
        }
        
        let content = UNMutableNotificationContent()
        content.title = "CFP Closing Soon"
        content.body = "Submit a talk for \(conference.name) now."
        content.sound = .default
        
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second],
                                                             from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        return UNNotificationRequest(identifier: "\(conference.id)-cfpclosing", content: content, trigger: trigger)
    }
    
    private func remindTravel(for attendance: CDAttendance?, at conference: Conference) -> UNNotificationRequest? {
        let startDate = conference.dates.lowerBound
        guard settingsStore.bool(for: .travelNotifications),
              let attendance = attendance,
              let type = attendance.type.flatMap(AttendanceType.init),
              type != .none,
              !attendance.travelBooked,
              let fireDate = Calendar.current.date(byAdding: .month, value: -1, to: startDate),
              fireDate > .now else {
            return nil
        }
        
        let content = UNMutableNotificationContent()
        content.title = "\(conference.name) is approaching"
        content.body = "Have you booked your travel yet?"
        content.sound = .default
        
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second],
                                                             from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        return UNNotificationRequest(identifier: "\(conference.id)-travel", content: content, trigger: trigger)
    }
}
    
// MARK: - Remove Notifications
extension NotificationScheduler {
    func removePendingCFPOpeningNotifications() async {
        await removePendingRequests(withSuffix: "-cfpopen")
    }
    
    func removePendingCFPClosingNotifications() async {
        await removePendingRequests(withSuffix: "-cfpclosing")
    }
    
    func removePendingTravelNotifications() async {
        await removePendingRequests(withSuffix: "-travel")
    }
    
    private func removePendingRequests(withSuffix suffix: String) async {
        let pendingRequests = await center
            .pendingNotificationRequests()
            .map(\.identifier)
            .filter { $0.hasSuffix(suffix) }
        center.removePendingNotificationRequests(withIdentifiers: pendingRequests)
    }
}
