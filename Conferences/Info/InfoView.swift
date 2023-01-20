import SwiftUI

struct InfoView: View {
    @Environment(\.dismiss) var dismiss
    
    @State
    private var url: URL?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("""
                        Conferences is the iOS app for iOS conferences!
                        
                        It's fully open source, so you can explore the code and add your own contributions.
                        """)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        
                        Button {
                            url = .github
                        } label: {
                            Label("Check out the code", systemImage: "ellipsis.curlybraces")
                                .font(.headline)
                        }.buttonStyle(.borderedProminent)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("I love this app!").font(.headline)
                        Text("Thanks - I love it too! Be sure to leave a good review on the App Store.")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                        Button {
                            url = .appStore.appending(queryItems: [.init(name: "action", value: "write-review")])
                        } label: {
                            Label("Leave a review", systemImage: "square.and.pencil")
                                .font(.headline)
                        }.buttonStyle(.borderedProminent)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("I've spotted a problem").font(.headline)
                        Text("""
                        You can raise an Issue on GitHub. This is a project I'm doing in my spare time, so please be patient.
                        I can't promise I'll be able to fix every issue, but feel free to raise a pull request yourself.
                        """)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                        Button {
                            url = .github.appending(path: "issues")
                        } label: {
                            Label("Raise an issue", systemImage: "ant")
                                .font(.headline)
                        }.buttonStyle(.borderedProminent)
                    }
                }.sectionStyle(title: "the app")
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("I'm Oliver Binns, a mobile developer / tech lead from the UK. I made this app to help encourage myself to speak at more conferences and track the ones I've submitted talks to. Hopefully you find it useful too!")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Button {
                        url = .mastodon
                    } label: {
                        Label("Find me on Mastodon", systemImage: "person.wave.2")
                            .font(.headline)
                    }.buttonStyle(.borderedProminent)
                    
                    Button {
                        url = .twitter
                    } label: {
                        Label("Find me on the bird app", systemImage: "bird")
                            .font(.headline)
                    }.buttonStyle(.borderedProminent)
                    
                }.sectionStyle(title: "the author")
            }
            .padding(16)
            .navigationTitle("Info")
            .sheet(item: $url) { url in
                SafariView(url: url)
            }
            .toolbar {
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                }

            }
        }
    }
}

