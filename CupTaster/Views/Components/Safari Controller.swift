//
//  Safari Controller.swift
//  CupTaster
//
//  Created by Nikita on 23.02.2024.
//

import SwiftUI
import SafariServices

struct SafariPreviewModifier: ViewModifier {
    @Binding var url: URL?
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: Binding(get: { url != nil }, set: { _ in url = nil })) {
                if let url {
                    SafariController(url: url).ignoresSafeArea()
                } else {
                    VStack {
                        Text("URL is invalid")
                        Button("Done") { url = nil }.buttonStyle(.bordered)
                    }
                }
            }
    }
}

extension View {
    func previewInSafari(url: Binding<URL?>) -> some View {
        modifier(SafariPreviewModifier(url: url))
    }
}

struct SafariController: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController { SFSafariViewController(url: url) }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariController>) { }
}
