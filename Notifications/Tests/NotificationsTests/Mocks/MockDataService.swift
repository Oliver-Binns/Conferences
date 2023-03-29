import CloudKit
import Service

struct MockDataService: DataService {
    func retrieve<T: Queryable>() async throws -> [T] {
        []
    }

    func retrieve<T>(id: CKRecord.ID) async throws -> T? {
        nil
    }
}
