import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url : URL
    
    func makeUIViewController(context: Context) -> some UIViewController {
        SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
}
