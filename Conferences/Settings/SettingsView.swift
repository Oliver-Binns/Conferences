import CoreData
import Model
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                NotificationsView()
            
                NavigationLink("About the App") {
                    InfoView()
                }
            }
        }.toolbar {
            Button {
                dismiss()
            } label: {
                Text("Done")
            }
        }
    }
}
