import Foundation

enum DataState<T> {
    case error
    case loading
    case loaded(T)
}

@MainActor
final class ConferenceDataStore: ObservableObject {
    private let service: DataService
    
    init(service: DataService = CloudKitService()) {
        self.service = service
    }
    
    @Published
    private(set) var state: DataState<[Conference]> = .loading
    
    func fetch() async {
        do {
            //guard case .loading == state else { return }
            let conferences: [Conference] = try await service.retrieve(type: .conference)
            state = .loaded(conferences)
        } catch {
            state = .error
        }
    }
}

