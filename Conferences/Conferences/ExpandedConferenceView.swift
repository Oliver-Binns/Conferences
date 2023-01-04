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
                
                VStack(alignment: .leading) {
                    Text(conference.dates.lowerBound, style: .relative)
                    
                    Button {
                        
                    } label: {
                        HStack {
                            Image(systemName: "mic.fill")
                            Text("Join as speaker")
                        }
                        .padding(.vertical, 2)
                        .frame(maxWidth: .infinity)
                    }
                    .font(.headline)
                    .buttonStyle(.borderedProminent)
                    
                    Button {
                        
                    } label: {
                        HStack {
                            Image(systemName: "chair.lounge.fill")
                            Text("Join as attendee")
                        }
                        .padding(.vertical, 2)
                        .frame(maxWidth: .infinity)
                    }
                    .font(.headline)
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle(conference.name)
            .frame(maxWidth: .infinity)
        }
    }
}
