import SwiftUI
import MapKit

struct ExpandedConferenceView: View {
    let conference: Conference
    
    enum AttendanceType {
        case none
        case attendee
        case speaker
    }
    
    enum Link: Identifiable {
        case web
        case twitter
        
        var id: Self { self }
    }
    
    @State private var attendanceType: AttendanceType = .none
    @State private var displayLink: Link? = .none
    
    private var region: MKCoordinateRegion {
        .init(center: conference.venue.location,
              latitudinalMeters: 750,
              longitudinalMeters: 750)
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
                            if conference.website != nil {
                                Button {
                                    displayLink = .web
                                } label: {
                                    Label("Website", systemImage: "safari.fill")
                                }
                                .font(.headline)
                                .buttonStyle(.borderedProminent)
                            }
                            
                            if conference.twitter != nil {
                                Button {
                                    displayLink = .twitter
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
                    
                    Picker("Attendance Type", selection: $attendanceType) {
                        Text("Not Attending").tag(AttendanceType.none)
                        Text("Attending").tag(AttendanceType.attendee)
                        Text("Speaking").tag(AttendanceType.speaker)
                    }
                    .pickerStyle(.segmented)
                    
                    switch attendanceType {
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
                    
                    if attendanceType == .speaker {
                        // CFP opens in...
                        
                        // if CFP is open: submitted talks
                        VStack(alignment: .leading, spacing: 8) {
                            
                            Text("Talks Submitted")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("Something Something Some Core Data")
                            Text("Something Something Some SwiftUI")
                            Text("Something Something Some WeatherKit")
                            Text("Something Something Some ARKit")
                            Text("Something Something Some Accessibility")
                            // Add Another Talk
                            // CFP closes in...
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        
                        // if CFP is closed: select a _single_ talk
                        
                        // if talk accepted:
                        // custom reminders?
                        // have you completed your talk yet?
                    }
                }
                .sheet(item: $displayLink) { linkType in
                    switch linkType {
                    case .twitter:
                        SafariView(url: conference.twitter!)
                    case .web:
                        SafariView(url: conference.website!)
                    }
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
        VStack {
            ExpandedConferenceView(conference: .deepDish)
        }
    }
}
#endif
