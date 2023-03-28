import CloudKit

public protocol DataService {
    func retrieve<T: Queryable>() async throws -> [T]
    func retrieve<T: Queryable>(id: CKRecord.ID) async throws -> T?
}
