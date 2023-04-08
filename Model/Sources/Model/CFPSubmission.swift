import Foundation

public struct CFPSubmission: Codable {
    public let opens: Date
    public let closes: Date?

    public init(opens: Date, closes: Date?) {
        self.opens = opens
        self.closes = closes
    }
    
    public init?(dates: [Date]?) {
        guard let dates,
              let opens = dates.first else { return nil }
        self.opens = opens
        self.closes = dates.count > 1 ? dates[1] : nil
    }
}
