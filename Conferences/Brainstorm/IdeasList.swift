import CoreData
import Model
import SwiftUI

struct IdeasList: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDIdea.title, ascending: true)],
        animation: .default)
    private var items: FetchedResults<CDIdea>
    
    @State
    private var editingIdea: Bool = false

    var body: some View {
        VStack {
            if items.isEmpty {
                Text("Your ideas start here...")
                    .font(.headline)
                    .foregroundColor(.secondary)
            } else {
                List {
                    ForEach(items) { idea in
                        NavigationLink {
                            ideaEditor(ideaID: idea.objectID)
                        } label: {
                            Text(idea.unwrappedTitle)
                        }
                            
                    }
                    .onDelete(perform: deleteItems)
                }
            }
        }
        .sheet(isPresented: $editingIdea) {
            try? viewContext.save()
        } content: {
            NavigationView {
                ideaEditor()
            }
        }
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            #endif
            ToolbarItem {
                Button {
                    editingIdea = true
                } label: {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
    }

    private func ideaEditor(ideaID: NSManagedObjectID? = nil) -> some View {
        let editingContext = viewContext.editingContext
        
        let childItem: CDIdea
        if let ideaID,
           let idea = editingContext.object(with: ideaID) as? CDIdea {
            childItem = idea
        } else {
            childItem = CDIdea(context: editingContext)
        }
        
        return EditIdea(idea: childItem)
            .environment(\.managedObjectContext, editingContext)
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

#if DEBUG
import Persistence

struct IdeasList_Previews: PreviewProvider {
    static var previews: some View {
        IdeasList()
            .environment(\.managedObjectContext, PersistenceController.preview.context)
    }
}
#endif
