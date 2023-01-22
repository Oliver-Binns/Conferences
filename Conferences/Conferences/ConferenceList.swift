import CoreData
import CloudKit
import SwiftUI

struct ConferenceList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var database: ConferenceDataStore
    
    @State
    private var isSettingsDisplayed: Bool = false
    
    @State
    private var isSortingDisplayed: Bool = false
    
    @State
    private var hasErrorOccurred: Bool = false
    
    @StateObject
    private var sortModel = SortModel()
    
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
                        ForEach(sortModel.process(conferences: conferences)) { conference in
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
                                isSettingsDisplayed = true
                            } label: {
                                Label("Info", systemImage: "gear")
                            }.sheet(isPresented: $isSettingsDisplayed) {
                                SettingsView()
                            }
                        }
                        ToolbarItem {
                            Button {
                                isSortingDisplayed = true
                            } label: {
                                Label("Sort", systemImage: "arrow.up.arrow.down")
                            }
                            .popover(isPresented: $isSortingDisplayed) {
                                SortView(viewModel: sortModel)
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
