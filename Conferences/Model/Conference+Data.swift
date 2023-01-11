import Foundation

extension Conference {
    static var all: [Conference] {
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
