import SwiftUI

struct CountdownText: View {
    let label: String
    let date: Date
    
    var components: DateComponents {
        Calendar.autoupdatingCurrent.dateComponents([.day, .month], from: .now, to: date)
    }
    
    let formatter = RelativeDateTimeFormatter()
    
    var body: some View {
        Text("\(label) \(formatter.localizedString(from: components))")
    }
}

#if DEBUG
struct CountdownView_Previews: PreviewProvider {
    static var previews: some View {
        CountdownText(label: "Starts",
                      date: Calendar.autoupdatingCurrent.date(byAdding: .month, value: 3, to: .now)!)
    }
}
#endif
