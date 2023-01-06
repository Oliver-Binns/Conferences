import Foundation

extension Date {
    init(day: Int, month: Int, year: Int, timeZone: TimeZone = .gmt) {
        let components = DateComponents(calendar: .autoupdatingCurrent,
                                        timeZone: timeZone,
                                        year: year, month: month, day: day)
        self = Calendar.autoupdatingCurrent.date(from: components)!
    }
    
    var isSoon: Bool {
        guard let inOneWeek = Calendar.current.date(byAdding: .day, value: 7, to: self) else {
            return false
        }
        return inOneWeek < .now
    }
}
