//
//  UIImage coding.swift
//  CupTaster
//
//  Created by Никита Баранов on 28.02.2023.
//

import SwiftUI

#warning("add image compression quality and png/jpeg toggle to settings")
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

struct ImagePicker: UIViewControllerRepresentable {
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
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: UIViewControllerRepresentableContext<ImagePicker>
    ) { }
}
