import Foundation

struct Conference: Identifiable {
    let id = UUID()
    let name: String
    let website: URL?
    let twitter: URL?
    let venue: Venue
    
    let cfpSubmission: CFPSubmission?
    let dates: ClosedRange<Date>
}

struct CFPSubmission {
    let opens: Date
    let closes: Date?
}
