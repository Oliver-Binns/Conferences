import SwiftUI

struct SectionStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
    }
}

extension View {
    func sectionStyle(title: String? = nil) -> some View {
        VStack {
            if let title {
                Text(title.uppercased())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, -2)
            }
            
            modifier(SectionStyle())
        }
    }
}
