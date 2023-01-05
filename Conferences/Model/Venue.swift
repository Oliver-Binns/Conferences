import CoreLocation

struct Venue: Identifiable {
    let id = UUID()
    let name: String
    let location: CLLocationCoordinate2D
}
