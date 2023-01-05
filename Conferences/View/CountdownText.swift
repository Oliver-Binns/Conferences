import SwiftUI

struct CountdownText: View {
    let label: String
    let date: Date
    
    var components: DateComponents {
        Calendar.autoupdatingCurrent.dateComponents([.day, .month], from: .init(), to: date)
    }
    
    let formatter = RelativeDateTimeFormatter()
    
    var body: some View {
        Text("\(label) \(formatter.localizedString(from: components))")
    }
}
