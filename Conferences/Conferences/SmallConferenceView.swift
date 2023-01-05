import SwiftUI

struct SmallConferenceView: View {
    let conference: Conference
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(conference.name)
                .font(.title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            CountdownText(label: "Starts", date: conference.dates.lowerBound)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

#if DEBUG
struct SmallConferenceView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SmallConferenceView(conference: .deepDish)
                .environment(\.dynamicTypeSize, .xSmall)
            
            SmallConferenceView(conference: .deepDish)
            
            SmallConferenceView(conference: .deepDish)
                .environment(\.dynamicTypeSize, .accessibility5)
        }
    }
}
#endif
