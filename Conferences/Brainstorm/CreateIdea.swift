import CoreData
import SwiftUI

struct EditIdea: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var database: ConferenceDataStore
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var idea: Idea
    
    private var allConferences: [Conference] {
        guard case .loaded(let allConferences) = database.state else {
            return []
        }
        return allConferences
    }
    
    var body: some View {
        Form {
            TextField("Title", text: .init(get: {
                idea.title ?? ""
            }, set: {
                idea.title = $0
            }))
            
            TextField("Overview", text: .init(get: {
                idea.overview ?? ""
            }, set: {
                idea.overview = $0
            }), axis: .vertical)
            
            if let conferences = idea.submittedTo?
                .compactMap({ $0 as? Attendance })
                .compactMap({ $0.conferenceId })
                .compactMap(UUID.init)
                .compactMap { conferenceId in
                    allConferences
                        .first(where: { $0.id == conferenceId })
                },
                conferences.count > 0 {
                Section("Submitted to") {
                    ForEach(conferences) { conference in
                        Text(conference.name)
                    }
                }
            }
        }
        .navigationTitle("Talk Idea")
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

#if DEBUG
struct EditIdea_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let idea = Idea(context: context)
        idea.title = "Something Something Core Data"
        idea.overview = """
        For those of you who may not be familiar, core data is a framework that allows for the storage, retrieval, and management of data in iOS, macOS, and watchOS applications. It provides a number of powerful features that make it an essential tool for any developer working with data on Apple platforms. In this talk, I will be providing an overview of core data, discussing its key features and benefits, and demonstrating how to use it effectively in your own projects.
        """
        return EditIdea(idea: idea)
            .environment(\.managedObjectContext, context)
            .environmentObject(ConferenceDataStore(service: PreviewDataService()))
    }
}
#endif
