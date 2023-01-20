import CoreData
import SwiftUI

struct ConferenceList: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State
    private var displayingInfo: Bool = false
    
    @State
    private var editingSort: Bool = false
    
    @State
    private var sort: ConferenceSort = .date

    
    var conferences: [Conference] {
        sort == .name ?
            Conference.all.sorted(by: \.name) :
            Conference.all.sorted(by: \.dates.lowerBound)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(conferences) { conference in
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        displayingInfo = true
                    } label: {
                        Label("Info", systemImage: "info.circle")
                    }.sheet(isPresented: $displayingInfo) {
                        InfoView()
                    }
                }
                ToolbarItem {
                    Button {
                        editingSort = true
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                    .popover(isPresented: $editingSort) {
                        SortView(sort: $sort)
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
