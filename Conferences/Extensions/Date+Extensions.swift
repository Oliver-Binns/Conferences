import Foundation

extension Date {
    init(day: Int, month: Int, year: Int, timeZone: TimeZone = .gmt) {
        let components = DateComponents(calendar: .autoupdatingCurrent,
                                        timeZone: timeZone,
                                        year: year, month: month, day: day)
        self = Calendar.autoupdatingCurrent.date(from: components)!
    }
}
