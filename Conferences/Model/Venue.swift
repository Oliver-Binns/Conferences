import CoreLocation

struct Venue: Codable, Identifiable {
    let id: UUID
    let name: String
    let city: String
    let country: String
    let location: CLLocationCoordinate2D
    
    init(id: UUID = UUID(),
         name: String,
         city: String,
         country: String,
         location: CLLocationCoordinate2D) {
        self.id = id
        self.name = name
        self.city = city
        self.country = country
        self.location = location
    }
}
