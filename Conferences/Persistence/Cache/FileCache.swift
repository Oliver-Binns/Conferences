import Foundation

protocol Cache {
    func store<T: Encodable>(items: [T], type: RecordType) throws
    func retrieve<T: Decodable>(type: RecordType) throws -> [T]?
}

struct FileCache: Cache {
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    
    private func url(for type: RecordType) -> URL? {
        FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("\(type.rawValue).json")
    }
    
    func store<T: Encodable>(items: [T], type: RecordType) throws {
        guard let cacheURL = url(for: type),
              !items.isEmpty else { return }
        try jsonEncoder
            .encode(items)
            .write(to: cacheURL)
    }
    
    func retrieve<T: Decodable>(type: RecordType) throws -> [T]? {
        guard let cacheURL = url(for: type) else { return nil }
        let cachedData = try Data(contentsOf: cacheURL)
        return try jsonDecoder.decode([T].self, from: cachedData)
    }
}
