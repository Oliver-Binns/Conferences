import SwiftUI

struct SelectTalksView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var attendance: Attendance
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Idea.title, ascending: true)],
        animation: .default)
    private var ideas: FetchedResults<Idea>
    
    var body: some View {
        NavigationView {
            VStack {
                if ideas.isEmpty {
                    Text("You haven't drafted any talks. Try the ideas tab!")
                        .foregroundColor(.secondary)
                } else {
                    List(ideas) { idea in
                        HStack {
                            Text(idea.unwrappedTitle)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            Image(systemName: "checkmark")
                                .opacity(isSubmitted(idea: idea) ? 1 : 0)
                                .foregroundColor(.secondary)
                        }
                        .onTapGesture {
                            if isSubmitted(idea: idea) {
                                idea.removeFromSubmittedTo(attendance)
                            } else {
                                idea.addToSubmittedTo(attendance)
                            }
                        }
                    }.listStyle(.inset)
                }
            }
            .navigationTitle("Select Talks")
            .toolbar {
                Button("Done") {
                    try? viewContext.save()
                    dismiss()
                }
            }
        }
    }
    
    func isSubmitted(idea: Idea) -> Bool {
        attendance.talks?.contains(idea) ?? false
    }
}

extension Set {
    mutating func toggle(element: Element) {
        if contains(element) {
            remove(element)
        } else {
            insert(element)
        }
    }
}
