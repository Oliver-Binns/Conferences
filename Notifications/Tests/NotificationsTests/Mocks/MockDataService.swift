import CloudKit
import Service

final class MockDataService: DataService {
    var data: [Any] = []

    func retrieve<T: Queryable>() async throws -> [T] {
        data.compactMap { $0 as? T }
    }

    func retrieve<T>(id: CKRecord.ID) async throws -> T? {
        guard let item = data.compactMap({ $0 as? T }).first else {
            return nil
        }
        return item
    }
}
