import MapKit
import SwiftUI

enum AttendanceType: String {
    case none
    case attendee
    case speaker
}

enum Link: Identifiable {
    case web
    case twitter
    
    var id: Self { self }
}

struct ConferenceDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var displayLink: URL?
    
    let conference: Conference
    @ObservedObject var attendance: Attendance
    
    private var region: MKCoordinateRegion {
        .init(center: conference.venue.location,
              latitudinalMeters: 750,
              longitudinalMeters: 750)
    }
    
    private var attendanceType: Binding<AttendanceType> { .init(
            get: { attendance.type.flatMap(AttendanceType.init) ?? .none },
            set: {
                attendance.type = $0.rawValue
                if $0 == .none {
                    attendance.travelReminders = false
                }
                try? viewContext.save()
            }
        )
    }
    
    private var travelReminders: Binding<Bool> {
        .init { attendance.travelReminders }
        set: {
            attendance.travelReminders = $0
            try? viewContext.save()
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Map(coordinateRegion: .constant(region), annotationItems: [conference.venue]) {
                    MapMarker(coordinate: $0.location)
                    
                }
                .frame(maxWidth: .infinity, minHeight: 300)
                
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            if let website = conference.website {
                                Button {
                                    displayLink = website
                                } label: {
                                    Label("Website", systemImage: "safari.fill")
                                }
                                .font(.headline)
                                .buttonStyle(.borderedProminent)
                            }
                            
                            if let twitter = conference.twitter {
                                Button {
                                    displayLink = twitter
                                } label: {
                                    Label("Twitter", systemImage: "safari.fill")
                                }
                                .font(.headline)
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        
                        CountdownText(label: "Starts", date: conference.dates.lowerBound)
                    }
                    
                    Divider()
                    
                    Picker("Attendance Type", selection: attendanceType) {
                        Text("Not Attending").tag(AttendanceType.none)
                        Text("Attending").tag(AttendanceType.attendee)
                        Text("Speaking").tag(AttendanceType.speaker)
                    }
                    .pickerStyle(.segmented)
                    
                    switch attendanceType.wrappedValue {
                    case .none: EmptyView()
                    default:
                        VStack(alignment: .leading) {
                            AddToCalendarButton(conference: conference)
                            Divider()
                            Toggle(isOn: travelReminders) {
                                Text("Travel Booked")
                            }
                        }
                        .sectionStyle()
                    }
                    
                    if attendanceType.wrappedValue == .speaker {
                        VStack(alignment: .leading, spacing: 8) {
                            // CFP opens in...
                            if let cfp = conference.cfpSubmission {
                                if cfp.opens > .now {
                                    CountdownText(label: "CFP opens", date: cfp.opens)
                                        .foregroundColor(.green)
                                    
                                    // Add Reminder: when CFP opens...
                                } else if let closeDate = cfp.closes,
                                          closeDate > .now {
                                    // if CFP is open:
                                    // Select Talks...
                                    SelectedTalksView(attendance: attendance)
                                    
                                    Divider()
                                    // CFP closes in
                                    CountdownText(label: "CFP closes", date: closeDate)
                                        .foregroundColor(closeDate.isSoon ? .red : .green)
                                    
                                    // Add Reminder: before CFP closes...
                                } else {
                                    // if CFP is closed: select a _single_ talk
                                    // if talk accepted:
                                    
                                    // custom reminders?
                                    // have you completed your talk yet?
                                    Text("CFP closed")
                                        .foregroundColor(.red)
                                }
                            } else {
                                Text("We don’t have any information.")
                            }
                        }
                        .sectionStyle()
                    }
                }
                .sheet(item: $displayLink) { link in
                    SafariView(url: link)
                }
                .padding()
            }
            .navigationTitle(conference.name)
            .navigationBarTitleDisplayMode(.inline)
            .frame(maxWidth: .infinity)
        }
    }
}


#if DEBUG
struct ExpandedConferenceView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let attendance = Attendance(context: context)
        
        return VStack {
            ConferenceDetailView(conference: .deepDish,
                                 attendance: attendance)
                .environment(\.managedObjectContext, context)
        }
    }
}
#endif
