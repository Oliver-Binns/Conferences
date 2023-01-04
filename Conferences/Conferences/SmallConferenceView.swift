import SwiftUI

struct SmallConferenceView: View {
    let conference: Conference
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(conference.name)
                .font(.title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(conference.dates.lowerBound, style: .relative)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }

}
