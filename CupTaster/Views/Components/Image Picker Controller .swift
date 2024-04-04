//
//  Image Picker Controller.swift
//  CupTaster
//
//  Created by Nikita on 23.02.2024.
//

import SwiftUI

extension UIImage {
    func encodeToData() -> Data? {
        self.jpegData(compressionQuality: 1.0)
    }
}

extension Data {
    func decodeToUIImage() -> UIImage? {
        UIImage(data: self) ?? UIImage(systemName: "exclamationmark.triangle.fill")
    }
}

struct ImagePickerController: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void
    
    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding private var presentationMode: PresentationMode
        private let sourceType: UIImagePickerController.SourceType
        private let onImagePicked: (UIImage) -> Void
        
        init(
            presentationMode: Binding<PresentationMode>,
            sourceType: UIImagePickerController.SourceType,
            onImagePicked: @escaping (UIImage) -> Void
        ) {
            self._presentationMode = presentationMode
            self.sourceType = sourceType
            self.onImagePicked = onImagePicked
        }
        
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            let uiImage = info[.originalImage] as! UIImage
            onImagePicked(uiImage)
            presentationMode.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            presentationMode.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(
            presentationMode: presentationMode,
            sourceType: sourceType,
            onImagePicked: onImagePicked
        )
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerController>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: UIViewControllerRepresentableContext<ImagePickerController>
    ) { }
}
