import CoreLocation

struct Venue: Codable, Identifiable {
    let id: UUID
    let name: String
    let location: CLLocationCoordinate2D
    
    init(id: UUID = UUID(),
         name: String,
         location: CLLocationCoordinate2D) {
        self.id = id
        self.name = name
        self.location = location
    }
}
