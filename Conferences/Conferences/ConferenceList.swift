import CoreData
import SwiftUI

struct ConferenceList: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State
    private var editingSort: Bool = false
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(Conference.all) { conference in
                    NavigationLink {
                        ConferenceDetailView(conference: conference,
                                             attendance: attendance(at: conference))
                    } label: {
                        SmallConferenceView(conference: conference)
                    }.buttonStyle(.plain)
                }
            }
            .padding(.vertical)
            .toolbar {
                ToolbarItem {
                    Button {
                        editingSort = true
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                    .popover(isPresented: $editingSort) {
                        SortView()
                    }
                }
            }
           
        }
       
    }
    
    func attendance(at conference: Conference) -> Attendance {
        let fetchRequest = Attendance.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "conferenceId = %@",
                                             conference.id.uuidString)
        fetchRequest.fetchLimit = 1
        guard let attendance = try? viewContext.fetch(fetchRequest).first else {
            let newAttendance = Attendance(context: viewContext)
            newAttendance.conferenceId = conference.id.uuidString
            return newAttendance
        }
        return attendance
    }
}

#if DEBUG
struct ConferenceList_Previews: PreviewProvider {
    static var previews: some View {
        ConferenceList()
    }
}
#endif
