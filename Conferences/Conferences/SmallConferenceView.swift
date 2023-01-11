import SwiftUI

struct SmallConferenceView: View {
    let conference: Conference
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading) {
                Text(conference.name)
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(conference.location)
            }

            VStack(alignment: .leading) {
                if let cfp = conference.cfpSubmission {
                    if cfp.opens > .now {
                        CountdownText(label: "CFP opens", date: cfp.opens)
                            .foregroundColor(.green)
                    } else if let closeDate = cfp.closes,
                              closeDate > .now {
                        CountdownText(label: "CFP closes", date: closeDate)
                            .foregroundColor(closeDate.isSoon ? .yellow : .green)
                    } else {
                        Text("CFP closed")
                            .foregroundColor(.red)
                    }
                }
                CountdownText(label: "Conference starts", date: conference.dates.lowerBound)
            }
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
