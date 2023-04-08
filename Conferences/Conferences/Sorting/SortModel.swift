import Foundation
import Model

final class SortModel: ObservableObject {
    @Published
    var sort: ConferenceSort = .date
    
    @Published
    var hidePastEvents = true
    
    func process(conferences: [Conference]) -> [Conference] {
        sorted(conferences: conferences)
            .filter {
                !hidePastEvents || $0.dates.upperBound > .now
            }
    }
    
    private func sorted(conferences: [Conference]) -> [Conference] {
        sort == .date ?
            conferences.sorted(by: \.dates.lowerBound) :
            conferences.sorted(by: \.name)
    }
}
