import UserNotifications

struct NotificationScheduler {
    let center: UNUserNotificationCenter
    let settingsStore: SettingsStore
    
    init(center: UNUserNotificationCenter = .current(),
         settingsStore: SettingsStore = UserDefaults.standard) {
        self.center = center
        self.settingsStore = settingsStore
    }
    
    // MARK: - Add Notifications
    
    func scheduleNotifications(for attendance: Attendance?,
                               at conference: Conference) async throws {
        for notification in [
            remindCFPOpening(conference: conference),
            remindCFPClosing(conference: conference),
            remindTravel(for: attendance, at: conference)
        ].compactMap({ $0 }) {
            try await center.add(notification)
        }
    }
    
    func remindCFPOpening(conference: Conference) -> UNNotificationRequest? {
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
    
    func remindCFPClosing(conference: Conference) -> UNNotificationRequest? {
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
    
    func remindTravel(for attendance: Attendance?, at conference: Conference) -> UNNotificationRequest? {
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
    
    // MARK: - Remove Notifications
    
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
