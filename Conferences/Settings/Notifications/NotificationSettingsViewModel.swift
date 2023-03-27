import CloudKit
import CoreData
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
    var newConferences: Bool? {
        didSet {
            Task {
                guard let newConferences else { return }
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
                if cfpOpening {
                    try await updateNotifications()
                } else {
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
                if cfpClosing {
                    try await updateNotifications()
                } else {
                    await scheduler.removePendingCFPClosingNotifications()
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
                if travelReminders {
                    try await updateNotifications()
                } else {
                    await scheduler.removePendingTravelNotifications()
                }
            }
        }
    }

    private var data: [(Attendance?, Conference)] {
        get async {
            switch await database.state {
            case .loaded(let conferences),
                    .cached(let conferences):
                return conferences.map {
                    ($0.attendance(context: viewContext), $0)
                }
            default: return []
            }
        }
    }

    private var database: ConferenceDataStore
    private var viewContext: NSManagedObjectContext
    private let centre: UNUserNotificationCenter
    private let newConferenceSubscriber = NewConferenceSubscriber()
    private let editConferenceSubscriber = EditConferenceSubscriber()
    private let editAttendanceSubscriber = EditAttendanceSubscriber()
    
    init(centre: UNUserNotificationCenter = .current(),
         context: NSManagedObjectContext,
         database: ConferenceDataStore) {
        self.centre = centre
        self.database = database
        self.viewContext = context

        Task {
            let newConferences = try await newConferenceSubscriber.isSubscribed
            await MainActor.run { self.newConferences = newConferences }
        }
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

    private func updateNotifications() async throws {
        for (attendance, conference) in await data {
            try await scheduler.scheduleNotifications(for: attendance, at: conference)
        }
        await UNUserNotificationCenter.current().pendingNotificationRequests().forEach {
            print("request", $0)
        }
    }
    
    func checkNotificationSettings() async {
        let status = await centre.getNotificationSettings()
            .authorizationStatus
        await MainActor.run { authorizationStatus = status }
    }
}
