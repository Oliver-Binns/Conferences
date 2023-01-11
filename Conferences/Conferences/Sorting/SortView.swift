import SwiftUI

struct SortView: View {
    var body: some View {
        List {
            Section("Sort by") {
                Text("Date")
                    .fixedSize(horizontal: true, vertical: false)
                Text("Name")
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
    }
}
