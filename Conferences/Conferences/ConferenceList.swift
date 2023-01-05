import SwiftUI

struct ConferenceList: View {
    @State
    private var editingSort: Bool = false
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(Conference.all) { conference in
                    NavigationLink {
                        ExpandedConferenceView(conference: conference)
                    } label: {
                        SmallConferenceView(conference: conference)
                    }.buttonStyle(.plain)
                }
            }
            .padding(.vertical)
            .toolbar {
                ToolbarItem {
                    Button {
                        
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }.popover(isPresented: $editingSort) {
                        Text("Test")
                            .font(.headline)
                            .padding()
                            .frame(minWidth: 300, minHeight: 300)
                    }
                }
            }
        }
       
    }
}

#if DEBUG
struct ConferenceList_Previews: PreviewProvider {
    static var previews: some View {
        ConferenceList()
    }
}
#endif
