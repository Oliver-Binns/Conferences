import CloudKit
import SwiftUI
import UserNotifications

final class NotificationSettingsViewModel: ObservableObject {
    @MainActor @Published
    private var authorizationStatus: UNAuthorizationStatus = .notDetermined
    private var scheduler = NotificationScheduler()
    
    @MainActor
    var isRejected: Bool {
        authorizationStatus == .denied
    }
    
    @MainActor @Published
    var newConferences: Bool = false {
        didSet {
            Task {
                try await requestAuthorizationIfNeeded()
                
                if newConferences {
                    try await newConferenceSubscriber.subscribe()
                } else {
                    try await newConferenceSubscriber.unsubscribe()
                }
            }
        }
    }

    @AppStorage(.cfpOpenNotifications)
    var cfpOpening: Bool = false {
        didSet {
            Task {
                try await requestAuthorizationIfNeeded()
                try await toggleSubscriptions()
                if !cfpOpening {
                    await scheduler.removePendingCFPOpeningNotifications()
                }
            }
        }
    }

    @AppStorage(.cfpCloseNotifications)
    var cfpClosing: Bool = false {
        didSet {
            Task {
                try await requestAuthorizationIfNeeded()
                try await toggleSubscriptions()
                if !cfpClosing {
                    await scheduler.removePendingCFPOpeningNotifications()
                }
            }
        }
    }

    @AppStorage(.travelNotifications)
    var travelReminders: Bool = false {
        didSet {
            Task {
                try await requestAuthorizationIfNeeded()
                try await toggleSubscriptions()
                if !travelReminders {
                    await scheduler.removePendingCFPOpeningNotifications()
                }
            }
        }
    }
    
    private let centre: UNUserNotificationCenter
    private let newConferenceSubscriber = NewConferenceSubscriber()
    private let editConferenceSubscriber = EditConferenceSubscriber()
    private let editAttendanceSubscriber = EditAttendanceSubscriber()
    
    init(centre: UNUserNotificationCenter = .current()) async throws {
        self.centre = centre
        
        let newConferences = try await newConferenceSubscriber.isSubscribed
        await MainActor.run { self.newConferences = newConferences }
    }
    
    private func requestAuthorizationIfNeeded() async throws {
        guard await authorizationStatus == .notDetermined else { return }
        try await centre
            .requestAuthorization(options: [.alert, .badge, .sound])
        await checkNotificationSettings()
    }
    
    private func toggleSubscriptions() async throws {
        if cfpOpening || cfpClosing || travelReminders {
            try await editAttendanceSubscriber.subscribe()
            try await editConferenceSubscriber.subscribe()
        } else {
            try await editAttendanceSubscriber.unsubscribe()
            try await editConferenceSubscriber.unsubscribe()
        }
    }
    
    func checkNotificationSettings() async {
        let status = await centre.getNotificationSettings()
            .authorizationStatus
        await MainActor.run { authorizationStatus = status }
    }
}
