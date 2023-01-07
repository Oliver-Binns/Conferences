import Foundation

struct Conference: Codable, Identifiable {
    let id: UUID
    let name: String
    let website: URL?
    let twitter: URL?
    let venue: Venue
    
    let cfpSubmission: CFPSubmission?
    let dates: ClosedRange<Date>
    
    init(id: UUID = UUID(),
         name: String,
         website: URL?,
         twitter: URL?,
         venue: Venue,
         cfpSubmission: CFPSubmission?,
         dates: ClosedRange<Date>) {
        self.id = id
        self.name = name
        self.website = website
        self.twitter = twitter
        self.venue = venue
        self.cfpSubmission = cfpSubmission
        self.dates = dates
    }
}

struct CFPSubmission: Codable {
    let opens: Date
    let closes: Date?
}
