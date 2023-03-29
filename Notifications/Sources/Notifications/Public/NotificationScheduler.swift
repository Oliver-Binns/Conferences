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
        try await remindCFPOpening(conference: conference)
        try await remindCFPClosing(conference: conference)
        try await remindTravel(for: attendance, at: conference)
    }
}
    
// MARK: - Add Notifications
extension NotificationScheduler {
    private var conferences: [Conference] {
        get async throws {
            try await service.retrieve()
        }
    }

    private var attendances: [(CDAttendance?, Conference)] {
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
        for conference in try await conferences {
            try await remindCFPOpening(conference: conference)
        }
    }

    func scheduleCFPClosingNotifications() async throws {
        for conference in try await conferences {
            try await remindCFPClosing(conference: conference)
        }
    }

    func scheduleTravelNotifications() async throws {
        for (attendance, conference) in try await attendances {
            try await remindTravel(for: attendance, at: conference)
        }
    }


    private func remindCFPOpening(conference: Conference) async throws {
        let identifier = "\(conference.id)-cfpopen"

        guard settingsStore.bool(for: .cfpOpenNotifications),
              let openingDate = conference.cfpSubmission?.opens,
              openingDate > .now else {
            return center.removePendingNotificationRequests(withIdentifiers: [identifier])
        }
        
        let content = UNMutableNotificationContent()
        content.title = "CFP Now Open"
        content.body = "Submit a talk for \(conference.name) now."
        content.sound = .default
        
        let fireDate = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second],
                                                       from: openingDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: fireDate, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        try await center.add(request)
    }
    
    private func remindCFPClosing(conference: Conference) async throws {
        let identifier = "\(conference.id)-cfpclosing"

        guard settingsStore.bool(for: .cfpCloseNotifications),
              let closingDate = conference.cfpSubmission?.closes,
              closingDate > .now,
              let fireDate = Calendar.current.date(byAdding: .day, value: -3, to: closingDate) else {
            return center.removePendingNotificationRequests(withIdentifiers: [identifier])
        }
        
        let content = UNMutableNotificationContent()
        content.title = "CFP Closing Soon"
        content.body = "Submit a talk for \(conference.name) now."
        content.sound = .default
        
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second],
                                                             from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        try await center.add(request)
    }
    
    private func remindTravel(for attendance: CDAttendance?, at conference: Conference) async throws {
        let identifier = "\(conference.id)-travel"

        let startDate = conference.dates.lowerBound
        guard settingsStore.bool(for: .travelNotifications),
              let attendance = attendance,
              let type = attendance.type.flatMap(AttendanceType.init),
              type != .none,
              !attendance.travelBooked,
              let fireDate = Calendar.current.date(byAdding: .month, value: -1, to: startDate),
              fireDate > .now else {
            return center.removePendingNotificationRequests(withIdentifiers: [identifier])
        }
        
        let content = UNMutableNotificationContent()
        content.title = "\(conference.name) is approaching"
        content.body = "Have you booked your travel yet?"
        content.sound = .default
        
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second],
                                                             from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        try await center.add(request)
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
