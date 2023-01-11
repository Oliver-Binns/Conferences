import EventKit
import EventKitUI
import SwiftUI

final class AddToCalendarButtonViewModel: NSObject, ObservableObject, EKEventEditViewDelegate {
    @Published var presented: Bool = false
    @Published var failed: Bool = false
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        presented = false
    }
}

struct AddToCalendarButton: View {
    let conference: Conference
    
    private let eventStore = EKEventStore()
    
    @ObservedObject
    private var viewModel = AddToCalendarButtonViewModel()
    
    private var event: EKEvent {
        let e = EKEvent(eventStore: eventStore)
        e.title = conference.name
        e.startDate = conference.dates.lowerBound
        e.endDate = conference.dates.upperBound
        e.url = conference.website
        e.isAllDay = true
        return e
    }
    
    var body: some View {
        Button {
            eventStore.requestAccess(to: .event) { granted, error in
                DispatchQueue.main.async {
                    guard granted, error == nil else {
                        viewModel.failed = true
                        return
                    }
                    viewModel.presented = true
                }
            }
        } label: {
            Label("Add to Calendar", systemImage: "calendar.badge.plus")
        }
        .sheet(isPresented: $viewModel.presented) {
            CalendarView(event: event, store: eventStore, delegate: viewModel)
        }
        .alert("We can't access your calendar.",
               isPresented: $viewModel.failed) {
            Button("OK", role: .cancel) { }
            Button("Go to Settings", role: .none) {
                guard let openSettingsURL = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                UIApplication.shared.open(openSettingsURL)
            }
        } message: {
            Text("You didn't grant permission to access the camera.")
        }

    }
}
