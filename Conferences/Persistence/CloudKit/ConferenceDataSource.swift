import Foundation
import Model
import Service

enum DataState<T> {
    case error
    case loading
    case cached(T)
    case loaded(T)
}

@MainActor
final class CachedService<T: Queryable & Codable>: ObservableObject {
    private let service: DataService
    private let cache: Cache
    
    init(service: DataService = CloudKitService.shared,
         cache: Cache = FileCache()) {
        self.service = service
        self.cache = cache
    }
    
    @Published
    private(set) var state: DataState<[T]> = .loading
    
    func fetch() {
        do {
            // Retrieve from cache first for quick load
            if let cachedItems: [T] = try? cache.retrieve(type: T.recordType),
               !cachedItems.isEmpty {
                state = .cached(cachedItems)
            }
            // Fetch from CloudKit for latest data
            Task {
                await performRemoteFetch()
            }
        }
    }
    
    private func performRemoteFetch() async {
        do {
            let items: [T] = try await service.retrieve()
            // Update State
            state = .loaded(items)
            // Save in cache for next use
            try? cache.store(items: items, type: T.recordType)
        } catch {
            // Only show error if we have no cached data
            guard case .loading = state else { return }
            state = .error
        }
    }
}

