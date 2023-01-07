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
    
    @State var viewModel: ExpandedConferenceViewModel
    @State private var displayLink: Link? = .none
    
    private var region: MKCoordinateRegion {
        .init(center: viewModel.conference.venue.location,
              latitudinalMeters: 750,
              longitudinalMeters: 750)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Map(coordinateRegion: .constant(region), annotationItems: [viewModel.conference.venue]) {
                    MapMarker(coordinate: $0.location)
                    
                }
                .frame(maxWidth: .infinity, minHeight: 300)
                
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            if viewModel.conference.website != nil {
                                Button {
                                    displayLink = .web
                                } label: {
                                    Label("Website", systemImage: "safari.fill")
                                }
                                .font(.headline)
                                .buttonStyle(.borderedProminent)
                            }
                            
                            if viewModel.conference.twitter != nil {
                                Button {
                                    displayLink = .twitter
                                } label: {
                                    Label("Twitter", systemImage: "safari.fill")
                                }
                                .font(.headline)
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        
                        CountdownText(label: "Starts", date: viewModel.conference.dates.lowerBound)
                    }
                    
                    Divider()
                    
                    Picker("Attendance Type", selection: $viewModel.attendanceType) {
                        Text("Not Attending").tag(AttendanceType.none)
                        Text("Attending").tag(AttendanceType.attendee)
                        Text("Speaking").tag(AttendanceType.speaker)
                    }
                    .pickerStyle(.segmented)
                    
                    switch viewModel.attendanceType {
                    case .none: EmptyView()
                    default:
                        VStack(alignment: .leading) {
                            Toggle(isOn: .constant(false)) {
                                Text("Travel Reminders")
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                    
                    if viewModel.attendanceType == .speaker {
                        VStack(alignment: .leading, spacing: 8) {
                            // CFP opens in...
                            if let cfp = viewModel.conference.cfpSubmission {
                                if cfp.opens > .now {
                                    CountdownText(label: "CFP opens", date: cfp.opens)
                                        .foregroundColor(.green)
                                    
                                    // Add Reminder: when CFP opens...
                                } else if let closeDate = cfp.closes,
                                          closeDate > .now {
                                    // if CFP is open:
                                    // Select Talks...
                                    Text("Talks Submitted")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("Something Something Some Core Data")
                                    Text("Something Something Some SwiftUI")
                                    Text("Something Something Some WeatherKit")
                                    Text("Something Something Some ARKit")
                                    Text("Something Something Some Accessibility")
                                    
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
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                }
                .sheet(item: $displayLink) { linkType in
                    switch linkType {
                    case .twitter:
                        SafariView(url: viewModel.conference.twitter!)
                    case .web:
                        SafariView(url: viewModel.conference.website!)
                    }
                }
                .padding()
            }
            .navigationTitle(viewModel.conference.name)
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
            ConferenceDetailView(viewModel: .init(conference: .deepDish, attendance: attendance))
                .environment(\.managedObjectContext, context)
        }
    }
}
#endif
