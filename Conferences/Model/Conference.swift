import Foundation

struct Conference: Identifiable {
    let id = UUID()
    let name: String
    let website: URL?
    let twitter: URL?
    let venue: Venue
    let dates: ClosedRange<Date>
}
