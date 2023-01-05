import CoreLocation
import SwiftUI

struct Conference: Identifiable {
    let id = UUID()
    let name: String
    let website: URL?
    let twitter: URL?
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
                   website: .init(string: "https://swiftleeds.co.uk"),
                   twitter: .init(string: "https://twitter.com/swift_leeds"),
                   venue: .init(name: "Leeds Playhouse", location: .init(latitude: 53.7980041, longitude: -1.5343041059594758)),
                   dates: Date(day: 22, month: 10, year: 2023)...Date(day: 22, month: 10, year: 2023)),
        
        Conference(name: "plSwift",
                   website: .init(string: "https://plswift.com"),
                   twitter: .init(string: "https://twitter.com/swift_pl"),
                   venue: .init(name: "Copernicus Science Centre", location: .init(latitude: 52.241776, longitude: 21.028600190793306)),
                   dates: Date(day: 30, month: 05, year: 2023)...Date(day: 31, month: 05, year: 2023)),
        
        Conference(name: "iOSDevUK",
                   website: .init(string: "https://www.iosdevuk.com"),
                   twitter: .init(string: "https://twitter.com/IOSDEVUK"),
                   venue: .init(name: "Aberystwyth University", location: .init(latitude: 52.41554955, longitude: -4.065054179671381)),
                   dates: Date(day: 4, month: 9, year: 2023)...Date(day: 7, month: 9, year: 2023)),
        
        Conference(name: "Deep Dish Swift",
                   website: .init(string: "https://deepdishswift.com"),
                   twitter: .init(string: "https://twitter.com/DeepDishSwift"),
                   venue: .init(name: "Loews Chicago O'Hare Hotel", location: .init(latitude: 41.97439645, longitude: -87.86365429710366)),
                   dates: Date(day: 30, month: 4, year: 2023)...Date(day: 2, month: 5, year: 2023)),
        
        Conference(name: "NYSwifty",
                   website: .init(string: "https://nyswifty.com"),
                   twitter: .init(string: "https://twitter.com/nyswifty"),
                   venue: .init(name: "Roulette", location: .init(latitude: 40.6855576, longitude: -73.9807166)),
                   dates: Date(day: 18, month: 4, year: 2023)...Date(day: 19, month: 4, year: 2023)),
        
        Conference(name: "ServerSide.swift",
                   website: .init(string: "https://www.serversideswift.info"),
                   twitter: .init(string: "https://twitter.com/SwiftServerConf"),
                   venue: .init(name: "Science Museum", location: .init(latitude: 51.4972, longitude: -0.1767)),
                   dates: Date(day: 01, month: 12, year: 2023)...Date(day: 31, month: 12, year: 2023)),
        
        Conference(name: "SwiftHEROES",
                   website: .init(string: "https://swiftheroes.com/2023/"),
                   twitter: .init(string: "https://twitter.com/swiftheroes_it"),
                   venue: .init(name: "Museo dell’Automobile", location: .init(latitude: 45.0318489, longitude: 7.673454742367636)),
                   dates: Date(day: 4, month: 05, year: 2023)...Date(day: 5, month: 05, year: 2023)),
        
        Conference(name: "Swiftable",
                   website: .init(string: "https://www.swiftable.co"),
                   twitter: .init(string: "https://twitter.com/baswiftable"),
                   venue: .init(name: "La Usina del Arte", location: .init(latitude: -34.628776099999996, longitude: -58.357099695529314)),
                   dates: Date(day: 1, month: 12, year: 2023)...Date(day: 31, month: 12, year: 2023)),
        
        Conference(name: "Swift TO",
                   website: .init(string: "https://www.swiftconf.to"),
                   twitter: .init(string: "https://twitter.com/swiftconfto"),
                   venue: .init(name: "TIFF Bell Lightbox", location: .init(latitude: 43.6467198, longitude: -79.3905334)),
                   dates: Date(day: 10, month: 08, year: 2023)...Date(day: 11, month: 08, year: 2023)),
        
        Conference(name: "iOS Conf SG",
                   website: .init(string: "https://iosconf.sg"),
                   twitter: .init(string: "https://twitter.com/iosconfsg"),
                   venue: .init(name: "Shaw Foundation Alumni House", location: .init(latitude: 1.2932204999999999, longitude: 103.77361236255943)),
                   dates: Date(day: 12, month: 1, year: 2023)...Date(day: 13, month: 1, year: 2023)),
        
        Conference(name: "Swift Island",
                   website: .init(string: "https://swiftisland.nl"),
                   twitter: .init(string: "https://twitter.com/SwiftIslandNL"),
                   venue: .init(name: "Texel", location: .init(latitude: 53.08870495, longitude: 4.821112543290136)),
                   dates: Date(day: 25, month: 8, year: 2023)...Date(day: 27, month: 8, year: 2023))
    ].sorted(by: { $0.dates.lowerBound < $1.dates.lowerBound })
    
    @State
    private var editingSort: Bool = false
    
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
            }
            .padding(.vertical)
            .toolbar {
                ToolbarItem {
                    Button {
                        
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }.popover(isPresented: $editingSort) {
                        Text("Test")
                            .font(.headline)
                            .padding()
                            .frame(minWidth: 300, minHeight: 300)
                    }
                }
            }
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
