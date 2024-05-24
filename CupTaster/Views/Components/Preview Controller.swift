//
//  Preview Controller.swift
//  CupTaster
//
//  Created by Nikita on 23.02.2024.
//

import SwiftUI
import QuickLook

struct QuickLookModifier: ViewModifier {
    @Binding var item: URL?
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: Binding(get: { item != nil }, set: { _ in })) {
                if let item {
                    PreviewController(url: item) { self.item = nil }
                        .edgesIgnoringSafeArea(.all)
                }
            }
    }
}

extension View {
    func quickLook(item: Binding<URL?>) -> some View {
        modifier(QuickLookModifier(item: item))
    }
}

struct PreviewController: UIViewControllerRepresentable {
    let url: URL
    let done: () -> ()
    
    init(url: URL, done: @escaping () -> Void) {
        self.url = url
        self.done = done
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done, target: context.coordinator,
            action: #selector(context.coordinator.done)
        )

        let navigationController = UINavigationController(rootViewController: controller)
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: QLPreviewControllerDataSource {
        
        let parent: PreviewController
        init(parent: PreviewController) { self.parent = parent }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem { parent.url as NSURL }
        
        @objc func done() { parent.done() }
    }
}
