import Combine
import Foundation
import Service
import UserNotifications

@MainActor
public final class NotificationManager: NotificationState {
    @Published public private(set) var isDenied: Bool = false

    @Published
    public var newConference: Bool = false {
        didSet {
            Task {
                if newConference,
                    try await requestAuthorizationIfNeeded() {
                    try await newConferenceSubscriber.subscribe()
                } else {
                    try await newConferenceSubscriber.unsubscribe()
                }
            }
        }
    }

    @Published
    public var cfpOpening: Bool {
        didSet {
            store.set(value: cfpOpening, for: .cfpOpenNotifications)
            Task {
                try await toggleSubscribers()

                if cfpOpening {
                    try await scheduler.scheduleCFPOpeningNotifications()
                } else {
                    await scheduler.removePendingCFPOpeningNotifications()
                }
            }
        }
    }

    @Published
    public var cfpClosing: Bool {
        didSet {
            store.set(value: cfpClosing, for: .cfpCloseNotifications)
            Task {
                try await toggleSubscribers()

                if cfpClosing {
                    try await scheduler.scheduleCFPClosingNotifications()
                } else {
                    await scheduler.removePendingCFPClosingNotifications()
                }
            }
        }
    }

    @Published
    public var travel: Bool {
        didSet {
            store.set(value: travel, for: .travelNotifications)
            Task {
                try await toggleSubscribers()

                if travel {
                    try await scheduler.scheduleTravelNotifications()
                } else {
                    await scheduler.removePendingTravelNotifications()
                }
            }
        }
    }

    private let store: SettingsStore

    private let newConferenceSubscriber: ObjectSubscriber
    private let editConferenceSubscriber: ObjectSubscriber
    private let editAttendanceSubscriber: ObjectSubscriber

    private let scheduler: NotificationScheduler
    private let center: NotificationCenter

    init(scheduler: NotificationScheduler,
         service: SubscriptionService,
         store: SettingsStore,
         center: NotificationCenter) {
        self.scheduler = scheduler
        self.store = store
        self.center = center

        newConferenceSubscriber = PersistenceSubscriber.newConference(service: service)
        editConferenceSubscriber = PersistenceSubscriber.editConference(service: service)
        editAttendanceSubscriber = PersistenceSubscriber.editAttendance(service: service)


        cfpOpening = store.bool(for: .cfpOpenNotifications)
        cfpClosing = store.bool(for: .cfpCloseNotifications)
        travel = store.bool(for: .travelNotifications)

        Task(priority: .userInitiated) {
            isDenied = await center.authorizationStatus == .denied
            newConference = try await newConferenceSubscriber.isSubscribed
        }
    }

    public convenience init(scheduler: NotificationScheduler) {
        self.init(scheduler: scheduler,
                  service: CloudKitService.shared,
                  store: UserDefaults.standard,
                  center: UNUserNotificationCenter.current())
    }

    private func toggleSubscribers() async throws {
        if (cfpOpening || cfpClosing || travel) {
            if try await requestAuthorizationIfNeeded() {
                try await editAttendanceSubscriber.subscribe()
                try await editConferenceSubscriber.subscribe()
            }
        } else {
            try await editAttendanceSubscriber.unsubscribe()
            try await editConferenceSubscriber.unsubscribe()
        }
    }

    private func requestAuthorizationIfNeeded() async throws -> Bool {
        let authorizationStatus = await center.authorizationStatus
        guard authorizationStatus == .notDetermined else {
            return authorizationStatus != .denied
        }
        let granted = try await center
            .requestAuthorization(options: [.alert, .badge, .sound])
        isDenied = !granted
        return granted
    }
}
