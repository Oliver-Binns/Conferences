import Foundation

enum DataState<T> {
    case error
    case loading
    case cached(T)
    case loaded(T)
}

@MainActor
final class ConferenceDataStore: ObservableObject {
    private let service: DataService
    private let cache: Cache
    
    init(service: DataService = CloudKitService(),
         cache: Cache = FileCache()) {
        self.service = service
        self.cache = cache
    }
    
    @Published
    private(set) var state: DataState<[Conference]> = .loading
    
    func fetch() {
        do {
            // Retrieve from cache first for quick load
            if let cachedConferences: [Conference] = try? cache
                .retrieve(type: .conference),
               !cachedConferences.isEmpty {
                print("cache hit", cachedConferences)
                state = .cached(cachedConferences)
            }
            // Fetch from CloudKit for latest data
            Task {
                await performRemoteFetch()
            }
        }
    }
    
    private func performRemoteFetch() async {
        do {
            let conferences: [Conference] = try await service.retrieve(type: .conference)
            // Update State
            state = .loaded(conferences)
            // Save in cache for next use
            try? cache.store(items: conferences, type: .conference)
        } catch {
            // Only show error if we have no cached data
            guard case .loading = state else { return }
            state = .error
        }
    }
}

