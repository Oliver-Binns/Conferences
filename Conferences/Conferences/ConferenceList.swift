import CoreData
import CloudKit
import SwiftUI

struct ConferenceList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var database: ConferenceDataStore
    
    @State
    private var displayingInfo: Bool = false
    
    @State
    private var editingSort: Bool = false
    
    @State
    private var errorOccurred: Bool = false
    
    @StateObject
    private var sort = SortModel()
    
    @State
    var conferences: [Conference] = []
    
    var body: some View {
        VStack(spacing: 16) {
            switch database.state {
            case .error:
                Spacer()
                
                VStack {
                    Image(systemName: "wifi.exclamationmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 150, maxHeight: 150)
                    Text("An error occured while fetching information.")
                }
                
                Spacer()
                
                Button("Try Again", action: fetchConferences)
                .buttonStyle(.borderedProminent)
                .padding(.bottom)
            case .loading:
                ProgressView().progressViewStyle(.circular)
                Text("Loading...")
                    .onAppear(perform: fetchConferences)
            case .loaded(let conferences),
                 .cached(let conferences):
                ScrollView {
                    LazyVStack {
                        ForEach(sort.process(conferences: conferences)) { conference in
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
                                SortView(viewModel: sort)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func fetchConferences() {
        database.fetch()
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
            .environmentObject(ConferenceDataStore(service: PreviewDataService()))
    }
}
#endif
