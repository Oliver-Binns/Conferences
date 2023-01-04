import CoreData
import SwiftUI

struct EditIdea: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @State var idea: Idea
    
    var body: some View {
        Form {
            TextField("Title", text: .init(get: {
                idea.title ?? ""
            }, set: {
                idea.title = $0
            }))
            
            TextEditor(text: .init(get: {
                idea.overview ?? ""
            }, set: {
                idea.overview = $0
            }))
            .foregroundColor(.secondary)
        }
        .navigationTitle("New Talk Idea")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    try? viewContext.save()
                    dismiss()
                }
            }
        }
    }
}
