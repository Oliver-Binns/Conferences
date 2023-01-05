import SwiftUI
import CoreData

struct IdeasList: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Idea.title, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Idea>
    
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
                            Text(idea.title ?? "Placeholder Title")
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
        let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = viewContext
        
        let childItem: Idea
        if let ideaID,
           let idea = childContext.object(with: ideaID) as? Idea {
            childItem = idea
        } else {
            childItem = Idea(context: childContext)
        }
        
        return EditIdea(idea: childItem)
            .environment(\.managedObjectContext, childContext)
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
struct IdeasList_Previews: PreviewProvider {
    static var previews: some View {
        IdeasList()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
#endif
