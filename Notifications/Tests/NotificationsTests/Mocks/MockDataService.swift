import CloudKit
import Service

final class MockDataService: DataService {
    var data: [Any] = []

    func retrieve<T: Queryable>() async throws -> [T] {
        []
    }

    func retrieve<T>(id: CKRecord.ID) async throws -> T? {
        guard let item = data.first as? T else {
            return nil
        }
        return item
    }
}
