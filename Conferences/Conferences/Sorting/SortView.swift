import SwiftUI

struct SortView: View {
    @Binding var sort: ConferenceSort
    
    var body: some View {
        List {
            Picker("Sort by", selection: $sort) {
                ForEach(ConferenceSort.allCases) { sort in
                    Text(sort.rawValue.capitalized)
                        .tag(sort)
                }
            }
        }.environment(\.editMode, .constant(.active))
    }
}

enum ConferenceSort: String, CaseIterable, Identifiable {
    case date, name
    
    var id: String {
        rawValue
    }
}
