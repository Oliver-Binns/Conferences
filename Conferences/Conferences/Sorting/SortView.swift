import SwiftUI

struct SortView: View {
    @ObservedObject
    var viewModel: SortModel
    
    var body: some View {
        List {
            Picker("Sort by", selection: $viewModel.sort) {
                ForEach(ConferenceSort.allCases) { sort in
                    Text(sort.rawValue.capitalized)
                        .tag(sort)
                }
            }
            
            Toggle("Hide Past Events", isOn: $viewModel.hidePastEvents)
        }.environment(\.editMode, .constant(.active))
    }
}

enum ConferenceSort: String, CaseIterable, Identifiable {
    case date, name
    
    var id: String {
        rawValue
    }
}
