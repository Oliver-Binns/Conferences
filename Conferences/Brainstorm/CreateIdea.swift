import CoreData
import Model
import SwiftUI

struct EditIdea: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var database: CachedService<Conference>
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var idea: CDIdea
    
    private var allConferences: [Conference] {
        switch database.state {
        case .loaded(let conferences),
             .cached(let conferences):
            return conferences
        default: return []
        }
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
                .compactMap({ $0 as? CDAttendance })
                .compactMap({ $0.conferenceId })
                .compactMap(UUID.init)
                .compactMap({ conferenceId in
                    allConferences
                        .first(where: { $0.id == conferenceId })
                }),
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
import Persistence

struct EditIdea_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.context
        let idea = CDIdea(context: context)
        idea.title = "Something Something Core Data"
        idea.overview = """
        For those of you who may not be familiar, core data is a framework that allows for the storage, retrieval, and management of data in iOS, macOS, and watchOS applications. It provides a number of powerful features that make it an essential tool for any developer working with data on Apple platforms. In this talk, I will be providing an overview of core data, discussing its key features and benefits, and demonstrating how to use it effectively in your own projects.
        """
        return EditIdea(idea: idea)
            .environment(\.managedObjectContext, context)
            .environmentObject(CachedService<Conference>(service: PreviewDataService()))
    }
}
#endif
