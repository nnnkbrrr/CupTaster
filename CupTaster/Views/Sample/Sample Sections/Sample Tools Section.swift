//
//  Sample Tools Section.swift
//  CupTaster
//
//  Created by Никита Баранов on 23.07.2023.
//

import SwiftUI
import CodeScanner

extension SampleView {
    struct ActionsToolsSection: View {
        @Environment(\.managedObjectContext) private var moc
        @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
        
        @State var deleteModalIsActive: Bool = false
        
        var body: some View {
            SampleToolsSection(tools: [
                .init(systemImageName: samplesControllerModel.selectedSample?.isFavorite ?? false ? "heart.fill" : "heart") {
                    withAnimation {
                        samplesControllerModel.selectedSample?.isFavorite.toggle()
                        samplesControllerModel.objectWillChange.send()
                    }
                    try? moc.save()
                },
                .init(systemImageName: "folder.badge.gearshape", disabled: true) {
#warning("action")
                },
                .init(systemImageName: "trash") {
                    deleteModalIsActive = true
                }
            ])
            .adaptiveSizeSheet(isPresented: $deleteModalIsActive) {
                VStack(spacing: .small) {
                    Text("Delete \(samplesControllerModel.selectedSample?.name ?? "Sample")?")
                        .resizableText(initialSize: 30)
                    
                    HStack(spacing: .extraSmall) {
                        Button("Delete") {
                            withAnimation {
                                samplesControllerModel.deleteSelectedSample(moc: moc)
                                try? moc.save()
                                deleteModalIsActive = false
                            }
                        }
                        .buttonStyle(.bottomSheetBlock)
                        
                        Button("Cancel") {
                            deleteModalIsActive = false
                        }
                        .buttonStyle(.accentBottomSheetBlock)
                    }
                }
                .padding(.small)
            }
        }
    }
    
    struct GeneralInfoToolsSection: View {
        @Environment(\.managedObjectContext) private var moc
        @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
        
        @State var cameraPhotoPickerIsActive: Bool = false
        @State var libraryPhotoPickerIsActive: Bool = false
        @State var qrScannerIsActive: Bool = false
        @State var fileImporterIsActive: Bool = false
        
        var body: some View {
            SampleToolsSection(tools: [
                .init(systemImageName: "textformat", disabled: true) {
#warning("action")
                },
                .init(systemImageName: "photo") { libraryPhotoPickerIsActive = true },
                .init(systemImageName: "camera", disabled: CameraManager.isAuthorized == false) { cameraPhotoPickerIsActive = true },
                .init(systemImageName: "qrcode.viewfinder", disabled: CameraManager.isAuthorized == false) { qrScannerIsActive = true },
                .init(systemImageName: "doc") { fileImporterIsActive = true }
            ])
            .fullScreenCover(isPresented: $cameraPhotoPickerIsActive) {
                ImagePickerController(sourceType: .camera) { uiImage in
                    addImage(uiImage: uiImage)
                }.ignoresSafeArea()
            }
            .fullScreenCover(isPresented: $libraryPhotoPickerIsActive) {
                ImagePickerController(sourceType: .photoLibrary) { uiImage in
                    addImage(uiImage: uiImage)
                }.ignoresSafeArea()
            }
            .fullScreenCover(isPresented: $qrScannerIsActive) {
                QRScannerView(isActive: $qrScannerIsActive) { response in
                    addLink(response: response)
                }
            }
            .fileImporter(isPresented: $fileImporterIsActive, allowedContentTypes: [.item]) { result in
                addFile(result)
            }
        }
        
        func addLink(response: (Result<ScanResult, ScanError>)) {
            guard let sample: Sample = samplesControllerModel.selectedSample else { return }
            let newLinkField: SampleGeneralInfo = SampleGeneralInfo(context: moc)
            newLinkField.title = "URL"
            switch response {
                case .success(let result): newLinkField.attachment = Data(result.string.utf8)
                case .failure(_): newLinkField.attachment = Data("Error".utf8)
            }
            newLinkField.ordinalNumber = Int16((sample.generalInfo.map({ $0.ordinalNumber }).max() ?? 0) + 1)
            newLinkField.sample = sample
            try? moc.save()
        }
        
        func addImage(uiImage: UIImage) {
            guard let sample: Sample = samplesControllerModel.selectedSample else { return }
            let newSGIField: SampleGeneralInfo = SampleGeneralInfo(context: moc)
            newSGIField.title = "Image"
            newSGIField.ordinalNumber = Int16((sample.generalInfo.map({ $0.ordinalNumber }).max() ?? 0) + 1)
            newSGIField.sample = sample
            newSGIField.attachment = uiImage.encodeToData() ?? Data()
            try? moc.save()
        }
        
        func addFile(_ file: Result<URL, any Error>) {
            guard let sample: Sample = samplesControllerModel.selectedSample else { return }
            
            let newSGIField: SampleGeneralInfo = SampleGeneralInfo(context: moc)
            newSGIField.ordinalNumber = Int16((sample.generalInfo.map({ $0.ordinalNumber }).max() ?? 0) + 1)
            newSGIField.sample = sample
            
            if let fileURL = try? file.get() {
                newSGIField.title = fileURL.lastPathComponent
                
                if fileURL.startAccessingSecurityScopedResource(), let fileData = try? Data(contentsOf: fileURL) {
                    newSGIField.attachment = fileData
                } else {
                    newSGIField.attachment = Data("error".utf8)
                }
            } else {
                newSGIField.title = "Error"
            }
            
            try? moc.save()
        }
    }
}
