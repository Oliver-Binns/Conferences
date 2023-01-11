import SwiftUI

struct SelectedTalksView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var isEditing: Bool = false
    @ObservedObject var attendance: Attendance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Talks Submitted")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button {
                    isEditing = true
                } label: {
                    Image(systemName: "square.and.pencil")
                }
            }.font(.title2)
            
            if let talks = attendance.talks?.compactMap({ $0 as? Idea }).sorted(),
               !talks.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(talks) { talk in
                        Text(talk.unwrappedTitle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            } else {
                Button("Select a Talk") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            SelectTalksView(attendance: attendance)
        }
    }
}
