import Foundation

extension URL: ExpressibleByStringLiteral {
    public init(stringLiteral value: StaticString) {
        self = URL(string: "\(value)").unsafelyUnwrapped
    }
    
    static var github: URL {
        "https://github.com/Oliver-Binns/Conferences/issues"
    }
    
    static var appStore: URL {
        "https://apps.apple.com/app/id1663060249"
    }
    
    static var twitter: URL {
        "https://twitter.com/Oliver_Binns"
    }
    
    static var mastodon: URL {
        "https://mastodon.social/@oliver_binns"
    }
}
