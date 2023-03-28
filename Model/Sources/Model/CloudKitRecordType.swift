import CloudKit
import Service

enum CloudKitRecordType: String {
    case conference = "Conference"
    case venue = "Venue"
    case attendance = "CD_Attendance"
}

extension CloudKitRecordType: RecordType {
    var database: KeyPath<CKContainer, CKDatabase> {
        switch self {
        case .attendance:
            return \.privateCloudDatabase
        default:
            return \.publicCloudDatabase
        }
    }
}
