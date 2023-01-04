import CoreLocation
import SwiftUI

struct Conference: Identifiable {
    let id = UUID()
    let name: String
    let venue: Venue
    let dates: ClosedRange<Date>
}

struct Venue: Identifiable {
    let id = UUID()
    let name: String
    let location: CLLocationCoordinate2D
}

struct ConferenceList: View {    
    let conferences = [
        Conference(name: "SwiftLeeds",
                   venue: .init(name: "Leeds Playhouse", location: .init(latitude: 53.7980041, longitude: -1.5343041059594758)),
                   dates: Date(day: 22, month: 10, year: 2023)...Date(day: 22, month: 10, year: 2023)),
        
        Conference(name: "plSwift",
                   venue: .init(name: "Copernicus Science Centre", location: .init(latitude: 52.241776, longitude: 21.028600190793306)),
                   dates: Date(day: 30, month: 05, year: 2023)...Date(day: 31, month: 05, year: 2023)),
        
        Conference(name: "iOSDevUK",
                   venue: .init(name: "Aberystwyth University", location: .init(latitude: 52.41554955, longitude: -4.065054179671381)),
                   dates: Date(day: 4, month: 9, year: 2023)...Date(day: 7, month: 9, year: 2023)),
        
        Conference(name: "Deep Dish Swift",
                   venue: .init(name: "Loews Chicago O'Hare Hotel", location: .init(latitude: 41.97439645, longitude: -87.86365429710366)),
                   dates: Date(day: 30, month: 4, year: 2023)...Date(day: 2, month: 5, year: 2023)),
        
        Conference(name: "NYSwifty",
                   venue: .init(name: "Roulette", location: .init(latitude: 40.6855576, longitude: -73.9807166)),
                   dates: Date(day: 18, month: 4, year: 2023)...Date(day: 19, month: 4, year: 2023)),
        
        Conference(name: "ServerSide.swift",
                   venue: .init(name: "Science Museum", location: .init(latitude: 51.4972, longitude: 0.1767)),
                   dates: Date(day: 01, month: 12, year: 2023)...Date(day: 31, month: 12, year: 2023)),
        
        Conference(name: "SwiftHEROES",
                   venue: .init(name: "Museo dell’Automobile", location: .init(latitude: 45.0318489, longitude: 7.673454742367636)),
                   dates: Date(day: 4, month: 05, year: 2023)...Date(day: 5, month: 05, year: 2023)),
        
        Conference(name: "Swiftable",
                   venue: .init(name: "La Usina del Arte", location: .init(latitude: -34.628776099999996, longitude: -58.357099695529314)),
                   dates: Date(day: 1, month: 12, year: 2023)...Date(day: 31, month: 12, year: 2023)),
        
        Conference(name: "Swift TO",
                   venue: .init(name: "TIFF Bell Lightbox", location: .init(latitude: 43.6467198, longitude: -79.3905334)),
                   dates: Date(day: 10, month: 08, year: 2023)...Date(day: 11, month: 08, year: 2023)),
        
        Conference(name: "iOS Conf SG",
                   venue: .init(name: "Shaw Foundation Alumni House", location: .init(latitude: 1.2932204999999999, longitude: 103.77361236255943)),
                   dates: Date(day: 12, month: 1, year: 2023)...Date(day: 13, month: 1, year: 2023)),
        
        Conference(name: "Swift Island",
                   venue: .init(name: "Texel", location: .init(latitude: 53.08870495, longitude: 4.821112543290136)),
                   dates: Date(day: 25, month: 8, year: 2023)...Date(day: 27, month: 8, year: 2023))
    ].sorted(by: { $0.dates.lowerBound < $1.dates.lowerBound })
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(conferences) { conference in
                    NavigationLink {
                        ExpandedConferenceView(conference: conference)
                    } label: {
                        SmallConferenceView(conference: conference)
                    }.buttonStyle(.plain)

                }
            }.padding(.vertical)
        }
    }
}

extension Date {
    init(day: Int, month: Int, year: Int, timeZone: TimeZone = .gmt) {
        let components = DateComponents(calendar: .autoupdatingCurrent,
                                        timeZone: timeZone,
                                        year: year, month: month, day: day)
        self = Calendar.autoupdatingCurrent.date(from: components)!
    }
}
