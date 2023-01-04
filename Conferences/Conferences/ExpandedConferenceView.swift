import SwiftUI
import MapKit

struct ExpandedConferenceView: View {
    let conference: Conference
    
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
                .disabled(true)
                
                Text(conference.dates.lowerBound, style: .relative)
                
                Spacer()
                
                Button("Join as speaker") {
                    
                }
                
                Button("Join as attendee") {
                    
                }
            }
            .navigationTitle(conference.name)
            .frame(maxWidth: .infinity)
        }
    }
}
