import EventKit
import EventKitUI
import SwiftUI

struct CalendarView: UIViewControllerRepresentable {
    let event: EKEvent
    let store: EKEventStore
    weak var delegate: EKEventEditViewDelegate?
    
    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let vc = EKEventEditViewController()
        vc.event = event
        vc.eventStore = store
        vc.editViewDelegate = delegate
        return vc
    }
    
    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {
        
    }
}
