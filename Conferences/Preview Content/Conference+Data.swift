#if DEBUG
import CloudKit
import Model
import Service

extension Conference {
    fileprivate static var all: [Conference] {
        guard
            let fileURL = Bundle.main.url(forResource: "conferences", withExtension: "json"),
            let data = try? String(contentsOf: fileURL).data(using: .utf8) else {
            preconditionFailure("Could not find `conferences.json` file in bundle")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try! decoder.decode([Conference].self, from: data)
    }
    
    static var deepDish = Conference.all[4]
}

struct PreviewDataService: DataService {
    func retrieve<T: Queryable>() async throws -> [T] {
        Conference.all.compactMap { $0 as? T }
    }
    
    func retrieve<T>(id: CKRecord.ID) async throws -> T? where T : Queryable {
        nil
    }
}
#endif
