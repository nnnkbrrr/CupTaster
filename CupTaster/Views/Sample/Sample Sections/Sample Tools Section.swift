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
        @FetchRequest(
            entity: Folder.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Folder.ordinalNumber, ascending: true)]
        ) var folders: FetchedResults<Folder>
        
        @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
        
        @State var foldersModalIsActive: Bool = false
        @State var deleteModalIsActive: Bool = false
        
        var body: some View {
            SampleToolsSection(tools: [
                .init(systemImageName: samplesControllerModel.selectedSample?.isFavorite ?? false ? "heart.fill" : "heart") {
                    withAnimation {
                        samplesControllerModel.selectedSample?.isFavorite.toggle()
                        samplesControllerModel.objectWillChange.send()
                    }
                    save(moc)
                },
                .init(systemImageName: "folder.badge.gearshape") { foldersModalIsActive = true },
                .init(systemImageName: "trash") { deleteModalIsActive = true }
            ])
            .adaptiveSizeSheet(isPresented: $deleteModalIsActive) {
                VStack(spacing: .small) {
                    Text("Delete \(samplesControllerModel.selectedSample?.name ?? "Sample")?")
                        .resizableText(initialSize: 30)
                    
                    HStack(spacing: .extraSmall) {
                        Button("Delete") {
                            withAnimation {
                                samplesControllerModel.deleteSelectedSample(moc: moc)
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
            .modalView(
                isPresented: $foldersModalIsActive,
                toolbar: .init(
                    title: "Folders",
                    trailingToolbarItem: .init("Done", action: { foldersModalIsActive = false })
                )
            ) {
                ScrollView {
                    LazyVStack(spacing: .extraSmall) {
                        ForEach([FolderFilter.favorites] + folders.map { FolderFilter(folder: $0) }) { folderFilter in
                            if let selectedSample = samplesControllerModel.selectedSample {
                                let folderContainsSample: Bool = folderFilter.containsSample(selectedSample)
                                
                                SettingsButtonSection(title: folderFilter.name ?? folderFilter.folder?.name ?? "New Folder") {
                                    if folderContainsSample { folderFilter.removeSample(selectedSample, context: moc) }
                                    else { folderFilter.addSample(selectedSample, context: moc) }
                                    samplesControllerModel.objectWillChange.send()
                                } leadingContent: {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.accentColor)
                                        .opacity(folderContainsSample ? 1 : 0)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, .small)
            }
        }
    }
    
    struct GeneralInfoToolsSection: View {
        @Environment(\.managedObjectContext) private var moc
        @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
        
        @State var noteTitle: String = ""
        @State var noteValue: String = ""
        @State var noteGeneralInfoModalIsActive: Bool = false
        
        @State var cameraPhotoPickerIsActive: Bool = false
        @State var libraryPhotoPickerIsActive: Bool = false
        @State var qrScannerIsActive: Bool = false
        @State var fileImporterIsActive: Bool = false
        
        var body: some View {
            SampleToolsSection(tools: [
                .init(systemImageName: "textformat") { noteGeneralInfoModalIsActive = true },
                .init(systemImageName: "photo") { libraryPhotoPickerIsActive = true },
                .init(systemImageName: "camera", disabled: CameraManager.isAuthorized == false) { cameraPhotoPickerIsActive = true },
                .init(systemImageName: "qrcode.viewfinder", disabled: CameraManager.isAuthorized == false) { qrScannerIsActive = true },
                .init(systemImageName: "doc") { fileImporterIsActive = true }
            ])
            .adaptiveSizeSheet(isPresented: $noteGeneralInfoModalIsActive) {
                VStack(spacing: .extraSmall) {
                    TextField("Title", text: $noteTitle)
                        .resizableText(weight: .light)
                        .submitLabel(.done)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, .regular)
                        .onChange(of: noteTitle) { title in
                            let noteTitleLengthLimit: Int = 50
                            if title.count > noteTitleLengthLimit {
                                noteTitle = String(title.prefix(noteTitleLengthLimit))
                            }
                        }
                        .bottomSheetBlock()
                    
                    TextField("Note", text: $noteValue)
                        .resizableText(weight: .light)
                        .submitLabel(.done)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, .regular)
                        .onChange(of: noteValue) { value in
                            let noteTitleLengthLimit: Int = 50
                            if value.count > noteTitleLengthLimit {
                                noteValue = String(value.prefix(noteTitleLengthLimit))
                            }
                        }
                        .bottomSheetBlock()
                    
                    HStack(spacing: .extraSmall) {
                        Button("Cancel") {
                            withAnimation {
                                noteGeneralInfoModalIsActive = false
                            }
                        }
                        .buttonStyle(.bottomSheetBlock)
                        
                        Button("Add") {
                            withAnimation {
                                if noteTitle != "" || noteValue != "" {
                                    addNote(title: noteTitle, value: noteValue)
                                }
                                noteTitle = ""
                                noteValue = ""
                                noteGeneralInfoModalIsActive = false
                            }
                        }
                        .buttonStyle(.accentBottomSheetBlock)
                    }
                }
                .padding(.small)
            }
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
        
        func addNote(title: String, value: String) {
            guard let sample: Sample = samplesControllerModel.selectedSample else { return }
            let newSGIField: SampleGeneralInfo = SampleGeneralInfo(context: moc)
            newSGIField.title = title
            newSGIField.value = value
            newSGIField.ordinalNumber = Int16((sample.generalInfo.map({ $0.ordinalNumber }).max() ?? 0) + 1)
            newSGIField.sample = sample
            save(moc)
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
            save(moc)
        }
        
        func addImage(uiImage: UIImage) {
            guard let sample: Sample = samplesControllerModel.selectedSample else { return }
            let newSGIField: SampleGeneralInfo = SampleGeneralInfo(context: moc)
            newSGIField.title = "Image"
            newSGIField.ordinalNumber = Int16((sample.generalInfo.map({ $0.ordinalNumber }).max() ?? 0) + 1)
            newSGIField.sample = sample
            newSGIField.attachment = uiImage.encodeToData() ?? Data()
            save(moc)
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
            
            save(moc)
        }
    }
}
